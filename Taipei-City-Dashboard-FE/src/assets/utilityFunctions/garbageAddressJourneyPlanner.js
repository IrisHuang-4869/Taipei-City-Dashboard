/**
 * 依輸入地址座標規劃「示意」清運路徑：地址 → 最近停靠站 → 第一階段集中站（分隊部／路線集中點，非黃金資收站）→ 焚化廠
 * 與地圖上清運弧線終點一致；實際收運路線以主管機關公告為準。
 */

import { getTaipeiBrigadeHubLngLatForStop } from "./garbageTaipeiStopToBrigadeArcs.js";
import { getNtpcRouteHubLngLatForStop } from "./garbageNtpcStopToRouteHubArcs.js";
import { resolveGarbageFacilityByDistrict } from "./garbageHubToIncineratorArcs.js";
import { sampleGreatCircleLngLat } from "./greatCircleSample.js";

const R = 6371000;
function toRad(d) {
	return (d * Math.PI) / 180;
}
/** 兩點間距離（公尺） */
export function distanceMeters(lon1, lat1, lon2, lat2) {
	const dLat = toRad(lat2 - lat1);
	const dLon = toRad(lon2 - lon1);
	const a =
		Math.sin(dLat / 2) ** 2 +
		Math.cos(toRad(lat1)) *
			Math.cos(toRad(lat2)) *
			Math.sin(dLon / 2) ** 2;
	return 2 * R * Math.asin(Math.min(1, Math.sqrt(a)));
}

/**
 * @param {number} userLng
 * @param {number} userLat
 * @param {GeoJSON.FeatureCollection} taipeiFc
 * @param {GeoJSON.FeatureCollection} ntpcFc
 * @returns {GeoJSON.Feature | null}
 */
export function findNearestGarbageStop(userLng, userLat, taipeiFc, ntpcFc) {
	let best = null;
	let bestD = Infinity;
	const consider = (f) => {
		if (f.geometry?.type !== "Point") return;
		const [lng, lat] = f.geometry.coordinates;
		const d = distanceMeters(userLng, userLat, lng, lat);
		if (d < bestD) {
			bestD = d;
			best = f;
		}
	};
	for (const f of taipeiFc?.features ?? []) consider(f);
	for (const f of ntpcFc?.features ?? []) consider(f);
	return best;
}

function isTaipeiStop(f) {
	return Boolean(f?.properties?.brigade);
}

/**
 * @returns {{
 *   waypoints: [number, number][],
 *   labels: string[],
 *   segmentPolylines: [number, number][][],
 *   meta: object
 * } | { error: string }}
 */
export function planGarbageAddressJourney(
	userLng,
	userLat,
	nearestStop,
	officesDoc,
	hubsDoc,
	facilitiesDoc,
) {
	if (!nearestStop?.geometry?.coordinates) {
		return { error: "找不到鄰近清運停靠點資料。" };
	}
	const d0 = distanceMeters(
		userLng,
		userLat,
		nearestStop.geometry.coordinates[0],
		nearestStop.geometry.coordinates[1],
	);
	if (d0 > 35_000) {
		return {
			error: `最近清運站距離超過 35 公里（約 ${Math.round(d0 / 1000)} km），請確認地址是否在雙北範圍內。`,
		};
	}

	const taipei = isTaipeiStop(nearestStop);
	let hubLng;
	let hubLat;
	if (taipei) {
		const hub = getTaipeiBrigadeHubLngLatForStop(nearestStop, officesDoc);
		if (!hub) {
			return {
				error:
					"無法推算該分隊第一階段集中站：站點需有 brigade 欄位，且座標需有效（若分隊表無座標則以該站為重心）。",
			};
		}
		hubLng = hub.lng;
		hubLat = hub.lat;
	} else {
		const hub = getNtpcRouteHubLngLatForStop(nearestStop, hubsDoc);
		if (!hub) {
			return {
				error:
					"無法推算該路線第一階段集中點：站點需有 dist、route_name 欄位與有效座標。",
			};
		}
		hubLng = hub.lng;
		hubLat = hub.lat;
	}

	const dist = String(nearestStop.properties?.dist ?? "").trim();
	if (!dist) return { error: "停靠點缺少行政區（dist）欄位，無法對照焚化廠。" };

	const fac = resolveGarbageFacilityByDistrict(dist, facilitiesDoc);
	if (!fac || !Number.isFinite(fac.longitude) || !Number.isFinite(fac.latitude)) {
		return { error: `無法依行政區「${dist}」對照焚化廠座標。` };
	}

	const [sx, sy] = nearestStop.geometry.coordinates;
	const waypoints = [
		[userLng, userLat],
		[sx, sy],
		[hubLng, hubLat],
		[fac.longitude, fac.latitude],
	];
	const labels = [
		"您輸入的位置",
		"最近清運停靠站",
		"第一階段集中站（分隊部／路線集中點，非黃金資收站）",
		fac.name_short || fac.name || "焚化廠（示意終點）",
	];

	const segmentPolylines = [
		sampleGreatCircleLngLat(waypoints[0], waypoints[1], 16),
		sampleGreatCircleLngLat(waypoints[1], waypoints[2], 24),
		sampleGreatCircleLngLat(waypoints[2], waypoints[3], 24),
	];

	return {
		waypoints,
		labels,
		segmentPolylines,
		meta: {
			nearestStopDistM: Math.round(d0),
			district: dist,
			isTaipeiStop: taipei,
		},
	};
}
