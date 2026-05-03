-- ============================================================
-- apply_all_dashboard.sql  ─  dashboard（圖表資料庫）全量套用入口
-- ============================================================
-- 對象資料庫：dashboard
-- 執行方式（從 repo 根目錄）：
--   PGPASSWORD=<pwd> psql -h 127.0.0.1 -p 5434 -U postgres -d dashboard \
--     -v ON_ERROR_STOP=1 -f db-sample-data/apply_all_dashboard.sql
--
-- 執行順序說明：
--   Step 1 │ 建立 ntpc_waste_mvp_monthly 歷史表 schema
--   Step 2 │ 新北回收/廚餘 MVP 快照資料（ntpc_waste_mvp）
--   Step 3 │ 新北回收/廚餘歷史月資料（ntpc_waste_mvp_monthly）
--   Step 4 │ 若舊欄位為 recycling_kg/kitchen_kg，遷移為 recycling_tons/kitchen_tons
--   Step 5 │ 臺北市資源回收月資料（tpc_recycling_monthly）
--   Step 6 │ 臺北市廚餘月資料（tpc_kitchen_monthly）
--
-- ⚠ query_charts 組件設定請改用 apply_all_manager.sql（對 dashboardmanager）
-- ============================================================

-- Step 1: 建立歷史月表 schema（ntpc_waste_mvp_monthly）
\ir schema_ntpc_waste_mvp_monthly.sql

-- Step 2: 新北回收/廚餘 MVP 快照（ntpc_waste_mvp，ON CONFLICT UPDATE）
\ir import_ntpc_waste_mvp_data.sql

-- Step 3: 新北歷史月資料（generated，由 build_ntpc_waste_history_sql.mjs 產生）
\ir generated/import_ntpc_waste_mvp_history.sql

-- Step 4: 公斤欄位遷移（僅舊版 DB 需要；新版 idempotent）
\ir migrate_ntpc_monthly_kg_to_tons.sql

-- Step 5: 臺北市資源回收月資料（generated，由 build_tpc_recycling_sql.mjs 產生）
\ir generated/import_tpc_recycling_from_pdf.sql

-- Step 6: 臺北市廚餘月資料（generated，由 build_tpc_kitchen_sql.mjs 產生）
\ir generated/import_tpc_kitchen_from_pdf.sql
