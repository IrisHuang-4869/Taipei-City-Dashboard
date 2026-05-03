-- +goose NO TRANSACTION
-- source: db-sample-data/metro_unified_query_charts_taipei_patch.sql（第三段；亦可整檔 \ir metro_unified_query_charts_taipei_patch.sql）

-- +goose Up
SET search_path TO public;

BEGIN;

DELETE FROM query_charts
WHERE city = 'taipei' AND index = 'garbage_district_compare_local';

INSERT INTO query_charts (
  index, history_config, map_config_ids, map_filter, time_from, time_to,
  update_freq, update_freq_unit, source, short_desc, long_desc, use_case,
  links, contributors, created_at, updated_at, query_type, query_chart, query_history, city
)
SELECT
  qc.index,
  qc.history_config,
  ARRAY[321]::integer[] AS map_config_ids,
  qc.map_filter,
  qc.time_from,
  qc.time_to,
  qc.update_freq,
  qc.update_freq_unit,
  qc.source,
  qc.short_desc,
  qc.long_desc,
  qc.use_case,
  qc.links,
  qc.contributors,
  NOW(),
  NOW(),
  qc.query_type,
  $garbage_flow_chart_taipei$
SELECT dist AS x_axis, '臺北市清運站數量（行政區）' AS y_axis, '' AS icon, count::double precision AS data
FROM (VALUES
  ('北投區',544),('士林區',653),('內湖區',200),('南港區',211),('松山區',106),
  ('信義區',168),('中山區',338),('大同區',251),('中正區',347),('萬華區',303),
  ('大安區',310),('文山區',581)
) AS t(dist, count)
ORDER BY 1
$garbage_flow_chart_taipei$,
  qc.query_history,
  'taipei'
FROM query_charts qc
WHERE qc.index = 'garbage_district_compare_local' AND qc.city = 'metrotaipei'
LIMIT 1;

COMMIT;

-- +goose Down
SET search_path TO public;

BEGIN;

DELETE FROM query_charts
WHERE city = 'taipei' AND index = 'garbage_district_compare_local';

COMMIT;
