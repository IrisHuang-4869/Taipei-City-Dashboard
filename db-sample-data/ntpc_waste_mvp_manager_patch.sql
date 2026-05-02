-- 新北垃圾／回收 MVP：Dashboard Manager 增量（請勿整包重跑含 TRUNCATE 的 demo）
-- 固定 id：component_maps 150–151、components 300–301；併入儀表板 index = garbage_map_metrotaipei（不再建立獨立 id 400）
-- 「僅 psql -f dashboardmanager-demo.sql」還原则已內含 300/301 與對應圖資列；若手動刪過或舊 DB 無此行，請再跑本檔。
-- 套用：psql -h ... -U ... -d <manager_db> -v ON_ERROR_STOP=1 -f db-sample-data/ntpc_waste_mvp_manager_patch.sql
-- 前置（順序）：
--   1) import_ntpc_waste_mvp_data.sql（建立 public.ntpc_waste_mvp 與示範列）
--   2) FE 已部署 public/mapData/ntpc_recycling_map_mvp.geojson 與 ntpc_kitchen_waste_map_mvp.geojson

BEGIN;

DELETE FROM public.dashboard_groups dg
USING public.dashboards d
WHERE d.id = dg.dashboard_id AND d.index = 'ntpc_waste_maps_mvp';
DELETE FROM public.dashboards WHERE id = 400 OR index = 'ntpc_waste_maps_mvp';
DELETE FROM query_charts
  WHERE index IN ('ntpc_recycling_map_mvp', 'ntpc_kitchen_waste_map_mvp') AND city = 'metrotaipei';
DELETE FROM component_charts WHERE index IN ('ntpc_recycling_map_mvp', 'ntpc_kitchen_waste_map_mvp');
DELETE FROM components WHERE id IN (300, 301) OR index IN ('ntpc_recycling_map_mvp', 'ntpc_kitchen_waste_map_mvp');
DELETE FROM component_maps WHERE id IN (150, 151);

INSERT INTO component_maps (id, index, title, type, source, size, icon, paint, property) VALUES
(150, 'ntpc_recycling_map_mvp', '新北資源回收量（分區）', 'fill', 'geojson', NULL, NULL,
 $paint150${
  "fill-opacity": 0.85,
  "fill-outline-color": "rgba(255,255,255,0.26)",
  "fill-color": ["interpolate",["linear"],["coalesce",["to-number",["get","recycling_tons"]],0],0,"#356b52",3500,"#4c8569",7000,"#63a082",10500,"#7ab99a",14000,"#9fe0c0"]
}$paint150$::json,
 '[{"key":"TNAME","name":"區名"},{"key":"recycling_tons","name":"回收量（公噸）"}]'::json),
(151, 'ntpc_kitchen_waste_map_mvp', '新北廚餘回收量（分區）', 'fill', 'geojson', NULL, NULL,
 $paint151${
  "fill-opacity": 0.85,
  "fill-outline-color": "rgba(255,255,255,0.26)",
  "fill-color": ["interpolate",["linear"],["coalesce",["to-number",["get","kitchen_tons"]],0],0,"#6e5a42",140,"#8c7358",320,"#aa8c6f",520,"#c6a686",780,"#e8d2b8"]
}$paint151$::json,
 '[{"key":"TNAME","name":"區名"},{"key":"kitchen_tons","name":"廚餘回收量（公噸）"}]'::json);

INSERT INTO components (id, index, name) VALUES
(300, 'ntpc_recycling_map_mvp', '回收地圖'),
(301, 'ntpc_kitchen_waste_map_mvp', '垃圾地圖');

INSERT INTO component_charts (index, color, types, unit) VALUES
('ntpc_recycling_map_mvp', '{#22c55e,#4ade80,#15803d,#14532d}', '{TreemapChart,ColumnChart}', '公噸'),
('ntpc_kitchen_waste_map_mvp', '{#fbbf24,#f59e0b,#d97706,#78350f}', '{TreemapChart,ColumnChart}', '公噸');

INSERT INTO query_charts (
  index, history_config, map_config_ids, map_filter, time_from, time_to,
  update_freq, update_freq_unit, source, short_desc, long_desc, use_case,
  links, contributors, created_at, updated_at, query_type, query_chart, query_history, city
) VALUES
(
  'ntpc_recycling_map_mvp', NULL, ARRAY[150]::integer[],
  '{"mode":"byParam","byParam":{"xParam":"TNAME"}}'::json,
  'static', NULL, 0, NULL,
  '新北市政府開放資料（整理）',
  '新北市各行政區資源回收量（區小計／總計），單位：公噸（由公斤換算）。資料期別：中華民國115年3月。',
  'MVP 為單月快照；臺北市區域於圖資上無數值（0）。之後可擴充多月與時間序列組件（history_config / query_history）。',
  '用於觀察各區資源回收量與空間分布。',
  ARRAY[]::text[], ARRAY['ntpc']::text[], NOW(), NOW(), 'three_d',
  $q$SELECT district AS x_axis,
       '資源回收量(公噸)' AS y_axis,
       ''::text AS icon,
       round(recycling_kg::numeric / 1000)::int AS data
FROM public.ntpc_waste_mvp
ORDER BY 1$q$,
  NULL, 'metrotaipei'
),
(
  'ntpc_kitchen_waste_map_mvp', NULL, ARRAY[151]::integer[],
  '{"mode":"byParam","byParam":{"xParam":"TNAME"}}'::json,
  'static', NULL, 0, NULL,
  '新北市政府開放資料（整理）',
  '新北市各行政區廚餘回收量，單位：公噸（由原月報公噸換算後以整數公噸呈現）。資料期別：中華民國115年2月。',
  'MVP 為單月快照；烏來區原表缺值時為 0。之後可擴充歷史月並改用 time 類型查詢。',
  '用於觀察各區廚餘回收量與空間分布。',
  ARRAY[]::text[], ARRAY['ntpc']::text[], NOW(), NOW(), 'three_d',
  $q$SELECT district AS x_axis,
       '廚餘回收量(公噸)' AS y_axis,
       ''::text AS icon,
       round(kitchen_kg::numeric / 1000)::int AS data
FROM public.ntpc_waste_mvp
ORDER BY 1$q$,
  NULL, 'metrotaipei'
);

UPDATE public.dashboards
SET
  components = CASE
    WHEN NOT (300 = ANY(components)) AND NOT (301 = ANY(components))
      THEN components || ARRAY[300, 301]::integer[]
    WHEN NOT (300 = ANY(components))
      THEN components || ARRAY[300]::integer[]
    WHEN NOT (301 = ANY(components))
      THEN components || ARRAY[301]::integer[]
    ELSE components
  END,
  updated_at = NOW()
WHERE index = 'garbage_map_metrotaipei';

COMMIT;

-- 若之後以 UI 新增組件出現 id 衝突，可手動將序列調高：
-- SELECT setval(pg_get_serial_sequence('public.components','id'), (SELECT MAX(id) FROM public.components));
