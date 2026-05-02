<!-- Developed by Taipei Urban Intelligence Center 2023-2024-->

<script setup>
import { computed, ref } from "vue";
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
	"fly",
]);

/** 矩形面積約與數值成正比：佔全圖比例過低時不顯示區名，避免小格字被裁切 */
const LABEL_MIN_SHARE_OF_TOTAL = 0.024;

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
	const data = nums.map((val, i) => {
		const y = Number(val);
		return {
			x: categories[i] != null ? categories[i] : `項目${i + 1}`,
			y: Number.isFinite(y) ? y : 0,
		};
	});
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
	return {
		chart: {
			borderRadius: 5,
			toolbar: {
				show: false,
			},
		},
		colors: [...(props.chart_config?.color || [])],
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
				shadeIntensity: 0,
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
				series,
				seriesIndex,
				dataPointIndex,
				w,
			}) {
				return (
					'<div class="chart-tooltip">' +
					"<h6>" +
					w.globals.categoryLabels[dataPointIndex] +
					"</h6>" +
					"<span>" +
					series[seriesIndex][dataPointIndex] +
					` ${unit}` +
					"</span>" +
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
