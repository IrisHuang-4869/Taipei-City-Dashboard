-- 雙北「資源回收統計」：合併原新北回收（300/150）與臺北回收（302/152）為單一組件（303/153）
-- 廚餘地圖另見 metro_kitchen_unified_manager_patch.sql（雙北合併與填色量級修正）。
-- 前置：
--   1) dashboard 已有 ntpc_waste_mvp、tpc_recycling_mvp 及月表（與先前 import 相同）
--   2) FE 已有 public/mapData/metro_recycling_map_mvp.geojson（cd scripts && node build_metro_recycling_geojson.mjs）
-- 套用：psql -h ... -U ... -d <manager_db> -v ON_ERROR_STOP=1 -f db-sample-data/metro_recycling_unified_manager_patch.sql

BEGIN;

DELETE FROM query_charts
WHERE index IN ('ntpc_recycling_map_mvp', 'tpc_recycling_map_mvp', 'metro_recycling_map_mvp')
  AND city = 'metrotaipei';
DELETE FROM component_charts
WHERE index IN ('ntpc_recycling_map_mvp', 'tpc_recycling_map_mvp', 'metro_recycling_map_mvp');
DELETE FROM components
WHERE id IN (300, 302, 303)
   OR index IN ('ntpc_recycling_map_mvp', 'tpc_recycling_map_mvp', 'metro_recycling_map_mvp');
DELETE FROM component_maps
WHERE id IN (150, 152, 153)
   OR index IN ('ntpc_recycling_map_mvp', 'tpc_recycling_map_mvp', 'metro_recycling_map_mvp');

INSERT INTO component_maps (id, index, title, type, source, size, icon, paint, property) VALUES
(153, 'metro_recycling_map_mvp', '資源回收統計', 'fill', 'geojson', NULL, NULL,
 $paint153${
  "fill-opacity": 1,
  "fill-outline-color": "rgba(255,255,255,0.22)",
  "fill-color": ["interpolate",["linear"],["coalesce",["to-number",["get","recycling_tons"]],0],0,"rgba(236,253,245,0.1)",275,"rgba(209,250,229,0.28)",550,"rgba(167,243,208,0.45)",825,"rgba(110,231,183,0.6)",1100,"rgba(52,211,153,0.74)",1375,"rgba(16,185,129,0.84)",1650,"rgba(16,185,129,0.88)",1925,"rgba(5,150,105,0.9)",2200,"rgba(5,150,105,0.92)"]
}$paint153$::json,
 '[{"key":"TNAME","name":"區名"},{"key":"COUNTY","name":"縣市"},{"key":"recycling_tons","name":"回收量（公噸）"}]'::json);

INSERT INTO components (id, index, name) VALUES
(303, 'metro_recycling_map_mvp', '資源回收統計');

INSERT INTO component_charts (index, color, types, unit) VALUES
('metro_recycling_map_mvp', '{#ecfdf5,#d1fae5,#a7f3d0,#6ee7b7,#34d399,#10b981,#047857,#064e3b}', '{TreemapChart,ColumnChart}', '公噸');

INSERT INTO query_charts (
  index, history_config, map_config_ids, map_filter, time_from, time_to,
  update_freq, update_freq_unit, source, short_desc, long_desc, use_case,
  links, contributors, created_at, updated_at, query_type, query_chart, query_history, city
) VALUES
(
  'metro_recycling_map_mvp',
  '{"range":["year_ago","halfyear_ago"],"color":["#22c55e","#4ade80"],"unit":"公噸"}'::json,
  ARRAY[153]::integer[],
  '{"mode":"byParam","byParam":{"xParam":"TNAME"}}'::json,
  'static', NULL, 0, NULL,
  '臺北市環保局 PDF、新北市月報（整理）',
  '臺北市、新北市各行政區資源回收量（清潔隊／環保單位口徑），單位：公噸。圖資為雙北合併；歷史圖為兩市各區該月加總後再依月加總。',
  '單月快照：合併 ntpc_waste_mvp 與 tpc_recycling_mvp 最近月；歷史圖合併 ntpc_waste_mvp_monthly 與 tpc_recycling_monthly。',
  '以與原回收／廚餘圖相同的矩形圖、長條圖、地圖呈現雙北資源回收。',
  ARRAY['https://data.gov.tw/dataset/163144','https://data.taipei/dataset/detail?id=34f4f00b-5386-43ab-bcc7-b0ae7ee3e305','https://oas.bas.ntpc.gov.tw/NTPCTRWD/NewPage/Publish.aspx?Mid1=382150000I&p=2&y=2025/12/25&s=10']::text[], ARRAY['doit','ntpc','tpc']::text[], NOW(), NOW(), 'three_d',
  $q$SELECT district AS x_axis,
       '資源回收量(公噸)' AS y_axis,
       ''::text AS icon,
       ROUND((recycling_kg::numeric / 1000.0), 2)::double precision AS data
FROM (
  SELECT district, recycling_kg FROM public.ntpc_waste_mvp
  UNION ALL
  SELECT district, recycling_kg FROM public.tpc_recycling_mvp
) AS u
ORDER BY 1$q$,
  $histmetro$
SELECT
  date_trunc('%s', report_month::timestamp) AS x_axis,
  '資源回收量(公噸)' AS y_axis,
  SUM(recycling_tons)::double precision AS data
FROM (
  SELECT report_month, recycling_tons FROM public.ntpc_waste_mvp_monthly
  UNION ALL
  SELECT report_month, recycling_tons FROM public.tpc_recycling_monthly
) AS u
WHERE report_month >= (('%s'::timestamptz) AT TIME ZONE 'Asia/Taipei')::date
  AND report_month <= (('%s'::timestamptz) AT TIME ZONE 'Asia/Taipei')::date
GROUP BY 1
ORDER BY 1
$histmetro$,
  'metrotaipei'
);

UPDATE public.dashboards
SET
  components = array_cat(
    array_remove(array_remove(components, 300), 302),
    CASE
      WHEN 303 = ANY(components) THEN ARRAY[]::integer[]
      ELSE ARRAY[303]::integer[]
    END
  ),
  updated_at = NOW()
WHERE index = 'garbage_map_metrotaipei';

COMMIT;
