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
  "fill-opacity": 1,
  "fill-outline-color": "rgba(255,255,255,0.22)",
  "fill-color": ["interpolate",["linear"],["coalesce",["to-number",["get","recycling_tons"]],0],0,"#ecfdf5",2000,"#d1fae5",4000,"#a7f3d0",6000,"#6ee7b7",8000,"#34d399",10000,"#10b981",12000,"#047857",14000,"#064e3b"]
}$paint150$::json,
 '[{"key":"TNAME","name":"區名"},{"key":"recycling_tons","name":"回收量（公噸）"}]'::json),
(151, 'ntpc_kitchen_waste_map_mvp', '新北廚餘回收量（分區）', 'fill', 'geojson', NULL, NULL,
 $paint151${
  "fill-opacity": 1,
  "fill-outline-color": "rgba(255,255,255,0.22)",
  "fill-color": ["interpolate",["linear"],["coalesce",["to-number",["get","kitchen_tons"]],0],0,"rgba(254,215,170,0.1)",0.16875,"rgba(253,186,116,0.28)",0.3375,"rgba(251,146,60,0.45)",0.50625,"rgba(249,115,22,0.6)",0.675,"rgba(234,88,12,0.74)",0.84375,"rgba(217,119,6,0.84)",1.0125,"rgba(194,65,12,0.88)",1.18125,"rgba(154,52,18,0.9)",1.35,"rgba(67,20,7,0.92)"]
}$paint151$::json,
 '[{"key":"TNAME","name":"區名"},{"key":"kitchen_tons","name":"廚餘回收量（公噸）"}]'::json);

INSERT INTO components (id, index, name) VALUES
(300, 'ntpc_recycling_map_mvp', '回收地圖'),
(301, 'ntpc_kitchen_waste_map_mvp', '廚餘地圖');

INSERT INTO component_charts (index, color, types, unit) VALUES
('ntpc_recycling_map_mvp', '{#ecfdf5,#d1fae5,#a7f3d0,#6ee7b7,#34d399,#10b981,#047857,#064e3b}', '{TreemapChart,ColumnChart}', '公噸'),
('ntpc_kitchen_waste_map_mvp', '{#fffbeb,#fef3c7,#fde68a,#fcd34d,#f59e0b,#d97706,#92400e,#451a03}', '{TreemapChart,ColumnChart}', '公噸');

INSERT INTO query_charts (
  index, history_config, map_config_ids, map_filter, time_from, time_to,
  update_freq, update_freq_unit, source, short_desc, long_desc, use_case,
  links, contributors, created_at, updated_at, query_type, query_chart, query_history, city
) VALUES
(
  'ntpc_recycling_map_mvp',
  '{"range":["year_ago","halfyear_ago"],"color":["#22c55e","#4ade80"],"unit":"公噸"}'::json,
  ARRAY[150]::integer[],
  '{"mode":"byParam","byParam":{"xParam":"TNAME"}}'::json,
  'static', NULL, 0, NULL,
  '新北市政府開放資料（整理）',
  '新北市各行政區資源回收量（區小計／總計），單位：公噸（由公斤換算）。資料期別：中華民國115年3月。',
  'MVP 為單月快照；臺北市區域於圖資上無數值（0）。歷史圖為全市各月加總（dashboard.ntpc_waste_mvp_monthly）。',
  '用於觀察各區資源回收量與空間分布。',
  ARRAY[]::text[], ARRAY['ntpc']::text[], NOW(), NOW(), 'three_d',
  $q$SELECT district AS x_axis,
       '資源回收量(公噸)' AS y_axis,
       ''::text AS icon,
       ROUND((recycling_kg::numeric / 1000.0), 2)::double precision AS data
FROM public.ntpc_waste_mvp
ORDER BY 1$q$,
  $hist300$
SELECT
  date_trunc('%s', report_month::timestamp) AS x_axis,
  '資源回收量(公噸)' AS y_axis,
  SUM(recycling_tons)::double precision AS data
FROM public.ntpc_waste_mvp_monthly
WHERE report_month >= (('%s'::timestamptz) AT TIME ZONE 'Asia/Taipei')::date
  AND report_month <= (('%s'::timestamptz) AT TIME ZONE 'Asia/Taipei')::date
GROUP BY 1
ORDER BY 1
$hist300$,
  'metrotaipei'
),
(
  'ntpc_kitchen_waste_map_mvp',
  '{"range":["year_ago","halfyear_ago"],"color":["#fbbf24","#f59e0b"],"unit":"公噸"}'::json,
  ARRAY[151]::integer[],
  '{"mode":"byParam","byParam":{"xParam":"TNAME"}}'::json,
  'static', NULL, 0, NULL,
  '新北市政府開放資料（整理）',
  '新北市各行政區廚餘回收量，單位：公噸（由原月報公噸換算後以整數公噸呈現）。資料期別：中華民國115年2月。',
  'MVP 為單月快照；烏來區原表缺值時為 0。歷史圖為全市各月加總（dashboard.ntpc_waste_mvp_monthly）。',
  '用於觀察各區廚餘回收量與空間分布。',
  ARRAY[]::text[], ARRAY['ntpc']::text[], NOW(), NOW(), 'three_d',
  $q$SELECT district AS x_axis,
       '廚餘回收量(公噸)' AS y_axis,
       ''::text AS icon,
       ROUND((kitchen_kg::numeric / 1000.0), 2)::double precision AS data
FROM public.ntpc_waste_mvp
ORDER BY 1$q$,
  $hist301$
SELECT
  date_trunc('%s', report_month::timestamp) AS x_axis,
  '廚餘回收量(公噸)' AS y_axis,
  SUM(kitchen_tons)::double precision AS data
FROM public.ntpc_waste_mvp_monthly
WHERE report_month >= (('%s'::timestamptz) AT TIME ZONE 'Asia/Taipei')::date
  AND report_month <= (('%s'::timestamptz) AT TIME ZONE 'Asia/Taipei')::date
GROUP BY 1
ORDER BY 1
$hist301$,
  'metrotaipei'
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
