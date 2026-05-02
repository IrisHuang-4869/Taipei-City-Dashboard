-- 由 scripts/build_tpc_recycling_sql.mjs 自動產生（臺北市 PDF 各區清潔隊資源回收量，公噸）

BEGIN;

CREATE TABLE IF NOT EXISTS public.tpc_recycling_monthly (
  report_month date NOT NULL,
  district text NOT NULL,
  recycling_tons double precision NOT NULL DEFAULT 0,
  PRIMARY KEY (report_month, district)
);

CREATE TABLE IF NOT EXISTS public.tpc_recycling_mvp (
  district text PRIMARY KEY,
  recycling_kg bigint NOT NULL DEFAULT 0
);

INSERT INTO public.tpc_recycling_monthly (report_month, district, recycling_tons) VALUES ('2025-01-01'::date, '中山區', 762.98) ON CONFLICT (report_month, district) DO UPDATE SET recycling_tons = EXCLUDED.recycling_tons;
INSERT INTO public.tpc_recycling_monthly (report_month, district, recycling_tons) VALUES ('2025-01-01'::date, '中正區', 318.3) ON CONFLICT (report_month, district) DO UPDATE SET recycling_tons = EXCLUDED.recycling_tons;
INSERT INTO public.tpc_recycling_monthly (report_month, district, recycling_tons) VALUES ('2025-01-01'::date, '信義區', 527.55) ON CONFLICT (report_month, district) DO UPDATE SET recycling_tons = EXCLUDED.recycling_tons;
INSERT INTO public.tpc_recycling_monthly (report_month, district, recycling_tons) VALUES ('2025-01-01'::date, '內湖區', 684.63) ON CONFLICT (report_month, district) DO UPDATE SET recycling_tons = EXCLUDED.recycling_tons;
INSERT INTO public.tpc_recycling_monthly (report_month, district, recycling_tons) VALUES ('2025-01-01'::date, '北投區', 435.78) ON CONFLICT (report_month, district) DO UPDATE SET recycling_tons = EXCLUDED.recycling_tons;
INSERT INTO public.tpc_recycling_monthly (report_month, district, recycling_tons) VALUES ('2025-01-01'::date, '南港區', 238.9) ON CONFLICT (report_month, district) DO UPDATE SET recycling_tons = EXCLUDED.recycling_tons;
INSERT INTO public.tpc_recycling_monthly (report_month, district, recycling_tons) VALUES ('2025-01-01'::date, '士林區', 615.35) ON CONFLICT (report_month, district) DO UPDATE SET recycling_tons = EXCLUDED.recycling_tons;
INSERT INTO public.tpc_recycling_monthly (report_month, district, recycling_tons) VALUES ('2025-01-01'::date, '大同區', 171) ON CONFLICT (report_month, district) DO UPDATE SET recycling_tons = EXCLUDED.recycling_tons;
INSERT INTO public.tpc_recycling_monthly (report_month, district, recycling_tons) VALUES ('2025-01-01'::date, '大安區', 832.36) ON CONFLICT (report_month, district) DO UPDATE SET recycling_tons = EXCLUDED.recycling_tons;
INSERT INTO public.tpc_recycling_monthly (report_month, district, recycling_tons) VALUES ('2025-01-01'::date, '文山區', 735.71) ON CONFLICT (report_month, district) DO UPDATE SET recycling_tons = EXCLUDED.recycling_tons;
INSERT INTO public.tpc_recycling_monthly (report_month, district, recycling_tons) VALUES ('2025-01-01'::date, '松山區', 488.92) ON CONFLICT (report_month, district) DO UPDATE SET recycling_tons = EXCLUDED.recycling_tons;
INSERT INTO public.tpc_recycling_monthly (report_month, district, recycling_tons) VALUES ('2025-01-01'::date, '萬華區', 372.81) ON CONFLICT (report_month, district) DO UPDATE SET recycling_tons = EXCLUDED.recycling_tons;
INSERT INTO public.tpc_recycling_monthly (report_month, district, recycling_tons) VALUES ('2025-02-01'::date, '中山區', 518.02) ON CONFLICT (report_month, district) DO UPDATE SET recycling_tons = EXCLUDED.recycling_tons;
INSERT INTO public.tpc_recycling_monthly (report_month, district, recycling_tons) VALUES ('2025-02-01'::date, '中正區', 231.76) ON CONFLICT (report_month, district) DO UPDATE SET recycling_tons = EXCLUDED.recycling_tons;
INSERT INTO public.tpc_recycling_monthly (report_month, district, recycling_tons) VALUES ('2025-02-01'::date, '信義區', 360.11) ON CONFLICT (report_month, district) DO UPDATE SET recycling_tons = EXCLUDED.recycling_tons;
INSERT INTO public.tpc_recycling_monthly (report_month, district, recycling_tons) VALUES ('2025-02-01'::date, '內湖區', 435.56) ON CONFLICT (report_month, district) DO UPDATE SET recycling_tons = EXCLUDED.recycling_tons;
INSERT INTO public.tpc_recycling_monthly (report_month, district, recycling_tons) VALUES ('2025-02-01'::date, '北投區', 287.51) ON CONFLICT (report_month, district) DO UPDATE SET recycling_tons = EXCLUDED.recycling_tons;
INSERT INTO public.tpc_recycling_monthly (report_month, district, recycling_tons) VALUES ('2025-02-01'::date, '南港區', 161.37) ON CONFLICT (report_month, district) DO UPDATE SET recycling_tons = EXCLUDED.recycling_tons;
INSERT INTO public.tpc_recycling_monthly (report_month, district, recycling_tons) VALUES ('2025-02-01'::date, '士林區', 415.14) ON CONFLICT (report_month, district) DO UPDATE SET recycling_tons = EXCLUDED.recycling_tons;
INSERT INTO public.tpc_recycling_monthly (report_month, district, recycling_tons) VALUES ('2025-02-01'::date, '大同區', 112.04) ON CONFLICT (report_month, district) DO UPDATE SET recycling_tons = EXCLUDED.recycling_tons;
INSERT INTO public.tpc_recycling_monthly (report_month, district, recycling_tons) VALUES ('2025-02-01'::date, '大安區', 583.67) ON CONFLICT (report_month, district) DO UPDATE SET recycling_tons = EXCLUDED.recycling_tons;
INSERT INTO public.tpc_recycling_monthly (report_month, district, recycling_tons) VALUES ('2025-02-01'::date, '文山區', 487.08) ON CONFLICT (report_month, district) DO UPDATE SET recycling_tons = EXCLUDED.recycling_tons;
INSERT INTO public.tpc_recycling_monthly (report_month, district, recycling_tons) VALUES ('2025-02-01'::date, '松山區', 334.82) ON CONFLICT (report_month, district) DO UPDATE SET recycling_tons = EXCLUDED.recycling_tons;
INSERT INTO public.tpc_recycling_monthly (report_month, district, recycling_tons) VALUES ('2025-02-01'::date, '萬華區', 257.63) ON CONFLICT (report_month, district) DO UPDATE SET recycling_tons = EXCLUDED.recycling_tons;
INSERT INTO public.tpc_recycling_monthly (report_month, district, recycling_tons) VALUES ('2025-03-01'::date, '中山區', 535.4) ON CONFLICT (report_month, district) DO UPDATE SET recycling_tons = EXCLUDED.recycling_tons;
INSERT INTO public.tpc_recycling_monthly (report_month, district, recycling_tons) VALUES ('2025-03-01'::date, '中正區', 238.24) ON CONFLICT (report_month, district) DO UPDATE SET recycling_tons = EXCLUDED.recycling_tons;
INSERT INTO public.tpc_recycling_monthly (report_month, district, recycling_tons) VALUES ('2025-03-01'::date, '信義區', 365.85) ON CONFLICT (report_month, district) DO UPDATE SET recycling_tons = EXCLUDED.recycling_tons;
INSERT INTO public.tpc_recycling_monthly (report_month, district, recycling_tons) VALUES ('2025-03-01'::date, '內湖區', 449.97) ON CONFLICT (report_month, district) DO UPDATE SET recycling_tons = EXCLUDED.recycling_tons;
INSERT INTO public.tpc_recycling_monthly (report_month, district, recycling_tons) VALUES ('2025-03-01'::date, '北投區', 304.94) ON CONFLICT (report_month, district) DO UPDATE SET recycling_tons = EXCLUDED.recycling_tons;
INSERT INTO public.tpc_recycling_monthly (report_month, district, recycling_tons) VALUES ('2025-03-01'::date, '南港區', 168.25) ON CONFLICT (report_month, district) DO UPDATE SET recycling_tons = EXCLUDED.recycling_tons;
INSERT INTO public.tpc_recycling_monthly (report_month, district, recycling_tons) VALUES ('2025-03-01'::date, '士林區', 426.57) ON CONFLICT (report_month, district) DO UPDATE SET recycling_tons = EXCLUDED.recycling_tons;
INSERT INTO public.tpc_recycling_monthly (report_month, district, recycling_tons) VALUES ('2025-03-01'::date, '大同區', 120.09) ON CONFLICT (report_month, district) DO UPDATE SET recycling_tons = EXCLUDED.recycling_tons;
INSERT INTO public.tpc_recycling_monthly (report_month, district, recycling_tons) VALUES ('2025-03-01'::date, '大安區', 608.7) ON CONFLICT (report_month, district) DO UPDATE SET recycling_tons = EXCLUDED.recycling_tons;
INSERT INTO public.tpc_recycling_monthly (report_month, district, recycling_tons) VALUES ('2025-03-01'::date, '文山區', 491.93) ON CONFLICT (report_month, district) DO UPDATE SET recycling_tons = EXCLUDED.recycling_tons;
INSERT INTO public.tpc_recycling_monthly (report_month, district, recycling_tons) VALUES ('2025-03-01'::date, '松山區', 351.46) ON CONFLICT (report_month, district) DO UPDATE SET recycling_tons = EXCLUDED.recycling_tons;
INSERT INTO public.tpc_recycling_monthly (report_month, district, recycling_tons) VALUES ('2025-03-01'::date, '萬華區', 271.68) ON CONFLICT (report_month, district) DO UPDATE SET recycling_tons = EXCLUDED.recycling_tons;
INSERT INTO public.tpc_recycling_monthly (report_month, district, recycling_tons) VALUES ('2025-04-01'::date, '中山區', 526.97) ON CONFLICT (report_month, district) DO UPDATE SET recycling_tons = EXCLUDED.recycling_tons;
INSERT INTO public.tpc_recycling_monthly (report_month, district, recycling_tons) VALUES ('2025-04-01'::date, '中正區', 239.57) ON CONFLICT (report_month, district) DO UPDATE SET recycling_tons = EXCLUDED.recycling_tons;
INSERT INTO public.tpc_recycling_monthly (report_month, district, recycling_tons) VALUES ('2025-04-01'::date, '信義區', 362.58) ON CONFLICT (report_month, district) DO UPDATE SET recycling_tons = EXCLUDED.recycling_tons;
INSERT INTO public.tpc_recycling_monthly (report_month, district, recycling_tons) VALUES ('2025-04-01'::date, '內湖區', 441.31) ON CONFLICT (report_month, district) DO UPDATE SET recycling_tons = EXCLUDED.recycling_tons;
INSERT INTO public.tpc_recycling_monthly (report_month, district, recycling_tons) VALUES ('2025-04-01'::date, '北投區', 302.88) ON CONFLICT (report_month, district) DO UPDATE SET recycling_tons = EXCLUDED.recycling_tons;
INSERT INTO public.tpc_recycling_monthly (report_month, district, recycling_tons) VALUES ('2025-04-01'::date, '南港區', 165.48) ON CONFLICT (report_month, district) DO UPDATE SET recycling_tons = EXCLUDED.recycling_tons;
INSERT INTO public.tpc_recycling_monthly (report_month, district, recycling_tons) VALUES ('2025-04-01'::date, '士林區', 415.81) ON CONFLICT (report_month, district) DO UPDATE SET recycling_tons = EXCLUDED.recycling_tons;
INSERT INTO public.tpc_recycling_monthly (report_month, district, recycling_tons) VALUES ('2025-04-01'::date, '大同區', 113.13) ON CONFLICT (report_month, district) DO UPDATE SET recycling_tons = EXCLUDED.recycling_tons;
INSERT INTO public.tpc_recycling_monthly (report_month, district, recycling_tons) VALUES ('2025-04-01'::date, '大安區', 592.94) ON CONFLICT (report_month, district) DO UPDATE SET recycling_tons = EXCLUDED.recycling_tons;
INSERT INTO public.tpc_recycling_monthly (report_month, district, recycling_tons) VALUES ('2025-04-01'::date, '文山區', 489.78) ON CONFLICT (report_month, district) DO UPDATE SET recycling_tons = EXCLUDED.recycling_tons;
INSERT INTO public.tpc_recycling_monthly (report_month, district, recycling_tons) VALUES ('2025-04-01'::date, '松山區', 339.32) ON CONFLICT (report_month, district) DO UPDATE SET recycling_tons = EXCLUDED.recycling_tons;
INSERT INTO public.tpc_recycling_monthly (report_month, district, recycling_tons) VALUES ('2025-04-01'::date, '萬華區', 260.07) ON CONFLICT (report_month, district) DO UPDATE SET recycling_tons = EXCLUDED.recycling_tons;
INSERT INTO public.tpc_recycling_monthly (report_month, district, recycling_tons) VALUES ('2025-05-01'::date, '中山區', 574.24) ON CONFLICT (report_month, district) DO UPDATE SET recycling_tons = EXCLUDED.recycling_tons;
INSERT INTO public.tpc_recycling_monthly (report_month, district, recycling_tons) VALUES ('2025-05-01'::date, '中正區', 263.68) ON CONFLICT (report_month, district) DO UPDATE SET recycling_tons = EXCLUDED.recycling_tons;
INSERT INTO public.tpc_recycling_monthly (report_month, district, recycling_tons) VALUES ('2025-05-01'::date, '信義區', 399.44) ON CONFLICT (report_month, district) DO UPDATE SET recycling_tons = EXCLUDED.recycling_tons;
INSERT INTO public.tpc_recycling_monthly (report_month, district, recycling_tons) VALUES ('2025-05-01'::date, '內湖區', 473.79) ON CONFLICT (report_month, district) DO UPDATE SET recycling_tons = EXCLUDED.recycling_tons;
INSERT INTO public.tpc_recycling_monthly (report_month, district, recycling_tons) VALUES ('2025-05-01'::date, '北投區', 344.11) ON CONFLICT (report_month, district) DO UPDATE SET recycling_tons = EXCLUDED.recycling_tons;
INSERT INTO public.tpc_recycling_monthly (report_month, district, recycling_tons) VALUES ('2025-05-01'::date, '南港區', 174.87) ON CONFLICT (report_month, district) DO UPDATE SET recycling_tons = EXCLUDED.recycling_tons;
INSERT INTO public.tpc_recycling_monthly (report_month, district, recycling_tons) VALUES ('2025-05-01'::date, '士林區', 452.24) ON CONFLICT (report_month, district) DO UPDATE SET recycling_tons = EXCLUDED.recycling_tons;
INSERT INTO public.tpc_recycling_monthly (report_month, district, recycling_tons) VALUES ('2025-05-01'::date, '大同區', 128.49) ON CONFLICT (report_month, district) DO UPDATE SET recycling_tons = EXCLUDED.recycling_tons;
INSERT INTO public.tpc_recycling_monthly (report_month, district, recycling_tons) VALUES ('2025-05-01'::date, '大安區', 647.22) ON CONFLICT (report_month, district) DO UPDATE SET recycling_tons = EXCLUDED.recycling_tons;
INSERT INTO public.tpc_recycling_monthly (report_month, district, recycling_tons) VALUES ('2025-05-01'::date, '文山區', 526.49) ON CONFLICT (report_month, district) DO UPDATE SET recycling_tons = EXCLUDED.recycling_tons;
INSERT INTO public.tpc_recycling_monthly (report_month, district, recycling_tons) VALUES ('2025-05-01'::date, '松山區', 380.09) ON CONFLICT (report_month, district) DO UPDATE SET recycling_tons = EXCLUDED.recycling_tons;
INSERT INTO public.tpc_recycling_monthly (report_month, district, recycling_tons) VALUES ('2025-05-01'::date, '萬華區', 284.98) ON CONFLICT (report_month, district) DO UPDATE SET recycling_tons = EXCLUDED.recycling_tons;
INSERT INTO public.tpc_recycling_monthly (report_month, district, recycling_tons) VALUES ('2025-06-01'::date, '中山區', 554.67) ON CONFLICT (report_month, district) DO UPDATE SET recycling_tons = EXCLUDED.recycling_tons;
INSERT INTO public.tpc_recycling_monthly (report_month, district, recycling_tons) VALUES ('2025-06-01'::date, '中正區', 260.4) ON CONFLICT (report_month, district) DO UPDATE SET recycling_tons = EXCLUDED.recycling_tons;
INSERT INTO public.tpc_recycling_monthly (report_month, district, recycling_tons) VALUES ('2025-06-01'::date, '信義區', 382.57) ON CONFLICT (report_month, district) DO UPDATE SET recycling_tons = EXCLUDED.recycling_tons;
INSERT INTO public.tpc_recycling_monthly (report_month, district, recycling_tons) VALUES ('2025-06-01'::date, '內湖區', 479.38) ON CONFLICT (report_month, district) DO UPDATE SET recycling_tons = EXCLUDED.recycling_tons;
INSERT INTO public.tpc_recycling_monthly (report_month, district, recycling_tons) VALUES ('2025-06-01'::date, '北投區', 329.74) ON CONFLICT (report_month, district) DO UPDATE SET recycling_tons = EXCLUDED.recycling_tons;
INSERT INTO public.tpc_recycling_monthly (report_month, district, recycling_tons) VALUES ('2025-06-01'::date, '南港區', 178.65) ON CONFLICT (report_month, district) DO UPDATE SET recycling_tons = EXCLUDED.recycling_tons;
INSERT INTO public.tpc_recycling_monthly (report_month, district, recycling_tons) VALUES ('2025-06-01'::date, '士林區', 451.3) ON CONFLICT (report_month, district) DO UPDATE SET recycling_tons = EXCLUDED.recycling_tons;
INSERT INTO public.tpc_recycling_monthly (report_month, district, recycling_tons) VALUES ('2025-06-01'::date, '大同區', 132.63) ON CONFLICT (report_month, district) DO UPDATE SET recycling_tons = EXCLUDED.recycling_tons;
INSERT INTO public.tpc_recycling_monthly (report_month, district, recycling_tons) VALUES ('2025-06-01'::date, '大安區', 630.17) ON CONFLICT (report_month, district) DO UPDATE SET recycling_tons = EXCLUDED.recycling_tons;
INSERT INTO public.tpc_recycling_monthly (report_month, district, recycling_tons) VALUES ('2025-06-01'::date, '文山區', 528.7) ON CONFLICT (report_month, district) DO UPDATE SET recycling_tons = EXCLUDED.recycling_tons;
INSERT INTO public.tpc_recycling_monthly (report_month, district, recycling_tons) VALUES ('2025-06-01'::date, '松山區', 362.14) ON CONFLICT (report_month, district) DO UPDATE SET recycling_tons = EXCLUDED.recycling_tons;
INSERT INTO public.tpc_recycling_monthly (report_month, district, recycling_tons) VALUES ('2025-06-01'::date, '萬華區', 270.14) ON CONFLICT (report_month, district) DO UPDATE SET recycling_tons = EXCLUDED.recycling_tons;
INSERT INTO public.tpc_recycling_monthly (report_month, district, recycling_tons) VALUES ('2025-07-01'::date, '中山區', 587.51) ON CONFLICT (report_month, district) DO UPDATE SET recycling_tons = EXCLUDED.recycling_tons;
INSERT INTO public.tpc_recycling_monthly (report_month, district, recycling_tons) VALUES ('2025-07-01'::date, '中正區', 271.96) ON CONFLICT (report_month, district) DO UPDATE SET recycling_tons = EXCLUDED.recycling_tons;
INSERT INTO public.tpc_recycling_monthly (report_month, district, recycling_tons) VALUES ('2025-07-01'::date, '信義區', 398.42) ON CONFLICT (report_month, district) DO UPDATE SET recycling_tons = EXCLUDED.recycling_tons;
INSERT INTO public.tpc_recycling_monthly (report_month, district, recycling_tons) VALUES ('2025-07-01'::date, '內湖區', 502.7) ON CONFLICT (report_month, district) DO UPDATE SET recycling_tons = EXCLUDED.recycling_tons;
INSERT INTO public.tpc_recycling_monthly (report_month, district, recycling_tons) VALUES ('2025-07-01'::date, '北投區', 359.15) ON CONFLICT (report_month, district) DO UPDATE SET recycling_tons = EXCLUDED.recycling_tons;
INSERT INTO public.tpc_recycling_monthly (report_month, district, recycling_tons) VALUES ('2025-07-01'::date, '南港區', 191.34) ON CONFLICT (report_month, district) DO UPDATE SET recycling_tons = EXCLUDED.recycling_tons;
INSERT INTO public.tpc_recycling_monthly (report_month, district, recycling_tons) VALUES ('2025-07-01'::date, '士林區', 477.74) ON CONFLICT (report_month, district) DO UPDATE SET recycling_tons = EXCLUDED.recycling_tons;
INSERT INTO public.tpc_recycling_monthly (report_month, district, recycling_tons) VALUES ('2025-07-01'::date, '大同區', 143.63) ON CONFLICT (report_month, district) DO UPDATE SET recycling_tons = EXCLUDED.recycling_tons;
INSERT INTO public.tpc_recycling_monthly (report_month, district, recycling_tons) VALUES ('2025-07-01'::date, '大安區', 674.07) ON CONFLICT (report_month, district) DO UPDATE SET recycling_tons = EXCLUDED.recycling_tons;
INSERT INTO public.tpc_recycling_monthly (report_month, district, recycling_tons) VALUES ('2025-07-01'::date, '文山區', 565.32) ON CONFLICT (report_month, district) DO UPDATE SET recycling_tons = EXCLUDED.recycling_tons;
INSERT INTO public.tpc_recycling_monthly (report_month, district, recycling_tons) VALUES ('2025-07-01'::date, '松山區', 379.63) ON CONFLICT (report_month, district) DO UPDATE SET recycling_tons = EXCLUDED.recycling_tons;
INSERT INTO public.tpc_recycling_monthly (report_month, district, recycling_tons) VALUES ('2025-07-01'::date, '萬華區', 291) ON CONFLICT (report_month, district) DO UPDATE SET recycling_tons = EXCLUDED.recycling_tons;
INSERT INTO public.tpc_recycling_monthly (report_month, district, recycling_tons) VALUES ('2025-08-01'::date, '中山區', 569) ON CONFLICT (report_month, district) DO UPDATE SET recycling_tons = EXCLUDED.recycling_tons;
INSERT INTO public.tpc_recycling_monthly (report_month, district, recycling_tons) VALUES ('2025-08-01'::date, '中正區', 268.26) ON CONFLICT (report_month, district) DO UPDATE SET recycling_tons = EXCLUDED.recycling_tons;
INSERT INTO public.tpc_recycling_monthly (report_month, district, recycling_tons) VALUES ('2025-08-01'::date, '信義區', 404.82) ON CONFLICT (report_month, district) DO UPDATE SET recycling_tons = EXCLUDED.recycling_tons;
INSERT INTO public.tpc_recycling_monthly (report_month, district, recycling_tons) VALUES ('2025-08-01'::date, '內湖區', 494.81) ON CONFLICT (report_month, district) DO UPDATE SET recycling_tons = EXCLUDED.recycling_tons;
INSERT INTO public.tpc_recycling_monthly (report_month, district, recycling_tons) VALUES ('2025-08-01'::date, '北投區', 350.62) ON CONFLICT (report_month, district) DO UPDATE SET recycling_tons = EXCLUDED.recycling_tons;
INSERT INTO public.tpc_recycling_monthly (report_month, district, recycling_tons) VALUES ('2025-08-01'::date, '南港區', 183.94) ON CONFLICT (report_month, district) DO UPDATE SET recycling_tons = EXCLUDED.recycling_tons;
INSERT INTO public.tpc_recycling_monthly (report_month, district, recycling_tons) VALUES ('2025-08-01'::date, '士林區', 474.81) ON CONFLICT (report_month, district) DO UPDATE SET recycling_tons = EXCLUDED.recycling_tons;
INSERT INTO public.tpc_recycling_monthly (report_month, district, recycling_tons) VALUES ('2025-08-01'::date, '大同區', 139.56) ON CONFLICT (report_month, district) DO UPDATE SET recycling_tons = EXCLUDED.recycling_tons;
INSERT INTO public.tpc_recycling_monthly (report_month, district, recycling_tons) VALUES ('2025-08-01'::date, '大安區', 676.19) ON CONFLICT (report_month, district) DO UPDATE SET recycling_tons = EXCLUDED.recycling_tons;
INSERT INTO public.tpc_recycling_monthly (report_month, district, recycling_tons) VALUES ('2025-08-01'::date, '文山區', 547.69) ON CONFLICT (report_month, district) DO UPDATE SET recycling_tons = EXCLUDED.recycling_tons;
INSERT INTO public.tpc_recycling_monthly (report_month, district, recycling_tons) VALUES ('2025-08-01'::date, '松山區', 366.11) ON CONFLICT (report_month, district) DO UPDATE SET recycling_tons = EXCLUDED.recycling_tons;
INSERT INTO public.tpc_recycling_monthly (report_month, district, recycling_tons) VALUES ('2025-08-01'::date, '萬華區', 293.37) ON CONFLICT (report_month, district) DO UPDATE SET recycling_tons = EXCLUDED.recycling_tons;
INSERT INTO public.tpc_recycling_monthly (report_month, district, recycling_tons) VALUES ('2025-09-01'::date, '中山區', 566.77) ON CONFLICT (report_month, district) DO UPDATE SET recycling_tons = EXCLUDED.recycling_tons;
INSERT INTO public.tpc_recycling_monthly (report_month, district, recycling_tons) VALUES ('2025-09-01'::date, '中正區', 269.65) ON CONFLICT (report_month, district) DO UPDATE SET recycling_tons = EXCLUDED.recycling_tons;
INSERT INTO public.tpc_recycling_monthly (report_month, district, recycling_tons) VALUES ('2025-09-01'::date, '信義區', 393) ON CONFLICT (report_month, district) DO UPDATE SET recycling_tons = EXCLUDED.recycling_tons;
INSERT INTO public.tpc_recycling_monthly (report_month, district, recycling_tons) VALUES ('2025-09-01'::date, '內湖區', 481.69) ON CONFLICT (report_month, district) DO UPDATE SET recycling_tons = EXCLUDED.recycling_tons;
INSERT INTO public.tpc_recycling_monthly (report_month, district, recycling_tons) VALUES ('2025-09-01'::date, '北投區', 336.32) ON CONFLICT (report_month, district) DO UPDATE SET recycling_tons = EXCLUDED.recycling_tons;
INSERT INTO public.tpc_recycling_monthly (report_month, district, recycling_tons) VALUES ('2025-09-01'::date, '南港區', 181.86) ON CONFLICT (report_month, district) DO UPDATE SET recycling_tons = EXCLUDED.recycling_tons;
INSERT INTO public.tpc_recycling_monthly (report_month, district, recycling_tons) VALUES ('2025-09-01'::date, '士林區', 464.14) ON CONFLICT (report_month, district) DO UPDATE SET recycling_tons = EXCLUDED.recycling_tons;
INSERT INTO public.tpc_recycling_monthly (report_month, district, recycling_tons) VALUES ('2025-09-01'::date, '大同區', 132.31) ON CONFLICT (report_month, district) DO UPDATE SET recycling_tons = EXCLUDED.recycling_tons;
INSERT INTO public.tpc_recycling_monthly (report_month, district, recycling_tons) VALUES ('2025-09-01'::date, '大安區', 668.25) ON CONFLICT (report_month, district) DO UPDATE SET recycling_tons = EXCLUDED.recycling_tons;
INSERT INTO public.tpc_recycling_monthly (report_month, district, recycling_tons) VALUES ('2025-09-01'::date, '文山區', 543.21) ON CONFLICT (report_month, district) DO UPDATE SET recycling_tons = EXCLUDED.recycling_tons;
INSERT INTO public.tpc_recycling_monthly (report_month, district, recycling_tons) VALUES ('2025-09-01'::date, '松山區', 369.03) ON CONFLICT (report_month, district) DO UPDATE SET recycling_tons = EXCLUDED.recycling_tons;
INSERT INTO public.tpc_recycling_monthly (report_month, district, recycling_tons) VALUES ('2025-09-01'::date, '萬華區', 278.49) ON CONFLICT (report_month, district) DO UPDATE SET recycling_tons = EXCLUDED.recycling_tons;
INSERT INTO public.tpc_recycling_monthly (report_month, district, recycling_tons) VALUES ('2025-10-01'::date, '中山區', 560.37) ON CONFLICT (report_month, district) DO UPDATE SET recycling_tons = EXCLUDED.recycling_tons;
INSERT INTO public.tpc_recycling_monthly (report_month, district, recycling_tons) VALUES ('2025-10-01'::date, '中正區', 257.74) ON CONFLICT (report_month, district) DO UPDATE SET recycling_tons = EXCLUDED.recycling_tons;
INSERT INTO public.tpc_recycling_monthly (report_month, district, recycling_tons) VALUES ('2025-10-01'::date, '信義區', 392.34) ON CONFLICT (report_month, district) DO UPDATE SET recycling_tons = EXCLUDED.recycling_tons;
INSERT INTO public.tpc_recycling_monthly (report_month, district, recycling_tons) VALUES ('2025-10-01'::date, '內湖區', 482.41) ON CONFLICT (report_month, district) DO UPDATE SET recycling_tons = EXCLUDED.recycling_tons;
INSERT INTO public.tpc_recycling_monthly (report_month, district, recycling_tons) VALUES ('2025-10-01'::date, '北投區', 339.19) ON CONFLICT (report_month, district) DO UPDATE SET recycling_tons = EXCLUDED.recycling_tons;
INSERT INTO public.tpc_recycling_monthly (report_month, district, recycling_tons) VALUES ('2025-10-01'::date, '南港區', 176.43) ON CONFLICT (report_month, district) DO UPDATE SET recycling_tons = EXCLUDED.recycling_tons;
INSERT INTO public.tpc_recycling_monthly (report_month, district, recycling_tons) VALUES ('2025-10-01'::date, '士林區', 463.4) ON CONFLICT (report_month, district) DO UPDATE SET recycling_tons = EXCLUDED.recycling_tons;
INSERT INTO public.tpc_recycling_monthly (report_month, district, recycling_tons) VALUES ('2025-10-01'::date, '大同區', 133) ON CONFLICT (report_month, district) DO UPDATE SET recycling_tons = EXCLUDED.recycling_tons;
INSERT INTO public.tpc_recycling_monthly (report_month, district, recycling_tons) VALUES ('2025-10-01'::date, '大安區', 657.92) ON CONFLICT (report_month, district) DO UPDATE SET recycling_tons = EXCLUDED.recycling_tons;
INSERT INTO public.tpc_recycling_monthly (report_month, district, recycling_tons) VALUES ('2025-10-01'::date, '文山區', 540.75) ON CONFLICT (report_month, district) DO UPDATE SET recycling_tons = EXCLUDED.recycling_tons;
INSERT INTO public.tpc_recycling_monthly (report_month, district, recycling_tons) VALUES ('2025-10-01'::date, '松山區', 355.07) ON CONFLICT (report_month, district) DO UPDATE SET recycling_tons = EXCLUDED.recycling_tons;
INSERT INTO public.tpc_recycling_monthly (report_month, district, recycling_tons) VALUES ('2025-10-01'::date, '萬華區', 279.33) ON CONFLICT (report_month, district) DO UPDATE SET recycling_tons = EXCLUDED.recycling_tons;
INSERT INTO public.tpc_recycling_monthly (report_month, district, recycling_tons) VALUES ('2025-11-01'::date, '中山區', 551.13) ON CONFLICT (report_month, district) DO UPDATE SET recycling_tons = EXCLUDED.recycling_tons;
INSERT INTO public.tpc_recycling_monthly (report_month, district, recycling_tons) VALUES ('2025-11-01'::date, '中正區', 253.53) ON CONFLICT (report_month, district) DO UPDATE SET recycling_tons = EXCLUDED.recycling_tons;
INSERT INTO public.tpc_recycling_monthly (report_month, district, recycling_tons) VALUES ('2025-11-01'::date, '信義區', 385.32) ON CONFLICT (report_month, district) DO UPDATE SET recycling_tons = EXCLUDED.recycling_tons;
INSERT INTO public.tpc_recycling_monthly (report_month, district, recycling_tons) VALUES ('2025-11-01'::date, '內湖區', 486.56) ON CONFLICT (report_month, district) DO UPDATE SET recycling_tons = EXCLUDED.recycling_tons;
INSERT INTO public.tpc_recycling_monthly (report_month, district, recycling_tons) VALUES ('2025-11-01'::date, '北投區', 343.22) ON CONFLICT (report_month, district) DO UPDATE SET recycling_tons = EXCLUDED.recycling_tons;
INSERT INTO public.tpc_recycling_monthly (report_month, district, recycling_tons) VALUES ('2025-11-01'::date, '南港區', 178.95) ON CONFLICT (report_month, district) DO UPDATE SET recycling_tons = EXCLUDED.recycling_tons;
INSERT INTO public.tpc_recycling_monthly (report_month, district, recycling_tons) VALUES ('2025-11-01'::date, '士林區', 431.98) ON CONFLICT (report_month, district) DO UPDATE SET recycling_tons = EXCLUDED.recycling_tons;
INSERT INTO public.tpc_recycling_monthly (report_month, district, recycling_tons) VALUES ('2025-11-01'::date, '大同區', 136.45) ON CONFLICT (report_month, district) DO UPDATE SET recycling_tons = EXCLUDED.recycling_tons;
INSERT INTO public.tpc_recycling_monthly (report_month, district, recycling_tons) VALUES ('2025-11-01'::date, '大安區', 650.33) ON CONFLICT (report_month, district) DO UPDATE SET recycling_tons = EXCLUDED.recycling_tons;
INSERT INTO public.tpc_recycling_monthly (report_month, district, recycling_tons) VALUES ('2025-11-01'::date, '文山區', 527.73) ON CONFLICT (report_month, district) DO UPDATE SET recycling_tons = EXCLUDED.recycling_tons;
INSERT INTO public.tpc_recycling_monthly (report_month, district, recycling_tons) VALUES ('2025-11-01'::date, '松山區', 357.94) ON CONFLICT (report_month, district) DO UPDATE SET recycling_tons = EXCLUDED.recycling_tons;
INSERT INTO public.tpc_recycling_monthly (report_month, district, recycling_tons) VALUES ('2025-11-01'::date, '萬華區', 281.87) ON CONFLICT (report_month, district) DO UPDATE SET recycling_tons = EXCLUDED.recycling_tons;
INSERT INTO public.tpc_recycling_monthly (report_month, district, recycling_tons) VALUES ('2025-12-01'::date, '中山區', 607.8) ON CONFLICT (report_month, district) DO UPDATE SET recycling_tons = EXCLUDED.recycling_tons;
INSERT INTO public.tpc_recycling_monthly (report_month, district, recycling_tons) VALUES ('2025-12-01'::date, '中正區', 269.1) ON CONFLICT (report_month, district) DO UPDATE SET recycling_tons = EXCLUDED.recycling_tons;
INSERT INTO public.tpc_recycling_monthly (report_month, district, recycling_tons) VALUES ('2025-12-01'::date, '信義區', 429.91) ON CONFLICT (report_month, district) DO UPDATE SET recycling_tons = EXCLUDED.recycling_tons;
INSERT INTO public.tpc_recycling_monthly (report_month, district, recycling_tons) VALUES ('2025-12-01'::date, '內湖區', 513.75) ON CONFLICT (report_month, district) DO UPDATE SET recycling_tons = EXCLUDED.recycling_tons;
INSERT INTO public.tpc_recycling_monthly (report_month, district, recycling_tons) VALUES ('2025-12-01'::date, '北投區', 363.44) ON CONFLICT (report_month, district) DO UPDATE SET recycling_tons = EXCLUDED.recycling_tons;
INSERT INTO public.tpc_recycling_monthly (report_month, district, recycling_tons) VALUES ('2025-12-01'::date, '南港區', 175.89) ON CONFLICT (report_month, district) DO UPDATE SET recycling_tons = EXCLUDED.recycling_tons;
INSERT INTO public.tpc_recycling_monthly (report_month, district, recycling_tons) VALUES ('2025-12-01'::date, '士林區', 458.34) ON CONFLICT (report_month, district) DO UPDATE SET recycling_tons = EXCLUDED.recycling_tons;
INSERT INTO public.tpc_recycling_monthly (report_month, district, recycling_tons) VALUES ('2025-12-01'::date, '大同區', 147.41) ON CONFLICT (report_month, district) DO UPDATE SET recycling_tons = EXCLUDED.recycling_tons;
INSERT INTO public.tpc_recycling_monthly (report_month, district, recycling_tons) VALUES ('2025-12-01'::date, '大安區', 705.37) ON CONFLICT (report_month, district) DO UPDATE SET recycling_tons = EXCLUDED.recycling_tons;
INSERT INTO public.tpc_recycling_monthly (report_month, district, recycling_tons) VALUES ('2025-12-01'::date, '文山區', 560.34) ON CONFLICT (report_month, district) DO UPDATE SET recycling_tons = EXCLUDED.recycling_tons;
INSERT INTO public.tpc_recycling_monthly (report_month, district, recycling_tons) VALUES ('2025-12-01'::date, '松山區', 396.36) ON CONFLICT (report_month, district) DO UPDATE SET recycling_tons = EXCLUDED.recycling_tons;
INSERT INTO public.tpc_recycling_monthly (report_month, district, recycling_tons) VALUES ('2025-12-01'::date, '萬華區', 293.61) ON CONFLICT (report_month, district) DO UPDATE SET recycling_tons = EXCLUDED.recycling_tons;
INSERT INTO public.tpc_recycling_monthly (report_month, district, recycling_tons) VALUES ('2026-01-01'::date, '中山區', 659.31) ON CONFLICT (report_month, district) DO UPDATE SET recycling_tons = EXCLUDED.recycling_tons;
INSERT INTO public.tpc_recycling_monthly (report_month, district, recycling_tons) VALUES ('2026-01-01'::date, '中正區', 304.51) ON CONFLICT (report_month, district) DO UPDATE SET recycling_tons = EXCLUDED.recycling_tons;
INSERT INTO public.tpc_recycling_monthly (report_month, district, recycling_tons) VALUES ('2026-01-01'::date, '信義區', 464.42) ON CONFLICT (report_month, district) DO UPDATE SET recycling_tons = EXCLUDED.recycling_tons;
INSERT INTO public.tpc_recycling_monthly (report_month, district, recycling_tons) VALUES ('2026-01-01'::date, '內湖區', 579.84) ON CONFLICT (report_month, district) DO UPDATE SET recycling_tons = EXCLUDED.recycling_tons;
INSERT INTO public.tpc_recycling_monthly (report_month, district, recycling_tons) VALUES ('2026-01-01'::date, '北投區', 418.92) ON CONFLICT (report_month, district) DO UPDATE SET recycling_tons = EXCLUDED.recycling_tons;
INSERT INTO public.tpc_recycling_monthly (report_month, district, recycling_tons) VALUES ('2026-01-01'::date, '南港區', 221.78) ON CONFLICT (report_month, district) DO UPDATE SET recycling_tons = EXCLUDED.recycling_tons;
INSERT INTO public.tpc_recycling_monthly (report_month, district, recycling_tons) VALUES ('2026-01-01'::date, '士林區', 528.47) ON CONFLICT (report_month, district) DO UPDATE SET recycling_tons = EXCLUDED.recycling_tons;
INSERT INTO public.tpc_recycling_monthly (report_month, district, recycling_tons) VALUES ('2026-01-01'::date, '大同區', 169.02) ON CONFLICT (report_month, district) DO UPDATE SET recycling_tons = EXCLUDED.recycling_tons;
INSERT INTO public.tpc_recycling_monthly (report_month, district, recycling_tons) VALUES ('2026-01-01'::date, '大安區', 781.4) ON CONFLICT (report_month, district) DO UPDATE SET recycling_tons = EXCLUDED.recycling_tons;
INSERT INTO public.tpc_recycling_monthly (report_month, district, recycling_tons) VALUES ('2026-01-01'::date, '文山區', 639.34) ON CONFLICT (report_month, district) DO UPDATE SET recycling_tons = EXCLUDED.recycling_tons;
INSERT INTO public.tpc_recycling_monthly (report_month, district, recycling_tons) VALUES ('2026-01-01'::date, '松山區', 432.76) ON CONFLICT (report_month, district) DO UPDATE SET recycling_tons = EXCLUDED.recycling_tons;
INSERT INTO public.tpc_recycling_monthly (report_month, district, recycling_tons) VALUES ('2026-01-01'::date, '萬華區', 330.4) ON CONFLICT (report_month, district) DO UPDATE SET recycling_tons = EXCLUDED.recycling_tons;
INSERT INTO public.tpc_recycling_monthly (report_month, district, recycling_tons) VALUES ('2026-02-01'::date, '中山區', 707.72) ON CONFLICT (report_month, district) DO UPDATE SET recycling_tons = EXCLUDED.recycling_tons;
INSERT INTO public.tpc_recycling_monthly (report_month, district, recycling_tons) VALUES ('2026-02-01'::date, '中正區', 305.7) ON CONFLICT (report_month, district) DO UPDATE SET recycling_tons = EXCLUDED.recycling_tons;
INSERT INTO public.tpc_recycling_monthly (report_month, district, recycling_tons) VALUES ('2026-02-01'::date, '信義區', 496.59) ON CONFLICT (report_month, district) DO UPDATE SET recycling_tons = EXCLUDED.recycling_tons;
INSERT INTO public.tpc_recycling_monthly (report_month, district, recycling_tons) VALUES ('2026-02-01'::date, '內湖區', 665.78) ON CONFLICT (report_month, district) DO UPDATE SET recycling_tons = EXCLUDED.recycling_tons;
INSERT INTO public.tpc_recycling_monthly (report_month, district, recycling_tons) VALUES ('2026-02-01'::date, '北投區', 413.53) ON CONFLICT (report_month, district) DO UPDATE SET recycling_tons = EXCLUDED.recycling_tons;
INSERT INTO public.tpc_recycling_monthly (report_month, district, recycling_tons) VALUES ('2026-02-01'::date, '南港區', 225.9) ON CONFLICT (report_month, district) DO UPDATE SET recycling_tons = EXCLUDED.recycling_tons;
INSERT INTO public.tpc_recycling_monthly (report_month, district, recycling_tons) VALUES ('2026-02-01'::date, '士林區', 608.8) ON CONFLICT (report_month, district) DO UPDATE SET recycling_tons = EXCLUDED.recycling_tons;
INSERT INTO public.tpc_recycling_monthly (report_month, district, recycling_tons) VALUES ('2026-02-01'::date, '大同區', 169.05) ON CONFLICT (report_month, district) DO UPDATE SET recycling_tons = EXCLUDED.recycling_tons;
INSERT INTO public.tpc_recycling_monthly (report_month, district, recycling_tons) VALUES ('2026-02-01'::date, '大安區', 835.62) ON CONFLICT (report_month, district) DO UPDATE SET recycling_tons = EXCLUDED.recycling_tons;
INSERT INTO public.tpc_recycling_monthly (report_month, district, recycling_tons) VALUES ('2026-02-01'::date, '文山區', 731.97) ON CONFLICT (report_month, district) DO UPDATE SET recycling_tons = EXCLUDED.recycling_tons;
INSERT INTO public.tpc_recycling_monthly (report_month, district, recycling_tons) VALUES ('2026-02-01'::date, '松山區', 469.34) ON CONFLICT (report_month, district) DO UPDATE SET recycling_tons = EXCLUDED.recycling_tons;
INSERT INTO public.tpc_recycling_monthly (report_month, district, recycling_tons) VALUES ('2026-02-01'::date, '萬華區', 374.33) ON CONFLICT (report_month, district) DO UPDATE SET recycling_tons = EXCLUDED.recycling_tons;
INSERT INTO public.tpc_recycling_monthly (report_month, district, recycling_tons) VALUES ('2026-03-01'::date, '中山區', 582.77) ON CONFLICT (report_month, district) DO UPDATE SET recycling_tons = EXCLUDED.recycling_tons;
INSERT INTO public.tpc_recycling_monthly (report_month, district, recycling_tons) VALUES ('2026-03-01'::date, '中正區', 265.65) ON CONFLICT (report_month, district) DO UPDATE SET recycling_tons = EXCLUDED.recycling_tons;
INSERT INTO public.tpc_recycling_monthly (report_month, district, recycling_tons) VALUES ('2026-03-01'::date, '信義區', 403.83) ON CONFLICT (report_month, district) DO UPDATE SET recycling_tons = EXCLUDED.recycling_tons;
INSERT INTO public.tpc_recycling_monthly (report_month, district, recycling_tons) VALUES ('2026-03-01'::date, '內湖區', 478.47) ON CONFLICT (report_month, district) DO UPDATE SET recycling_tons = EXCLUDED.recycling_tons;
INSERT INTO public.tpc_recycling_monthly (report_month, district, recycling_tons) VALUES ('2026-03-01'::date, '北投區', 338.99) ON CONFLICT (report_month, district) DO UPDATE SET recycling_tons = EXCLUDED.recycling_tons;
INSERT INTO public.tpc_recycling_monthly (report_month, district, recycling_tons) VALUES ('2026-03-01'::date, '南港區', 191.6) ON CONFLICT (report_month, district) DO UPDATE SET recycling_tons = EXCLUDED.recycling_tons;
INSERT INTO public.tpc_recycling_monthly (report_month, district, recycling_tons) VALUES ('2026-03-01'::date, '士林區', 444.23) ON CONFLICT (report_month, district) DO UPDATE SET recycling_tons = EXCLUDED.recycling_tons;
INSERT INTO public.tpc_recycling_monthly (report_month, district, recycling_tons) VALUES ('2026-03-01'::date, '大同區', 145.91) ON CONFLICT (report_month, district) DO UPDATE SET recycling_tons = EXCLUDED.recycling_tons;
INSERT INTO public.tpc_recycling_monthly (report_month, district, recycling_tons) VALUES ('2026-03-01'::date, '大安區', 680.16) ON CONFLICT (report_month, district) DO UPDATE SET recycling_tons = EXCLUDED.recycling_tons;
INSERT INTO public.tpc_recycling_monthly (report_month, district, recycling_tons) VALUES ('2026-03-01'::date, '文山區', 542.69) ON CONFLICT (report_month, district) DO UPDATE SET recycling_tons = EXCLUDED.recycling_tons;
INSERT INTO public.tpc_recycling_monthly (report_month, district, recycling_tons) VALUES ('2026-03-01'::date, '松山區', 372.28) ON CONFLICT (report_month, district) DO UPDATE SET recycling_tons = EXCLUDED.recycling_tons;
INSERT INTO public.tpc_recycling_monthly (report_month, district, recycling_tons) VALUES ('2026-03-01'::date, '萬華區', 285.35) ON CONFLICT (report_month, district) DO UPDATE SET recycling_tons = EXCLUDED.recycling_tons;

INSERT INTO public.tpc_recycling_mvp (district, recycling_kg)
SELECT district,
  ROUND(recycling_tons * 1000)::bigint
FROM public.tpc_recycling_monthly
WHERE report_month = (SELECT MAX(report_month) FROM public.tpc_recycling_monthly)
ON CONFLICT (district) DO UPDATE SET
  recycling_kg = EXCLUDED.recycling_kg;

COMMIT;
