-- MOENV 回收點：八圖層合併為單一組件（id=229, index=moenv_wr_recycle_metrotaipei），component_maps 仍為 111–118。
-- 可重複執行。
-- 建議順序：若儀表板含雙北資源回收統計／廚餘，先跑 metro_recycling_unified_manager_patch（或確認 components 已有 301、303），再跑本檔。

BEGIN;

DELETE FROM query_charts
WHERE city = 'metrotaipei'
  AND (index ~ '^moenv_wr_recycle_' OR index = 'moenv_wr_recycle_metrotaipei');

DELETE FROM components
WHERE id IN (221, 222, 223, 224, 225, 226, 227, 228)
   OR index = 'moenv_wr_recycle_metrotaipei';

DELETE FROM component_charts
WHERE index ~ '^moenv_wr_recycle_'
   OR index = 'moenv_wr_recycle_metrotaipei';

DELETE FROM component_maps WHERE id BETWEEN 111 AND 118;

INSERT INTO component_charts (index, color, types, unit) VALUES
('moenv_wr_recycle_metrotaipei',
 ARRAY['#E170A6', '#24B0DD', '#56B96D', '#F8CF58', '#F5AD4A', '#9DC56E', '#8B5CF6', '#ED6A45'],
 ARRAY['MoenvRecycleLayerToggles'],
 NULL);

INSERT INTO component_maps (id, index, title, type, source, size, icon, paint, property) VALUES
(111, 'moenv_wr_recycle_6ca8d697f6', '3C用品類', 'circle', 'geojson', 'small', NULL, '{"circle-color":"#E170A6","circle-opacity":0.85,"circle-radius":2}'::json, '[{"key":"site_name","name":"點位名稱"},{"key":"full_address","name":"地址"},{"key":"item","name":"回收類別"},{"key":"service_type","name":"服務類型"},{"key":"tel","name":"電話"}]'::json),
(112, 'moenv_wr_recycle_7b805c8fa1', '其他類', 'circle', 'geojson', 'small', NULL, '{"circle-color":"#24B0DD","circle-opacity":0.85,"circle-radius":2}'::json, '[{"key":"site_name","name":"點位名稱"},{"key":"full_address","name":"地址"},{"key":"item","name":"回收類別"},{"key":"service_type","name":"服務類型"},{"key":"tel","name":"電話"}]'::json),
(113, 'moenv_wr_recycle_6a4bc66658', '家具類', 'circle', 'geojson', 'small', NULL, '{"circle-color":"#56B96D","circle-opacity":0.85,"circle-radius":2}'::json, '[{"key":"site_name","name":"點位名稱"},{"key":"full_address","name":"地址"},{"key":"item","name":"回收類別"},{"key":"service_type","name":"服務類型"},{"key":"tel","name":"電話"}]'::json),
(114, 'moenv_wr_recycle_014ce45e54', '書籍類', 'circle', 'geojson', 'small', NULL, '{"circle-color":"#F8CF58","circle-opacity":0.85,"circle-radius":2}'::json, '[{"key":"site_name","name":"點位名稱"},{"key":"full_address","name":"地址"},{"key":"item","name":"回收類別"},{"key":"service_type","name":"服務類型"},{"key":"tel","name":"電話"}]'::json),
(115, 'moenv_wr_recycle_8863327e9b', '玩具類', 'circle', 'geojson', 'small', NULL, '{"circle-color":"#F5AD4A","circle-opacity":0.85,"circle-radius":2}'::json, '[{"key":"site_name","name":"點位名稱"},{"key":"full_address","name":"地址"},{"key":"item","name":"回收類別"},{"key":"service_type","name":"服務類型"},{"key":"tel","name":"電話"}]'::json),
(116, 'moenv_wr_recycle_c5e75de7e7', '生活用品類', 'circle', 'geojson', 'small', NULL, '{"circle-color":"#9DC56E","circle-opacity":0.85,"circle-radius":2}'::json, '[{"key":"site_name","name":"點位名稱"},{"key":"full_address","name":"地址"},{"key":"item","name":"回收類別"},{"key":"service_type","name":"服務類型"},{"key":"tel","name":"電話"}]'::json),
(117, 'moenv_wr_recycle_e62fbe91a5', '舊衣類', 'circle', 'geojson', 'small', NULL, '{"circle-color":"#8B5CF6","circle-opacity":0.85,"circle-radius":2}'::json, '[{"key":"site_name","name":"點位名稱"},{"key":"full_address","name":"地址"},{"key":"item","name":"回收類別"},{"key":"service_type","name":"服務類型"},{"key":"tel","name":"電話"}]'::json),
(118, 'moenv_wr_recycle_4554828c57', '電器類', 'circle', 'geojson', 'small', NULL, '{"circle-color":"#ED6A45","circle-opacity":0.85,"circle-radius":2}'::json, '[{"key":"site_name","name":"點位名稱"},{"key":"full_address","name":"地址"},{"key":"item","name":"回收類別"},{"key":"service_type","name":"服務類型"},{"key":"tel","name":"電話"}]'::json);

INSERT INTO components (id, index, name) VALUES
(229, 'moenv_wr_recycle_metrotaipei', '大台北地區回收點');

INSERT INTO query_charts (index, history_config, map_config_ids, map_filter, time_from, time_to, update_freq, update_freq_unit, source, short_desc, long_desc, use_case, links, contributors, created_at, updated_at, query_type, query_chart, query_history, city) VALUES
('moenv_wr_recycle_metrotaipei', NULL, ARRAY[111, 112, 113, 114, 115, 116, 117, 118]::integer[], '{}'::json, 'static', NULL, 0, NULL,
 '環境部',
 '北北基地區環境部公開回收點，八類物資分層顯示。',
 '資料來自環境部回收點位公開資訊；範圍為臺北市、新北市、基隆市（已排除桃園市）。於組件內可獨立開關各類別圖層。',
 '先開啟組件地圖開關，再依需求勾選要顯示的物資類別。',
 ARRAY[]::text[], ARRAY['doit', 'ntpc'], '2026-05-02 00:00:00+00', '2026-05-02 00:00:00+00', 'three_d',
 $q$select * from (values ('MOENV 回收點','圖層數','類',8),('MOENV 回收點','涵蓋縣市','項',3)) as t(x_axis,y_axis,icon,data)$q$,
 NULL,
 'metrotaipei');

-- 與 dashboardmanager-demo、新北 300/301 併存；並取代舊版「221–228 每類一個組件」的清單
UPDATE dashboards
SET components = ARRAY[219, 220, 999, 229, 300, 301, 303]::integer[]
WHERE index = 'garbage_map_metrotaipei';

SELECT setval('component_maps_id_seq', (SELECT COALESCE(MAX(id), 1) FROM component_maps));
SELECT setval('components_id_seq', (SELECT COALESCE(MAX(id), 1) FROM components));

COMMIT;
