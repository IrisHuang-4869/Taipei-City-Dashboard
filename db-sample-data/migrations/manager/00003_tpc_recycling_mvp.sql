-- +goose NO TRANSACTION
-- source: db-sample-data/tpc_recycling_mvp_manager_patch.sql

-- +goose Up
SET search_path TO public;

-- 臺北市資源回收地圖（PDF 彙整）：component_maps 152、components 302；併入 garbage_map_metrotaipei
-- 前置：
--   1) db-sample-data/generated/import_tpc_recycling_from_pdf.sql（cd scripts && node build_tpc_recycling_sql.mjs）
--   2) **dashboard** DB 須先執行上述 import（含 tpc_recycling_mvp / tpc_recycling_monthly），否則圖表查詢會失敗
--   3) FE 須能取得 /mapData/tpc_recycling_map_mvp.geojson（建置後已於 repo 內）
-- 套用：psql -h ... -U ... -d <manager_db> -v ON_ERROR_STOP=1 -f db-sample-data/tpc_recycling_mvp_manager_patch.sql
--
-- 若前端仍只看到新北：① 確認本檔已對 **dashboardmanager** 執行成功 ② 儀表板列已含 302：
--   SELECT index, components FROM dashboards WHERE index = 'garbage_map_metrotaipei';
-- ③ 瀏覽器強制重新整理或重登，讓 GET /dashboard 重新載入組件列表

BEGIN;

DELETE FROM query_charts
WHERE index = 'tpc_recycling_map_mvp' AND city = 'metrotaipei';
DELETE FROM component_charts WHERE index = 'tpc_recycling_map_mvp';
DELETE FROM components WHERE id = 302 OR index = 'tpc_recycling_map_mvp';
DELETE FROM component_maps WHERE id = 152 OR index = 'tpc_recycling_map_mvp';

INSERT INTO component_maps (id, index, title, type, source, size, icon, paint, property) VALUES
(152, 'tpc_recycling_map_mvp', '臺北資源回收量（分區·清潔隊）', 'fill', 'geojson', NULL, NULL,
 $paint152${
  "fill-opacity": 1,
  "fill-outline-color": "rgba(255,255,255,0.22)",
  "fill-color": ["interpolate",["linear"],["coalesce",["to-number",["get","recycling_tons"]],0],0,"#ecfdf5",200,"#d1fae5",400,"#a7f3d0",700,"#6ee7b7",1100,"#34d399",1600,"#10b981",2500,"#047857",4000,"#064e3b"]
}$paint152$::json,
 '[{"key":"TNAME","name":"區名"},{"key":"recycling_tons","name":"回收量（公噸）"}]'::json);

INSERT INTO components (id, index, name) VALUES
(302, 'tpc_recycling_map_mvp', '臺北回收地圖');

INSERT INTO component_charts (index, color, types, unit) VALUES
('tpc_recycling_map_mvp', '{#ecfdf5,#d1fae5,#a7f3d0,#6ee7b7,#34d399,#10b981,#047857,#064e3b}', '{TreemapChart,ColumnChart}', '公噸');

INSERT INTO query_charts (
  index, history_config, map_config_ids, map_filter, time_from, time_to,
  update_freq, update_freq_unit, source, short_desc, long_desc, use_case,
  links, contributors, created_at, updated_at, query_type, query_chart, query_history, city
) VALUES
(
  'tpc_recycling_map_mvp',
  '{"range":["year_ago","halfyear_ago"],"color":["#22c55e","#4ade80"],"unit":"公噸"}'::json,
  ARRAY[152]::integer[],
  '{"mode":"byParam","byParam":{"xParam":"TNAME"}}'::json,
  'static', NULL, 0, NULL,
  '臺北市政府環境保護局統計表（PDF 彙整）',
  '臺北市各行政區清潔隊資源回收量，單位：公噸。資料來源：raw/tpc_recycling_history 之年報 PDF。',
  'MVP 為單月快照（與 ntpc_waste_mvp 相同邏輯：取 tpc_recycling_monthly 最近月）。歷史圖為全市各月加總（dashboard.tpc_recycling_monthly）。',
  '與新北回收地圖同頁對照臺北市各區回收量。',
  ARRAY[]::text[], ARRAY['tpc']::text[], NOW(), NOW(), 'three_d',
  $q$SELECT district AS x_axis,
       '資源回收量(公噸)' AS y_axis,
       ''::text AS icon,
       ROUND((recycling_kg::numeric / 1000.0), 2)::double precision AS data
FROM public.tpc_recycling_mvp
ORDER BY 1$q$,
  $histtpc$
SELECT
  date_trunc('%s', report_month::timestamp) AS x_axis,
  '資源回收量(公噸)' AS y_axis,
  SUM(recycling_tons)::double precision AS data
FROM public.tpc_recycling_monthly
WHERE report_month >= (('%s'::timestamptz) AT TIME ZONE 'Asia/Taipei')::date
  AND report_month <= (('%s'::timestamptz) AT TIME ZONE 'Asia/Taipei')::date
GROUP BY 1
ORDER BY 1
$histtpc$,
  'metrotaipei'
);

UPDATE public.dashboards
SET
  components = CASE
    WHEN NOT (302 = ANY(components))
      THEN components || ARRAY[302]::integer[]
    ELSE components
  END,
  updated_at = NOW()
WHERE index = 'garbage_map_metrotaipei';

COMMIT;

-- +goose Down
-- TODO: 視需要填寫回滾 SQL
