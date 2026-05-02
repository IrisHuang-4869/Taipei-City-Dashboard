<!-- Developed by Taipei Urban Intelligence Center 2023-2024-->

<script setup>
import { computed, ref } from "vue";
import VueApexCharts from "vue3-apexcharts";
import {
	discreteNtpcRankColors,
	isNtpcWasteRankColorChart,
} from "../utilities/ntpcWasteMvpPalette";

const props = defineProps([
	"chart_config",
	"activeChart",
	"series",
	"map_config",
	"map_filter",
	"map_filter_on",
]);

const emits = defineEmits([
	"filterByParam",
	"filterByLayer",
	"clearByParamFilter",
	"clearByLayerFilter",
	"fly",
]);

/** 僅用於橫向長條圖：依各類別數值加總降冪（矩形圖／Treemap 不使用此排序） */
const columnDisplay = computed(() => {
	const cats = props.chart_config?.categories;
	const {series} = props;
	if (!series?.length || !series[0]?.data?.length) {
		return { categories: cats || [], series: series || [] };
	}
	if (cats?.length) {
		const n = cats.length;
		if (!series.every((s) => Array.isArray(s.data) && s.data.length === n)) {
			return { categories: cats, series };
		}
		const idx = Array.from({ length: n }, (_, i) => i);
		const totalAt = (i) =>
			series.reduce((acc, ser) => {
				const v = Number(ser.data[i]);
				return acc + (Number.isFinite(v) ? v : 0);
			}, 0);
		idx.sort((a, b) => totalAt(b) - totalAt(a));
		return {
			categories: idx.map((i) => cats[i]),
			series: series.map((ser) => ({
				...ser,
				data: idx.map((i) => ser.data[i]),
			})),
		};
	}
	const d0 = series[0].data[0];
	if (d0 && typeof d0 === "object" && "y" in d0) {
		const order = [...series[0].data]
			.map((pt, i) => ({ i, y: Number(pt.y) || 0 }))
			.sort((a, b) => b.y - a.y)
			.map((x) => x.i);
		return {
			categories: [],
			series: series.map((ser) => ({
				...ser,
				data: order.map((i) => ser.data[i]),
			})),
		};
	}
	return { categories: cats || [], series };
});

/**
 * Apex 可能就地修改傳入的 series／categories；與 DistrictChart 等共用 config.chart_data 時會打亂索引與著色。
 * 只餵圖表複本，勿改動父層 props.series。
 */
const columnSeriesForApex = computed(() => {
	const raw = columnDisplay.value.series;
	try {
		return structuredClone(raw);
	} catch {
		return JSON.parse(JSON.stringify(raw));
	}
});

const categoryCount = computed(() => {
	const d = columnDisplay.value;
	if (d.categories.length) {
		return d.categories.length;
	}
	return d.series?.[0]?.data?.length ?? 0;
});

/** 新北 MVP 橫向長條：與矩形圖／地圖同 8 階，依顯示序（已由大到小）分桶 */
const ntpcColumnDistributedColors = computed(() => {
	if (!isNtpcWasteRankColorChart(props.chart_config)) {
		return null;
	}
	const display = columnDisplay.value;
	const multi = (display.series?.length ?? 0) > 1;
	if (multi) {
		return null;
	}
	const n = categoryCount.value;
	if (!n) {
		return null;
	}
	return discreteNtpcRankColors(n, props.chart_config.index);
});

/** 與 BarChart／Moenv 回收點橫向長條一致：依筆數撐高、區名在左側 */
const chartHeight = computed(() => {
	const n = categoryCount.value;
	if (!n) {
		return "120";
	}
	return `${Math.max(120, 36 + n * 28)}`;
});

const columnChartOptions = computed(() => {
	const display = columnDisplay.value;
	const cats = display.categories;
	const unit = props.chart_config?.unit || "";
	const multi = (display.series?.length ?? 0) > 1;
	const hasCats = cats.length > 0;
	const ntpcColors = ntpcColumnDistributedColors.value;
	const barColors =
		ntpcColors?.length && !multi ? ntpcColors : [...(props.chart_config?.color || [])];
	return {
		chart: {
			offsetY: 10,
			stacked: true,
			toolbar: {
				show: false,
			},
			zoom: {
				allowMouseWheelZoom: false,
			},
		},
		colors: barColors,
		dataLabels: {
			enabled: true,
			offsetX: 8,
			textAnchor: "start",
			dropShadow: {
				enabled: false,
			},
			style: {
				colors: ["#FFFFFF"],
			},
		},
		grid: {
			show: false,
		},
		legend:
			multi && hasCats
				? {
					show: true,
					horizontalAlign: "left",
					offsetX: 20,
					floating: true,
				}
				: { show: false },
		plotOptions: {
			bar: {
				borderRadius: 2,
				distributed: !multi,
				horizontal: true,
				dataLabels: {
					position: "top",
					hideOverflowingLabels: false,
				},
			},
		},
		stroke: {
			colors: ["#282a2c"],
			show: true,
			width: 0,
		},
		tooltip: {
			custom: function ({
				series,
				seriesIndex,
				dataPointIndex,
				w,
			}) {
				return (
					'<div class="chart-tooltip">' +
					"<h6>" +
					w.globals.labels[dataPointIndex] +
					`${
						hasCats ? "-" + w.globals.seriesNames[seriesIndex] : ""
					}` +
					"</h6>" +
					"<span>" +
					series[seriesIndex][dataPointIndex] +
					` ${unit}` +
					"</span>" +
					"</div>"
				);
			},
			followCursor: true,
		},
		xaxis: {
			axisBorder: {
				show: false,
			},
			axisTicks: {
				show: false,
			},
			categories: hasCats ? [...cats] : [],
			labels: {
				show: false,
			},
			type: "category",
		},
		yaxis: {
			labels: {
				formatter: function (value) {
					if (value == null) {
						return "";
					}
					const s = String(value);
					return s.length > 8 ? `${s.slice(0, 7)}…` : s;
				},
			},
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
			const w = config.w.globals;
			const label =
				w.categoryLabels?.[config.dataPointIndex] ??
				w.labels?.[config.dataPointIndex];
			emits(
				"filterByParam",
				props.map_filter,
				props.map_config,
				label,
				w.seriesNames?.[config.seriesIndex],
			);
		} else if (props.map_filter.mode === "byLayer") {
			const w = config.w.globals;
			const label =
				w.categoryLabels?.[config.dataPointIndex] ??
				w.labels?.[config.dataPointIndex];
			emits("filterByLayer", props.map_config, label);
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
    v-if="activeChart === 'ColumnChart'"
    class="columnChart"
  >
    <VueApexCharts
      :key="chartHeight"
      width="100%"
      :height="chartHeight"
      type="bar"
      :options="columnChartOptions"
      :series="columnSeriesForApex"
      @data-point-selection="handleDataSelection"
    />
  </div>
</template>

<style lang="scss" scoped>
.columnChart {
	overflow: auto;
	position: relative;
	height: 100%;

	.vue-apexcharts {
		justify-content: unset !important;
	}
}
</style>
