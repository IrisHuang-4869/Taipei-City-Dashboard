<script setup>
import { ref } from "vue";
import { useMapStore } from "../../store/mapStore";

const props = defineProps({
	disabled: { type: Boolean, default: false },
});

const mapStore = useMapStore();

const addressInput = ref("");
const statusText = ref("");
const legLabel = ref("");
const running = ref(false);

async function onRun() {
	const q = addressInput.value.trim();
	if (!q || props.disabled || running.value) return;
	running.value = true;
	legLabel.value = "";
	statusText.value = "";
	try {
		await mapStore.runGarbageAddressJourney({
			address: q,
			onStatus: (s) => {
				statusText.value = s;
			},
			onLegLabel: (s) => {
				legLabel.value = s;
			},
		});
	} finally {
		running.value = false;
	}
}

function onStop() {
	mapStore.clearGarbageAddressJourney();
	statusText.value = "";
	legLabel.value = "";
	running.value = false;
}
</script>

<template>
  <div class="garbage-journey">
    <p class="garbage-journey__title">
      地址模擬清運路徑
    </p>
    <p class="garbage-journey__desc">
      輸入地址後以 Mapbox 地理編碼定位，再依雙北清運點位推算「最近停靠站 → 第一階段集中站（分隊部／路線集中點，非黃金資收站）→ 焚化廠」；標記沿測地線弧線示意移動，俯瞰視角固定（非實際車行路線）。
    </p>
    <div class="garbage-journey__row">
      <input
        v-model="addressInput"
        type="text"
        class="garbage-journey__input"
        placeholder="例：臺北市大安區仁愛路四段100號"
        :disabled="disabled || running"
        @keydown.enter.prevent="onRun"
      >
      <button
        type="button"
        class="garbage-journey__btn garbage-journey__btn--primary"
        :disabled="disabled || running || !addressInput.trim()"
        @click="onRun"
      >
        {{ running ? "處理中…" : "查詢並模擬" }}
      </button>
      <button
        type="button"
        class="garbage-journey__btn"
        :disabled="disabled"
        @click="onStop"
      >
        清除標記
      </button>
    </div>
    <p
      v-if="statusText"
      class="garbage-journey__status"
    >
      {{ statusText }}
    </p>
    <p
      v-if="legLabel"
      class="garbage-journey__leg"
    >
      目前段落：{{ legLabel }}
    </p>
  </div>
</template>

<style scoped lang="scss">
.garbage-journey {
	margin-top: 10px;
	padding-top: 10px;
	border-top: 1px solid rgba(255, 255, 255, 0.12);
	font-size: 0.78rem;
	color: var(--color-complement-text, #ccc);

	&__title {
		margin: 0 0 4px;
		font-weight: 600;
		color: var(--color-complement-text, #ddd);
	}

	&__desc {
		margin: 0 0 8px;
		line-height: 1.45;
		opacity: 0.92;
	}

	&__row {
		display: flex;
		flex-wrap: wrap;
		gap: 6px;
		align-items: center;
	}

	&__input {
		flex: 1 1 160px;
		min-width: 0;
		padding: 6px 8px;
		border-radius: 4px;
		border: 1px solid rgba(255, 255, 255, 0.22);
		background: rgba(0, 0, 0, 0.25);
		color: inherit;
		font-size: inherit;
	}

	&__btn {
		padding: 6px 10px;
		border-radius: 4px;
		border: 1px solid rgba(255, 255, 255, 0.22);
		background: rgba(255, 255, 255, 0.08);
		color: inherit;
		font-size: inherit;
		cursor: pointer;

		&:hover:not(:disabled) {
			background: rgba(255, 255, 255, 0.14);
		}

		&--primary {
			border-color: rgba(234, 88, 12, 0.65);
			background: rgba(234, 88, 12, 0.25);
		}

		&:disabled {
			opacity: 0.5;
			cursor: not-allowed;
		}
	}

	&__status,
	&__leg {
		margin: 6px 0 0;
		line-height: 1.4;
	}

	&__leg {
		color: #fdba74;
	}
}
</style>
