/**
 * 台北垃圾車停靠點 → 清潔隊分隊「匯聚」弧線（deck.gl ArcLayer 用）
 *
 * 終點優先序：
 * 1. public/mapData/garbage_taipei_brigade_offices.json 中該分隊之 latitude／longitude（已地理編碼或手動補齊）
 * 2. 否則使用該分隊下所有停靠站之座標重心（與舊版相同）
 */

const MIN_LEN2 = 1e-16;
/** 雙北收運點合理範圍（略寬鬆）；超出則不畫該弧線，避免錯誤座標「沖天」 */
const BBOX = { lonMin: 121.25, lonMax: 122.05, latMin: 24.75, latMax: 25.35 };
/** 停靠點→終點最長弧線（公里），超過視為異常不畫 */
const MAX_ARC_KM = 35;

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

function inTaipeiBBox(lon, lat) {
	return (
		lon >= BBOX.lonMin &&
		lon <= BBOX.lonMax &&
		lat >= BBOX.latMin &&
		lat <= BBOX.latMax
	);
}

/**
 * @param {object | null} officesDoc 由 garbage_taipei_brigade_offices.json 解析
 * @returns {Map<string, { lng: number, lat: number, address: string }>}
 */
function buildOfficeCoordMap(officesDoc) {
	const map = new Map();
	if (!officesDoc?.offices?.length) return map;
	for (const row of officesDoc.offices) {
		const lat = Number(row.latitude);
		const lng = Number(row.longitude);
		if (!Number.isFinite(lat) || !Number.isFinite(lng)) continue;
		if (!row.name) continue;
		map.set(row.name, {
			lng,
			lat,
			address: row.address ?? "",
		});
	}
	return map;
}

/**
 * @param {GeoJSON.FeatureCollection} featureCollection 點位，properties.brigade 為分隊名
 * @param {object | null} [officesDoc] 分隊地址／座標表（可為 null）
 * @returns {GeoJSON.FeatureCollection} LineString [停靠點, 分隊終點]
 */
export function buildTaipeiGarbageBrigadeArcs(featureCollection, officesDoc = null) {
	const byBrigade = new Map();
	for (const f of featureCollection.features) {
		if (f.geometry?.type !== "Point") continue;
		const b = f.properties?.brigade;
		if (!b) continue;
		if (!byBrigade.has(b)) byBrigade.set(b, []);
		byBrigade.get(b).push(f.geometry.coordinates);
	}

	const hub = new Map();
	for (const [name, coordsList] of byBrigade) {
		let sx = 0;
		let sy = 0;
		for (const c of coordsList) {
			sx += c[0];
			sy += c[1];
		}
		const n = coordsList.length;
		hub.set(name, [sx / n, sy / n]);
	}

	const aliases =
		officesDoc?.brigade_name_aliases &&
		typeof officesDoc.brigade_name_aliases === "object"
			? officesDoc.brigade_name_aliases
			: {};
	const officeCoordsByName = buildOfficeCoordMap(officesDoc);

	const features = [];
	for (const f of featureCollection.features) {
		if (f.geometry?.type !== "Point") continue;
		const b = f.properties?.brigade;
		if (!b || !hub.has(b)) continue;
		const [lng, lat] = f.geometry.coordinates;
		if (!inTaipeiBBox(lng, lat)) continue;

		const officeName = aliases[b] != null ? aliases[b] : b;
		const officePt = officeCoordsByName.get(officeName);
		let tlng;
		let tlat;
		let flowTarget;
		let hubSource;
		if (officePt) {
			tlng = officePt.lng;
			tlat = officePt.lat;
			hubSource = "office";
			flowTarget = `${officeName}（登記地址座標）`;
		} else {
			[tlng, tlat] = hub.get(b);
			hubSource = "centroid";
			flowTarget = `${b}（站點座標重心）`;
		}

		if (!inTaipeiBBox(tlng, tlat)) continue;
		if (haversineKm(lat, lng, tlat, tlng) > MAX_ARC_KM) continue;

		const dx = lng - tlng;
		const dy = lat - tlat;
		if (dx * dx + dy * dy < MIN_LEN2) continue;

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
				...f.properties,
				flow_target: flowTarget,
				hub_source: hubSource,
				...(officePt?.address
					? { brigade_office_address: officePt.address }
					: {}),
			},
		});
	}

	return { type: "FeatureCollection", features };
}
