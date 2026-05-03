-- ============================================================
-- apply_all_manager.sql  ─  dashboardmanager 全量套用入口
-- ============================================================
-- 對象資料庫：dashboardmanager
-- 執行方式（從 repo 根目錄）：
--   PGPASSWORD=<pwd> psql -h 127.0.0.1 -p 5432 -U postgres -d dashboardmanager \
--     -v ON_ERROR_STOP=1 -f db-sample-data/apply_all_manager.sql
--
-- 執行順序說明：
--   Step 0  │ dashboardmanager-demo  ← TRUNCATE+COPY 全量基礎，必須放最前
--   Step 1  │ ntpc 新北垃圾/回收 MVP 設定（300/301）
--   Step 2  │ tpc 臺北回收統計設定（302）
--   Step 3  │ 雙北資源回收統計合併（303；移除 300/302）
--   Step 4  │ 雙北廚餘地圖統一（metro_kitchen_waste_map_mvp）
--   Step 5  │ MOENV 回收點八圖層（229；safe-append）
--   Step 6  │ 雙北垃圾站點清運圖層（410–415；safe-append）
--   Step 7  │ 清運流向弧線＋黃金資收站（416–417；safe-append）
--   Step 8  │ 台北視圖切換（taipei 版 query_charts）
--   Step 9  │ MOENV 台北專屬地圖（*_tpe 版 component_maps）
--   Step 10 │ 確保 301/303 在垃圾地圖（safe-append）
--   Step 11 │ 新北回收/廚餘歷史圖（query_history）
--   Step 12 │ 圖表查詢改為 ORDER BY 區名
--   Step 13 │ 地圖 paint 更新：新北回收/廚餘
--   Step 14 │ 地圖 paint 更新：雙北資源回收
--   Step 15 │ 地圖 paint 更新：雙北廚餘
--   Step 16 │ MOENV 圖層 paint 更新（circle-radius 縮小）
--   Step 17 │ 移除 placeholder 組件 219/220（最後執行）
--   Step 18 │ 雙北統一回收／廚餘／清運流向之 city=taipei 圖表查詢（修 /chart?city=taipei 404）
--
-- ⚠ 不包含 local_garbage_flow_and_gold_manager_patch.sql（已被 Step 7 取代）
-- ⚠ dashboard（圖表資料庫）請改用 apply_all_dashboard.sql
-- ============================================================

-- Step 0: 全量基礎（先清空，再 COPY）
-- dashboardmanager-demo.sql 是 pg_dump COPY 格式，需乾淨的表才能重複執行
TRUNCATE TABLE
  public.dashboard_groups,
  public.dashboards,
  public.query_charts,
  public.component_charts,
  public.component_maps,
  public.components,
  public.groups,
  public.contributors,
  public.issues
RESTART IDENTITY CASCADE;

\ir dashboardmanager-demo.sql

-- dashboardmanager-demo.sql 會把 search_path 清空，這裡還原讓後續 patch 不需加 schema 前綴
SET search_path TO public;

-- Step 1: 新北垃圾/回收 MVP（component_maps 150–151、components 300–301）
\ir ntpc_waste_mvp_manager_patch.sql

-- Step 2: 臺北回收統計（component_maps 152、components 302）
\ir tpc_recycling_mvp_manager_patch.sql

-- Step 3: 雙北資源回收統計合併（component_maps 153、components 303；移除 300/302）
\ir metro_recycling_unified_manager_patch.sql

-- Step 4: 雙北廚餘地圖統一（component_maps 154/155、components metro_kitchen）
\ir metro_kitchen_unified_manager_patch.sql

-- Step 5: MOENV 回收點（component_maps 111–118、components 229）
\ir import_moenv_recycle_incremental.sql

-- Step 6: 雙北垃圾站點（component_maps 310–315、components 410–415）
\ir sync_dual_taipei_garbage.sql

-- Step 7: 清運流向弧線＋黃金資收站（component_maps 320–322、components 416–417）
\ir unify_local_garbage_to_db.sql

-- Step 8: taipei 版 query_charts（焚化爐/MOENV/回收/廚餘 taipei city）
\ir garbage_map_city_toggle_patch.sql

-- Step 9: MOENV 台北專屬地圖（component_maps 157–164 *_tpe）
\ir moenv_recycle_taipei_only_map_patch.sql

-- Step 10: 確保 301/303 在垃圾地圖 components（safe-append）
\ir ntpc_merge_waste_into_garbage_map_metrotaipei.sql

-- Step 11: 新北回收/廚餘歷史圖（query_history 欄位）
\ir ntpc_waste_mvp_history_manager_patch.sql

-- Step 12: 圖表查詢改為依行政區名排序
\ir ntpc_waste_mvp_query_order_desc.sql

-- Step 13: 新北回收/廚餘地圖 paint 填色調整（component_maps 150/151）
\ir ntpc_waste_mvp_map_paint_transparency.sql

-- Step 14: 雙北資源回收統計地圖 paint（component_maps 153）
\ir metro_recycling_map_paint.sql

-- Step 15: 雙北廚餘地圖 paint（component_maps 154）
\ir metro_kitchen_map_paint.sql

-- Step 16: MOENV 圖層 paint 更新（component_maps 111–118 circle-radius）
\ir patch_moenv_recycle_component_maps_paint.sql

-- Step 17: 移除 placeholder 組件 219/220（ARRAY_REMOVE，最後執行）
\ir patch_garbage_dashboard_prune_placeholder_components.sql

-- Step 18: 為 metro_recycling（303）、metro_kitchen（301）、garbage_district_compare（416）補 query_charts city=taipei
\ir metro_unified_query_charts_taipei_patch.sql

-- Step 19: 新增清運流向第二階段弧線圖層（component_maps id 323/324）並更新 garbage_district_compare_local map_config_ids
\ir garbage_flow_phase2_map_layers_patch.sql
