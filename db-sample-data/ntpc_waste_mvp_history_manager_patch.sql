-- 新北垃圾／回收 MVP：為既有 query_charts 接上歷史圖（Manager DB）
-- 前置：dashboard 已建立 public.ntpc_waste_mvp_monthly 並匯入歷史月資料
--       （schema_ntpc_waste_mvp_monthly.sql、import_ntpc_waste_mvp_history.sql 等）
-- 套用：psql -h ... -U ... -d <postgres-manager> -v ON_ERROR_STOP=1 -f db-sample-data/ntpc_waste_mvp_history_manager_patch.sql
--
-- query_history 內 %s 須為 3 的倍數：後端依序替換為 timeStepUnit、time_from、time_to
-- （見 Taipei-City-Dashboard-BE/app/models/componentData.go GetComponentHistoryDataQuery）
-- 歷史查詢在 **dashboard** 執行，表名 public.ntpc_waste_mvp_monthly。

BEGIN;

UPDATE public.query_charts
SET
  history_config = '{"range":["year_ago","halfyear_ago"],"color":["#22c55e","#4ade80"],"unit":"公噸"}'::json,
  query_history = $q$
SELECT
  date_trunc('%s', report_month::timestamp) AS x_axis,
  '資源回收量(公噸)' AS y_axis,
  SUM(recycling_tons)::double precision AS data
FROM public.ntpc_waste_mvp_monthly
WHERE report_month >= (('%s'::timestamptz) AT TIME ZONE 'Asia/Taipei')::date
  AND report_month <= (('%s'::timestamptz) AT TIME ZONE 'Asia/Taipei')::date
GROUP BY 1
ORDER BY 1
$q$,
  long_desc = '新北市各行政區資源回收量（區小計／總計），單位：公噸（由公斤換算）。資料期別：中華民國115年3月。歷史圖為全市各月加總（來自 ntpc_waste_mvp_monthly）。',
  updated_at = NOW()
WHERE index = 'ntpc_recycling_map_mvp' AND city = 'metrotaipei';

UPDATE public.query_charts
SET
  history_config = '{"range":["year_ago","halfyear_ago"],"color":["#fbbf24","#f59e0b"],"unit":"公噸"}'::json,
  query_history = $q$
SELECT
  date_trunc('%s', report_month::timestamp) AS x_axis,
  '廚餘回收量(公噸)' AS y_axis,
  SUM(kitchen_tons)::double precision AS data
FROM public.ntpc_waste_mvp_monthly
WHERE report_month >= (('%s'::timestamptz) AT TIME ZONE 'Asia/Taipei')::date
  AND report_month <= (('%s'::timestamptz) AT TIME ZONE 'Asia/Taipei')::date
GROUP BY 1
ORDER BY 1
$q$,
  long_desc = '新北市各行政區廚餘回收量，單位：公噸（由原月報公噸換算後以整數公噸呈現）。資料期別：中華民國115年2月。歷史圖為全市各月加總（來自 ntpc_waste_mvp_monthly）。',
  updated_at = NOW()
WHERE index = 'ntpc_kitchen_waste_map_mvp' AND city = 'metrotaipei';

UPDATE public.query_charts
SET
  history_config = '{"range":["year_ago","halfyear_ago"],"color":["#22c55e","#4ade80"],"unit":"公噸"}'::json,
  query_history = $q$
SELECT
  date_trunc('%s', report_month::timestamp) AS x_axis,
  '資源回收量(公噸)' AS y_axis,
  SUM(recycling_tons)::double precision AS data
FROM (
  SELECT report_month, recycling_tons FROM public.ntpc_waste_mvp_monthly
  UNION ALL
  SELECT report_month, recycling_tons FROM public.tpc_recycling_monthly
) AS u
WHERE report_month >= (('%s'::timestamptz) AT TIME ZONE 'Asia/Taipei')::date
  AND report_month <= (('%s'::timestamptz) AT TIME ZONE 'Asia/Taipei')::date
GROUP BY 1
ORDER BY 1
$q$,
  long_desc = '臺北、新北各行政區資源回收量（清潔隊／環保單位口徑），單位：公噸。歷史圖為兩市各區該月加總後再依月加總。',
  updated_at = NOW()
WHERE index = 'metro_recycling_map_mvp' AND city = 'metrotaipei';

UPDATE public.query_charts
SET
  history_config = '{"range":["year_ago","halfyear_ago"],"color":["#fbbf24","#f59e0b"],"unit":"公噸"}'::json,
  query_history = $q$
SELECT
  date_trunc('%s', report_month::timestamp) AS x_axis,
  '廚餘回收量(公噸)' AS y_axis,
  SUM(kitchen_tons)::double precision AS data
FROM (
  SELECT report_month, kitchen_tons FROM public.ntpc_waste_mvp_monthly
  UNION ALL
  SELECT report_month, kitchen_tons FROM public.tpc_kitchen_monthly
) AS u
WHERE report_month >= (('%s'::timestamptz) AT TIME ZONE 'Asia/Taipei')::date
  AND report_month <= (('%s'::timestamptz) AT TIME ZONE 'Asia/Taipei')::date
GROUP BY 1
ORDER BY 1
$q$,
  long_desc = '臺北、新北各行政區廚餘回收量，單位：公噸。歷史圖為兩市各區該月加總後再依月加總（ntpc_waste_mvp_monthly ∪ tpc_kitchen_monthly）。',
  updated_at = NOW()
WHERE index = 'metro_kitchen_waste_map_mvp' AND city = 'metrotaipei';

COMMIT;
