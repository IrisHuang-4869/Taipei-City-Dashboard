-- 將既有 ntpc_waste_mvp_monthly（公斤欄位）遷移為公噸欄位（數值 ÷1000）。
-- 若已是 recycling_tons／kitchen_tons 則不變。僅 dashboard。
-- psql ... -d dashboard -v ON_ERROR_STOP=1 -f db-sample-data/migrate_ntpc_monthly_kg_to_tons.sql

BEGIN;

DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.tables
    WHERE table_schema = 'public' AND table_name = 'ntpc_waste_mvp_monthly'
  ) AND EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public' AND table_name = 'ntpc_waste_mvp_monthly'
      AND column_name = 'recycling_kg'
  ) THEN
    ALTER TABLE public.ntpc_waste_mvp_monthly RENAME COLUMN recycling_kg TO recycling_kg_legacy;
    ALTER TABLE public.ntpc_waste_mvp_monthly RENAME COLUMN kitchen_kg TO kitchen_kg_legacy;
    ALTER TABLE public.ntpc_waste_mvp_monthly
      ADD COLUMN recycling_tons numeric(20, 8) NOT NULL DEFAULT 0;
    ALTER TABLE public.ntpc_waste_mvp_monthly
      ADD COLUMN kitchen_tons numeric(20, 8) NOT NULL DEFAULT 0;
    UPDATE public.ntpc_waste_mvp_monthly SET
      recycling_tons = recycling_kg_legacy / 1000.0,
      kitchen_tons = kitchen_kg_legacy / 1000.0;
    ALTER TABLE public.ntpc_waste_mvp_monthly DROP COLUMN recycling_kg_legacy;
    ALTER TABLE public.ntpc_waste_mvp_monthly DROP COLUMN kitchen_kg_legacy;
  END IF;
END $$;

COMMIT;
