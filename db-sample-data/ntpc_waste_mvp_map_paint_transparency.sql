-- 新北回收／廚餘地圖：填色為寫死 8 階（與 FE ntpcWasteMvpPalette.js 同色 hex；圖表為名次分桶、地圖為數值線性插值）
-- 回收停駐（公噸）：0,2000,4000,6000,8000,10000,12000,14000
-- 廚餘停駐（公噸）：約 0–1.35；alpha 階梯與 metro_recycling_map_mvp（153）一致，停駐依 2200:1.35 換算自回收公噸軸
-- 套用：psql ... -d <postgres-manager> -v ON_ERROR_STOP=1 -f db-sample-data/ntpc_waste_mvp_map_paint_transparency.sql

BEGIN;

UPDATE public.component_maps
SET paint = $json${
  "fill-opacity": 1,
  "fill-outline-color": "rgba(255,255,255,0.22)",
  "fill-color": ["interpolate",["linear"],["coalesce",["to-number",["get","recycling_tons"]],0],0,"#ecfdf5",2000,"#d1fae5",4000,"#a7f3d0",6000,"#6ee7b7",8000,"#34d399",10000,"#10b981",12000,"#047857",14000,"#064e3b"]
}$json$::json
WHERE id = 150 AND index = 'ntpc_recycling_map_mvp';

-- 廚餘：alpha 0.1→0.92 與雙北回收相同；色相為琥珀系（低量柔、非白）
UPDATE public.component_maps
SET paint = $json${
  "fill-opacity": 1,
  "fill-outline-color": "rgba(255,255,255,0.22)",
  "fill-color": ["interpolate",["linear"],["coalesce",["to-number",["get","kitchen_tons"]],0],0,"rgba(254,215,170,0.1)",0.16875,"rgba(253,186,116,0.28)",0.3375,"rgba(251,146,60,0.45)",0.50625,"rgba(249,115,22,0.6)",0.675,"rgba(234,88,12,0.74)",0.84375,"rgba(217,119,6,0.84)",1.0125,"rgba(194,65,12,0.88)",1.18125,"rgba(154,52,18,0.9)",1.35,"rgba(67,20,7,0.92)"]
}$json$::json
WHERE id = 151 AND index = 'ntpc_kitchen_waste_map_mvp';

COMMIT;
