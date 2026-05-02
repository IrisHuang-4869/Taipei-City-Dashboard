-- 僅調整 MVP 兩個 fill 圖層色階（可重複執行）
-- 本次：略提高對比（低量稍沉、高量稍亮／拉開）
-- psql ... -d dashboardmanager -f db-sample-data/ntpc_waste_mvp_map_paint_soft.sql

UPDATE public.component_maps
SET paint = $p${
  "fill-opacity": 0.85,
  "fill-outline-color": "rgba(255,255,255,0.26)",
  "fill-color": ["interpolate",["linear"],["coalesce",["to-number",["get","recycling_tons"]],0],0,"#356b52",3500,"#4c8569",7000,"#63a082",10500,"#7ab99a",14000,"#9fe0c0"]
}$p$::json
WHERE id = 150 AND index = 'ntpc_recycling_map_mvp';

UPDATE public.component_maps
SET paint = $p${
  "fill-opacity": 0.85,
  "fill-outline-color": "rgba(255,255,255,0.26)",
  "fill-color": ["interpolate",["linear"],["coalesce",["to-number",["get","kitchen_tons"]],0],0,"#6e5a42",140,"#8c7358",320,"#aa8c6f",520,"#c6a686",780,"#e8d2b8"]
}$p$::json
WHERE id = 151 AND index = 'ntpc_kitchen_waste_map_mvp';
