-- +goose NO TRANSACTION
-- source: db-sample-data/sync_dual_taipei_garbage.sql

-- +goose Up
SET search_path TO public;

BEGIN;

UPDATE public.dashboards 
SET name = '垃圾地圖', updated_at = NOW() 
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
INSERT INTO query_charts (
  index, map_config_ids, map_filter, time_from, time_to,
  update_freq, update_freq_unit, source,
  short_desc, long_desc, use_case,
  links, contributors, created_at, updated_at, query_type, city
) VALUES
(
  'garbage_taipei_truck_local', ARRAY[310]::integer[],
  '{"mode":"byParam","byParam":{"xParam":"dist"}}'::json,
  'static', NULL, 0, NULL,
  '臺北市環保局',
  '顯示臺北市各里垃圾車收運點位及預定到達時間。',
  '呈現臺北市環保局各清潔隊分隊垃圾車收運站點，標示行政區、里別、地點及抵達／離開時間；點位顏色依抵達時間分四個時段深淺標示，方便民眾辨識收運時段。',
  '查詢住家附近的垃圾車收運點位與時間，安排適時出門配合清運；亦可供環保單位掌握各路線站點分布與收運密度。',
  ARRAY['https://data.taipei/dataset/detail?id=6bb3304b-4f46-4bb0-8cd1-60c66dcd1cae']::text[], ARRAY['doit']::text[], NOW(), NOW(), 'map_legend', 'taipei'
),
(
  'garbage_taipei_dropoff_local', ARRAY[311]::integer[],
  NULL, 'static', NULL, 0, NULL,
  '臺北市環保局',
  '顯示臺北市限時收受點位置，僅在特定時段開放投放垃圾。',
  '呈現臺北市環保局設置的限時收受點，各點位標示行政區、分隊、電話、地址及備註資訊，民眾需在指定時段前往投放垃圾。',
  '查詢鄰近的限時收受點位置與開放時段，方便在無固定收運路線的區域安排垃圾投放，避免錯過收受時間。',
  ARRAY['https://data.taipei/dataset/detail?id=1acf38f3-1509-4cb1-898a-9b1d4f31a3af']::text[], ARRAY['doit']::text[], NOW(), NOW(), 'map_legend', 'taipei'
),
(
  'garbage_ntpc_route_local', ARRAY[312]::integer[],
  '{"mode":"byParam","byParam":{"xParam":"dist"}}'::json,
  'static', NULL, 0, NULL,
  '新北市環保局',
  '顯示新北市各里循線清運點，為固定路線定期清運站點。',
  '呈現新北市環保局循線定期清運之站點，包含行政區、里別、清運點名稱、路線名稱及表定清運時間，涵蓋各區固定收運路線的所有停靠點位。',
  '查詢所在里別附近的固定循線清運點及時間，安排垃圾投放；亦可供環保單位分析清運路線密度與各里覆蓋情形。',
  ARRAY['https://data.ntpc.gov.tw/datasets/edc3ad26-8ae7-4916-a00b-bc6048d19bf8']::text[], ARRAY['ntpc']::text[], NOW(), NOW(), 'map_legend', 'metrotaipei'
),
(
  'garbage_ntpc_mobile_local', ARRAY[313]::integer[],
  '{"mode":"byParam","byParam":{"xParam":"dist"}}'::json,
  'static', NULL, 0, NULL,
  '新北市環保局',
  '顯示新北市機動定點清運站，依需求彈性設置於固定路線未涵蓋區域。',
  '呈現新北市環保局以機動方式調整的定點清運站，包含行政區、里別、清運點名稱、站點型態及表定時間，彈性補足固定路線未涵蓋之區域清運需求。',
  '查詢住家附近的機動定點清運站，了解非固定路線的清運服務位置與時間；亦可供環保局評估機動站點的空間佈局與服務需求。',
  ARRAY[]::text[], ARRAY['ntpc']::text[], NOW(), NOW(), 'map_legend', 'metrotaipei'
),
(
  'garbage_ntpc_timed_local', ARRAY[314]::integer[],
  '{"mode":"byParam","byParam":{"xParam":"dist"}}'::json,
  'static', NULL, 0, NULL,
  '新北市環保局',
  '顯示新北市限時定點清運站，僅在特定時段開放投放垃圾。',
  '呈現新北市環保局設置的限時定點清運站，包含行政區、里別、清運點名稱、站點型態及表定開放時段，民眾需在規定時段內前往投放垃圾。',
  '確認限時定點清運站的位置與開放時段，避免錯過投放時間；亦可供環保局分析此類站點的空間分布與服務涵蓋。',
  ARRAY[]::text[], ARRAY['ntpc']::text[], NOW(), NOW(), 'map_legend', 'metrotaipei'
),
(
  'garbage_ntpc_temp_local', ARRAY[315]::integer[],
  '{"mode":"byParam","byParam":{"xParam":"dist"}}'::json,
  'static', NULL, 0, NULL,
  '新北市環保局',
  '顯示新北市臨停清運點，為垃圾車行駛路線中的臨時性補充停靠點。',
  '呈現新北市環保局設置的臨停清運點，包含行政區、里別、清運點名稱及相關資訊，為正式路線以外的臨時性或補充性停靠點，依實際需求彈性調整。',
  '查詢鄰近的臨停清運點位置，把握垃圾車臨時停靠的投放機會；亦可供環保單位評估臨停站點的空間分布與服務效益。',
  ARRAY[]::text[], ARRAY['ntpc']::text[], NOW(), NOW(), 'map_legend', 'metrotaipei'
);

-- 5. 將 410–415 safe-append 至 garbage_map_metrotaipei（不覆蓋其他 id）
UPDATE public.dashboards
SET
  components = components || ARRAY(
    SELECT v FROM unnest(ARRAY[410,411,412,413,414,415]::integer[]) v
    WHERE NOT (v = ANY(components))
  ),
  updated_at = NOW()
WHERE index = 'garbage_map_metrotaipei';

COMMIT;

-- +goose Down
-- TODO: 視需要填寫回滾 SQL
