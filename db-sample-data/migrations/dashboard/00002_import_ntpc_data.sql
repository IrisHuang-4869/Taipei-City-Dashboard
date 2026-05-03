-- +goose NO TRANSACTION
-- source: db-sample-data/import_ntpc_waste_mvp_data.sql

-- +goose Up
-- 新北回收／廚餘 MVP：查詢用資料表 + 示範列（與 mapData 內兩份 GeoJSON 屬性對齊）。
-- 數字為專案內示範用；若需與官方月報一致（各區清潔隊／環保單位回收量），請以 raw 報表執行
--   cd scripts && node build_ntpc_waste_history_sql.mjs
-- 產出 db-sample-data/generated/import_ntpc_waste_mvp_history.sql 並同步 GeoJSON 後，再匯入 DB。
--
-- 後端架構：query_charts 存在 **dashboardmanager**；實際 chart SQL 由 API 在 **dashboard**
-- 資料庫執行（DBDashboard）。因此下列指令須在 **兩個** DB 各執行一次（或僅 dashboard 若 manager 已由其他流程寫入）。
--
--   # 資料庫（圖表查詢實際執行處，必填）
--   psql ... -d dashboard -f db-sample-data/import_ntpc_waste_mvp_data.sql
--   # 儀表板管理庫（若需與 manager 共用同一表做維運／查詢，可選）
--   psql ... -d dashboardmanager -f db-sample-data/import_ntpc_waste_mvp_data.sql
--
-- 接下來再跑（僅 dashboardmanager）：
--   db-sample-data/ntpc_waste_mvp_manager_patch.sql

BEGIN;

CREATE TABLE IF NOT EXISTS public.ntpc_waste_mvp (
  district    text PRIMARY KEY,
  recycling_kg numeric NOT NULL DEFAULT 0,
  kitchen_kg   numeric NOT NULL DEFAULT 0
);

INSERT INTO public.ntpc_waste_mvp (district, recycling_kg, kitchen_kg) VALUES ('八里區', 235000, 84200) ON CONFLICT (district) DO UPDATE SET recycling_kg = EXCLUDED.recycling_kg, kitchen_kg = EXCLUDED.kitchen_kg;
INSERT INTO public.ntpc_waste_mvp (district, recycling_kg, kitchen_kg) VALUES ('三芝區', 750300, 135200) ON CONFLICT (district) DO UPDATE SET recycling_kg = EXCLUDED.recycling_kg, kitchen_kg = EXCLUDED.kitchen_kg;
INSERT INTO public.ntpc_waste_mvp (district, recycling_kg, kitchen_kg) VALUES ('三重區', 559100, 149000) ON CONFLICT (district) DO UPDATE SET recycling_kg = EXCLUDED.recycling_kg, kitchen_kg = EXCLUDED.kitchen_kg;
INSERT INTO public.ntpc_waste_mvp (district, recycling_kg, kitchen_kg) VALUES ('三峽區', 285600, 56300) ON CONFLICT (district) DO UPDATE SET recycling_kg = EXCLUDED.recycling_kg, kitchen_kg = EXCLUDED.kitchen_kg;
INSERT INTO public.ntpc_waste_mvp (district, recycling_kg, kitchen_kg) VALUES ('土城區', 353800, 104100) ON CONFLICT (district) DO UPDATE SET recycling_kg = EXCLUDED.recycling_kg, kitchen_kg = EXCLUDED.kitchen_kg;
INSERT INTO public.ntpc_waste_mvp (district, recycling_kg, kitchen_kg) VALUES ('中和區', 925000, 148000) ON CONFLICT (district) DO UPDATE SET recycling_kg = EXCLUDED.recycling_kg, kitchen_kg = EXCLUDED.kitchen_kg;
INSERT INTO public.ntpc_waste_mvp (district, recycling_kg, kitchen_kg) VALUES ('五股區', 878800, 120900) ON CONFLICT (district) DO UPDATE SET recycling_kg = EXCLUDED.recycling_kg, kitchen_kg = EXCLUDED.kitchen_kg;
INSERT INTO public.ntpc_waste_mvp (district, recycling_kg, kitchen_kg) VALUES ('平溪區', 365800, 89700) ON CONFLICT (district) DO UPDATE SET recycling_kg = EXCLUDED.recycling_kg, kitchen_kg = EXCLUDED.kitchen_kg;
INSERT INTO public.ntpc_waste_mvp (district, recycling_kg, kitchen_kg) VALUES ('永和區', 399900, 148300) ON CONFLICT (district) DO UPDATE SET recycling_kg = EXCLUDED.recycling_kg, kitchen_kg = EXCLUDED.kitchen_kg;
INSERT INTO public.ntpc_waste_mvp (district, recycling_kg, kitchen_kg) VALUES ('汐止區', 779700, 63800) ON CONFLICT (district) DO UPDATE SET recycling_kg = EXCLUDED.recycling_kg, kitchen_kg = EXCLUDED.kitchen_kg;
INSERT INTO public.ntpc_waste_mvp (district, recycling_kg, kitchen_kg) VALUES ('坪林區', 634400, 104800) ON CONFLICT (district) DO UPDATE SET recycling_kg = EXCLUDED.recycling_kg, kitchen_kg = EXCLUDED.kitchen_kg;
INSERT INTO public.ntpc_waste_mvp (district, recycling_kg, kitchen_kg) VALUES ('林口區', 604200, 32500) ON CONFLICT (district) DO UPDATE SET recycling_kg = EXCLUDED.recycling_kg, kitchen_kg = EXCLUDED.kitchen_kg;
INSERT INTO public.ntpc_waste_mvp (district, recycling_kg, kitchen_kg) VALUES ('板橋區', 303300, 36800) ON CONFLICT (district) DO UPDATE SET recycling_kg = EXCLUDED.recycling_kg, kitchen_kg = EXCLUDED.kitchen_kg;
INSERT INTO public.ntpc_waste_mvp (district, recycling_kg, kitchen_kg) VALUES ('金山區', 989200, 36500) ON CONFLICT (district) DO UPDATE SET recycling_kg = EXCLUDED.recycling_kg, kitchen_kg = EXCLUDED.kitchen_kg;
INSERT INTO public.ntpc_waste_mvp (district, recycling_kg, kitchen_kg) VALUES ('泰山區', 421500, 123800) ON CONFLICT (district) DO UPDATE SET recycling_kg = EXCLUDED.recycling_kg, kitchen_kg = EXCLUDED.kitchen_kg;
INSERT INTO public.ntpc_waste_mvp (district, recycling_kg, kitchen_kg) VALUES ('烏來區', 327000, 115300) ON CONFLICT (district) DO UPDATE SET recycling_kg = EXCLUDED.recycling_kg, kitchen_kg = EXCLUDED.kitchen_kg;
INSERT INTO public.ntpc_waste_mvp (district, recycling_kg, kitchen_kg) VALUES ('貢寮區', 694700, 141300) ON CONFLICT (district) DO UPDATE SET recycling_kg = EXCLUDED.recycling_kg, kitchen_kg = EXCLUDED.kitchen_kg;
INSERT INTO public.ntpc_waste_mvp (district, recycling_kg, kitchen_kg) VALUES ('淡水區', 364600, 45500) ON CONFLICT (district) DO UPDATE SET recycling_kg = EXCLUDED.recycling_kg, kitchen_kg = EXCLUDED.kitchen_kg;
INSERT INTO public.ntpc_waste_mvp (district, recycling_kg, kitchen_kg) VALUES ('深坑區', 793400, 111800) ON CONFLICT (district) DO UPDATE SET recycling_kg = EXCLUDED.recycling_kg, kitchen_kg = EXCLUDED.kitchen_kg;
INSERT INTO public.ntpc_waste_mvp (district, recycling_kg, kitchen_kg) VALUES ('新店區', 423000, 125300) ON CONFLICT (district) DO UPDATE SET recycling_kg = EXCLUDED.recycling_kg, kitchen_kg = EXCLUDED.kitchen_kg;
INSERT INTO public.ntpc_waste_mvp (district, recycling_kg, kitchen_kg) VALUES ('新莊區', 313500, 88200) ON CONFLICT (district) DO UPDATE SET recycling_kg = EXCLUDED.recycling_kg, kitchen_kg = EXCLUDED.kitchen_kg;
INSERT INTO public.ntpc_waste_mvp (district, recycling_kg, kitchen_kg) VALUES ('瑞芳區', 817400, 79900) ON CONFLICT (district) DO UPDATE SET recycling_kg = EXCLUDED.recycling_kg, kitchen_kg = EXCLUDED.kitchen_kg;
INSERT INTO public.ntpc_waste_mvp (district, recycling_kg, kitchen_kg) VALUES ('萬里區', 612600, 47600) ON CONFLICT (district) DO UPDATE SET recycling_kg = EXCLUDED.recycling_kg, kitchen_kg = EXCLUDED.kitchen_kg;
INSERT INTO public.ntpc_waste_mvp (district, recycling_kg, kitchen_kg) VALUES ('樹林區', 287200, 48100) ON CONFLICT (district) DO UPDATE SET recycling_kg = EXCLUDED.recycling_kg, kitchen_kg = EXCLUDED.kitchen_kg;
INSERT INTO public.ntpc_waste_mvp (district, recycling_kg, kitchen_kg) VALUES ('蘆洲區', 851800, 128600) ON CONFLICT (district) DO UPDATE SET recycling_kg = EXCLUDED.recycling_kg, kitchen_kg = EXCLUDED.kitchen_kg;
INSERT INTO public.ntpc_waste_mvp (district, recycling_kg, kitchen_kg) VALUES ('鶯歌區', 519400, 52800) ON CONFLICT (district) DO UPDATE SET recycling_kg = EXCLUDED.recycling_kg, kitchen_kg = EXCLUDED.kitchen_kg;
INSERT INTO public.ntpc_waste_mvp (district, recycling_kg, kitchen_kg) VALUES ('石碇區', 443400, 83800) ON CONFLICT (district) DO UPDATE SET recycling_kg = EXCLUDED.recycling_kg, kitchen_kg = EXCLUDED.kitchen_kg;
INSERT INTO public.ntpc_waste_mvp (district, recycling_kg, kitchen_kg) VALUES ('石門區', 613400, 43200) ON CONFLICT (district) DO UPDATE SET recycling_kg = EXCLUDED.recycling_kg, kitchen_kg = EXCLUDED.kitchen_kg;
INSERT INTO public.ntpc_waste_mvp (district, recycling_kg, kitchen_kg) VALUES ('雙溪區', 253700, 104300) ON CONFLICT (district) DO UPDATE SET recycling_kg = EXCLUDED.recycling_kg, kitchen_kg = EXCLUDED.kitchen_kg;

COMMIT;

-- +goose Down
-- TODO: 視需要填寫回滾 SQL
