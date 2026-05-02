-- 為 garbage_map_metrotaipei 相關組件補上 taipei 版本（可切換「台北 / 雙北」）
-- 套用：
-- psql -h 127.0.0.1 -p 5432 -U postgres -d dashboardmanager -v ON_ERROR_STOP=1 -f db-sample-data/garbage_map_city_toggle_patch.sql

BEGIN;

-- Taipei 專用 map config（回收 / 廚餘）
DELETE FROM component_maps WHERE id IN (152, 154);

INSERT INTO component_maps (id, index, title, type, source, size, icon, paint, property) VALUES
(152, 'tpc_recycling_map_mvp', '臺北資源回收量（分區）', 'fill', 'geojson', NULL, NULL,
 $paint152${
  "fill-opacity": 1,
  "fill-outline-color": "rgba(255,255,255,0.22)",
  "fill-color": ["interpolate",["linear"],["coalesce",["to-number",["get","recycling_tons"]],0],0,"#ecfdf5",200,"#d1fae5",400,"#a7f3d0",700,"#6ee7b7",1100,"#34d399",1600,"#10b981",2500,"#047857",4000,"#064e3b"]
}$paint152$::json,
 '[{"key":"TNAME","name":"區名"},{"key":"recycling_tons","name":"回收量（公噸）"}]'::json),
(154, 'tpc_kitchen_map_mvp', '臺北廚餘回收量（分區）', 'fill', 'geojson', NULL, NULL,
 $paint154${
  "fill-opacity": 1,
  "fill-outline-color": "rgba(255,255,255,0.22)",
  "fill-color": ["interpolate",["linear"],["coalesce",["to-number",["get","kitchen_tons"]],0],0,"rgba(254,215,170,0.1)",0.16875,"rgba(253,186,116,0.28)",0.3375,"rgba(251,146,60,0.45)",0.50625,"rgba(249,115,22,0.6)",0.675,"rgba(234,88,12,0.74)",0.84375,"rgba(217,119,6,0.84)",1.0125,"rgba(194,65,12,0.88)",1.18125,"rgba(154,52,18,0.9)",1.35,"rgba(67,20,7,0.92)"]
}$paint154$::json,
 '[{"key":"TNAME","name":"區名"},{"key":"kitchen_tons","name":"廚餘回收量（公噸）"}]'::json);

-- MOENV 八大回收圖層：臺北市專用（對應 public/mapData/moenv_wr_recycle_*_tpe.geojson）
DELETE FROM component_maps WHERE id BETWEEN 157 AND 164 OR index LIKE 'moenv_wr_recycle_%\_tpe' ESCAPE '\';

INSERT INTO component_maps (id, index, title, type, source, size, icon, paint, property) VALUES
(157, 'moenv_wr_recycle_6ca8d697f6_tpe', '3C用品類', 'circle', 'geojson', 'small', NULL, '{"circle-color":"#E170A6","circle-opacity":0.85,"circle-radius":2}'::json, '[{"key":"site_name","name":"點位名稱"},{"key":"full_address","name":"地址"},{"key":"item","name":"回收類別"},{"key":"service_type","name":"服務類型"},{"key":"tel","name":"電話"}]'::json),
(158, 'moenv_wr_recycle_7b805c8fa1_tpe', '其他類', 'circle', 'geojson', 'small', NULL, '{"circle-color":"#24B0DD","circle-opacity":0.85,"circle-radius":2}'::json, '[{"key":"site_name","name":"點位名稱"},{"key":"full_address","name":"地址"},{"key":"item","name":"回收類別"},{"key":"service_type","name":"服務類型"},{"key":"tel","name":"電話"}]'::json),
(159, 'moenv_wr_recycle_6a4bc66658_tpe', '家具類', 'circle', 'geojson', 'small', NULL, '{"circle-color":"#56B96D","circle-opacity":0.85,"circle-radius":2}'::json, '[{"key":"site_name","name":"點位名稱"},{"key":"full_address","name":"地址"},{"key":"item","name":"回收類別"},{"key":"service_type","name":"服務類型"},{"key":"tel","name":"電話"}]'::json),
(160, 'moenv_wr_recycle_014ce45e54_tpe', '書籍類', 'circle', 'geojson', 'small', NULL, '{"circle-color":"#F8CF58","circle-opacity":0.85,"circle-radius":2}'::json, '[{"key":"site_name","name":"點位名稱"},{"key":"full_address","name":"地址"},{"key":"item","name":"回收類別"},{"key":"service_type","name":"服務類型"},{"key":"tel","name":"電話"}]'::json),
(161, 'moenv_wr_recycle_8863327e9b_tpe', '玩具類', 'circle', 'geojson', 'small', NULL, '{"circle-color":"#F5AD4A","circle-opacity":0.85,"circle-radius":2}'::json, '[{"key":"site_name","name":"點位名稱"},{"key":"full_address","name":"地址"},{"key":"item","name":"回收類別"},{"key":"service_type","name":"服務類型"},{"key":"tel","name":"電話"}]'::json),
(162, 'moenv_wr_recycle_c5e75de7e7_tpe', '生活用品類', 'circle', 'geojson', 'small', NULL, '{"circle-color":"#9DC56E","circle-opacity":0.85,"circle-radius":2}'::json, '[{"key":"site_name","name":"點位名稱"},{"key":"full_address","name":"地址"},{"key":"item","name":"回收類別"},{"key":"service_type","name":"服務類型"},{"key":"tel","name":"電話"}]'::json),
(163, 'moenv_wr_recycle_e62fbe91a5_tpe', '舊衣類', 'circle', 'geojson', 'small', NULL, '{"circle-color":"#8B5CF6","circle-opacity":0.85,"circle-radius":2}'::json, '[{"key":"site_name","name":"點位名稱"},{"key":"full_address","name":"地址"},{"key":"item","name":"回收類別"},{"key":"service_type","name":"服務類型"},{"key":"tel","name":"電話"}]'::json),
(164, 'moenv_wr_recycle_4554828c57_tpe', '電器類', 'circle', 'geojson', 'small', NULL, '{"circle-color":"#ED6A45","circle-opacity":0.85,"circle-radius":2}'::json, '[{"key":"site_name","name":"點位名稱"},{"key":"full_address","name":"地址"},{"key":"item","name":"回收類別"},{"key":"service_type","name":"服務類型"},{"key":"tel","name":"電話"}]'::json);

-- 先移除既有 taipei 版本，避免重複
DELETE FROM query_charts
WHERE city = 'taipei'
  AND index IN (
    'incinerator_capacity',
    'moenv_wr_recycle_metrotaipei',
    'ntpc_recycling_map_mvp',
    'ntpc_kitchen_waste_map_mvp'
  );

-- 1) 雙北焚化爐處理量能 -> 台北版（僅三廠）
INSERT INTO query_charts (
  index, history_config, map_config_ids, map_filter, time_from, time_to,
  update_freq, update_freq_unit, source, short_desc, long_desc, use_case,
  links, contributors, created_at, updated_at, query_type, query_chart, query_history, city
)
SELECT
  index,
  history_config,
  map_config_ids,
  map_filter,
  time_from,
  time_to,
  update_freq,
  update_freq_unit,
  source,
  short_desc,
  long_desc,
  use_case,
  links,
  contributors,
  NOW(),
  NOW(),
  query_type,
  $q$
SELECT district AS x_axis, '焚化爐處理量能' AS y_axis, ROUND(capacity_ratio) AS data
FROM (
  VALUES
    ('北投區','臺北市北投垃圾焚化廠',68.84),
    ('文山區','臺北市木柵垃圾焚化廠',58.39),
    ('內湖區','臺北市內湖垃圾焚化廠',52.86)
) AS t(district, name, capacity_ratio)
  $q$,
  query_history,
  'taipei'
FROM query_charts
WHERE index = 'incinerator_capacity' AND city = 'metrotaipei'
LIMIT 1;

-- 2) 大台北地區回收點 -> 台北版（僅臺北市點位；八圖層使用 *_tpe.geojson）
INSERT INTO query_charts (
  index, history_config, map_config_ids, map_filter, time_from, time_to,
  update_freq, update_freq_unit, source, short_desc, long_desc, use_case,
  links, contributors, created_at, updated_at, query_type, query_chart, query_history, city
)
SELECT
  index,
  history_config,
  ARRAY[157, 158, 159, 160, 161, 162, 163, 164]::integer[],
  map_filter,
  time_from,
  time_to,
  update_freq,
  update_freq_unit,
  source,
  '臺北市環境部公開回收點，八類物資分層顯示。',
  '資料來自環境部回收點位公開資訊；此視圖僅顯示位於臺北市行政區之點位。於組件內可獨立開關各類別圖層。',
  use_case,
  links,
  contributors,
  NOW(),
  NOW(),
  query_type,
  $$SELECT * FROM (VALUES ('MOENV 回收點','圖層數','類',8),('MOENV 回收點','涵蓋縣市','項',1)) AS t(x_axis,y_axis,icon,data)$$,
  query_history,
  'taipei'
FROM query_charts
WHERE index = 'moenv_wr_recycle_metrotaipei' AND city = 'metrotaipei'
LIMIT 1;

-- 3) 回收地圖 -> 台北版（使用 tpc_recycling_map_mvp.geojson 對應資料）
INSERT INTO query_charts (
  index, history_config, map_config_ids, map_filter, time_from, time_to,
  update_freq, update_freq_unit, source, short_desc, long_desc, use_case,
  links, contributors, created_at, updated_at, query_type, query_chart, query_history, city
)
SELECT
  index,
  history_config,
  ARRAY[152]::integer[],
  map_filter,
  time_from,
  time_to,
  update_freq,
  update_freq_unit,
  source,
  short_desc,
  long_desc,
  use_case,
  links,
  contributors,
  NOW(),
  NOW(),
  query_type,
  $q$
SELECT district AS x_axis, '資源回收量(公噸)' AS y_axis, ''::text AS icon, data
FROM (
  VALUES
    ('中山區',582.77::double precision),
    ('中正區',265.65::double precision),
    ('信義區',403.83::double precision),
    ('內湖區',478.47::double precision),
    ('北投區',338.99::double precision),
    ('南港區',191.60::double precision),
    ('士林區',444.23::double precision),
    ('大同區',145.91::double precision),
    ('大安區',680.16::double precision),
    ('文山區',542.69::double precision),
    ('松山區',372.28::double precision),
    ('萬華區',285.35::double precision)
) AS t(district, data)
ORDER BY 1
  $q$,
  query_history,
  'taipei'
FROM query_charts
WHERE index = 'ntpc_recycling_map_mvp' AND city = 'metrotaipei'
LIMIT 1;

-- 4) 垃圾地圖 -> 台北版（目前台北廚餘資料為 0 快照）
INSERT INTO query_charts (
  index, history_config, map_config_ids, map_filter, time_from, time_to,
  update_freq, update_freq_unit, source, short_desc, long_desc, use_case,
  links, contributors, created_at, updated_at, query_type, query_chart, query_history, city
)
SELECT
  index,
  history_config,
  ARRAY[154]::integer[],
  map_filter,
  time_from,
  time_to,
  update_freq,
  update_freq_unit,
  source,
  short_desc,
  long_desc,
  use_case,
  links,
  contributors,
  NOW(),
  NOW(),
  query_type,
  $q$
SELECT district AS x_axis, '廚餘回收量(公噸)' AS y_axis, ''::text AS icon, data
FROM (
  VALUES
    ('中山區',0::double precision),
    ('中正區',0::double precision),
    ('信義區',0::double precision),
    ('內湖區',0::double precision),
    ('北投區',0::double precision),
    ('南港區',0::double precision),
    ('士林區',0::double precision),
    ('大同區',0::double precision),
    ('大安區',0::double precision),
    ('文山區',0::double precision),
    ('松山區',0::double precision),
    ('萬華區',0::double precision)
) AS t(district, data)
ORDER BY 1
  $q$,
  query_history,
  'taipei'
FROM query_charts
WHERE index = 'ntpc_kitchen_waste_map_mvp' AND city = 'metrotaipei'
LIMIT 1;

COMMIT;
