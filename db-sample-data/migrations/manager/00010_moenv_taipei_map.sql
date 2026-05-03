-- +goose NO TRANSACTION
-- source: db-sample-data/moenv_recycle_taipei_only_map_patch.sql

-- +goose Up
SET search_path TO public;

-- 「大台北地區回收點」台北視圖：改用僅含臺北市點位的 geojson（*_tpe）與獨立 component_maps。
-- 前置：前端已提供 public/mapData/moenv_wr_recycle_*_tpe.geojson（八個檔）。
-- 套用（dashboardmanager）：
-- PGPASSWORD=... psql -h 127.0.0.1 -p 5432 -U postgres -d dashboardmanager -v ON_ERROR_STOP=1 -f db-sample-data/moenv_recycle_taipei_only_map_patch.sql

BEGIN;

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

UPDATE query_charts
SET
  map_config_ids = ARRAY[157, 158, 159, 160, 161, 162, 163, 164]::integer[],
  short_desc = '臺北市環境部公開回收點，八類物資分層顯示。',
  long_desc = '資料來自環境部回收點位公開資訊；此視圖僅顯示位於臺北市行政區之點位。於組件內可獨立開關各類別圖層。',
  query_chart = $$SELECT * FROM (VALUES ('MOENV 回收點','圖層數','類',8),('MOENV 回收點','涵蓋縣市','項',1)) AS t(x_axis,y_axis,icon,data)$$,
  updated_at = NOW()
WHERE index = 'moenv_wr_recycle_metrotaipei' AND city = 'taipei';

COMMIT;

-- +goose Down
-- TODO: 視需要填寫回滾 SQL
