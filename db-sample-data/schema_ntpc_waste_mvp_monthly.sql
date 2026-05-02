-- 新北回收／廚餘：依「月 × 區」歷史表（欄位為公噸，與圖資 recycling_tons / kitchen_tons 語意一致）。
-- 快照表 ntpc_waste_mvp 仍為 **公斤**（與 import_ntpc_waste_mvp_data.sql、query_charts 之 round(kg/1000) 一致）。
-- 僅在 dashboard 執行。
-- psql ... -d dashboard -v ON_ERROR_STOP=1 -f db-sample-data/schema_ntpc_waste_mvp_monthly.sql
--
-- 若資料庫內已是舊版欄位名 recycling_kg／kitchen_kg，請先執行：
--   db-sample-data/migrate_ntpc_monthly_kg_to_tons.sql

BEGIN;

CREATE TABLE IF NOT EXISTS public.ntpc_waste_mvp_monthly (
  report_month    date NOT NULL,
  district        text NOT NULL,
  recycling_tons  numeric(20, 8) NOT NULL DEFAULT 0,
  kitchen_tons    numeric(20, 8) NOT NULL DEFAULT 0,
  PRIMARY KEY (report_month, district)
);

CREATE INDEX IF NOT EXISTS idx_ntpc_waste_mvp_monthly_district
  ON public.ntpc_waste_mvp_monthly (district);

CREATE INDEX IF NOT EXISTS idx_ntpc_waste_mvp_monthly_month
  ON public.ntpc_waste_mvp_monthly (report_month);

COMMIT;
