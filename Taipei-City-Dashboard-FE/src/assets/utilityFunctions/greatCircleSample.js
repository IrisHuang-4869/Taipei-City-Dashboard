/**
 * 兩點間大圓路徑取樣（與 deck.gl ArcLayer 視覺相近之測地線）
 * @param {[number, number]} from [lng, lat]
 * @param {[number, number]} to [lng, lat]
 * @param {number} [segments=40]
 * @returns {[number, number][]}
 */
export function sampleGreatCircleLngLat(from, to, segments = 40) {
	const [lng1, lat1] = from;
	const [lng2, lat2] = to;
	const out = [];
	const φ1 = (lat1 * Math.PI) / 180;
	const φ2 = (lat2 * Math.PI) / 180;
	const λ1 = (lng1 * Math.PI) / 180;
	const λ2 = (lng2 * Math.PI) / 180;
	const d =
		2 *
		Math.asin(
			Math.sqrt(
				Math.sin((φ2 - φ1) / 2) ** 2 +
					Math.cos(φ1) * Math.cos(φ2) * Math.sin((λ2 - λ1) / 2) ** 2,
			),
		);
	if (!Number.isFinite(d) || d < 1e-10) {
		return [from, to];
	}
	const n = Math.max(2, Math.round(segments));
	for (let i = 0; i <= n; i++) {
		const f = i / n;
		const A = Math.sin((1 - f) * d) / Math.sin(d);
		const B = Math.sin(f * d) / Math.sin(d);
		const x =
			A * Math.cos(φ1) * Math.cos(λ1) + B * Math.cos(φ2) * Math.cos(λ2);
		const y =
			A * Math.cos(φ1) * Math.sin(λ1) + B * Math.cos(φ2) * Math.sin(λ2);
		const z = A * Math.sin(φ1) + B * Math.sin(φ2);
		const φ = Math.atan2(z, Math.sqrt(x * x + y * y));
		const λ = Math.atan2(y, x);
		out.push([(λ * 180) / Math.PI, (φ * 180) / Math.PI]);
	}
	return out;
}
