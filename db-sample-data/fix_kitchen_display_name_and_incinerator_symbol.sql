-- 修正：① 雙北廚餘組件顯示名稱 ② 焚化爐地圖圖層應為 symbol+flame（點位 GeoJSON 不可用 fill）
-- 可重複執行。目標庫：dashboardmanager。
-- psql ... -d dashboardmanager -v ON_ERROR_STOP=1 -f db-sample-data/fix_kitchen_display_name_and_incinerator_symbol.sql

BEGIN;

-- 1) 組件列表名稱（儀表板側邊／標題常用 components.name）
UPDATE public.components
SET name = '廚餘回收量統計'
WHERE index = 'metro_kitchen_waste_map_mvp';

-- 2) 地圖圖層標題與 metro_kitchen_unified 一致（可選，避免與舊「雙北」口語混淆）
UPDATE public.component_maps
SET title = '廚餘回收量（雙北）'
WHERE id = 154 AND index = 'metro_kitchen_waste_map_mvp';

-- 3) 焚化爐：還原為 symbol + flame；capacity_ratio 為 0–1，與 public/mapData/incinerator_capacity*.geojson 一致
UPDATE public.component_maps
SET
  type = 'symbol',
  size = NULL,
  icon = 'flame',
  paint =
    '{"icon-color":["interpolate",["linear"],["get","capacity_ratio"],0,"#4CAF50",0.5,"#4CAF50",0.75,"#FFEB3B",1,"#F44336"],"icon-opacity":0.8}'::json,
  property =
    '[{"key":"name","name":"焚化廠名稱"},{"key":"capacity_ratio_pct","name":"焚化量能比率"},{"key":"district","name":"行政區"},{"key":"actual_volume_month","name":"總焚化量 (公噸/月)"}]'::json
WHERE index = 'incinerator_capacity'
  AND id = 103;

COMMIT;
