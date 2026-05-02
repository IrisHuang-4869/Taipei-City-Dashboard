
<script setup>
import { computed } from "vue";

const props = defineProps([
	"chart_config",
	"activeChart",
	"series",
	"map_config",
	"map_filter",
	"map_filter_on",
]);

const isSingleMetric = computed(() => (props.series?.length ?? 0) === 1);

// const emits = defineEmits([
// 	"filterByParam",
// 	"filterByLayer",
// 	"clearByParamFilter",
// 	"clearByLayerFilter",
// 	"fly"
// ]);
</script>

<template>
  <div
    v-if="activeChart === 'TextUnitChart'"
    class="TextUnitChart"
    :class="{ 'TextUnitChart--single': isSingleMetric }"
  >
    <div
      class="TextUnitChart__container"
      :class="{ 'TextUnitChart__container--single': isSingleMetric }"
    >
      <div
        v-for="item in series"
        :key="item.name"
        class="TextUnitChart__content"
        :class="{ 'TextUnitChart__content--single': isSingleMetric }"
      >
        <div
          class="TextUnitChart__name"
          :style="{ color: props.chart_config.color[0] }"
        >
          {{ item.name }}
        </div>
        <div>
          <span
            class="TextUnitChart__value"
            :style="{ color: props.chart_config.color[1] }"
          >{{ item.data[0] }}</span>
          <span
            class="TextUnitChart__unit"
            :style="{ color: props.chart_config.color[2] }"
          >{{ item.icon }}</span>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped lang="scss">
.TextUnitChart {
	position: relative;
	max-height: 100%;
	height: 100%;
	flex: 1;
	color: var(--color-normal-text);
	overflow-y: auto;

	// 單一指標：在卡片可視區域內垂直＋水平置中
	&--single {
		display: flex;
		flex-direction: column;
		justify-content: center;
		align-items: center;
		min-height: 0;
	}

	&__container {
		display: grid;
		grid-template-columns: 1fr 1fr;
		min-height: 100%;

		// 僅一筆指標時：單欄、置中、版面較緊湊（避免右側空白欄）
		&--single {
			grid-template-columns: 1fr;
			justify-items: center;
			align-content: center;
			max-width: 12rem;
			width: 100%;
			flex-shrink: 0;
			min-height: auto;
		}
	}
	&__content {
		display: flex;
		flex-direction: column;
		align-items: center;
		justify-content: center;
		padding: 1rem;
		border-bottom: 1px solid var(--color-border);
		width: 100%;
		box-sizing: border-box;

		&--single {
			padding: 0.5rem 0.75rem;
			border-bottom: none;
			border-right: none;
			text-align: center;
		}

		// 右邊框（不包括每行最後一個）
		&:not(:nth-child(2n)) {
			border-right: 1px solid var(--color-border);
		}

		// 單欄模式不畫直向分隔
		.TextUnitChart__container--single &:not(:nth-child(2n)) {
			border-right: none;
		}
    
		// 移除最後一個項目的底部邊框
		&:last-child {
			border-bottom: none;
		}
    
		// 倒數第二個如果在右邊（偶數位置），移除底部邊框
		&:nth-last-child(2):nth-child(2n-1) {
			border-bottom: none;
		}
	}
	&__value {
		font-size: 1.5rem;
		padding-right: 0.25rem;
	}
}
</style>
