-- +goose NO TRANSACTION
-- source: db-sample-data/metro_kitchen_unified_manager_patch.sql

-- +goose Up
SET search_path TO public;

-- 雙北「廚餘地圖」：合併新北（原 301/151）與臺北 tpc_kitchen；填色約 0–1.35 公噸，低量為琥珀半透明（淡）、高量加深（與 ntpc_waste_mvp_map_paint_transparency 廚餘段一致）。
-- 前置：
--   1) dashboard 已建立 ntpc_waste_mvp / ntpc_waste_mvp_monthly
--   2) 已執行 db-sample-data/generated/import_tpc_kitchen_from_pdf.sql（cd scripts && node build_tpc_kitchen_sql.mjs [--placeholder]）
--   3) FE 已部署 public/mapData/metro_kitchen_waste_map_mvp.geojson（node build_metro_kitchen_geojson.mjs）
-- 套用：psql -h ... -U ... -d <manager_db> -v ON_ERROR_STOP=1 -f db-sample-data/metro_kitchen_unified_manager_patch.sql

BEGIN;

DELETE FROM query_charts
WHERE index IN ('ntpc_kitchen_waste_map_mvp', 'metro_kitchen_waste_map_mvp')
  AND city = 'metrotaipei';
DELETE FROM component_charts
WHERE index IN ('ntpc_kitchen_waste_map_mvp', 'metro_kitchen_waste_map_mvp');
DELETE FROM component_maps
WHERE id IN (151, 154)
   OR index IN ('ntpc_kitchen_waste_map_mvp', 'metro_kitchen_waste_map_mvp');

UPDATE public.components
SET
  index = 'metro_kitchen_waste_map_mvp',
  name = '廚餘回收量統計'
WHERE id = 301;

INSERT INTO component_maps (id, index, title, type, source, size, icon, paint, property) VALUES
(154, 'metro_kitchen_waste_map_mvp', '廚餘回收量（雙北）', 'fill', 'geojson', NULL, NULL,
 $paint154${
  "fill-opacity": 1,
  "fill-outline-color": "rgba(255,255,255,0.22)",
  "fill-color": ["interpolate",["linear"],["coalesce",["to-number",["get","kitchen_tons"]],0],0,"rgba(254,215,170,0.1)",0.16875,"rgba(253,186,116,0.28)",0.3375,"rgba(251,146,60,0.45)",0.50625,"rgba(249,115,22,0.6)",0.675,"rgba(234,88,12,0.74)",0.84375,"rgba(217,119,6,0.84)",1.0125,"rgba(194,65,12,0.88)",1.18125,"rgba(154,52,18,0.9)",1.35,"rgba(67,20,7,0.92)"]
}$paint154$::json,
 '[{"key":"TNAME","name":"區名"},{"key":"COUNTY","name":"縣市"},{"key":"kitchen_tons","name":"廚餘回收量（公噸）"}]'::json);

INSERT INTO component_charts (index, color, types, unit) VALUES
('metro_kitchen_waste_map_mvp', '{#fffbeb,#fef3c7,#fde68a,#fcd34d,#f59e0b,#d97706,#92400e,#451a03}', '{TreemapChart,ColumnChart}', '公噸');

INSERT INTO query_charts (
  index, history_config, map_config_ids, map_filter, time_from, time_to,
  update_freq, update_freq_unit, source, short_desc, long_desc, use_case,
  links, contributors, created_at, updated_at, query_type, query_chart, query_history, city
) VALUES
(
  'metro_kitchen_waste_map_mvp',
  '{"range":["year_ago","halfyear_ago"],"color":["#fbbf24","#f59e0b"],"unit":"公噸"}'::json,
  ARRAY[154]::integer[],
  '{"mode":"byParam","byParam":{"xParam":"TNAME"}}'::json,
  'static', NULL, 0, NULL,
  '臺北市環保局統計表、新北市月報（整理）',
  '臺北市、新北市各行政區廚餘回收量（清潔隊／環保單位口徑），單位：公噸。圖資為雙北合併；歷史圖為兩市各區該月加總後再依月加總。',
  '單月快照：合併 ntpc_waste_mvp 與 tpc_kitchen_mvp 最近月；歷史圖合併 ntpc_waste_mvp_monthly 與 tpc_kitchen_monthly。',
  '以與原廚餘圖相同的矩形圖、長條圖、地圖呈現雙北廚餘。',
  ARRAY[]::text[], ARRAY['doit','ntpc','tpc']::text[], NOW(), NOW(), 'three_d',
  $q$SELECT district AS x_axis,
       '廚餘回收量(公噸)' AS y_axis,
       ''::text AS icon,
       ROUND((kitchen_kg::numeric / 1000.0), 2)::double precision AS data
FROM (
  SELECT district, kitchen_kg FROM public.ntpc_waste_mvp
  UNION ALL
  SELECT district, kitchen_kg FROM public.tpc_kitchen_mvp
) AS u
ORDER BY 1$q$,
  $histmetro$
SELECT
  date_trunc('%s', report_month::timestamp) AS x_axis,
  '廚餘回收量(公噸)' AS y_axis,
  SUM(kitchen_tons)::double precision AS data
FROM (
  SELECT report_month, kitchen_tons FROM public.ntpc_waste_mvp_monthly
  UNION ALL
  SELECT report_month, kitchen_tons FROM public.tpc_kitchen_monthly
) AS u
WHERE report_month >= (('%s'::timestamptz) AT TIME ZONE 'Asia/Taipei')::date
  AND report_month <= (('%s'::timestamptz) AT TIME ZONE 'Asia/Taipei')::date
GROUP BY 1
ORDER BY 1
$histmetro$,
  'metrotaipei'
);

UPDATE public.dashboards
SET updated_at = NOW()
WHERE index = 'garbage_map_metrotaipei';

COMMIT;

-- +goose Down
-- TODO: 視需要填寫回滾 SQL
