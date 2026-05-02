-- 將回收／廚餘圖表查詢還原為依行政區名排序（ORDER BY 1），與矩形圖「不降冪」一致。
-- 若曾執行降冪版，可再跑本檔還原。
-- psql -h ... -U ... -d <manager_db> -v ON_ERROR_STOP=1 -f db-sample-data/ntpc_waste_mvp_query_order_desc.sql

BEGIN;

UPDATE public.query_charts
SET
  query_chart = $q$SELECT district AS x_axis,
       '資源回收量(公噸)' AS y_axis,
       ''::text AS icon,
       ROUND((recycling_kg::numeric / 1000.0), 2)::double precision AS data
FROM public.ntpc_waste_mvp
ORDER BY 1$q$,
  updated_at = NOW()
WHERE index = 'ntpc_recycling_map_mvp' AND city = 'metrotaipei';

UPDATE public.query_charts
SET
  query_chart = $q$SELECT district AS x_axis,
       '資源回收量(公噸)' AS y_axis,
       ''::text AS icon,
       ROUND((recycling_kg::numeric / 1000.0), 2)::double precision AS data
FROM (
  SELECT district, recycling_kg FROM public.ntpc_waste_mvp
  UNION ALL
  SELECT district, recycling_kg FROM public.tpc_recycling_mvp
) AS u
ORDER BY 1$q$,
  updated_at = NOW()
WHERE index = 'metro_recycling_map_mvp' AND city = 'metrotaipei';

UPDATE public.query_charts
SET
  query_chart = $q$SELECT district AS x_axis,
       '廚餘回收量(公噸)' AS y_axis,
       ''::text AS icon,
       ROUND((kitchen_kg::numeric / 1000.0), 2)::double precision AS data
FROM public.ntpc_waste_mvp
ORDER BY 1$q$,
  updated_at = NOW()
WHERE index = 'ntpc_kitchen_waste_map_mvp' AND city = 'metrotaipei';

UPDATE public.query_charts
SET
  query_chart = $q$SELECT district AS x_axis,
       '廚餘回收量(公噸)' AS y_axis,
       ''::text AS icon,
       ROUND((kitchen_kg::numeric / 1000.0), 2)::double precision AS data
FROM (
  SELECT district, kitchen_kg FROM public.ntpc_waste_mvp
  UNION ALL
  SELECT district, kitchen_kg FROM public.tpc_kitchen_mvp
) AS u
ORDER BY 1$q$,
  updated_at = NOW()
WHERE index = 'metro_kitchen_waste_map_mvp' AND city = 'metrotaipei';

COMMIT;
