/**
 * 雙北清運收運流向：地圖開啟時循環播放（Web Audio，給愛麗絲主題片段）
 * 需在使用者操作後啟動（例如勾選圖層），否則 AudioContext 可能維持 suspended。
 */

const FUR_ELISE_NOTES = [
	[659.25, 0.5], [622.25, 0.5], [659.25, 0.5], [622.25, 0.5],
	[659.25, 0.5], [493.88, 0.5], [587.33, 0.5], [523.25, 0.5],
	[440.0, 1.5], [0, 0.5],
	[261.63, 0.5], [329.63, 0.5], [440.0, 0.5],
	[493.88, 1.5], [0, 0.5],
	[329.63, 0.5], [415.3, 0.5], [493.88, 0.5],
	[523.25, 1.5], [0, 0.5],
	[329.63, 0.5], [659.25, 0.5], [622.25, 0.5], [659.25, 0.5],
	[622.25, 0.5], [659.25, 0.5], [493.88, 0.5], [587.33, 0.5], [523.25, 0.5],
	[440.0, 1.5], [0, 0.5],
	[261.63, 0.5], [329.63, 0.5], [440.0, 0.5],
	[493.88, 1.5], [0, 0.5],
	[329.63, 0.5], [523.25, 0.5], [493.88, 0.5],
	[440.0, 3.0],
];

const BEAT_DURATION = 0.5;

let audioCtx = null;
let activeNodes = [];
let loopTimerId = null;
let running = false;

function stopOscillators() {
	if (!audioCtx) {
		activeNodes = [];
		return;
	}
	activeNodes.forEach(({ osc, gain }) => {
		try {
			gain.gain.setTargetAtTime(0, audioCtx.currentTime, 0.02);
			osc.stop(audioCtx.currentTime + 0.1);
		} catch {
			/* already stopped */
		}
	});
	activeNodes = [];
}

function scheduleOnePass() {
	if (!audioCtx || !running) return;
	stopOscillators();

	const t0 = audioCtx.currentTime + 0.05;
	let t = t0;
	let lastEnd = t0;

	FUR_ELISE_NOTES.forEach(([freq, beats]) => {
		const dur = beats * BEAT_DURATION;
		if (freq === 0) {
			t += dur;
			lastEnd = t;
			return;
		}

		const osc = audioCtx.createOscillator();
		const gain = audioCtx.createGain();
		osc.connect(gain);
		gain.connect(audioCtx.destination);

		osc.type = "triangle";
		osc.frequency.value = freq;
		gain.gain.setValueAtTime(0, t);
		gain.gain.linearRampToValueAtTime(0.14, t + 0.01);
		gain.gain.setTargetAtTime(0, t + dur * 0.7, 0.04);

		osc.start(t);
		osc.stop(t + dur + 0.1);
		const endAt = t + dur + 0.15;
		if (endAt > lastEnd) lastEnd = endAt;

		osc.onended = () => {
			activeNodes = activeNodes.filter((n) => n.osc !== osc);
		};
		activeNodes.push({ osc, gain });
		t += dur;
	});

	const gapSec = 0.35;
	const delayMs = Math.max(0, (lastEnd - audioCtx.currentTime + gapSec) * 1000);
	if (loopTimerId) clearTimeout(loopTimerId);
	loopTimerId = setTimeout(() => {
		loopTimerId = null;
		if (running) scheduleOnePass();
	}, delayMs);
}

/**
 * 開始循環播放（若已在播放則不重複啟動）
 */
export function startGarbageFlowAmbienceLoop() {
	if (running) return;
	running = true;
	audioCtx = audioCtx ?? new (window.AudioContext || window.webkitAudioContext)();
	if (audioCtx.state === "suspended") {
		audioCtx.resume().catch(() => {});
	}
	scheduleOnePass();
}

/**
 * 停止循環並關閉排程
 */
export function stopGarbageFlowAmbience() {
	running = false;
	if (loopTimerId) {
		clearTimeout(loopTimerId);
		loopTimerId = null;
	}
	if (audioCtx) {
		stopOscillators();
	}
}
