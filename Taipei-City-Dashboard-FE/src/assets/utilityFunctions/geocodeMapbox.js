/**
 * 以 Mapbox Geocoding API 將地址轉為 WGS84 座標（與地圖 token 相同，限雙北／台灣搜尋建議搭配 region/country 參數）
 * @param {string} address
 * @param {string} accessToken import.meta.env.VITE_MAPBOXTOKEN
 * @returns {Promise<{ lng: number, lat: number, placeName: string } | null>}
 */
export async function geocodeAddressMapbox(address, accessToken) {
	const q = String(address ?? "").trim();
	if (!q || !accessToken) return null;
	const url = new URL(
		`https://api.mapbox.com/geocoding/v5/mapbox.places/${encodeURIComponent(q)}.json`,
	);
	url.searchParams.set("access_token", accessToken);
	url.searchParams.set("limit", "1");
	url.searchParams.set("language", "zh-Hant");
	url.searchParams.set("country", "tw");
	url.searchParams.set("proximity", "121.5,25.05");

	const res = await fetch(url.toString(), { method: "GET" });
	if (!res.ok) return null;
	const data = await res.json();
	const feat = data?.features?.[0];
	if (!feat?.center || feat.center.length < 2) return null;
	const [lng, lat] = feat.center;
	if (!Number.isFinite(lng) || !Number.isFinite(lat)) return null;
	return {
		lng,
		lat,
		placeName: String(feat.place_name || feat.text || q),
	};
}
