<!-- Developed by Taipei Urban Intelligence Center 2023-2024-->

<script setup>
import { computed, ref, watch } from "vue";
import VueApexCharts from "vue3-apexcharts";
import {
	isNtpcWasteRankColorChart,
	treemapBarColorsByPerCapitaKg,
} from "../utilities/ntpcWasteMvpPalette";

const props = defineProps([
	"chart_config",
	"activeChart",
	"activeCity",
	"series",
	"map_config",
	"map_filter",
	"map_filter_on",
]);

// 雙北儀表板：外層 v-for :key 會在 metrotaipei ↔ taipei 回到相同字串時復用同一個
// TreemapChart 實例，vue3-apexcharts 內部狀態不會重繪；依 activeCity 遞增 nonce 強制重建圖表。
const chartMountNonce = ref(0);
watch(
	() => props.activeCity,
	() => {
		chartMountNonce.value += 1;
	},
);

const emits = defineEmits([
	"filterByParam",
	"filterByLayer",
	"clearByParamFilter",
	"clearByLayerFilter",
	"fly",
]);

/** 矩形面積約與數值成正比：佔全圖比例過低時不顯示區名，避免小格字被裁切 */
const LABEL_MIN_SHARE_OF_TOTAL = 0.024;

/** 新北 MVP：矩形圖依量由大到小排，與長條／地圖共用寫死 8 階；圖表依「名次」分桶（非數值線性） */
const useNtpcRankTreemapStyle = computed(() =>
	isNtpcWasteRankColorChart(props.chart_config),
);

/** two_d：data 為 { x, y }[]；three_d／percent：data 為數字[]，需搭配 chart_config.categories（維持 API 順序，不另外降冪） */
const treemapSeries = computed(() => {
	const raw = props.series;
	if (!raw?.[0]?.data?.length) {
		return [{ data: [] }];
	}
	const first = raw[0].data[0];
	if (
		first !== null &&
		typeof first === "object" &&
		"x" in first &&
		"y" in first
	) {
		return raw;
	}
	const categories = props.chart_config?.categories ?? [];
	const nums = raw[0].data;
	let data = nums.map((val, i) => {
		const y = Number(val);
		return {
			x: categories[i] != null ? categories[i] : `項目${i + 1}`,
			y: Number.isFinite(y) ? y : 0,
		};
	});
	if (useNtpcRankTreemapStyle.value) {
		data = [...data].sort((a, b) => {
			const dy = b.y - a.y;
			if (dy !== 0) {
				return dy;
			}
			return String(a.x).localeCompare(String(b.x), "zh-Hant");
		});
	}
	return [{ data }];
});

const sum = computed(() => {
	let total = 0;
	for (const item of treemapSeries.value[0]?.data ?? []) {
		const y = Number(item?.y);
		if (Number.isFinite(y)) {
			total += y;
		}
	}
	return Math.round(total * 100) / 100;
});

const treemapChartOptions = computed(() => {
	const rows = treemapSeries.value[0]?.data ?? [];
	const total = rows.reduce((s, d) => s + (Number(d?.y) || 0), 0);
	const unit = props.chart_config?.unit || "";
	const baseColors = [...(props.chart_config?.color || [])];
	const colors =
		useNtpcRankTreemapStyle.value && rows.length > 0
			? treemapBarColorsByPerCapitaKg(rows, props.chart_config.index)
			: baseColors;
	return {
		chart: {
			borderRadius: 5,
			toolbar: {
				show: false,
			},
		},
		colors,
		dataLabels: {
			formatter(val, opts) {
				const pt =
					opts?.w?.config?.series?.[opts.seriesIndex]?.data?.[
						opts.dataPointIndex
					];
				const y = pt && typeof pt === "object" ? Number(pt.y) : NaN;
				if (
					total > 0 &&
					Number.isFinite(y) &&
					y / total < LABEL_MIN_SHARE_OF_TOTAL
				) {
					return "";
				}
				if (pt && typeof pt === "object" && pt.x != null) {
					return String(pt.x);
				}
				return val != null && val !== "" ? String(val) : "";
			},
		},
		grid: {
			show: false,
		},
		legend: {
			show: false,
		},
		plotOptions: {
			treemap: {
				distributed: true,
				shadeIntensity: 0.35,
				dataLabels: {
					hideOverflowingLabels: true,
				},
			},
		},
		stroke: {
			colors: ["#282a2c"],
			show: true,
			width: 2,
		},
		tooltip: {
			custom: function ({
				seriesIndex,
				dataPointIndex,
				w,
			}) {
				let seriesRows = "";
				const label = w.globals.categoryLabels[dataPointIndex];
				// 取得該行政區在原始資料中的索引 (假設 categories 順序與 props.series 一致，如果不一致則需比對)
				const categories = props.chart_config?.categories || [];
				let originalIdx = categories.indexOf(label);
				
				// 如果 categories 沒定義，則嘗試從 props.series[0].data 找 x
				if (originalIdx === -1 && props.series[0]?.data?.[0]?.x) {
					originalIdx = props.series[0].data.findIndex(d => d.x === label);
				}

				if (originalIdx !== -1) {
					props.series.forEach((s) => {
						const val = s.data[originalIdx];
						seriesRows += `<div>${s.name}: ${val} ${unit}</div>`;
					});
				} else {
					// 退而求其次顯示目前 series 的值
					seriesRows = `<div>數據: ${w.globals.series[seriesIndex][dataPointIndex]} ${unit}</div>`;
				}
				
				return (
					'<div class="chart-tooltip">' +
					"<h6>" + label + "</h6>" +
					seriesRows +
					"</div>"
				);
			},
		},
		xaxis: {
			axisBorder: {
				show: false,
			},
			axisTicks: {
				show: false,
			},
			labels: {
				show: false,
			},
			type: "category",
		},
	};
});

const selectedIndex = ref(null);

function handleDataSelection(_e, _chartContext, config) {
	if (!props.map_filter || !props.map_filter_on) {
		return;
	}
	if (
		`${config.dataPointIndex}-${config.seriesIndex}` !== selectedIndex.value
	) {
		if (props.map_filter.mode === "byParam") {
			emits(
				"filterByParam",
				props.map_filter,
				props.map_config,
				config.w.globals.categoryLabels[config.dataPointIndex],
				null,
			);
		} else if (props.map_filter.mode === "byLayer") {
			emits(
				"filterByLayer",
				props.map_config,
				config.w.globals.categoryLabels[config.dataPointIndex],
			);
		}
		selectedIndex.value = `${config.dataPointIndex}-${config.seriesIndex}`;
	} else {
		if (props.map_filter.mode === "byParam") {
			emits("clearByParamFilter", props.map_config);
		} else if (props.map_filter.mode === "byLayer") {
			emits("clearByLayerFilter", props.map_config);
		}
		selectedIndex.value = null;
	}
}
</script>

<template>
  <div
    v-if="activeChart === 'TreemapChart'"
    class="treemapchart"
  >
    <div class="treemapchart-title">
      <h5>總合</h5>
      <h6>{{ sum }} {{ chart_config.unit }}</h6>
    </div>
    <VueApexCharts
      :key="`treemap-${props.activeCity ?? 'na'}-${chartMountNonce}`"
      width="100%"
      type="treemap"
      :options="treemapChartOptions"
      :series="treemapSeries"
      @data-point-selection="handleDataSelection"
    />
  </div>
</template>

<style scoped lang="scss">
.treemapchart {
	&-title {
		display: flex;
		justify-content: center;
		flex-direction: column;
		margin: 0.5rem 0 -0.5rem;

		h5 {
			margin: 0;
			color: var(--color-complement-text);
		}

		h6 {
			margin: 0;
			color: var(--color-complement-text);
			font-size: var(--font-m);
			font-weight: 400;
		}
	}
}
</style>
