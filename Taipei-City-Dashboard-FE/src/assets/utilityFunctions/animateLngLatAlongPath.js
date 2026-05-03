/**
 * 以 Mapbox Marker 沿折線分段線性插值移動（端點間直線）
 * @param {import('mapbox-gl').Map} map
 * @param {import('mapbox-gl').Marker} marker
 * @param {[number, number][]} waypoints [lng, lat][]
 * @param {object} [opts]
 * @param {number} [opts.msPerLeg=3200]
 * @param {(legIndex: number) => void} [opts.onLegStart]
 * @param {boolean} [opts.followCamera=false] 為 true 時每幀 setCenter 跟隨標記
 * @returns {{ promise: Promise<void>, cancel: () => void }}
 */
export function startMarkerLngLatPathAnimation(map, marker, waypoints, opts = {}) {
	const msPerLeg = opts.msPerLeg ?? 3200;
	const onLegStart = opts.onLegStart ?? (() => {});
	const followCamera = opts.followCamera === true;

	let cancelled = false;
	let raf = 0;

	const promise = (async () => {
		if (!map || !marker || !waypoints?.length) return;

		for (let leg = 0; leg < waypoints.length - 1; leg++) {
			if (cancelled) return;
			onLegStart(leg);
			const from = waypoints[leg];
			const to = waypoints[leg + 1];
			const t0 = performance.now();

			await new Promise((resolveSeg) => {
				function frame(now) {
					if (cancelled) {
						resolveSeg();
						return;
					}
					const t = Math.min(1, (now - t0) / msPerLeg);
					const lng = from[0] + (to[0] - from[0]) * t;
					const lat = from[1] + (to[1] - from[1]) * t;
					marker.setLngLat([lng, lat]);
					if (followCamera) map.setCenter([lng, lat]);
					if (t < 1) {
						raf = requestAnimationFrame(frame);
					} else {
						raf = 0;
						resolveSeg();
					}
				}
				raf = requestAnimationFrame(frame);
			});

			if (cancelled) return;
			await new Promise((r) => {
				setTimeout(r, 400);
			});
		}
	})();

	return {
		promise,
		cancel: () => {
			cancelled = true;
			if (raf) cancelAnimationFrame(raf);
			raf = 0;
		},
	};
}

/**
 * 沿多段折線（通常為大圓取樣）移動 Marker；預設不動地圖相機。
 * @param {import('mapbox-gl').Map | null} map
 * @param {import('mapbox-gl').Marker} marker
 * @param {[number, number][][]} segmentPolylines 每段 [lng, lat][]，依序播放
 * @param {object} [opts]
 * @param {number} [opts.msPerLeg=3200]
 * @param {number} [opts.pauseMsBetweenLegs=150] 每段結束後暫停（毫秒）
 * @param {(legIndex: number) => void} [opts.onLegStart]
 * @param {boolean} [opts.followCamera=false]
 * @returns {{ promise: Promise<void>, cancel: () => void }}
 */
export function startMarkerAlongSegmentPolylines(
	map,
	marker,
	segmentPolylines,
	opts = {},
) {
	const msPerLeg = opts.msPerLeg ?? 3200;
	const pauseMs = opts.pauseMsBetweenLegs ?? 150;
	const onLegStart = opts.onLegStart ?? (() => {});
	const followCamera = opts.followCamera === true;

	let cancelled = false;
	let raf = 0;

	const promise = (async () => {
		if (!marker || !segmentPolylines?.length) return;

		for (let leg = 0; leg < segmentPolylines.length; leg++) {
			if (cancelled) return;
			const poly = segmentPolylines[leg];
			if (!poly?.length) continue;
			onLegStart(leg);

			if (poly.length === 1) {
				marker.setLngLat(poly[0]);
				if (followCamera && map) map.setCenter(poly[0]);
				await new Promise((r) => setTimeout(r, pauseMs));
				continue;
			}

			const t0 = performance.now();
			await new Promise((resolveSeg) => {
				function frame(now) {
					if (cancelled) {
						resolveSeg();
						return;
					}
					const t = Math.min(1, (now - t0) / msPerLeg);
					const idxFloat = t * (poly.length - 1);
					const i0 = Math.floor(idxFloat);
					const i1 = Math.min(i0 + 1, poly.length - 1);
					const f = idxFloat - i0;
					const lng = poly[i0][0] + (poly[i1][0] - poly[i0][0]) * f;
					const lat = poly[i0][1] + (poly[i1][1] - poly[i0][1]) * f;
					marker.setLngLat([lng, lat]);
					if (followCamera && map) map.setCenter([lng, lat]);
					if (t < 1) {
						raf = requestAnimationFrame(frame);
					} else {
						raf = 0;
						resolveSeg();
					}
				}
				raf = requestAnimationFrame(frame);
			});

			if (cancelled) return;
			await new Promise((r) => setTimeout(r, pauseMs));
		}
	})();

	return {
		promise,
		cancel: () => {
			cancelled = true;
			if (raf) cancelAnimationFrame(raf);
			raf = 0;
		},
	};
}
