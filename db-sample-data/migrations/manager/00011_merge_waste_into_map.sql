-- +goose NO TRANSACTION
-- source: db-sample-data/ntpc_merge_waste_into_garbage_map_metrotaipei.sql

-- +goose Up
SET search_path TO public;

-- 將新北廚餘（301）與雙北資源回收統計（303）併入「垃圾地圖」garbage_map_metrotaipei，並移除獨立儀表板 ntpc_waste_maps_mvp。
-- （回收已合併為 metro_recycling_map_mvp；廚餘可再跑 metro_kitchen_unified_manager_patch.sql 改為雙北 metro_kitchen_waste_map_mvp。）
-- 前置：import_ntpc_waste_mvp_data.sql → ntpc_waste_mvp_manager_patch.sql（manager_patch 已會 UPDATE garbage_map_metrotaipei；若僅缺 components 陣列可再跑本檔）。
-- 可重複執行：僅在未含 300/301 時擴充 components；刪除獨立儀表板為冪等。
-- psql -h ... -U ... -d <manager_db> -v ON_ERROR_STOP=1 -f db-sample-data/ntpc_merge_waste_into_garbage_map_metrotaipei.sql

BEGIN;

UPDATE public.dashboards
SET
  components = CASE
    WHEN NOT (301 = ANY(components)) AND NOT (303 = ANY(components))
      THEN components || ARRAY[301, 303]::integer[]
    WHEN NOT (301 = ANY(components))
      THEN components || ARRAY[301]::integer[]
    WHEN NOT (303 = ANY(components))
      THEN components || ARRAY[303]::integer[]
    ELSE components
  END,
  updated_at = NOW()
WHERE index = 'garbage_map_metrotaipei';

DELETE FROM public.dashboard_groups dg
USING public.dashboards d
WHERE d.id = dg.dashboard_id AND d.index = 'ntpc_waste_maps_mvp';

DELETE FROM public.dashboards WHERE index = 'ntpc_waste_maps_mvp' OR id = 400;

COMMIT;

-- +goose Down
-- TODO: 視需要填寫回滾 SQL
