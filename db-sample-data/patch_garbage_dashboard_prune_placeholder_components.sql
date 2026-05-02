-- 移除「垃圾地圖總覽」(index garbage_map_overview, component id 219)與
-- 「垃圾地圖交叉比對」(garbage_map_cross_compare, id 220)及其專用地圖圖資
-- (component_maps id 102 / index garbage_map_cross_compare_placeholder)。
--
-- 可重複執行（DELETE / UPDATE 為冪等）。
-- psql ... -d dashboardmanager -v ON_ERROR_STOP=1 -f db-sample-data/patch_garbage_dashboard_prune_placeholder_components.sql

BEGIN;

UPDATE public.dashboards
SET
  components = ARRAY_REMOVE(ARRAY_REMOVE(components, 219), 220),
  updated_at = NOW()
WHERE
  components IS NOT NULL
  AND (
    219 = ANY (components)
    OR 220 = ANY (components)
  );

DELETE FROM public.query_charts
WHERE index IN ('garbage_map_overview', 'garbage_map_cross_compare');

DELETE FROM public.component_charts
WHERE index IN ('garbage_map_overview', 'garbage_map_cross_compare');

DELETE FROM public.components
WHERE id IN (219, 220)
   OR index IN ('garbage_map_overview', 'garbage_map_cross_compare');

DELETE FROM public.component_maps
WHERE id = 102
   OR index = 'garbage_map_cross_compare_placeholder';

COMMIT;
