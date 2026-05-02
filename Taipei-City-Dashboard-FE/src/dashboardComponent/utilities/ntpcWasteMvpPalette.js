/**
 * 新北資源回收／廚餘 MVP：地圖、矩形圖、長條圖共用寫死 8 階色階（同一組 hex）。
 * 圖表：依「名次」分桶到 8 階（與 Treemap／Column 排序後列序一致）。
 * 地圖：數值線性插值於 8 個停駐點；請與
 * db-sample-data/ntpc_waste_mvp_map_paint_transparency.sql、
 * db-sample-data/ntpc_waste_mvp_manager_patch.sql、
 * db-sample-data/tpc_recycling_mvp_manager_patch.sql、
 * db-sample-data/metro_recycling_unified_manager_patch.sql、
 * db-sample-data/metro_kitchen_unified_manager_patch.sql 內 fill-color 同步。
 */
export const NTPC_RECYCLING_MAP_INDEX = "ntpc_recycling_map_mvp";
export const NTPC_KITCHEN_MAP_INDEX = "ntpc_kitchen_waste_map_mvp";
/** 雙北合併廚餘（取代僅新北廚餘地圖後） */
export const METRO_KITCHEN_MAP_INDEX = "metro_kitchen_waste_map_mvp";
/** 雙北合併資源回收（取代獨立新北／臺北回收組件後） */
export const METRO_RECYCLING_MAP_INDEX = "metro_recycling_map_mvp";
/** 舊 index：仍保留色階以免快取舊儀表板異常 */
export const TPC_RECYCLING_MAP_INDEX = "tpc_recycling_map_mvp";

/** 回收：淺綠 → 深綠，共 8 階 */
export const NTPC_RECYCLING_COLORS_8 = [
	"#ecfdf5",
	"#d1fae5",
	"#a7f3d0",
	"#6ee7b7",
	"#34d399",
	"#10b981",
	"#047857",
	"#064e3b",
];

/** 廚餘：淺琥珀 → 深褐，共 8 階 */
export const NTPC_KITCHEN_COLORS_8 = [
	"#fffbeb",
	"#fef3c7",
	"#fde68a",
	"#fcd34d",
	"#f59e0b",
	"#d97706",
	"#92400e",
	"#451a03",
];

export function isNtpcWasteRankColorChart(chartConfig) {
	const idx = chartConfig?.index;
	return (
		idx === NTPC_RECYCLING_MAP_INDEX ||
		idx === NTPC_KITCHEN_MAP_INDEX ||
		idx === METRO_KITCHEN_MAP_INDEX ||
		idx === TPC_RECYCLING_MAP_INDEX ||
		idx === METRO_RECYCLING_MAP_INDEX
	);
}

/**
 * @param {number} n 資料筆數（已依量由大到小排序後的列序）
 * @param {string} chartIndex component index
 * @returns {string[]}
 */
export function discreteNtpcRankColors(n, chartIndex) {
	const ramp =
		chartIndex === NTPC_KITCHEN_MAP_INDEX || chartIndex === METRO_KITCHEN_MAP_INDEX
			? NTPC_KITCHEN_COLORS_8
			: NTPC_RECYCLING_COLORS_8;
	const steps = ramp.length;
	return Array.from({ length: n }, (_, i) => {
		const inv = n <= 1 ? 1 : 1 - i / (n - 1);
		const bi = Math.min(steps - 1, Math.round(inv * (steps - 1)));
		return ramp[bi];
	});
}
