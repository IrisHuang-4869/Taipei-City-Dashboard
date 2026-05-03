-- 清運收運流向第二階段弧線圖層（集中點 → 焚化廠）
-- 新增 component_maps id 323/324，並更新 garbage_district_compare_local 之 map_config_ids。
-- 可重複執行（DELETE 前置）。

SET search_path TO public;

BEGIN;

DELETE FROM component_maps WHERE id IN (323, 324)
   OR index IN ('garbage_ntpc_hub_incinerator_arcs_local', 'garbage_taipei_hub_incinerator_arcs_local');

INSERT INTO component_maps (id, index, title, type, source, size, icon, paint, property) VALUES
(323, 'garbage_ntpc_hub_incinerator_arcs_local', '收運流向第二階段（新北：集中點→焚化廠）', 'arc', 'geojson', 'big', NULL,
 '{"arc-color":["#2196f3","#4dd0e1"],"arc-width":3,"arc-width-property":"arc_width","arc-opacity":0.7}'::json,
 '[{"key":"dist","name":"行政區"},{"key":"route_name","name":"路線名稱"},{"key":"hub_source","name":"集中點來源"},{"key":"incinerator_name","name":"焚化廠"},{"key":"stop_count_hub","name":"路線站數"},{"key":"flow_stage2","name":"流向（示意）"}]'::json),
(324, 'garbage_taipei_hub_incinerator_arcs_local', '收運流向第二階段（臺北：分隊→焚化廠）', 'arc', 'geojson', 'big', NULL,
 '{"arc-color":["#ff7043","#ffd54f"],"arc-width":3,"arc-width-property":"arc_width","arc-opacity":0.7}'::json,
 '[{"key":"dist","name":"行政區"},{"key":"brigade","name":"清潔隊分隊"},{"key":"hub_source","name":"集中點來源"},{"key":"incinerator_name","name":"焚化廠"},{"key":"stop_count_hub","name":"分隊站數"},{"key":"flow_stage2","name":"流向（示意）"}]'::json);

-- 雙北模式：四層全部
UPDATE query_charts
SET map_config_ids = ARRAY[320, 321, 323, 324]::integer[],
    updated_at = NOW()
WHERE index = 'garbage_district_compare_local'
  AND city = 'metrotaipei';

-- 臺北模式：僅臺北兩層
UPDATE query_charts
SET map_config_ids = ARRAY[321, 324]::integer[],
    updated_at = NOW()
WHERE index = 'garbage_district_compare_local'
  AND city = 'taipei';

SELECT setval('component_maps_id_seq', (SELECT COALESCE(MAX(id), 1) FROM component_maps));

COMMIT;
