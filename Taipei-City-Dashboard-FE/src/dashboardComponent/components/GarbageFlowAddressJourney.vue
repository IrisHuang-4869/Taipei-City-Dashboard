<script setup>
import { ref } from "vue";
import { useMapStore } from "../../store/mapStore";

const props = defineProps({
	disabled: { type: Boolean, default: false },
});

const mapStore = useMapStore();

const addressInput = ref("");
const running = ref(false);

async function onRun() {
	const q = addressInput.value.trim();
	if (!q || props.disabled || running.value) return;
	running.value = true;
	try {
		await mapStore.runGarbageAddressJourney({ address: q });
	} finally {
		running.value = false;
	}
}

function onStop() {
	mapStore.clearGarbageAddressJourney();
	running.value = false;
}
</script>

<template>
  <div class="garbage-journey">
    <p class="garbage-journey__title">
      垃圾的旅途
    </p>
    <div class="garbage-journey__row">
      <input
        v-model="addressInput"
        type="text"
        class="garbage-journey__input"
        placeholder="請輸入地點"
        :disabled="disabled || running"
        @keydown.enter.prevent="onRun"
      >
      <button
        type="button"
        class="garbage-journey__btn garbage-journey__btn--primary"
        :disabled="disabled || running || !addressInput.trim()"
        @click="onRun"
      >
        查詢並模擬
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
		margin: 0 0 8px;
		font-weight: 600;
		color: var(--color-complement-text, #ddd);
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
}
</style>
