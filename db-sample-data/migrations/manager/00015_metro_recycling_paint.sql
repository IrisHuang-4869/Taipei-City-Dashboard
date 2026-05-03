-- +goose NO TRANSACTION
-- source: db-sample-data/metro_recycling_map_paint.sql

-- +goose Up
SET search_path TO public;

-- 資源回收統計地圖：量越低越透明（rgba），量高則較不透明且較飽和；停駐點仍對齊約 0–2200 公噸
-- psql ... -d <postgres-manager> -v ON_ERROR_STOP=1 -f db-sample-data/metro_recycling_map_paint.sql

BEGIN;

UPDATE public.component_maps
SET paint = $json${
  "fill-opacity": 1,
  "fill-outline-color": "rgba(255,255,255,0.22)",
  "fill-color": ["interpolate",["linear"],["coalesce",["to-number",["get","recycling_tons"]],0],0,"rgba(236,253,245,0.1)",275,"rgba(209,250,229,0.28)",550,"rgba(167,243,208,0.45)",825,"rgba(110,231,183,0.6)",1100,"rgba(52,211,153,0.74)",1375,"rgba(16,185,129,0.84)",1650,"rgba(16,185,129,0.88)",1925,"rgba(5,150,105,0.9)",2200,"rgba(5,150,105,0.92)"]
}$json$::json
WHERE id = 153 AND index = 'metro_recycling_map_mvp';

COMMIT;

-- +goose Down
-- TODO: 視需要填寫回滾 SQL
