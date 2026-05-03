-- +goose NO TRANSACTION
-- source: db-sample-data/metro_kitchen_map_paint.sql

-- +goose Up
SET search_path TO public;

-- 雙北廚餘地圖填色微調（component_maps id 154）
-- psql ... -d <postgres-manager> -v ON_ERROR_STOP=1 -f db-sample-data/metro_kitchen_map_paint.sql

BEGIN;

UPDATE public.component_maps
SET paint = $json${
  "fill-opacity": 1,
  "fill-outline-color": "rgba(255,255,255,0.22)",
  "fill-color": ["interpolate",["linear"],["coalesce",["to-number",["get","kitchen_tons"]],0],0,"rgba(254,215,170,0.1)",0.16875,"rgba(253,186,116,0.28)",0.3375,"rgba(251,146,60,0.45)",0.50625,"rgba(249,115,22,0.6)",0.675,"rgba(234,88,12,0.74)",0.84375,"rgba(217,119,6,0.84)",1.0125,"rgba(194,65,12,0.88)",1.18125,"rgba(154,52,18,0.9)",1.35,"rgba(67,20,7,0.92)"]
}$json$::json
WHERE id = 154 AND index = 'metro_kitchen_waste_map_mvp';

COMMIT;

-- +goose Down
-- TODO: 視需要填寫回滾 SQL
