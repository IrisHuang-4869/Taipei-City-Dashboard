/**
 * 新北循線清運點 → 路線「集中點」弧線（deck.gl ArcLayer 用）
 *
 * 新北開放資料無「隊部／轉運站」欄位時，以同一行政區＋同一路線名稱下所有停靠點之座標重心為匯聚點（語意上等同該路線表定收運之幾何中心）。
 * 若提供 garbage_ntpc_route_hubs.json，可依 dist + route_name 覆寫終點座標（登記地址地理編碼或手動經緯）。
 */

const MIN_LEN2 = 1e-16;

/** 新北 schedule_summary（"HH:MM" 或 "HH:MM；HH:MM"）→ 分鐘數（0–1439），取第一個時段 */
function schedule_to_minutes(summary) {
	if (!summary) return null;
	const first = String(summary).split("；")[0].trim();
	const m = first.match(/^(\d{1,2}):(\d{2})$/);
	if (!m) return null;
	return parseInt(m[1], 10) * 60 + parseInt(m[2], 10);
}
/** 雙北周邊合理範圍（含新北東北角、烏來等略放寬） */
const BBOX = { lonMin: 121.2, lonMax: 122.15, latMin: 24.7, latMax: 25.35 };
/** 停靠點→集中點最長弧線（公里）；偏遠山區路線略放寬 */
const MAX_ARC_KM = 50;

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

function inBBox(lon, lat) {
	return (
		lon >= BBOX.lonMin &&
		lon <= BBOX.lonMax &&
		lat >= BBOX.latMin &&
		lat <= BBOX.latMax
	);
}

function routeGroupKey(dist, routeName) {
	const d = String(dist ?? "").trim();
	const r = String(routeName ?? "").trim();
	return `${d}|${r}`;
}

/**
 * @param {object | null} hubsDoc 可選；格式見 public/mapData/garbage_ntpc_route_hubs.json
 * @returns {Map<string, { lng: number, lat: number, address: string }>}
 */
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
		const key = routeGroupKey(dist, routeName);
		map.set(key, {
			lng,
			lat,
			address: row.address != null ? String(row.address) : "",
		});
	}
	return map;
}

/**
 * 單一站推算路線集中點（hubs 表優先，否則為該站座標＝僅一筆時之重心）。
 * 不因「停靠點與集中點重合」而略過，供地址模擬路徑等使用。
 * @param {GeoJSON.Feature} stopFeature
 * @param {object | null} [hubsDoc]
 * @returns {{ lng: number, lat: number } | null}
 */
export function getNtpcRouteHubLngLatForStop(stopFeature, hubsDoc = null) {
	if (stopFeature?.geometry?.type !== "Point") return null;
	const p = stopFeature.properties || {};
	const { dist } = p;
	const routeName = p.route_name;
	if (!dist || !routeName) return null;
	const key = routeGroupKey(dist, routeName);
	const overrides = buildRouteHubOverrideMap(hubsDoc);
	const hubPt = overrides.get(key);
	if (hubPt) {
		return { lng: hubPt.lng, lat: hubPt.lat };
	}
	const [lng, lat] = stopFeature.geometry.coordinates;
	if (!Number.isFinite(lng) || !Number.isFinite(lat)) return null;
	return { lng, lat };
}

/**
 * @param {GeoJSON.FeatureCollection} featureCollection 點位；properties 需含 dist、route_name（與 garbage_ntpc_route_local.geojson 一致）
 * @param {object | null} [hubsDoc] 可選之路線集中點覆寫表
 * @returns {GeoJSON.FeatureCollection} LineString [停靠點, 集中點]
 */
export function buildNtpcGarbageRouteHubArcs(
	featureCollection,
	hubsDoc = null,
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
		byRoute.get(key).push(f.geometry.coordinates);
	}

	const centroid = new Map();
	for (const [key, coordsList] of byRoute) {
		let sx = 0;
		let sy = 0;
		for (const c of coordsList) {
			sx += c[0];
			sy += c[1];
		}
		const n = coordsList.length;
		centroid.set(key, [sx / n, sy / n]);
	}

	const overrides = buildRouteHubOverrideMap(hubsDoc);

	const features = [];
	for (const f of featureCollection.features) {
		if (f.geometry?.type !== "Point") continue;
		const p = f.properties || {};
		const { dist } = p;
		const routeName = p.route_name;
		if (!dist || !routeName) continue;
		const key = routeGroupKey(dist, routeName);
		if (!centroid.has(key)) continue;

		const [lng, lat] = f.geometry.coordinates;
		if (!inBBox(lng, lat)) continue;

		const hubPt = overrides.get(key);
		let tlng;
		let tlat;
		let flowTarget;
		let hubSource;
		if (hubPt) {
			tlng = hubPt.lng;
			tlat = hubPt.lat;
			hubSource = "hub_table";
			flowTarget = `${dist} ${routeName}（登記集中點）`;
		} else {
			[tlng, tlat] = centroid.get(key);
			hubSource = "centroid";
			flowTarget = `${dist} ${routeName}（該路線停靠點座標重心）`;
		}

		if (!inBBox(tlng, tlat)) continue;
		if (haversineKm(lat, lng, tlat, tlng) > MAX_ARC_KM) continue;

		const dx = lng - tlng;
		const dy = lat - tlat;
		if (dx * dx + dy * dy < MIN_LEN2) continue;

		const timeMinutes = schedule_to_minutes(p.schedule_summary);
		features.push({
			type: "Feature",
			geometry: {
				type: "LineString",
				coordinates: [
					[lng, lat],
					[tlng, tlat],
				],
			},
			properties: {
				...p,
				route_group_key: key,
				flow_target: flowTarget,
				hub_source: hubSource,
				...(hubPt?.address ? { hub_table_address: hubPt.address } : {}),
				time_minutes: timeMinutes,
			},
		});
	}

	return { type: "FeatureCollection", features };
}
