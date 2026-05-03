-- +goose NO TRANSACTION
-- source: db-sample-data/unify_local_garbage_to_db.sql

-- +goose Up
SET search_path TO public;

-- 將前端 localGarbageLayers.js 的兩個本地組件統一進資料庫。
-- 可重複執行。
-- 執行順序：需在 sync_dual_taipei_garbage.sql 之後。

BEGIN;

-- 1. component_maps：新增弧線圖層與黃金資收站圖層
DELETE FROM component_maps WHERE id IN (320, 321, 322)
   OR index IN ('garbage_ntpc_route_arcs_local', 'garbage_taipei_truck_arcs_local', 'garbage_ntpc_gold_local');

INSERT INTO component_maps (id, index, title, type, source, size, icon, paint, property) VALUES
(320, 'garbage_ntpc_route_arcs_local', '收運流向（新北）', 'arc', 'geojson', 'big', NULL,
 '{"arc-color":["#4e79a7","#a8c8e8"],"arc-width":2,"arc-opacity":0.38}'::json,
 '[{"key":"dist","name":"行政區"},{"key":"vil","name":"里別"},{"key":"point_name","name":"清運點名稱"},{"key":"route_name","name":"路線名稱"},{"key":"schedule_summary","name":"表定時間"},{"key":"flow_target","name":"弧線終點"},{"key":"hub_source","name":"終點來源"},{"key":"hub_table_address","name":"集中點登記地址"}]'::json),
(321, 'garbage_taipei_truck_local', '收運流向（台北）', 'arc', 'geojson', 'big', NULL,
 '{"arc-color":["#fd7900","#47d3d9"],"arc-width":2.2,"arc-opacity":0.42}'::json,
 '[{"key":"dist","name":"行政區"},{"key":"vil","name":"里別"},{"key":"brigade","name":"清潔隊分隊"},{"key":"address","name":"地點"},{"key":"arrive_time","name":"抵達時間"},{"key":"leave_time","name":"離開時間"},{"key":"flow_target","name":"弧線終點"},{"key":"hub_source","name":"終點來源"},{"key":"brigade_office_address","name":"分隊登記地址"}]'::json),
(322, 'garbage_ntpc_gold_local', '黃金資收站', 'circle', 'geojson', 'big', NULL,
 '{"circle-color":"#c9a227","circle-opacity":0.88,"circle-stroke-color":"#fff0b3","circle-stroke-width":0.9}'::json,
 '[{"key":"dist","name":"行政區"},{"key":"vil","name":"里別"},{"key":"leader","name":"里長"},{"key":"siteaddress","name":"資收地點"},{"key":"worktime","name":"資收時間"},{"key":"phone","name":"電話"}]'::json);

-- 2. components
DELETE FROM components WHERE id IN (416, 417)
   OR index IN ('garbage_district_compare_local', 'garbage_ntpc_gold_district_local');

INSERT INTO components (id, index, name) VALUES
(416, 'garbage_district_compare_local', '雙北清運收運流向'),
(417, 'garbage_ntpc_gold_district_local', '黃金資收站分布');

-- 3. component_charts
DELETE FROM component_charts WHERE index IN ('garbage_district_compare_local', 'garbage_ntpc_gold_district_local');

INSERT INTO component_charts (index, color, types, unit) VALUES
('garbage_district_compare_local',  ARRAY['#1f7aff']::text[], ARRAY['DistrictChart']::text[], '站'),
('garbage_ntpc_gold_district_local', ARRAY['#c9a227']::text[], ARRAY['DistrictChart']::text[], '站');

-- 4. query_charts
DELETE FROM query_charts WHERE index IN ('garbage_district_compare_local', 'garbage_ntpc_gold_district_local');

INSERT INTO query_charts (
  index, map_config_ids, map_filter, time_from, time_to,
  update_freq, update_freq_unit, source,
  short_desc, long_desc, use_case,
  links, contributors, created_at, updated_at, query_type, query_chart, city
) VALUES
(
  'garbage_district_compare_local',
  ARRAY[320, 321]::integer[],
  '{"mode":"byParam","byParam":{"xParam":"dist"}}'::json,
  'static', NULL, 0, NULL,
  '新北市環保局、臺北市環保局',
  '以行政區比較清運站數；地圖以弧線呈現各站收運往分隊或路線集中點之流向。',
  '整合臺北市垃圾車收運點位與新北市循線清運點：長條圖以行政區比較站點數量；地圖以弧線呈現收運流向——各停靠點收運往何處匯聚。',
  '檢視雙北各區清運站數量，並從弧線理解收運往何處匯聚。',
  ARRAY[
    'https://data.taipei/dataset/detail?id=6bb3304b-4f46-4bb0-8cd1-60c66dcd1cae',
    'https://data.taipei/dataset/detail?id=1acf38f3-1509-4cb1-898a-9b1d4f31a3af',
    'https://data.ntpc.gov.tw/datasets/edc3ad26-8ae7-4916-a00b-bc6048d19bf8'
  ]::text[],
  ARRAY['doit', 'ntpc']::text[],
  NOW(), NOW(), 'two_d',
  $q$SELECT dist AS x_axis, '雙北清運站數量（行政區）' AS y_axis, '' AS icon, count::double precision AS data
FROM (VALUES
  ('北投區',544),('士林區',653),('內湖區',200),('南港區',211),('松山區',106),
  ('信義區',168),('中山區',338),('大同區',251),('中正區',347),('萬華區',303),
  ('大安區',310),('文山區',581),('新莊區',2125),('淡水區',642),('汐止區',357),
  ('板橋區',2985),('三重區',932),('樹林區',804),('土城區',867),('蘆洲區',394),
  ('中和區',822),('永和區',1139),('新店區',1055),('鶯歌區',179),('三峽區',271),
  ('瑞芳區',246),('五股區',329),('泰山區',245),('林口區',170),('深坑區',134),
  ('石碇區',128),('坪林區',58),('三芝區',103),('石門區',62),('八里區',135),
  ('平溪區',16),('雙溪區',96),('貢寮區',99),('金山區',235),('萬里區',215),('烏來區',90)
) AS t(dist, count)
ORDER BY 1$q$,
  'metrotaipei'
),
(
  'garbage_ntpc_gold_district_local',
  ARRAY[322]::integer[],
  '{"mode":"byParam","byParam":{"xParam":"dist"}}'::json,
  'static', NULL, 0, NULL,
  '新北市環保局',
  '以行政區為單位，呈現新北市各區黃金資收站數量分布。',
  '整合新北市黃金資收站資訊，以行政區為單位呈現各區站點數量，可比較新北各區資源回收設施的分布密度與差異。',
  '用於比較新北市各行政區黃金資收站數量分布。',
  ARRAY[
    'https://recyclebank.epd.ntpc.gov.tw/Map/Index'
  ]::text[],
  ARRAY['ntpc']::text[],
  NOW(), NOW(), 'two_d',
  $q$SELECT dist AS x_axis, '黃金資收站數量' AS y_axis, '' AS icon, count::double precision AS data
FROM (VALUES
  ('三峽區',10),('三芝區',1),('三重區',10),('中和區',4),('五股區',3),('八里區',4),
  ('土城區',6),('坪林區',6),('平溪區',1),('新店區',20),('新莊區',5),('板橋區',6),
  ('林口區',3),('樹林區',9),('永和區',13),('汐止區',7),('淡水區',28),('深坑區',7),
  ('瑞芳區',9),('石碇區',3),('萬里區',5),('蘆洲區',3),('貢寮區',1),('金山區',13),
  ('雙溪區',2),('鶯歌區',16)
) AS t(dist, count)
ORDER BY 1$q$,
  'metrotaipei'
);

-- 5. 更新儀表板，加入兩個新組件 ID（若尚未存在）
UPDATE public.dashboards
SET components = CASE
      WHEN NOT (416 = ANY(components)) AND NOT (417 = ANY(components))
        THEN components || ARRAY[416, 417]::integer[]
      WHEN NOT (416 = ANY(components))
        THEN components || ARRAY[416]::integer[]
      WHEN NOT (417 = ANY(components))
        THEN components || ARRAY[417]::integer[]
      ELSE components
    END,
    updated_at = NOW()
WHERE index = 'garbage_map_metrotaipei';

-- 6. 更新 ID sequence
SELECT setval('component_maps_id_seq', (SELECT COALESCE(MAX(id), 1) FROM component_maps));
SELECT setval('components_id_seq',     (SELECT COALESCE(MAX(id), 1) FROM components));

-- 7. 補上各組件相關資料連結（dashboardmanager-demo.sql 初版 links 為空，此處確保有值）

-- 焚化爐
UPDATE query_charts
SET links = ARRAY['https://data.moenv.gov.tw/dataset/detail/FAC_S_02']::text[]
WHERE index = 'incinerator_capacity'
  AND (links IS NULL OR links = '{}'::text[]);

-- 大台北地區回收點（環境部 MOENV）
UPDATE query_charts
SET links = ARRAY['https://data.gov.tw/dataset/163144']::text[]
WHERE index = 'moenv_wr_recycle_metrotaipei'
  AND (links IS NULL OR links = '{}'::text[]);

-- 資源回收統計（雙北）
UPDATE query_charts
SET links = ARRAY[
  'https://data.taipei/dataset/detail?id=34f4f00b-5386-43ab-bcc7-b0ae7ee3e305',
  'https://oas.bas.ntpc.gov.tw/NTPCTRWD/NewPage/Publish.aspx?Mid1=382150000I&p=2&y=2025/12/25&s=10'
]::text[]
WHERE index = 'metro_recycling_map_mvp'
  AND (links IS NULL OR links = '{}'::text[]);

-- 回收地圖（新北）：補充 ntpc 連結
UPDATE query_charts
SET links = array_append(links, 'https://oas.bas.ntpc.gov.tw/NTPCTRWD/NewPage/Publish.aspx?Mid1=382150000I&p=2&y=2025/12/25&s=10')
WHERE index = 'ntpc_recycling_map_mvp'
  AND NOT ('https://oas.bas.ntpc.gov.tw/NTPCTRWD/NewPage/Publish.aspx?Mid1=382150000I&p=2&y=2025/12/25&s=10' = ANY(links));

-- 臺北回收地圖：補充 ntpc 連結
UPDATE query_charts
SET links = array_append(links, 'https://oas.bas.ntpc.gov.tw/NTPCTRWD/NewPage/Publish.aspx?Mid1=382150000I&p=2&y=2025/12/25&s=10')
WHERE index = 'tpc_recycling_map_mvp'
  AND NOT ('https://oas.bas.ntpc.gov.tw/NTPCTRWD/NewPage/Publish.aspx?Mid1=382150000I&p=2&y=2025/12/25&s=10' = ANY(links));

-- 廚餘地圖（雙北）
UPDATE query_charts
SET links = ARRAY['https://oas.bas.ntpc.gov.tw/NTPCTRWD/NewPage/Publish.aspx?Mid1=382150000I&p=2&y=2025/12/25&s=10']::text[]
WHERE index = 'metro_kitchen_waste_map_mvp'
  AND (links IS NULL OR links = '{}'::text[]);

COMMIT;

-- +goose Down
