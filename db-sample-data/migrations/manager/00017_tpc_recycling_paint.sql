-- +goose NO TRANSACTION
-- source: db-sample-data/tpc_recycling_map_paint.sql

-- +goose Up
SET search_path TO public;

-- 僅更新臺北回收地圖填色（component_maps id=152）；與 tpc_recycling_mvp_manager_patch.sql 內 paint 建議一致
-- psql ... -d <postgres-manager> -v ON_ERROR_STOP=1 -f db-sample-data/tpc_recycling_map_paint.sql

BEGIN;

UPDATE public.component_maps
SET paint = $json${
  "fill-opacity": 1,
  "fill-outline-color": "rgba(255,255,255,0.22)",
  "fill-color": ["interpolate",["linear"],["coalesce",["to-number",["get","recycling_tons"]],0],0,"#ecfdf5",200,"#d1fae5",400,"#a7f3d0",700,"#6ee7b7",1100,"#34d399",1600,"#10b981",2500,"#047857",4000,"#064e3b"]
}$json$::json
WHERE id = 152 AND index = 'tpc_recycling_map_mvp';

COMMIT;

-- +goose Down
-- TODO: 視需要填寫回滾 SQL
