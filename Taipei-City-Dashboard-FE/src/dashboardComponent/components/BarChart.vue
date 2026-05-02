<!-- Developed by Taipei Urban Intelligence Center 2023-2024-->
<script setup>
import { ref, computed } from "vue";
import VueApexCharts from "vue3-apexcharts";

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
	"fly"
]);

const apexChartOptions = computed(() => {
	const unit = props.chart_config.unit || "";
	return {
		chart: {
			offsetY: 15,
			stacked: true,
			toolbar: {
				show: false,
			},
		},
		colors: [...(props.chart_config.color || [])],
		dataLabels: {
			enabled: true,
			// 橫向長條：`plotOptions.bar.dataLabels.position: 'top'` 將錨點放在條的右端；
			// `textAnchor: 'start'` + 小幅 `offsetX` 讓數字畫在條外右側（不壓在色塊內）
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
		legend: {
			show: false,
		},
		plotOptions: {
			bar: {
				borderRadius: 2,
				distributed: true,
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
			labels: {
				show: false,
			},
			type: "category",
			categories: props.chart_config.categories || [],
		},
		yaxis: {
			labels: {
				formatter: function (value) {
					if (value == null) {
						return "";
					}
					const s = String(value);
					return s.length > 7 ? s.slice(0, 6) + "..." : s;
				},
			},
		},
	};
});

const chartHeight = computed(() => {
	const n = props.series?.[0]?.data?.length ?? 0;
	return `${40 + n * 30}`;
});

const selectedIndex = ref(null);

function handleDataSelection(_e, _chartContext, config) {
	if (!props.map_filter || !props.map_filter_on) {
		return;
	}
	if (
		`${config.dataPointIndex}-${config.seriesIndex}` !== selectedIndex.value
	) {
		// Supports filtering by xAxis
		if (props.map_filter.mode === "byParam") {
			emits(
				"filterByParam",
				props.map_filter,
				props.map_config,
				config.w.globals.labels[config.dataPointIndex],
				null
			);
		}
		// Supports filtering by xAxis
		else if (props.map_filter.mode === "byLayer") {
			emits(
				"filterByLayer",
				props.map_config,
				config.w.globals.labels[config.dataPointIndex]
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
  <div v-if="activeChart === 'BarChart'">
    <VueApexCharts
      width="100%"
      :height="chartHeight"
      type="bar"
      :options="apexChartOptions"
      :series="series"
      @data-point-selection="handleDataSelection"
    />
  </div>
</template>
