-- 僅更新圖表類型與色票（不重刪儀表板／組件）
-- psql ... -f db-sample-data/ntpc_waste_mvp_chart_types_hotfix.sql

UPDATE public.component_charts
SET
  color = '{#22c55e,#4ade80,#15803d,#14532d}',
  types = '{TreemapChart,ColumnChart}'
WHERE index = 'ntpc_recycling_map_mvp';

UPDATE public.component_charts
SET
  color = '{#fbbf24,#f59e0b,#d97706,#78350f}',
  types = '{TreemapChart,ColumnChart}'
WHERE index = 'ntpc_kitchen_waste_map_mvp';
