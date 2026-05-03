/**
 * 第二階段：清運匯聚點（臺北分隊／新北路線集中點）→ 焚化廠代表座標
 * 對照表：public/mapData/incinerator_facilities.json 之 district_to_facility_hint
 */

const MIN_LEN2 = 1e-16;
const MAX_HUB_TO_PLANT_KM = 95;

function haversineKm(lat1, lon1, lat2, lon2) {
	const R = 6371;
	const toRad = (d) => (d * Math.PI) / 180;
	const dLat = toRad(lat2 - lat1);
	const dLon = toRad(lon2 - lon1);
	const a =
		Math.sin(dLat / 2) ** 2 +
		Math.cos(toRad(lat1)) * Math.cos(toRad(lat2)) * Math.sin(dLon / 2) ** 2;
	return 2 * R * Math.asin(Math.min(1, Math.sqrt(a)));
}

/** 依該匯聚點涵蓋之停靠站數粗估弧寬（deck.gl ArcLayer getWidth） */
function widthFromStopCount(n) {
	const raw = 1.6 + Math.sqrt(Math.max(1, n)) * 0.52;
	return Math.min(12, Math.max(4, Math.round(raw * 10) / 10));
}

/** 依行政區對照 incinerator_facilities.json 之焚化廠（供弧線與地址模擬路徑共用） */
export function resolveGarbageFacilityByDistrict(dist, facilitiesDoc) {
	const hint = facilitiesDoc?.district_to_facility_hint;
	if (!hint || !dist) return null;
	const id = hint[dist];
	if (!id || typeof id !== "string") return null;
	const fac = (facilitiesDoc.facilities || []).find((f) => f.id === id);
	return fac ?? null;
}

function modeDistFromProps(propsList) {
	const counts = new Map();
	for (const p of propsList) {
		const d = String(p?.dist ?? "").trim();
		if (!d) continue;
		counts.set(d, (counts.get(d) || 0) + 1);
	}
	let best = null;
	let bestc = 0;
	for (const [d, c] of counts) {
		if (c > bestc) {
			best = d;
			bestc = c;
		}
	}
	return best;
}

function buildOfficeCoordMap(officesDoc) {
	const map = new Map();
	if (!officesDoc?.offices?.length) return map;
	for (const row of officesDoc.offices) {
		const lat = Number(row.latitude);
		const lng = Number(row.longitude);
		if (!Number.isFinite(lat) || !Number.isFinite(lng)) continue;
		if (!row.name) continue;
		map.set(row.name, { lng, lat, address: row.address ?? "" });
	}
	return map;
}

/**
 * 臺北：每個分隊一條弧線（分隊部或站點重心 → 依多數停靠點所在行政區對照之焚化廠）
 * @param {GeoJSON.FeatureCollection} featureCollection 原始停靠點
 * @param {object | null} officesDoc garbage_taipei_brigade_offices.json
 * @param {object} facilitiesDoc incinerator_facilities.json
 */
export function buildTaipeiHubToIncineratorArcs(
	featureCollection,
	officesDoc,
	facilitiesDoc,
) {
	const byBrigade = new Map();
	for (const f of featureCollection.features) {
		if (f.geometry?.type !== "Point") continue;
		const b = f.properties?.brigade;
		if (!b) continue;
		if (!byBrigade.has(b)) byBrigade.set(b, { coords: [], props: [] });
		const g = byBrigade.get(b);
		g.coords.push(f.geometry.coordinates);
		g.props.push(f.properties || {});
	}

	const hubCentroid = new Map();
	for (const [name, { coords }] of byBrigade) {
		let sx = 0;
		let sy = 0;
		for (const c of coords) {
			sx += c[0];
			sy += c[1];
		}
		const n = coords.length;
		hubCentroid.set(name, [sx / n, sy / n]);
	}

	const aliases =
		officesDoc?.brigade_name_aliases &&
		typeof officesDoc.brigade_name_aliases === "object"
			? officesDoc.brigade_name_aliases
			: {};
	const officeCoordsByName = buildOfficeCoordMap(officesDoc);

	const features = [];
	for (const [brigade, { coords, props }] of byBrigade) {
		const n = coords.length;
		const dist = modeDistFromProps(props);
		if (!dist) continue;

		const fac = resolveGarbageFacilityByDistrict(dist, facilitiesDoc);
		if (
			!fac ||
			!Number.isFinite(fac.longitude) ||
			!Number.isFinite(fac.latitude)
		)
			continue;

		const officeName =
			aliases[brigade] != null ? aliases[brigade] : brigade;
		const officePt = officeCoordsByName.get(officeName);
		let tlng;
		let tlat;
		let hubSource;
		if (officePt) {
			tlng = officePt.lng;
			tlat = officePt.lat;
			hubSource = "office";
		} else {
			[tlng, tlat] = hubCentroid.get(brigade);
			hubSource = "centroid";
		}

		const flat = fac.latitude;
		const flng = fac.longitude;
		if (haversineKm(tlat, tlng, flat, flng) > MAX_HUB_TO_PLANT_KM) continue;

		const dx = flng - tlng;
		const dy = flat - tlat;
		if (dx * dx + dy * dy < MIN_LEN2) continue;

		features.push({
			type: "Feature",
			geometry: {
				type: "LineString",
				coordinates: [
					[tlng, tlat],
					[flng, flat],
				],
			},
			properties: {
				dist,
				brigade,
				hub_source: hubSource,
				incinerator_id: fac.id,
				incinerator_name: fac.name_short ?? fac.name,
				flow_stage2: `${fac.name_short ?? fac.name}（依 ${dist} 對照 district_to_facility_hint）`,
				arc_width: widthFromStopCount(n),
				stop_count_hub: n,
				time_minutes: 1440,
			},
		});
	}

	return { type: "FeatureCollection", features };
}

function routeGroupKey(dist, routeName) {
	const d = String(dist ?? "").trim();
	const r = String(routeName ?? "").trim();
	return `${d}|${r}`;
}

function buildRouteHubOverrideMap(hubsDoc) {
	const map = new Map();
	const rows = hubsDoc?.route_hubs;
	if (!Array.isArray(rows)) return map;
	for (const row of rows) {
		const dist = String(row.dist ?? "").trim();
		const routeName = String(row.route_name ?? "").trim();
		if (!dist || !routeName) continue;
		const lat = Number(row.latitude);
		const lng = Number(row.longitude);
		if (!Number.isFinite(lat) || !Number.isFinite(lng)) continue;
		map.set(routeGroupKey(dist, routeName), { lng, lat });
	}
	return map;
}

/**
 * 新北：每個「行政區＋路線」一條弧線（集中點或重心 → 該區對照之焚化廠）
 */
export function buildNtpcHubToIncineratorArcs(
	featureCollection,
	hubsDoc,
	facilitiesDoc,
) {
	const byRoute = new Map();
	for (const f of featureCollection.features) {
		if (f.geometry?.type !== "Point") continue;
		const p = f.properties || {};
		const { dist } = p;
		const routeName = p.route_name;
		if (!dist || !routeName) continue;
		const key = routeGroupKey(dist, routeName);
		if (!byRoute.has(key)) byRoute.set(key, []);
		byRoute.get(key).push(f);
	}

	const centroid = new Map();
	for (const [key, feats] of byRoute) {
		let sx = 0;
		let sy = 0;
		for (const f of feats) {
			const c = f.geometry.coordinates;
			sx += c[0];
			sy += c[1];
		}
		const n = feats.length;
		centroid.set(key, [sx / n, sy / n]);
	}

	const overrides = buildRouteHubOverrideMap(hubsDoc);
	const features = [];

	for (const [key, feats] of byRoute) {
		const p0 = feats[0]?.properties || {};
		const dist = String(p0.dist ?? "").trim();
		if (!dist) continue;

		const fac = resolveGarbageFacilityByDistrict(dist, facilitiesDoc);
		if (
			!fac ||
			!Number.isFinite(fac.longitude) ||
			!Number.isFinite(fac.latitude)
		)
			continue;

		const hubPt = overrides.get(key);
		let tlng;
		let tlat;
		let hubSource;
		if (hubPt) {
			tlng = hubPt.lng;
			tlat = hubPt.lat;
			hubSource = "hub_table";
		} else {
			[tlng, tlat] = centroid.get(key);
			hubSource = "centroid";
		}

		const flat = fac.latitude;
		const flng = fac.longitude;
		if (haversineKm(tlat, tlng, flat, flng) > MAX_HUB_TO_PLANT_KM) continue;

		const dx = flng - tlng;
		const dy = flat - tlat;
		if (dx * dx + dy * dy < MIN_LEN2) continue;

		const n = feats.length;
		features.push({
			type: "Feature",
			geometry: {
				type: "LineString",
				coordinates: [
					[tlng, tlat],
					[flng, flat],
				],
			},
			properties: {
				dist,
				route_name: p0.route_name,
				route_group_key: key,
				point_name: p0.route_name,
				hub_source: hubSource,
				incinerator_id: fac.id,
				incinerator_name: fac.name_short ?? fac.name,
				flow_stage2: `${fac.name_short ?? fac.name}（依 ${dist} 對照 district_to_facility_hint）`,
				arc_width: widthFromStopCount(n),
				stop_count_hub: n,
				time_minutes: 1440,
			},
		});
	}

	return { type: "FeatureCollection", features };
}
