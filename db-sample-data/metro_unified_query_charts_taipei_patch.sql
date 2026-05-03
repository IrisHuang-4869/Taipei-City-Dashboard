-- 補上 query_charts.city = 'taipei'，避免垃圾地圖切「臺北」時 GET /component/:id/chart?city=taipei 為 404。
-- 含：metro_recycling（303）、metro_kitchen（301）、garbage_district_compare_local（416）。
-- 統一回收 patch 後，garbage_map_city_toggle_patch.sql 從 ntpc_recycling_* 複製的 taipei 列不會再產生列，需另行補此檔。
-- 套用：
--   PGPASSWORD=... psql -h ... -U ... -d dashboardmanager -v ON_ERROR_STOP=1 -f db-sample-data/metro_unified_query_charts_taipei_patch.sql

BEGIN;

DELETE FROM query_charts
WHERE city = 'taipei'
  AND index IN (
    'metro_recycling_map_mvp',
    'metro_kitchen_waste_map_mvp',
    'garbage_district_compare_local',
    'garbage_ntpc_gold_district_local'
  );

-- ── 303 資源回收統計：臺北市（資料僅來自 public.tpc_recycling_mvp／tpc_recycling_monthly）
INSERT INTO query_charts (
  index, history_config, map_config_ids, map_filter, time_from, time_to,
  update_freq, update_freq_unit, source, short_desc, long_desc, use_case,
  links, contributors, created_at, updated_at, query_type, query_chart, query_history, city
)
SELECT
  qc.index,
  qc.history_config,
  qc.map_config_ids,
  qc.map_filter,
  qc.time_from,
  qc.time_to,
  qc.update_freq,
  qc.update_freq_unit,
  qc.source,
  qc.short_desc,
  qc.long_desc,
  qc.use_case,
  qc.links,
  qc.contributors,
  NOW(),
  NOW(),
  qc.query_type,
  $metro_rec_chart_taipei$
WITH pop_data(district, pop) AS (
  VALUES
  ('松山區', 189917),('信義區', 203780),('大安區', 276785),('中山區', 212959),('中正區', 148011),
  ('大同區', 118933),('萬華區', 173041),('文山區', 257551),('南港區', 112750),('內湖區', 273398),
  ('士林區', 262973),('北投區', 241551),('板橋區', 554160),('三重區', 383617),('中和區', 403982),
  ('永和區', 212456),('新莊區', 423668),('新店區', 304728),('樹林區', 180121),('鶯歌區', 88410),
  ('三峽區', 115274),('淡水區', 196236),('汐止區', 209673),('瑞芳區', 37424),('土城區', 238814),
  ('蘆洲區', 200055),('五股區', 91439),('泰山區', 77320),('林口區', 133748),('深坑區', 23528),
  ('石碇區', 7230),('坪林區', 6540),('三芝區', 22204),('石門區', 10960),('八里區', 41302),
  ('平溪區', 4216),('雙溪區', 8102),('貢寮區', 11100),('金山區', 20500),('萬里區', 21100),('烏來區', 6285)
),
recycling_data AS (
   SELECT district, recycling_kg FROM public.tpc_recycling_mvp
)
SELECT r.district AS x_axis,
       '人均資源回收量 (公斤)' AS y_axis,
       ROUND((r.recycling_kg::numeric / p.pop), 2)::double precision AS data
FROM recycling_data r JOIN pop_data p ON r.district = p.district
UNION ALL
SELECT r.district AS x_axis,
       '總資源回收量 (公噸)' AS y_axis,
       ROUND((r.recycling_kg::numeric / 1000.0), 2)::double precision AS data
FROM recycling_data r JOIN pop_data p ON r.district = p.district
ORDER BY x_axis
$metro_rec_chart_taipei$,
  $metro_rec_hist_taipei$
SELECT
  date_trunc('%s', report_month::timestamp) AS x_axis,
  '資源回收量(公噸)' AS y_axis,
  SUM(recycling_tons)::double precision AS data
FROM public.tpc_recycling_monthly
WHERE report_month >= (('%s'::timestamptz) AT TIME ZONE 'Asia/Taipei')::date
  AND report_month <= (('%s'::timestamptz) AT TIME ZONE 'Asia/Taipei')::date
GROUP BY 1
ORDER BY 1
$metro_rec_hist_taipei$,
  'taipei'
FROM query_charts qc
WHERE qc.index = 'metro_recycling_map_mvp' AND qc.city = 'metrotaipei'
LIMIT 1;

-- ── 301 廚餘（雙北統一）：臺北市視圖（僅 public.tpc_kitchen_mvp／tpc_kitchen_monthly）
INSERT INTO query_charts (
  index, history_config, map_config_ids, map_filter, time_from, time_to,
  update_freq, update_freq_unit, source, short_desc, long_desc, use_case,
  links, contributors, created_at, updated_at, query_type, query_chart, query_history, city
)
SELECT
  qc.index,
  qc.history_config,
  qc.map_config_ids,
  qc.map_filter,
  qc.time_from,
  qc.time_to,
  qc.update_freq,
  qc.update_freq_unit,
  qc.source,
  qc.short_desc,
  qc.long_desc,
  qc.use_case,
  qc.links,
  qc.contributors,
  NOW(),
  NOW(),
  qc.query_type,
  $metro_kit_chart_taipei$
WITH pop_data(district, pop) AS (
  VALUES
  ('松山區', 189917),('信義區', 203780),('大安區', 276785),('中山區', 212959),('中正區', 148011),
  ('大同區', 118933),('萬華區', 173041),('文山區', 257551),('南港區', 112750),('內湖區', 273398),
  ('士林區', 262973),('北投區', 241551),('板橋區', 554160),('三重區', 383617),('中和區', 403982),
  ('永和區', 212456),('新莊區', 423668),('新店區', 304728),('樹林區', 180121),('鶯歌區', 88410),
  ('三峽區', 115274),('淡水區', 196236),('汐止區', 209673),('瑞芳區', 37424),('土城區', 238814),
  ('蘆洲區', 200055),('五股區', 91439),('泰山區', 77320),('林口區', 133748),('深坑區', 23528),
  ('石碇區', 7230),('坪林區', 6540),('三芝區', 22204),('石門區', 10960),('八里區', 41302),
  ('平溪區', 4216),('雙溪區', 8102),('貢寮區', 11100),('金山區', 20500),('萬里區', 21100),('烏來區', 6285)
),
kitchen_data AS (
   SELECT district, kitchen_kg FROM public.tpc_kitchen_mvp
)
SELECT k.district AS x_axis,
       '人均廚餘回收量 (公斤)' AS y_axis,
       ROUND((k.kitchen_kg::numeric / p.pop), 2)::double precision AS data
FROM kitchen_data k JOIN pop_data p ON k.district = p.district
UNION ALL
SELECT k.district AS x_axis,
       '總廚餘回收量 (公噸)' AS y_axis,
       ROUND((k.kitchen_kg::numeric / 1000.0), 2)::double precision AS data
FROM kitchen_data k JOIN pop_data p ON k.district = p.district
ORDER BY x_axis
$metro_kit_chart_taipei$,
  $metro_kit_hist_taipei$
SELECT
  date_trunc('%s', report_month::timestamp) AS x_axis,
  '廚餘回收量(公噸)' AS y_axis,
  SUM(kitchen_tons)::double precision AS data
FROM public.tpc_kitchen_monthly
WHERE report_month >= (('%s'::timestamptz) AT TIME ZONE 'Asia/Taipei')::date
  AND report_month <= (('%s'::timestamptz) AT TIME ZONE 'Asia/Taipei')::date
GROUP BY 1
ORDER BY 1
$metro_kit_hist_taipei$,
  'taipei'
FROM query_charts qc
WHERE qc.index = 'metro_kitchen_waste_map_mvp' AND qc.city = 'metrotaipei'
LIMIT 1;

-- ── 416 雙北清運收運流向：臺北市（僅臺北 12 區站數；地圖僅啟用臺北弧線圖層 321）
INSERT INTO query_charts (
  index, history_config, map_config_ids, map_filter, time_from, time_to,
  update_freq, update_freq_unit, source, short_desc, long_desc, use_case,
  links, contributors, created_at, updated_at, query_type, query_chart, query_history, city
)
SELECT
  qc.index,
  qc.history_config,
  ARRAY[321]::integer[] AS map_config_ids,
  qc.map_filter,
  qc.time_from,
  qc.time_to,
  qc.update_freq,
  qc.update_freq_unit,
  qc.source,
  qc.short_desc,
  qc.long_desc,
  qc.use_case,
  qc.links,
  qc.contributors,
  NOW(),
  NOW(),
  qc.query_type,
  $garbage_flow_chart_taipei$
SELECT dist AS x_axis, '臺北市清運站數量（行政區）' AS y_axis, '' AS icon, count::double precision AS data
FROM (VALUES
  ('北投區',544),('士林區',653),('內湖區',200),('南港區',211),('松山區',106),
  ('信義區',168),('中山區',338),('大同區',251),('中正區',347),('萬華區',303),
  ('大安區',310),('文山區',581)
) AS t(dist, count)
ORDER BY 1
$garbage_flow_chart_taipei$,
  qc.query_history,
  'taipei'
FROM query_charts qc
WHERE qc.index = 'garbage_district_compare_local' AND qc.city = 'metrotaipei'
LIMIT 1;

COMMIT;
