<script setup>
import { ref, watch, nextTick, onMounted, computed } from "vue";
import VueApexCharts from "vue3-apexcharts";
import { useMapStore } from "../../store/mapStore";
import http from "../../router/axios";
import "../styles/toggleswitch.css";

const props = defineProps({
	chart_config: { type: Object, required: true },
	activeChart: { type: String, required: true },
	series: { type: Array, default: () => [] },
	map_config: { type: Array, default: () => [] },
	map_filter: { type: [Object, null], default: null },
	map_filter_on: { type: Boolean, default: false },
	/** 地圖模式主開關（由 DashboardComponent 傳入） */
	parentMapOn: { type: Boolean, default: true },
	/**
	 * 儀表板總覽：只顯示「站點數量」長條圖（與地圖交叉比對該分頁相同邏輯），不顯示分頁與圖層開關。
	 */
	countsOnly: { type: Boolean, default: false },
});

const mapStore = useMapStore();
/** 使用者是否要顯示該類別（主開關再次開啟時會沿用） */
const userLayerEnabled = ref([]);

const activeSubTab = ref("layers");
const layerCounts = ref([]);
const countsLoading = ref(false);
const countsLoaded = ref(false);

const tabs = [
	{ id: "layers", label: "圖層開關" },
	{ id: "counts", label: "站點數量" },
];

const aiUserMessage = ref("");
const aiResultText = ref("");
const aiLoading = ref(false);

const getSystemPrompt = () => {
	const layerInfo = props.map_config.map((mc, idx) => `${idx}: ${mc.title || mc.index}`).join('\n');
	return `你是一個大台北地區回收點分類小幫手。請根據使用者的物品，判斷對應的回收類別索引。
請優先判斷物品的「主要回收類別」。除非物品確實明顯同時具備多種回收屬性（例如：電子玩具兼具玩具與電器屬性），才需要呼叫多個工具。
請保持精簡，避免過度分類，以使用者最直覺的分類為主。
可用的類別與索引如下：\n${layerInfo}`;
};

const sendAIMessage = async () => {
	if (!aiUserMessage.value.trim() || aiLoading.value) return;
	
	const userInput = aiUserMessage.value;
	aiResultText.value = "AI 正在分類中...";
	aiLoading.value = true;
	
	try {
		const requestPayload = {
			session: "recycle_ai_" + Date.now(),
			stream: false,
			messages: [
				{ role: 'system', content: getSystemPrompt() },
				{ role: 'user', content: userInput }
			],
			tools: [
				{
					type: "function",
					function: {
						name: "toggle_recycle_layer",
						description: "開啟對應的回收物資圖層",
						parameters: {
							type: "object",
							properties: {
								layer_index: {
									type: "integer",
									description: "圖層的陣列索引值"
								}
							},
							required: ["layer_index"]
						}
					}
				}
			]
		};
		
		const response = await http.post("/ai/chat/twai", requestPayload);
		const data = response.data?.data;
		
		if (data?.tool_used && data.executed_tools) {
			const toolsStr = data.executed_tools;
			const executedTools = JSON.parse(toolsStr);
			
			const targetIndices = [];
			for (const t of executedTools) {
				if (t.name === "toggle_recycle_layer") {
					try {
						const args = JSON.parse(t.arguments);
						if (args.layer_index !== undefined) {
							const idx = args.layer_index;
							if (idx >= 0 && idx < props.map_config.length) {
								targetIndices.push(idx);
							}
						}
					} catch (err) {
						console.error("Failed to parse tool arguments", err);
					}
				}
			}

			if (targetIndices.length > 0) {
				// Turn off all recycle layers first
				for (let i = 0; i < props.map_config.length; i++) {
					onSubToggle(i, false);
				}
				// Turn on target layers
				for (const idx of targetIndices) {
					onSubToggle(idx, true);
				}
				const names = targetIndices.map(idx => layerTitle(props.map_config[idx]));
				aiResultText.value = `已為您開啟：${names.join('、')}`;
			} else {
				aiResultText.value = "抱歉，我無法判斷該物品的分類。";
			}
		} else {
			aiResultText.value = data?.content || "抱歉，我無法判斷該物品的分類。";
		}
	} catch (error) {
		console.error("AI chat error", error);
		aiResultText.value = "AI 分類時發生錯誤，請稍後再試。";
	} finally {
		aiLoading.value = false;
		// 3秒後自動清除小字
		setTimeout(() => {
			if (aiResultText.value && !aiLoading.value) {
				aiResultText.value = "";
			}
		}, 5000);
	}
};

function syncPrefLength() {
	const len = props.map_config?.length ?? 0;
	while (userLayerEnabled.value.length < len) {
		userLayerEnabled.value.push(true);
	}
	if (userLayerEnabled.value.length > len) {
		userLayerEnabled.value = userLayerEnabled.value.slice(0, len);
	}
}

function resetCounts() {
	countsLoaded.value = false;
	layerCounts.value = [];
}

function applyUserPreferencesToMap() {
	if (!props.parentMapOn || !props.map_config?.length) {
		return;
	}
	props.map_config.forEach((cfg, i) => {
		if (userLayerEnabled.value[i]) {
			mapStore.addToMapLayerList([cfg]);
		} else {
			mapStore.turnOffMapLayerVisibility([cfg]);
		}
	});
}

watch(
	() => props.map_config,
	async () => {
		syncPrefLength();
		resetCounts();
		if (props.countsOnly) {
			await loadLayerCounts();
		}
	},
	{ deep: true },
);

watch(
	() => props.parentMapOn,
	async (on, prev) => {
		syncPrefLength();
		if (!on) {
			return;
		}
		if (prev === false || prev === undefined) {
			await nextTick();
			applyUserPreferencesToMap();
		}
	},
);

watch(activeSubTab, (tab) => {
	if (props.countsOnly) {
		return;
	}
	if (tab === "counts" && !countsLoaded.value && !countsLoading.value) {
		loadLayerCounts();
	}
});

onMounted(async () => {
	syncPrefLength();
	await nextTick();
	if (props.countsOnly) {
		await loadLayerCounts();
		return;
	}
	if (props.parentMapOn) {
		applyUserPreferencesToMap();
	}
});

async function countFeaturesForLayer(mc) {
	const url = `/mapData/${mc.index}.geojson`;
	const res = await fetch(url);
	if (!res.ok) {
		throw new Error(`HTTP ${res.status}`);
	}
	const data = await res.json();
	if (data?.type === "FeatureCollection" && Array.isArray(data.features)) {
		return data.features.length;
	}
	if (data?.type === "Feature") {
		return 1;
	}
	return 0;
}

async function loadLayerCounts() {
	if (!props.map_config?.length) {
		return;
	}
	countsLoading.value = true;
	try {
		const settled = await Promise.allSettled(
			props.map_config.map((mc) => countFeaturesForLayer(mc)),
		);
		layerCounts.value = settled.map((s) =>
			s.status === "fulfilled" ? s.value : null,
		);
		countsLoaded.value = true;
	} finally {
		countsLoading.value = false;
	}
}

const totalCount = computed(() => {
	if (!countsLoaded.value || !props.map_config?.length) {
		return null;
	}
	const nums = layerCounts.value.filter((n) => typeof n === "number");
	if (!nums.length) {
		return null;
	}
	return nums.reduce((a, b) => a + b, 0);
});

const allCountsOk = computed(
	() =>
		countsLoaded.value &&
		layerCounts.value.length === props.map_config?.length &&
		layerCounts.value.every((n) => typeof n === "number"),
);

const hasCountLoadError = computed(
	() => countsLoaded.value && !allCountsOk.value && totalCount.value !== null,
);

function layerColor(i) {
	const c = props.chart_config?.color;
	if (Array.isArray(c) && c[i]) {
		return c[i];
	}
	return "#888888";
}

/** 顯示用：移除「回收點｜／回收點 |」等前綴（與 DB / 圖資標題相容） */
function stripRecyclePointPrefix(raw) {
	if (raw == null || raw === "") {
		return "";
	}
	let s = String(raw).trim();
	const prefixes = ["回收點｜", "回收點 | ", "回收點 |", "回收點|"];
	for (const p of prefixes) {
		if (s.startsWith(p)) {
			return s.slice(p.length).trimStart();
		}
	}
	return s;
}

function layerTitle(mc) {
	return stripRecyclePointPrefix(mc?.title || mc?.index || "");
}

/** 圖表 Y 軸與 layerTitle 一致（標題已不再帶前綴時可略過多餘分段） */
function shortLayerTitle(mc) {
	const t = layerTitle(mc);
	const sep = "｜";
	const idx = t.indexOf(sep);
	return idx >= 0 ? t.slice(idx + sep.length).trimStart() : t;
}

/** 長條圖：依數量遞減；載入失敗者排在最後 */
const countBarSeries = computed(() => {
	if (!countsLoaded.value || !props.map_config?.length) {
		return {
			labels: [],
			fullLabels: [],
			data: [],
			rawCounts: [],
			colors: [],
		};
	}
	const items = props.map_config.map((mc, i) => ({
		label: shortLayerTitle(mc),
		fullLabel: layerTitle(mc),
		count: layerCounts.value[i],
		color: layerColor(i),
	}));
	items.sort((a, b) => {
		const av = typeof a.count === "number" ? a.count : -1;
		const bv = typeof b.count === "number" ? b.count : -1;
		return bv - av;
	});
	return {
		labels: items.map((x) => x.label),
		fullLabels: items.map((x) => x.fullLabel),
		data: items.map((x) => (typeof x.count === "number" ? x.count : 0)),
		rawCounts: items.map((x) => x.count),
		colors: items.map((x) => x.color),
	};
});

const countsChartSeries = computed(() => [
	{ name: "站點數", data: countBarSeries.value.data },
]);

const countsChartHeight = computed(() => {
	const n = countBarSeries.value.data.length;
	if (!n) {
		return "120";
	}
	return `${36 + n * 28}`;
});

const countsChartOptions = computed(() => {
	const bs = countBarSeries.value;
	const unit = "處";
	return {
		chart: {
			offsetY: 10,
			stacked: true,
			toolbar: { show: false },
		},
		colors: [...bs.colors],
		dataLabels: {
			enabled: true,
			offsetX: 8,
			textAnchor: "start",
			dropShadow: { enabled: false },
			style: { colors: ["#FFFFFF"] },
			formatter(val, opts) {
				const i = opts.dataPointIndex;
				if (bs.rawCounts[i] == null) {
					return "—";
				}
				return val != null ? String(val) : "";
			},
		},
		grid: { show: false },
		legend: { show: false },
		plotOptions: {
			bar: {
				borderRadius: 2,
				distributed: true,
				horizontal: true,
				dataLabels: { position: "top", hideOverflowingLabels: false },
			},
		},
		stroke: { colors: ["#282a2c"], show: true, width: 0 },
		tooltip: {
			custom({ series, dataPointIndex }) {
				const label = bs.fullLabels[dataPointIndex];
				const raw = bs.rawCounts[dataPointIndex];
				const v = series[0][dataPointIndex];
				const valueStr =
					raw == null
						? "無法載入"
						: `${Number(v).toLocaleString("zh-TW")} ${unit}`;
				return `<div class="chart-tooltip"><h6>${label}</h6><span>${valueStr}</span></div>`;
			},
			followCursor: true,
		},
		xaxis: {
			axisBorder: { show: false },
			axisTicks: { show: false },
			labels: { show: false },
			type: "category",
			categories: bs.labels,
		},
		yaxis: {
			labels: {
				formatter(value) {
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

function onSubToggle(i, enabled) {
	if (!props.parentMapOn) {
		return;
	}
	userLayerEnabled.value[i] = enabled;
	const cfg = props.map_config[i];
	if (!cfg) {
		return;
	}
	if (enabled) {
		mapStore.addToMapLayerList([cfg]);
	} else {
		mapStore.turnOffMapLayerVisibility([cfg]);
	}
}

const allLayersEnabled = computed(() => {
	const len = props.map_config?.length ?? 0;
	if (!len) {
		return false;
	}
	for (let i = 0; i < len; i++) {
		if (!userLayerEnabled.value[i]) {
			return false;
		}
	}
	return true;
});

function toggleSelectAllLayers() {
	if (!props.parentMapOn || !props.map_config?.length) {
		return;
	}
	const turnOn = !allLayersEnabled.value;
	userLayerEnabled.value = props.map_config.map(() => turnOn);
	if (turnOn) {
		mapStore.addToMapLayerList(props.map_config);
	} else {
		mapStore.turnOffMapLayerVisibility(props.map_config);
	}
}
</script>

<template>
  <div
    v-if="activeChart === 'MoenvRecycleLayerToggles'"
    class="moenv-layer-toggles"
  >
    <template v-if="countsOnly">
      <p class="moenv-layer-toggles__hint">
        各類別點位總數依公開圖資統計（不分行政區），長條由多至少排列。
      </p>
      <div
        v-if="countsLoading"
        class="moenv-layer-toggles__loading"
      >
        載入中…
      </div>
      <template v-else-if="countsLoaded && countBarSeries.data.length">
        <div class="moenv-layer-toggles__chart-wrap">
          <VueApexCharts
            width="100%"
            :height="countsChartHeight"
            type="bar"
            :options="countsChartOptions"
            :series="countsChartSeries"
          />
        </div>
        <div
          v-if="totalCount !== null"
          class="moenv-layer-toggles__total"
        >
          <template v-if="allCountsOk">
            合計 <strong>{{ totalCount.toLocaleString("zh-TW") }}</strong> 處
          </template>
          <template v-else>
            已載入類別合計 <strong>{{ totalCount.toLocaleString("zh-TW") }}</strong> 處
          </template>
        </div>
        <p
          v-if="hasCountLoadError"
          class="moenv-layer-toggles__warn"
        >
          部分圖檔無法讀取；顯示「—」的類別未計入長條長度（值為 0）。
        </p>
      </template>
    </template>
    <template v-else>
    <div
      class="moenv-tabs"
      role="tablist"
    >
      <button
        v-for="t in tabs"
        :key="t.id"
        type="button"
        class="moenv-tab"
        :class="{ 'moenv-tab--active': activeSubTab === t.id }"
        role="tab"
        :aria-selected="activeSubTab === t.id"
        @click="activeSubTab = t.id"
      >
        {{ t.label }}
      </button>
    </div>

    <template v-if="activeSubTab === 'layers'">
      <p class="moenv-layer-toggles__hint">
        開啟組件主開關後，可在此選擇要顯示的回收物資類別。
      </p>
      <div class="moenv-layer-toggles__bulk">
        <div class="moenv-layer-toggles__ai-input-wrap">
          <input
            v-model="aiUserMessage"
            type="text"
            class="moenv-layer-toggles__ai-input"
            placeholder="輸入你想回收的東西"
            :disabled="!parentMapOn || aiLoading"
            @keyup.enter="sendAIMessage"
          >
          <button
            class="moenv-layer-toggles__ai-btn"
            :disabled="!parentMapOn || aiLoading || !aiUserMessage.trim()"
            @click="sendAIMessage"
          >
            <i
              v-if="aiLoading"
              class="fas fa-spinner fa-spin"
            />
            <span v-else>🔍</span>
          </button>
        </div>

        <button
          v-if="map_config?.length"
          type="button"
          class="moenv-layer-toggles__select-all"
          :disabled="!parentMapOn"
          @click="toggleSelectAllLayers"
        >
          {{ allLayersEnabled ? "取消全選" : "全選" }}
        </button>
      </div>
      <div
        v-if="aiResultText"
        class="moenv-layer-toggles__ai-result"
      >
        {{ aiResultText }}
      </div>
      <div
        v-for="(mc, i) in map_config"
        :key="`layer-${mc.index}-${mc.city || ''}-${i}`"
        class="moenv-layer-toggles__row"
      >
        <span
          class="moenv-layer-toggles__swatch"
          :style="{ backgroundColor: layerColor(i) }"
        />
        <span class="moenv-layer-toggles__label">{{ layerTitle(mc) }}</span>
        <label class="toggleswitch moenv-layer-toggles__switch">
          <input
            type="checkbox"
            :checked="!!userLayerEnabled[i]"
            :disabled="!parentMapOn"
            @change="(e) => onSubToggle(i, e.target.checked)"
          >
          <span class="toggleswitch-slider" />
        </label>
      </div>
    </template>

    <template v-else-if="activeSubTab === 'counts'">
      <p class="moenv-layer-toggles__hint">
        各類別點位總數依公開圖資統計（不分行政區），長條由多至少排列。
      </p>
      <div
        v-if="countsLoading"
        class="moenv-layer-toggles__loading"
      >
        載入中…
      </div>
      <template v-else-if="countsLoaded && countBarSeries.data.length">
        <div class="moenv-layer-toggles__chart-wrap">
          <VueApexCharts
            width="100%"
            :height="countsChartHeight"
            type="bar"
            :options="countsChartOptions"
            :series="countsChartSeries"
          />
        </div>
        <div
          v-if="totalCount !== null"
          class="moenv-layer-toggles__total"
        >
          <template v-if="allCountsOk">
            合計 <strong>{{ totalCount.toLocaleString("zh-TW") }}</strong> 處
          </template>
          <template v-else>
            已載入類別合計 <strong>{{ totalCount.toLocaleString("zh-TW") }}</strong> 處
          </template>
        </div>
        <p
          v-if="hasCountLoadError"
          class="moenv-layer-toggles__warn"
        >
          部分圖檔無法讀取；顯示「—」的類別未計入長條長度（值為 0）。
        </p>
      </template>
    </template>
    </template>
  </div>
</template>

<style scoped lang="scss">
.moenv-layer-toggles {
	padding: 0.25rem 0 0.5rem;
	font-size: 0.9rem;
}

.moenv-tabs {
	display: flex;
	gap: 0.125rem;
	margin-bottom: 0.65rem;
	border-bottom: 1px solid rgba(255, 255, 255, 0.12);
}

.moenv-tab {
	flex: 1;
	padding: 0.4rem 0.35rem 0.5rem;
	font-size: 0.82rem;
	cursor: pointer;
	border: none;
	background: transparent;
	color: rgba(255, 255, 255, 0.55);
	border-bottom: 2px solid transparent;
	margin-bottom: -1px;
	font-family: inherit;
	border-radius: 4px 4px 0 0;

	&:hover {
		color: rgba(255, 255, 255, 0.85);
		background: rgba(255, 255, 255, 0.04);
	}

	&.moenv-tab--active {
		color: #fff;
		border-bottom-color: #24b0dd;
		font-weight: 600;
	}
}

.moenv-layer-toggles__hint {
	margin: 0 0 0.5rem;
	line-height: 1.45;
	color: var(--color-component-text-secondary, rgba(255, 255, 255, 0.75));
}

.moenv-layer-toggles__bulk {
	display: flex;
	align-items: center;
	gap: 0.5rem;
	margin: 0 0 0.55rem;
}

.moenv-layer-toggles__select-all {
	flex-shrink: 0;
	font-size: 0.78rem;
	padding: 0.28rem 0.65rem;
	cursor: pointer;
	border: 1px solid rgba(36, 176, 221, 0.45);
	border-radius: 4px;
	background: rgba(36, 176, 221, 0.12);
	color: #6fd4f0;
	font-family: inherit;
	font-weight: 500;

	&:hover:not(:disabled) {
		background: rgba(36, 176, 221, 0.22);
		color: #a8e8fb;
	}

	&:disabled {
		opacity: 0.42;
		cursor: not-allowed;
	}
}

.moenv-layer-toggles__ai-input-wrap {
	flex: 1;
	display: flex;
	align-items: center;
	background: rgba(0, 0, 0, 0.2);
	border: 1px solid rgba(255, 255, 255, 0.15);
	border-radius: 4px;
	overflow: hidden;
	height: 28px;
}

.moenv-layer-toggles__ai-input {
	flex: 1;
	background: transparent;
	border: none;
	color: #fff;
	font-size: 0.8rem;
	padding: 0 0.5rem;
	width: 100%;

	&::placeholder {
		color: rgba(255, 255, 255, 0.4);
	}

	&:focus {
		outline: none;
	}

	&:disabled {
		opacity: 0.5;
	}
}

.moenv-layer-toggles__ai-btn {
	background: transparent;
	border: none;
	color: #fff;
	padding: 0 0.4rem;
	cursor: pointer;
	display: flex;
	align-items: center;
	justify-content: center;
	opacity: 0.7;

	&:hover:not(:disabled) {
		opacity: 1;
		background: rgba(255, 255, 255, 0.1);
	}

	&:disabled {
		cursor: not-allowed;
		opacity: 0.3;
	}
}

.moenv-layer-toggles__ai-result {
	font-size: 0.75rem;
	color: #88c0d0;
	margin: -0.25rem 0 0.55rem;
	padding-left: 0.2rem;
	animation: fadeIn 0.3s;
}

@keyframes fadeIn {
	from { opacity: 0; transform: translateY(-3px); }
	to { opacity: 1; transform: translateY(0); }
}

.moenv-layer-toggles__loading {
	padding: 0.5rem 0;
	color: rgba(255, 255, 255, 0.65);
	font-size: 0.85rem;
}

.moenv-layer-toggles__chart-wrap {
	margin: 0 -0.25rem;
	min-height: 120px;
}

.moenv-layer-toggles__row {
	display: flex;
	align-items: center;
	gap: 0.5rem;
	margin-bottom: 0.45rem;
}

.moenv-layer-toggles__swatch {
	width: 10px;
	height: 10px;
	border-radius: 50%;
	flex-shrink: 0;
	border: 1px solid rgba(255, 255, 255, 0.35);
}

.moenv-layer-toggles__label {
	flex: 1;
	min-width: 0;
	line-height: 1.35;
}

.moenv-layer-toggles__switch {
	flex-shrink: 0;
}

.moenv-layer-toggles__total {
	margin-top: 0.35rem;
	padding-top: 0.5rem;
	border-top: 1px solid rgba(255, 255, 255, 0.1);
	text-align: right;
	font-size: 0.88rem;
	color: rgba(255, 255, 255, 0.8);

	strong {
		color: #fff;
		margin: 0 0.15rem;
	}
}

.moenv-layer-toggles__warn {
	margin: 0.5rem 0 0;
	font-size: 0.75rem;
	line-height: 1.4;
	color: rgba(255, 200, 120, 0.9);
}


</style>
