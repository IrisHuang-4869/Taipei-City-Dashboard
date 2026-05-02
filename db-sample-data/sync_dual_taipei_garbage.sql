BEGIN;

-- 1. 更新儀表板名稱為「雙北垃圾車」
UPDATE public.dashboards 
SET name = '雙北垃圾車', updated_at = NOW() 
WHERE index = 'garbage_map_metrotaipei';

-- 2. 插入新北與台北的所有垃圾圖層 (ID 使用 310-315)
DELETE FROM component_maps WHERE id BETWEEN 310 AND 315;
INSERT INTO component_maps (id, index, title, type, source, size, icon, paint, property) VALUES
(310, 'garbage_taipei_truck_local', '垃圾車收運點位（台北）', 'circle', 'geojson', 'big', NULL,
 '{"circle-color":["case",["<",["to-number",["get","arrive_time"]],1700],"#E6DF44",["<",["to-number",["get","arrive_time"]],1900],"#F4633C",["<",["to-number",["get","arrive_time"]],2100],"#D63940","#9C2A4B"],"circle-opacity":0.85,"circle-stroke-color":"#ffffff","circle-stroke-width":0.6}'::json,
 '[{"key":"dist","name":"行政區"},{"key":"vil","name":"里別"},{"key":"brigade","name":"分隊"},{"key":"license_plate","name":"車號"},{"key":"route","name":"路線"},{"key":"route_shift","name":"車次"},{"key":"arrive_time","name":"抵達時間"},{"key":"leave_time","name":"離開時間"},{"key":"address","name":"地點"}]'::json),
(311, 'garbage_taipei_dropoff_local', '★ 限時收受點（台北）', 'circle', 'geojson', 'big', NULL,
 '{"circle-color":"#00e676","circle-opacity":0.95,"circle-stroke-color":"#ffffff","circle-stroke-width":2.5}'::json,
 '[{"key":"dist","name":"行政區"},{"key":"brigade","name":"分隊"},{"key":"phone","name":"電話"},{"key":"address","name":"地址"},{"key":"note","name":"備註"}]'::json),
(312, 'garbage_ntpc_route_local', '循線清運點（新北）', 'circle', 'geojson', 'big', NULL,
 '{"circle-color":"#4e79a7","circle-opacity":0.82,"circle-stroke-color":"#f4f4f4","circle-stroke-width":0.8}'::json,
 '[{"key":"dist","name":"行政區"},{"key":"vil","name":"里別"},{"key":"point_name","name":"清運點名稱"},{"key":"point_type_summary","name":"站點型態"},{"key":"schedule_summary","name":"表定時間"}]'::json),
(313, 'garbage_ntpc_mobile_local', '機動定點清運點（新北）', 'circle', 'geojson', 'big', NULL,
 '{"circle-color":"#f28e2b","circle-opacity":0.82,"circle-stroke-color":"#f4f4f4","circle-stroke-width":0.8}'::json,
 '[{"key":"dist","name":"行政區"},{"key":"vil","name":"里別"},{"key":"point_name","name":"清運點名稱"},{"key":"point_type_summary","name":"站點型態"},{"key":"schedule_summary","name":"表定時間"}]'::json),
(314, 'garbage_ntpc_timed_local', '限時定點清運點（新北）', 'circle', 'geojson', 'big', NULL,
 '{"circle-color":"#e15759","circle-opacity":0.82,"circle-stroke-color":"#f4f4f4","circle-stroke-width":0.8}'::json,
 '[{"key":"dist","name":"行政區"},{"key":"vil","name":"里別"},{"key":"point_name","name":"清運點名稱"},{"key":"point_type_summary","name":"站點型態"},{"key":"schedule_summary","name":"表定時間"}]'::json),
(315, 'garbage_ntpc_temp_local', '臨停清運點（新北）', 'circle', 'geojson', 'big', NULL,
 '{"circle-color":"#76b7b2","circle-opacity":0.82,"circle-stroke-color":"#f4f4f4","circle-stroke-width":0.8}'::json,
 '[{"key":"dist","name":"行政區"},{"key":"vil","name":"里別"},{"key":"point_name","name":"清運點名稱"},{"key":"point_type_summary","name":"站點型態"},{"key":"schedule_summary","name":"表定時間"}]'::json);

-- 3. 插入對應的 components (ID 使用 410-415)
DELETE FROM components WHERE id BETWEEN 410 AND 415;
INSERT INTO components (id, index, name) VALUES
(410, 'garbage_taipei_truck_local', '垃圾車（台北）'),
(411, 'garbage_taipei_dropoff_local', '限時點（台北）'),
(412, 'garbage_ntpc_route_local', '循線（新北）'),
(413, 'garbage_ntpc_mobile_local', '機動（新北）'),
(414, 'garbage_ntpc_timed_local', '限時（新北）'),
(415, 'garbage_ntpc_temp_local', '臨停（新北）');

-- 4. 插入對應的 query_charts
DELETE FROM query_charts WHERE index IN ('garbage_taipei_truck_local', 'garbage_taipei_dropoff_local', 'garbage_ntpc_route_local', 'garbage_ntpc_mobile_local', 'garbage_ntpc_timed_local', 'garbage_ntpc_temp_local');
INSERT INTO query_charts (index, map_config_ids, source, city, query_type, created_at, updated_at) VALUES
('garbage_taipei_truck_local', ARRAY[310]::integer[], '臺北市環保局', 'taipei', 'map_legend', NOW(), NOW()),
('garbage_taipei_dropoff_local', ARRAY[311]::integer[], '臺北市環保局', 'taipei', 'map_legend', NOW(), NOW()),
('garbage_ntpc_route_local', ARRAY[312]::integer[], '新北市環保局', 'metrotaipei', 'map_legend', NOW(), NOW()),
('garbage_ntpc_mobile_local', ARRAY[313]::integer[], '新北市環保局', 'metrotaipei', 'map_legend', NOW(), NOW()),
('garbage_ntpc_timed_local', ARRAY[314]::integer[], '新北市環保局', 'metrotaipei', 'map_legend', NOW(), NOW()),
('garbage_ntpc_temp_local', ARRAY[315]::integer[], '新北市環保局', 'metrotaipei', 'map_legend', NOW(), NOW());

-- 5. 更新儀表板的組件列表，整合雙北所有垃圾站點並保留焚化爐 (999)
UPDATE public.dashboards 
SET components = ARRAY[219, 220, 229, 410, 411, 412, 413, 414, 415, 300, 301, 999], updated_at = NOW() 
WHERE index = 'garbage_map_metrotaipei';

COMMIT;
