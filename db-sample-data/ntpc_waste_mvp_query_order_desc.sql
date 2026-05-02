-- 將回收／廚餘圖表查詢還原為依行政區名排序（ORDER BY 1），與矩形圖「不降冪」一致。
-- 若曾執行降冪版，可再跑本檔還原。
-- psql -h ... -U ... -d <manager_db> -v ON_ERROR_STOP=1 -f db-sample-data/ntpc_waste_mvp_query_order_desc.sql

BEGIN;

UPDATE public.query_charts
SET
  query_chart = $q$SELECT district AS x_axis,
       '資源回收量(公噸)' AS y_axis,
       ''::text AS icon,
       round(recycling_kg::numeric / 1000)::int AS data
FROM public.ntpc_waste_mvp
ORDER BY 1$q$,
  updated_at = NOW()
WHERE index = 'ntpc_recycling_map_mvp' AND city = 'metrotaipei';

UPDATE public.query_charts
SET
  query_chart = $q$SELECT district AS x_axis,
       '廚餘回收量(公噸)' AS y_axis,
       ''::text AS icon,
       round(kitchen_kg::numeric / 1000)::int AS data
FROM public.ntpc_waste_mvp
ORDER BY 1$q$,
  updated_at = NOW()
WHERE index = 'ntpc_kitchen_waste_map_mvp' AND city = 'metrotaipei';

COMMIT;
