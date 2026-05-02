-- 將新北回收／廚餘地圖組件（components 300、301）併入「垃圾地圖」garbage_map_metrotaipei，並移除獨立儀表板 ntpc_waste_maps_mvp。
-- 前置：已執行 ntpc_waste_mvp_manager_patch.sql（或至少已有 components 300、301 與對應 query_charts）。
-- 可重複執行：僅在未含 300/301 時擴充 components；刪除獨立儀表板為冪等。
-- psql -h ... -U ... -d <manager_db> -v ON_ERROR_STOP=1 -f db-sample-data/ntpc_merge_waste_into_garbage_map_metrotaipei.sql

BEGIN;

UPDATE public.dashboards
SET
  components = CASE
    WHEN NOT (300 = ANY(components)) AND NOT (301 = ANY(components))
      THEN components || ARRAY[300, 301]::integer[]
    WHEN NOT (300 = ANY(components))
      THEN components || ARRAY[300]::integer[]
    WHEN NOT (301 = ANY(components))
      THEN components || ARRAY[301]::integer[]
    ELSE components
  END,
  updated_at = NOW()
WHERE index = 'garbage_map_metrotaipei';

DELETE FROM public.dashboard_groups dg
USING public.dashboards d
WHERE d.id = dg.dashboard_id AND d.index = 'ntpc_waste_maps_mvp';

DELETE FROM public.dashboards WHERE index = 'ntpc_waste_maps_mvp' OR id = 400;

COMMIT;
