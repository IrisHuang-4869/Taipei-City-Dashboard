<script setup>
import { computed } from "vue";
import { storeToRefs } from "pinia";
import { useMapStore } from "../../store/mapStore";

const props = defineProps({
	/** chart_data 格式，取 [0].data[].x 作為行政區選單 */
	series: { type: Array, default: () => [] },
	disabled: { type: Boolean, default: false },
});

const mapStore = useMapStore();
const { garbageFlowArcPhaseMode, arcDistrictFilter, loadingLayers } = storeToRefs(mapStore);

const GARBAGE_ARC_LAYER_IDS = [
	"garbage_ntpc_route_arcs_local-arc-metrotaipei",
	"garbage_ntpc_hub_incinerator_arcs_local-arc-metrotaipei",
	"garbage_taipei_truck_local-arc-metrotaipei",
	"garbage_taipei_hub_incinerator_arcs_local-arc-metrotaipei",
	"garbage_taipei_truck_local-arc-taipei",
	"garbage_taipei_hub_incinerator_arcs_local-arc-taipei",
];

const districtBusy = computed(() =>
	loadingLayers.value.some((id) => GARBAGE_ARC_LAYER_IDS.includes(id)),
);

const districtOptions = computed(() => {
	const rows = props.series?.[0]?.data;
	if (!Array.isArray(rows)) return [];
	const names = rows.map((d) => d?.x).filter(Boolean);
	return [...new Set(names)].sort((a, b) =>
		a.localeCompare(b, "zh-Hant"),
	);
});

// 直接用 store 的 arcDistrictFilter 作為 select 的 model（null → ""）
const selectedDistrict = computed({
	get() {
		return arcDistrictFilter.value ?? "";
	},
	set(v) {
		mapStore.setArcDistrictFilter(v || null);
	},
});

function setPhase(mode) {
	mapStore.setGarbageFlowArcPhase(mode);
}
</script>

<template>
  <div
    class="garbage-flow-controls"
    :class="{ 'garbage-flow-controls--disabled': disabled || districtBusy }"
  >
    <div class="garbage-flow-controls__row">
      <label class="garbage-flow-controls__label">行政區</label>
      <select
        v-model="selectedDistrict"
        class="garbage-flow-controls__select"
        :disabled="disabled || districtBusy"
      >
        <option value="">
          全部
        </option>
        <option
          v-for="d in districtOptions"
          :key="d"
          :value="d"
        >
          {{ d }}
        </option>
      </select>
    </div>
    <div class="garbage-flow-controls__row">
      <span class="garbage-flow-controls__label">弧線階段</span>
      <div class="garbage-flow-controls__seg">
        <button
          type="button"
          class="garbage-flow-controls__btn"
          :class="{ 'garbage-flow-controls__btn--on': garbageFlowArcPhaseMode === 'all' }"
          :disabled="disabled || districtBusy"
          @click="setPhase('all')"
        >
          全部
        </button>
        <button
          type="button"
          class="garbage-flow-controls__btn"
          :class="{ 'garbage-flow-controls__btn--on': garbageFlowArcPhaseMode === '1' }"
          :disabled="disabled || districtBusy"
          @click="setPhase('1')"
        >
          第一階段
        </button>
        <button
          type="button"
          class="garbage-flow-controls__btn"
          :class="{ 'garbage-flow-controls__btn--on': garbageFlowArcPhaseMode === '2' }"
          :disabled="disabled || districtBusy"
          @click="setPhase('2')"
        >
          第二階段
        </button>
      </div>
    </div>
    <p
      v-if="districtBusy"
      class="garbage-flow-controls__hint"
    >
      圖層載入中…
    </p>
  </div>
</template>

<style scoped lang="scss">
.garbage-flow-controls {
	margin-top: 8px;
	padding-top: 8px;
	border-top: 1px solid rgba(255, 255, 255, 0.12);
	font-size: 0.8rem;
	color: var(--color-complement-text, #ccc);

	&--disabled {
		opacity: 0.55;
		pointer-events: none;
	}

	&__row {
		display: flex;
		align-items: center;
		gap: 8px;
		margin-bottom: 6px;
		flex-wrap: wrap;
	}

	&__label {
		flex: 0 0 auto;
		min-width: 3.5em;
		color: var(--color-complement-text, #aaa);
	}

	&__select {
		flex: 1 1 140px;
		min-width: 0;
		max-width: 100%;
		padding: 4px 6px;
		border-radius: 4px;
		border: 1px solid rgba(255, 255, 255, 0.2);
		background: rgba(0, 0, 0, 0.25);
		color: inherit;
		font-size: inherit;
	}

	&__seg {
		display: flex;
		flex-wrap: wrap;
		gap: 4px;
		flex: 1 1 auto;
	}

	&__btn {
		padding: 4px 8px;
		border-radius: 4px;
		border: 1px solid rgba(255, 255, 255, 0.22);
		background: rgba(255, 255, 255, 0.06);
		color: inherit;
		font-size: inherit;
		cursor: pointer;
		line-height: 1.3;

		&:hover:not(:disabled) {
			background: rgba(255, 255, 255, 0.12);
		}

		&--on {
			border-color: rgba(31, 122, 255, 0.75);
			background: rgba(31, 122, 255, 0.22);
		}
	}

	&__hint {
		margin: 4px 0 0;
		font-size: 0.75rem;
		opacity: 0.85;
	}
}
</style>
