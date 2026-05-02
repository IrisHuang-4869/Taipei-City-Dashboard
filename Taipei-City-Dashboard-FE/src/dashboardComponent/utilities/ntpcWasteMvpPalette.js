/**
 * 新北／雙北資源回收、廚餘 MVP：共用 8 階色階（hex）。
 * 矩形圖／橫向長條：依公噸排序；顏色依人均公斤在當批 min–max 內分桶（見 ntpcMetroDistrictPopulation114.js）。
 * 地圖 fill：輸入為公噸×1000÷人口（公斤／人）。廚餘色相／alpha 與 ntpc_waste_mvp_map_paint_transparency.sql（對齊 metro id 153 之 alpha 階）一致，停駐由公噸 0～1.35 線性映射至人均軸；回收用 metro_recycling_unified_manager_patch id 153 之 rgba 與 0～2200 公噸停駐映射至人均軸。
 */
import {
	buildMetroPopulationMatchMax1Expr,
	getMetroDistrictPopulation114,
} from "./ntpcMetroDistrictPopulation114.js";

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

/**
 * 矩形圖／長條：列已依公噸由大到小，但顏色依「人均公斤」在當批資料 min–max 內映射到 8 階。
 * @param {{ x: string, y: number }[]} sortedRows
 * @param {string} chartIndex
 * @returns {string[]}
 */
export function treemapBarColorsByPerCapitaKg(sortedRows, chartIndex) {
	const ramp =
		chartIndex === NTPC_KITCHEN_MAP_INDEX || chartIndex === METRO_KITCHEN_MAP_INDEX
			? NTPC_KITCHEN_COLORS_8
			: NTPC_RECYCLING_COLORS_8;
	const kgpc = sortedRows.map((r) => {
		const pop = getMetroDistrictPopulation114(r.x);
		const y = Number(r.y);
		if (!pop || !Number.isFinite(y)) {
			return null;
		}
		return (y * 1000) / pop;
	});
	const valid = kgpc.filter((v) => v != null && Number.isFinite(v));
	if (valid.length === 0) {
		return discreteNtpcRankColors(sortedRows.length, chartIndex);
	}
	const lo = Math.min(...valid);
	const hi = Math.max(...valid);
	const span = hi - lo || 1;
	return sortedRows.map((_, i) => {
		const v = kgpc[i];
		if (v == null || !Number.isFinite(v)) {
			return ramp[0];
		}
		const t = (v - lo) / span;
		const bi = Math.min(ramp.length - 1, Math.round(t * (ramp.length - 1)));
		return ramp[bi];
	});
}

function mapPerCapitaRatioExpr(tonsProperty) {
	const denom = buildMetroPopulationMatchMax1Expr();
	return [
		"/",
		["*", 1000, ["coalesce", ["to-number", ["get", tonsProperty]], 0]],
		denom,
	];
}

/** 廚餘 SQL 公噸停駐（0～1.35）對齊 2200:1.35 與雙北回收 alpha 階 */
const KITCHEN_FILL_TON_STOPS = [
	0, 0.16875, 0.3375, 0.50625, 0.675, 0.84375, 1.0125, 1.18125, 1.35,
];
/** 與 ntpc_waste_mvp_map_paint_transparency.sql id 151 一致（低量 254,215,170,0.1） */
const KITCHEN_FILL_RGBA_STOPS = [
	"rgba(254,215,170,0.1)",
	"rgba(253,186,116,0.28)",
	"rgba(251,146,60,0.45)",
	"rgba(249,115,22,0.6)",
	"rgba(234,88,12,0.74)",
	"rgba(217,119,6,0.84)",
	"rgba(194,65,12,0.88)",
	"rgba(154,52,18,0.9)",
	"rgba(67,20,7,0.92)",
];
/**
 * 人均軸上界（kg／人）：對應原廚餘 1.35 公噸在參考人口下之換算；可視全區資料調高／調低。
 * 1.35e3/350000 ≈ 0.00386；取略大讓多數區落在階內。
 */
const KITCHEN_PC_GRADIENT_R_MAX = 0.0045;

/** 廚餘面圖：人均 → 與 SQL 相同琥珀 rgba／alpha，停駐為公噸階線性映射至人均 */
export const MAP_KITCHEN_PER_CAPITA_GRADIENT_FILL = (() => {
	const r = mapPerCapitaRatioExpr("kitchen_tons");
	const expr = ["interpolate", ["linear"], r];
	const scale = KITCHEN_PC_GRADIENT_R_MAX / 1.35;
	for (let i = 0; i < KITCHEN_FILL_TON_STOPS.length; i++) {
		expr.push(KITCHEN_FILL_TON_STOPS[i] * scale, KITCHEN_FILL_RGBA_STOPS[i]);
	}
	return expr;
})();

/** metro_recycling_map_mvp id 153：公噸停駐與 rgba（alpha 與廚餘同一組） */
const METRO_RECYCLING_TON_STOPS = [
	0, 275, 550, 825, 1100, 1375, 1650, 1925, 2200,
];
const METRO_RECYCLING_RGBA_STOPS = [
	"rgba(236,253,245,0.1)",
	"rgba(209,250,229,0.28)",
	"rgba(167,243,208,0.45)",
	"rgba(110,231,183,0.6)",
	"rgba(52,211,153,0.74)",
	"rgba(16,185,129,0.84)",
	"rgba(16,185,129,0.88)",
	"rgba(5,150,105,0.9)",
	"rgba(5,150,105,0.92)",
];
/** 人均軸上界（kg／人）：對應原 2200 公噸在參考人口下之換算 */
const RECYCLING_PC_GRADIENT_R_MAX = 12;

/** 回收面圖：人均 → 與雙北 metro 153 相同 rgba／alpha，停駐為 0～2200 公噸線性映射至人均 */
export const MAP_RECYCLING_PER_CAPITA_GRADIENT_FILL = (() => {
	const r = mapPerCapitaRatioExpr("recycling_tons");
	const expr = ["interpolate", ["linear"], r];
	const scale = RECYCLING_PC_GRADIENT_R_MAX / 2200;
	for (let i = 0; i < METRO_RECYCLING_TON_STOPS.length; i++) {
		expr.push(METRO_RECYCLING_TON_STOPS[i] * scale, METRO_RECYCLING_RGBA_STOPS[i]);
	}
	return expr;
})();

/**
 * Mapbox fill-color 表達式：雙北 MVP 廚餘／回收面圖專用（依人均連續漸層）。
 * @param {string} componentIndex map_config.index
 * @returns {unknown[]|null}
 */
export function getMapPerCapitaGradientFillExpr(componentIndex) {
	if (
		componentIndex === NTPC_KITCHEN_MAP_INDEX ||
		componentIndex === METRO_KITCHEN_MAP_INDEX
	) {
		return MAP_KITCHEN_PER_CAPITA_GRADIENT_FILL;
	}
	if (
		componentIndex === NTPC_RECYCLING_MAP_INDEX ||
		componentIndex === METRO_RECYCLING_MAP_INDEX ||
		componentIndex === TPC_RECYCLING_MAP_INDEX
	) {
		return MAP_RECYCLING_PER_CAPITA_GRADIENT_FILL;
	}
	return null;
}
