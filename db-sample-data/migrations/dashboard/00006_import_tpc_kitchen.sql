-- +goose NO TRANSACTION
-- source: db-sample-data/generated/import_tpc_kitchen_from_pdf.sql

-- +goose Up
-- 由 scripts/build_tpc_kitchen_sql.mjs 自動產生（臺北市 PDF 各區清潔隊廚餘回收量，公噸）

BEGIN;

CREATE TABLE IF NOT EXISTS public.tpc_kitchen_monthly (
  report_month date NOT NULL,
  district text NOT NULL,
  kitchen_tons double precision NOT NULL DEFAULT 0,
  PRIMARY KEY (report_month, district)
);

CREATE TABLE IF NOT EXISTS public.tpc_kitchen_mvp (
  district text PRIMARY KEY,
  kitchen_kg bigint NOT NULL DEFAULT 0
);

INSERT INTO public.tpc_kitchen_monthly (report_month, district, kitchen_tons) VALUES ('2025-04-01'::date, '中山區', 0) ON CONFLICT (report_month, district) DO UPDATE SET kitchen_tons = EXCLUDED.kitchen_tons;
INSERT INTO public.tpc_kitchen_monthly (report_month, district, kitchen_tons) VALUES ('2025-04-01'::date, '中正區', 0) ON CONFLICT (report_month, district) DO UPDATE SET kitchen_tons = EXCLUDED.kitchen_tons;
INSERT INTO public.tpc_kitchen_monthly (report_month, district, kitchen_tons) VALUES ('2025-04-01'::date, '信義區', 0) ON CONFLICT (report_month, district) DO UPDATE SET kitchen_tons = EXCLUDED.kitchen_tons;
INSERT INTO public.tpc_kitchen_monthly (report_month, district, kitchen_tons) VALUES ('2025-04-01'::date, '內湖區', 0) ON CONFLICT (report_month, district) DO UPDATE SET kitchen_tons = EXCLUDED.kitchen_tons;
INSERT INTO public.tpc_kitchen_monthly (report_month, district, kitchen_tons) VALUES ('2025-04-01'::date, '北投區', 0) ON CONFLICT (report_month, district) DO UPDATE SET kitchen_tons = EXCLUDED.kitchen_tons;
INSERT INTO public.tpc_kitchen_monthly (report_month, district, kitchen_tons) VALUES ('2025-04-01'::date, '南港區', 0) ON CONFLICT (report_month, district) DO UPDATE SET kitchen_tons = EXCLUDED.kitchen_tons;
INSERT INTO public.tpc_kitchen_monthly (report_month, district, kitchen_tons) VALUES ('2025-04-01'::date, '士林區', 0) ON CONFLICT (report_month, district) DO UPDATE SET kitchen_tons = EXCLUDED.kitchen_tons;
INSERT INTO public.tpc_kitchen_monthly (report_month, district, kitchen_tons) VALUES ('2025-04-01'::date, '大同區', 0) ON CONFLICT (report_month, district) DO UPDATE SET kitchen_tons = EXCLUDED.kitchen_tons;
INSERT INTO public.tpc_kitchen_monthly (report_month, district, kitchen_tons) VALUES ('2025-04-01'::date, '大安區', 0) ON CONFLICT (report_month, district) DO UPDATE SET kitchen_tons = EXCLUDED.kitchen_tons;
INSERT INTO public.tpc_kitchen_monthly (report_month, district, kitchen_tons) VALUES ('2025-04-01'::date, '文山區', 0) ON CONFLICT (report_month, district) DO UPDATE SET kitchen_tons = EXCLUDED.kitchen_tons;
INSERT INTO public.tpc_kitchen_monthly (report_month, district, kitchen_tons) VALUES ('2025-04-01'::date, '松山區', 0) ON CONFLICT (report_month, district) DO UPDATE SET kitchen_tons = EXCLUDED.kitchen_tons;
INSERT INTO public.tpc_kitchen_monthly (report_month, district, kitchen_tons) VALUES ('2025-04-01'::date, '萬華區', 0) ON CONFLICT (report_month, district) DO UPDATE SET kitchen_tons = EXCLUDED.kitchen_tons;

INSERT INTO public.tpc_kitchen_mvp (district, kitchen_kg)
SELECT district,
  ROUND(kitchen_tons * 1000)::bigint
FROM public.tpc_kitchen_monthly
WHERE report_month = (SELECT MAX(report_month) FROM public.tpc_kitchen_monthly)
ON CONFLICT (district) DO UPDATE SET
  kitchen_kg = EXCLUDED.kitchen_kg;

COMMIT;

-- +goose Down
-- TODO: 視需要填寫回滾 SQL
