-- MOENV 回收點組件增量匯入（假設 demo 基底已存在；焚化爐圖層為 component_maps.id=103，MOENV 為 111–118）
-- 可重複執行：先刪除同 index / id 再插入

BEGIN;

DELETE FROM query_charts WHERE index LIKE 'moenv_wr_recycle_%' AND city = 'metrotaipei';
DELETE FROM components WHERE id IN (221, 222, 223, 224, 225, 226, 227, 228);
DELETE FROM component_maps WHERE id BETWEEN 111 AND 118;
DELETE FROM component_charts WHERE index LIKE 'moenv_wr_recycle_%';

INSERT INTO component_charts (index, color, types, unit) VALUES
('moenv_wr_recycle_6ca8d697f6', ARRAY['#E170A6', '#E170A6', '#E170A6'], ARRAY['TextUnitChart'], '處'),
('moenv_wr_recycle_7b805c8fa1', ARRAY['#24B0DD', '#24B0DD', '#24B0DD'], ARRAY['TextUnitChart'], '處'),
('moenv_wr_recycle_6a4bc66658', ARRAY['#56B96D', '#56B96D', '#56B96D'], ARRAY['TextUnitChart'], '處'),
('moenv_wr_recycle_014ce45e54', ARRAY['#F8CF58', '#F8CF58', '#F8CF58'], ARRAY['TextUnitChart'], '處'),
('moenv_wr_recycle_8863327e9b', ARRAY['#F5AD4A', '#F5AD4A', '#F5AD4A'], ARRAY['TextUnitChart'], '處'),
('moenv_wr_recycle_c5e75de7e7', ARRAY['#9DC56E', '#9DC56E', '#9DC56E'], ARRAY['TextUnitChart'], '處'),
('moenv_wr_recycle_e62fbe91a5', ARRAY['#8B5CF6', '#8B5CF6', '#8B5CF6'], ARRAY['TextUnitChart'], '處'),
('moenv_wr_recycle_4554828c57', ARRAY['#ED6A45', '#ED6A45', '#ED6A45'], ARRAY['TextUnitChart'], '處');

INSERT INTO component_maps (id, index, title, type, source, size, icon, paint, property) VALUES
(111, 'moenv_wr_recycle_6ca8d697f6', '回收點｜3C用品類', 'circle', 'geojson', 'small', NULL, '{"circle-color":"#E170A6","circle-opacity":0.85,"circle-radius":5,"circle-stroke-width":1,"circle-stroke-color":"#ffffff"}'::json, '[{"key":"site_name","name":"點位名稱"},{"key":"full_address","name":"地址"},{"key":"item","name":"回收類別"},{"key":"service_type","name":"服務類型"},{"key":"tel","name":"電話"}]'::json),
(112, 'moenv_wr_recycle_7b805c8fa1', '回收點｜其他類', 'circle', 'geojson', 'small', NULL, '{"circle-color":"#24B0DD","circle-opacity":0.85,"circle-radius":5,"circle-stroke-width":1,"circle-stroke-color":"#ffffff"}'::json, '[{"key":"site_name","name":"點位名稱"},{"key":"full_address","name":"地址"},{"key":"item","name":"回收類別"},{"key":"service_type","name":"服務類型"},{"key":"tel","name":"電話"}]'::json),
(113, 'moenv_wr_recycle_6a4bc66658', '回收點｜家具類', 'circle', 'geojson', 'small', NULL, '{"circle-color":"#56B96D","circle-opacity":0.85,"circle-radius":5,"circle-stroke-width":1,"circle-stroke-color":"#ffffff"}'::json, '[{"key":"site_name","name":"點位名稱"},{"key":"full_address","name":"地址"},{"key":"item","name":"回收類別"},{"key":"service_type","name":"服務類型"},{"key":"tel","name":"電話"}]'::json),
(114, 'moenv_wr_recycle_014ce45e54', '回收點｜書籍類', 'circle', 'geojson', 'small', NULL, '{"circle-color":"#F8CF58","circle-opacity":0.85,"circle-radius":5,"circle-stroke-width":1,"circle-stroke-color":"#ffffff"}'::json, '[{"key":"site_name","name":"點位名稱"},{"key":"full_address","name":"地址"},{"key":"item","name":"回收類別"},{"key":"service_type","name":"服務類型"},{"key":"tel","name":"電話"}]'::json),
(115, 'moenv_wr_recycle_8863327e9b', '回收點｜玩具類', 'circle', 'geojson', 'small', NULL, '{"circle-color":"#F5AD4A","circle-opacity":0.85,"circle-radius":5,"circle-stroke-width":1,"circle-stroke-color":"#ffffff"}'::json, '[{"key":"site_name","name":"點位名稱"},{"key":"full_address","name":"地址"},{"key":"item","name":"回收類別"},{"key":"service_type","name":"服務類型"},{"key":"tel","name":"電話"}]'::json),
(116, 'moenv_wr_recycle_c5e75de7e7', '回收點｜生活用品類', 'circle', 'geojson', 'small', NULL, '{"circle-color":"#9DC56E","circle-opacity":0.85,"circle-radius":5,"circle-stroke-width":1,"circle-stroke-color":"#ffffff"}'::json, '[{"key":"site_name","name":"點位名稱"},{"key":"full_address","name":"地址"},{"key":"item","name":"回收類別"},{"key":"service_type","name":"服務類型"},{"key":"tel","name":"電話"}]'::json),
(117, 'moenv_wr_recycle_e62fbe91a5', '回收點｜舊衣類', 'circle', 'geojson', 'small', NULL, '{"circle-color":"#8B5CF6","circle-opacity":0.85,"circle-radius":5,"circle-stroke-width":1,"circle-stroke-color":"#ffffff"}'::json, '[{"key":"site_name","name":"點位名稱"},{"key":"full_address","name":"地址"},{"key":"item","name":"回收類別"},{"key":"service_type","name":"服務類型"},{"key":"tel","name":"電話"}]'::json),
(118, 'moenv_wr_recycle_4554828c57', '回收點｜電器類', 'circle', 'geojson', 'small', NULL, '{"circle-color":"#ED6A45","circle-opacity":0.85,"circle-radius":5,"circle-stroke-width":1,"circle-stroke-color":"#ffffff"}'::json, '[{"key":"site_name","name":"點位名稱"},{"key":"full_address","name":"地址"},{"key":"item","name":"回收類別"},{"key":"service_type","name":"服務類型"},{"key":"tel","name":"電話"}]'::json);

INSERT INTO components (id, index, name) VALUES
(221, 'moenv_wr_recycle_6ca8d697f6', '回收點｜3C用品類'),
(222, 'moenv_wr_recycle_7b805c8fa1', '回收點｜其他類'),
(223, 'moenv_wr_recycle_6a4bc66658', '回收點｜家具類'),
(224, 'moenv_wr_recycle_014ce45e54', '回收點｜書籍類'),
(225, 'moenv_wr_recycle_8863327e9b', '回收點｜玩具類'),
(226, 'moenv_wr_recycle_c5e75de7e7', '回收點｜生活用品類'),
(227, 'moenv_wr_recycle_e62fbe91a5', '回收點｜舊衣類'),
(228, 'moenv_wr_recycle_4554828c57', '回收點｜電器類');

INSERT INTO query_charts (index, history_config, map_config_ids, map_filter, time_from, time_to, update_freq, update_freq_unit, source, short_desc, long_desc, use_case, links, contributors, created_at, updated_at, query_type, query_chart, query_history, city) VALUES
('moenv_wr_recycle_6ca8d697f6', NULL, ARRAY[111]::integer[], '{}'::json, 'static', NULL, 0, NULL, '環境部', '北北基 MOENV 回收點：3C用品類。', '圖層來自環境部回收點位公開資料；範圍僅臺北市、新北市、基隆市（已排除桃園市）；單一圖層僅含 3C用品類。', '於地圖模式可獨立開關本圖層以檢視點位與屬性。', ARRAY[]::text[], ARRAY['doit', 'ntpc'], '2026-05-02 00:00:00+00', '2026-05-02 00:00:00+00', 'three_d', $q$select * from (values ('3C用品類','點位數','處',69)) as t(x_axis,y_axis,icon,data)$q$, NULL, 'metrotaipei'),
('moenv_wr_recycle_7b805c8fa1', NULL, ARRAY[112]::integer[], '{}'::json, 'static', NULL, 0, NULL, '環境部', '北北基 MOENV 回收點：其他類。', '圖層來自環境部回收點位公開資料；範圍僅臺北市、新北市、基隆市（已排除桃園市）；單一圖層僅含其他類。', '於地圖模式可獨立開關本圖層以檢視點位與屬性。', ARRAY[]::text[], ARRAY['doit', 'ntpc'], '2026-05-02 00:00:00+00', '2026-05-02 00:00:00+00', 'three_d', $q$select * from (values ('其他類','點位數','處',39)) as t(x_axis,y_axis,icon,data)$q$, NULL, 'metrotaipei'),
('moenv_wr_recycle_6a4bc66658', NULL, ARRAY[113]::integer[], '{}'::json, 'static', NULL, 0, NULL, '環境部', '北北基 MOENV 回收點：家具類。', '圖層來自環境部回收點位公開資料；範圍僅臺北市、新北市、基隆市（已排除桃園市）；單一圖層僅含家具類。', '於地圖模式可獨立開關本圖層以檢視點位與屬性。', ARRAY[]::text[], ARRAY['doit', 'ntpc'], '2026-05-02 00:00:00+00', '2026-05-02 00:00:00+00', 'three_d', $q$select * from (values ('家具類','點位數','處',12)) as t(x_axis,y_axis,icon,data)$q$, NULL, 'metrotaipei'),
('moenv_wr_recycle_014ce45e54', NULL, ARRAY[114]::integer[], '{}'::json, 'static', NULL, 0, NULL, '環境部', '北北基 MOENV 回收點：書籍類。', '圖層來自環境部回收點位公開資料；範圍僅臺北市、新北市、基隆市（已排除桃園市）；單一圖層僅含書籍類。', '於地圖模式可獨立開關本圖層以檢視點位與屬性。', ARRAY[]::text[], ARRAY['doit', 'ntpc'], '2026-05-02 00:00:00+00', '2026-05-02 00:00:00+00', 'three_d', $q$select * from (values ('書籍類','點位數','處',13)) as t(x_axis,y_axis,icon,data)$q$, NULL, 'metrotaipei'),
('moenv_wr_recycle_8863327e9b', NULL, ARRAY[115]::integer[], '{}'::json, 'static', NULL, 0, NULL, '環境部', '北北基 MOENV 回收點：玩具類。', '圖層來自環境部回收點位公開資料；範圍僅臺北市、新北市、基隆市（已排除桃園市）；單一圖層僅含玩具類。', '於地圖模式可獨立開關本圖層以檢視點位與屬性。', ARRAY[]::text[], ARRAY['doit', 'ntpc'], '2026-05-02 00:00:00+00', '2026-05-02 00:00:00+00', 'three_d', $q$select * from (values ('玩具類','點位數','處',10)) as t(x_axis,y_axis,icon,data)$q$, NULL, 'metrotaipei'),
('moenv_wr_recycle_c5e75de7e7', NULL, ARRAY[116]::integer[], '{}'::json, 'static', NULL, 0, NULL, '環境部', '北北基 MOENV 回收點：生活用品類。', '圖層來自環境部回收點位公開資料；範圍僅臺北市、新北市、基隆市（已排除桃園市）；單一圖層僅含生活用品類。', '於地圖模式可獨立開關本圖層以檢視點位與屬性。', ARRAY[]::text[], ARRAY['doit', 'ntpc'], '2026-05-02 00:00:00+00', '2026-05-02 00:00:00+00', 'three_d', $q$select * from (values ('生活用品類','點位數','處',47)) as t(x_axis,y_axis,icon,data)$q$, NULL, 'metrotaipei'),
('moenv_wr_recycle_e62fbe91a5', NULL, ARRAY[117]::integer[], '{}'::json, 'static', NULL, 0, NULL, '環境部', '北北基 MOENV 回收點：舊衣類。', '圖層來自環境部回收點位公開資料；範圍僅臺北市、新北市、基隆市（已排除桃園市）；單一圖層僅含舊衣類。', '於地圖模式可獨立開關本圖層以檢視點位與屬性。', ARRAY[]::text[], ARRAY['doit', 'ntpc'], '2026-05-02 00:00:00+00', '2026-05-02 00:00:00+00', 'three_d', $q$select * from (values ('舊衣類','點位數','處',144)) as t(x_axis,y_axis,icon,data)$q$, NULL, 'metrotaipei'),
('moenv_wr_recycle_4554828c57', NULL, ARRAY[118]::integer[], '{}'::json, 'static', NULL, 0, NULL, '環境部', '北北基 MOENV 回收點：電器類。', '圖層來自環境部回收點位公開資料；範圍僅臺北市、新北市、基隆市（已排除桃園市）；單一圖層僅含電器類。', '於地圖模式可獨立開關本圖層以檢視點位與屬性。', ARRAY[]::text[], ARRAY['doit', 'ntpc'], '2026-05-02 00:00:00+00', '2026-05-02 00:00:00+00', 'three_d', $q$select * from (values ('電器類','點位數','處',19)) as t(x_axis,y_axis,icon,data)$q$, NULL, 'metrotaipei');

UPDATE dashboards
SET components = ARRAY[219, 220, 999, 221, 222, 223, 224, 225, 226, 227, 228]::integer[]
WHERE index = 'garbage_map_metrotaipei';

SELECT setval('component_maps_id_seq', (SELECT COALESCE(MAX(id), 1) FROM component_maps));
SELECT setval('components_id_seq', (SELECT COALESCE(MAX(id), 1) FROM components));

COMMIT;
