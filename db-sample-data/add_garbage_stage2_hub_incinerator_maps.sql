-- 補齊「雙北清運收運流向」第二階段：集中點／分隊 → 焚化廠 弧線圖層。
-- 原因：unify_local_garbage_to_db.sql 初版僅註冊 map_config_ids {320,321}（第一階段），
-- 前端 mapStore / GarbageFlowArcControls 仍需要 garbage_*_hub_incinerator_arcs_local。
-- 可重複執行。目標庫：dashboardmanager。
-- psql ... -d dashboardmanager -v ON_ERROR_STOP=1 -f db-sample-data/add_garbage_stage2_hub_incinerator_maps.sql

BEGIN;

DELETE FROM component_maps
WHERE id IN (323, 324)
   OR index IN (
     'garbage_ntpc_hub_incinerator_arcs_local',
     'garbage_taipei_hub_incinerator_arcs_local'
   );

INSERT INTO component_maps (id, index, title, type, source, size, icon, paint, property) VALUES
(323, 'garbage_ntpc_hub_incinerator_arcs_local', '匯聚→焚化廠（新北）', 'arc', 'geojson', 'big', NULL,
 '{"arc-color":["#6b4c9a","#c4a8e8"],"arc-width":2.5,"arc-width-property":"arc_width","arc-opacity":0.5}'::json,
 '[{"key":"dist","name":"行政區"},{"key":"route_name","name":"路線名稱"},{"key":"incinerator_name","name":"對照焚化廠"},{"key":"flow_stage2","name":"第二階段說明"},{"key":"hub_source","name":"匯聚點來源"},{"key":"stop_count_hub","name":"該路線停靠站數"}]'::json),
(324, 'garbage_taipei_hub_incinerator_arcs_local', '匯聚→焚化廠（台北）', 'arc', 'geojson', 'big', NULL,
 '{"arc-color":["#b85c00","#ffd27a"],"arc-width":2.5,"arc-width-property":"arc_width","arc-opacity":0.48}'::json,
 '[{"key":"dist","name":"代表行政區（多數站點）"},{"key":"brigade","name":"清潔隊分隊"},{"key":"incinerator_name","name":"對照焚化廠"},{"key":"flow_stage2","name":"第二階段說明"},{"key":"hub_source","name":"匯聚點來源"},{"key":"stop_count_hub","name":"該分隊停靠站數"}]'::json);

UPDATE public.query_charts
SET
  map_config_ids = ARRAY[320, 323, 321, 324]::integer[],
  short_desc =
    '以行政區比較清運站數；地圖以弧線呈現各站收運往分隊或路線集中點，以及集中點至焚化廠之示意流向。',
  long_desc =
    '整合臺北市垃圾車收運點位與新北市循線清運點：長條圖以行政區比較站點數量；地圖以弧線呈現「收運流向」——各停靠點收運往何處匯聚（新北不另顯示圓點）。臺北弧線終點為所屬清潔隊分隊之幾何匯聚點（站點重心或分隊部座標）。新北弧線終點為同行政區、同路線名稱下之停靠點座標重心，或 garbage_ntpc_route_hubs.json 所登記之集中點。另可疊加第二階段弧線：由上述匯聚點連至 incinerator_facilities.json 所載焚化廠代表座標（示意，實務調度以主管機關公告為準）；弧線寬度依該匯聚點涵蓋之停靠站數粗估。',
  updated_at = NOW()
WHERE index = 'garbage_district_compare_local';

SELECT setval('component_maps_id_seq', (SELECT COALESCE(MAX(id), 1) FROM component_maps));

COMMIT;
