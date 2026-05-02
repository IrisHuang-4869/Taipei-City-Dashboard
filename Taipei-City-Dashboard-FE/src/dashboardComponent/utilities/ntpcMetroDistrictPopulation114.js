/**
 * 雙北各行政區人口（人）：供廚餘／回收「人均公斤」填色與圖表用。
 * 新北：主計處「提要分析」114 年 11 月底（各區欄位）；臺北：內政部戶籍人口概值（與圖資 TNAME 對齊）。
 * 若之後要改為 API 動態載入，可替換本常數表。
 */
export const METRO_DISTRICT_POPULATION_114_11 = {
	// —— 新北市 29 區（114 年 11 月底）——
	八里區: 43528,
	三芝區: 22094,
	三峽區: 115044,
	三重區: 382899,
	中和區: 404167,
	五股區: 94674,
	平溪區: 3914,
	新店區: 306921,
	新莊區: 421396,
	板橋區: 549895,
	林口區: 138280,
	樹林區: 177441,
	永和區: 211497,
	汐止區: 212752,
	泰山區: 78071,
	淡水區: 207477,
	深坑區: 23671,
	烏來區: 6183,
	瑞芳區: 35674,
	石碇區: 6930,
	石門區: 10003,
	萬里區: 20237,
	蘆洲區: 196565,
	貢寮區: 10454,
	金山區: 19751,
	雙溪區: 7467,
	鶯歌區: 89547,
	坪林區: 6167,
	土城區: 242602,

	// —— 臺北市 12 區（戶籍概值，與 COUNTY=TAIPEI 圖資區名一致）——
	中正區: 148831,
	大同區: 118954,
	中山區: 194383,
	松山區: 192803,
	大安區: 283326,
	萬華區: 170063,
	信義區: 194989,
	士林區: 265072,
	北投區: 233348,
	內湖區: 276364,
	南港區: 121163,
	文山區: 259718,
};

/**
 * @param {string} districtName 圖資 TNAME（如「板橋區」）
 * @returns {number|null}
 */
export function getMetroDistrictPopulation114(districtName) {
	if (districtName == null || districtName === "") {
		return null;
	}
	const n = METRO_DISTRICT_POPULATION_114_11[districtName];
	return typeof n === "number" && n > 0 ? n : null;
}

/**
 * Mapbox：`["max",1,["match",["get","TNAME"],…,1]]`
 */
export function buildMetroPopulationMatchMax1Expr() {
	const pairs = [];
	for (const [name, pop] of Object.entries(
		METRO_DISTRICT_POPULATION_114_11,
	)) {
		pairs.push(name, pop);
	}
	return ["max", 1, ["match", ["get", "TNAME"], ...pairs, 1]];
}
