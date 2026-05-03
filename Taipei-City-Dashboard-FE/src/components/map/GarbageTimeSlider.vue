<!-- 收運流向時間軸控制器 -->
<script setup>
import { computed, onUnmounted, ref } from "vue";
import { useMapStore } from "../../store/mapStore";

const mapStore = useMapStore();

// ── Für Elise player ──────────────────────────────────────────────
const furElisePlaying = ref(false);
let audioCtx = null;
let furEliseNodes = []; // active oscillator + gain pairs

// Für Elise note sequence: [frequency Hz, duration beats]
const FUR_ELISE_NOTES = [
	// Theme A
	[659.25, 0.5], [622.25, 0.5], [659.25, 0.5], [622.25, 0.5],
	[659.25, 0.5], [493.88, 0.5], [587.33, 0.5], [523.25, 0.5],
	[440.00, 1.5], [0, 0.5],
	[261.63, 0.5], [329.63, 0.5], [440.00, 0.5],
	[493.88, 1.5], [0, 0.5],
	[329.63, 0.5], [415.30, 0.5], [493.88, 0.5],
	[523.25, 1.5], [0, 0.5],
	[329.63, 0.5], [659.25, 0.5], [622.25, 0.5], [659.25, 0.5],
	[622.25, 0.5], [659.25, 0.5], [493.88, 0.5], [587.33, 0.5], [523.25, 0.5],
	[440.00, 1.5], [0, 0.5],
	[261.63, 0.5], [329.63, 0.5], [440.00, 0.5],
	[493.88, 1.5], [0, 0.5],
	[329.63, 0.5], [523.25, 0.5], [493.88, 0.5],
	[440.00, 3.0],
];

const BEAT_DURATION = 0.5; // seconds per beat — 垃圾車速

function stopFurElise() {
	furEliseNodes.forEach(({ osc, gain }) => {
		try {
			gain.gain.setTargetAtTime(0, audioCtx.currentTime, 0.02);
			osc.stop(audioCtx.currentTime + 0.1);
		} catch (_) { /* already stopped */ }
	});
	furEliseNodes = [];
	furElisePlaying.value = false;
}

function playFurElise() {
	if (furElisePlaying.value) {
		stopFurElise();
		return;
	}
	audioCtx = audioCtx ?? new (window.AudioContext || window.webkitAudioContext)();
	if (audioCtx.state === "suspended") audioCtx.resume();

	furElisePlaying.value = true;
	let t = audioCtx.currentTime + 0.05;

	FUR_ELISE_NOTES.forEach(([freq, beats]) => {
		const dur = beats * BEAT_DURATION;
		if (freq === 0) { t += dur; return; }

		const osc = audioCtx.createOscillator();
		const gain = audioCtx.createGain();
		osc.connect(gain);
		gain.connect(audioCtx.destination);

		osc.type = "triangle";
		osc.frequency.value = freq;
		gain.gain.setValueAtTime(0, t);
		gain.gain.linearRampToValueAtTime(0.18, t + 0.01);
		gain.gain.setTargetAtTime(0, t + dur * 0.7, 0.04);

		osc.start(t);
		osc.stop(t + dur + 0.1);
		osc.onended = () => {
			furEliseNodes = furEliseNodes.filter(n => n.osc !== osc);
			if (furEliseNodes.length === 0) furElisePlaying.value = false;
		};
		furEliseNodes.push({ osc, gain });
		t += dur;
	});
}
// ─────────────────────────────────────────────────────────────────

const MIN_TIME = 360;   // 06:00 — 最早班次
const MAX_TIME = 1440;  // 第二階段弧線統一在此出現

const sliderMin = MIN_TIME;
const sliderMax = MAX_TIME;

const sliderValue = computed({
	get() {
		return mapStore.arcTimeMinutes ?? MIN_TIME;
	},
	set(v) {
		mapStore.stopArcTimeAnimation();
		mapStore.setArcTimeMinutes(Number(v));
	},
});

function formatTime(minutes) {
	const m = ((minutes % 1440) + 1440) % 1440;
	const h = String(Math.floor(m / 60)).padStart(2, "0");
	const min = String(m % 60).padStart(2, "0");
	return `${h}:${min}`;
}

const displayTime = computed(() =>
	sliderValue.value >= 1440 ? "第二階段" : formatTime(sliderValue.value),
);

function togglePlay() {
	if (mapStore.arcTimeAnimating) {
		mapStore.stopArcTimeAnimation();
	} else {
		mapStore.startArcTimeAnimation();
	}
}

function handleReset() {
	mapStore.resetArcTimeFilter();
}

onUnmounted(() => {
	mapStore.stopArcTimeAnimation();
	stopFurElise();
});
</script>

<template>
  <div class="arc-time-slider">
    <div class="arc-time-slider-header">
      <span class="arc-time-slider-label">收運時間</span>
      <span class="arc-time-slider-range">
        {{ mapStore.arcTimeMinutes === null ? "全部" : displayTime }}
      </span>
      <button
        class="arc-time-slider-btn"
        :title="mapStore.arcTimeMinutes === null ? '已顯示全部' : '重設（顯示全部）'"
        :class="{ active: mapStore.arcTimeMinutes === null }"
        @click="handleReset"
      >
        <span>restart_alt</span>
      </button>
      <button
        class="arc-time-slider-btn"
        :title="mapStore.arcTimeAnimating ? '暫停' : '播放'"
        :class="{ active: mapStore.arcTimeAnimating }"
        @click="togglePlay"
      >
        <span>{{ mapStore.arcTimeAnimating ? "pause" : "play_arrow" }}</span>
      </button>
      <button
        class="arc-time-slider-btn arc-time-slider-btn--music"
        :title="furElisePlaying ? '停止給愛麗絲' : '播放給愛麗絲'"
        :class="{ active: furElisePlaying }"
        @click="playFurElise"
      >
        <span>{{ furElisePlaying ? "music_off" : "music_note" }}</span>
      </button>
    </div>
    <input
      v-model="sliderValue"
      type="range"
      :min="sliderMin"
      :max="sliderMax"
      step="1"
      class="arc-time-slider-input"
    >
  </div>
</template>

<style scoped lang="scss">
.arc-time-slider {
	display: flex;
	flex-direction: column;
	gap: 4px;
	padding: 6px 8px;
	background-color: var(--color-component-background);
	border-radius: 5px;
	min-width: 220px;

	&-header {
		display: flex;
		align-items: center;
		gap: 6px;
	}

	&-label {
		font-size: var(--font-s);
		color: var(--color-complement-text);
		white-space: nowrap;
		flex-shrink: 0;
	}

	&-range {
		font-size: var(--font-s);
		color: var(--color-highlight);
		font-variant-numeric: tabular-nums;
		flex: 1;
		text-align: center;
		white-space: nowrap;
	}

	&-btn {
		display: flex;
		align-items: center;
		justify-content: center;
		width: 1.5rem;
		height: 1.5rem;
		flex-shrink: 0;
		border-radius: 4px;
		background: transparent;
		cursor: pointer;
		color: var(--color-complement-text);
		transition: color 0.15s;

		span {
			font-family: var(--font-icon);
			font-size: 1rem;
		}

		&.active,
		&:hover {
			color: var(--color-highlight);
		}
	}

	&-input {
		width: 100%;
		height: 4px;
		accent-color: var(--color-highlight);
		cursor: pointer;
	}
}
</style>
