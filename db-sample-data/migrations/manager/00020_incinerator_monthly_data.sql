-- +goose NO TRANSACTION
-- source: db-sample-data/update_incinerator_monthly_data.sql

-- +goose Up
SET search_path TO public;

BEGIN;

-- 1. 更新地圖圖層屬性顯示 (使用「實際處理量」與「月」單位)
UPDATE component_maps 
SET property = '[{"key":"name","name":"焚化廠名稱"},{"key":"capacity_ratio_pct","name":"焚化量能比率"},{"key":"district","name":"行政區"},{"key":"actual_volume_month","name":"總焚化量 (公噸/月)"}]'::json
WHERE index = 'incinerator_capacity';

-- 2. 更新圖表查詢 (使用實際月處理量資料)
UPDATE query_charts 
SET query_chart = $q$
SELECT district AS x_axis, 
       '焚化量能比率 (%)' AS y_axis, 
       round(capacity_ratio * 100) AS data 
FROM (VALUES 
    ('北投區', 0.688, 41304),
    ('文山區', 0.584, 31530),
    ('內湖區', 0.529, 14272),
    ('八里區', 0.900, 54000),
    ('新店區', 0.750, 45000),
    ('樹林區', 0.633, 38000)
) AS t(district, capacity_ratio, actual_volume)
UNION ALL
SELECT district AS x_axis, 
       '總焚化量 (公噸/月)' AS y_axis, 
       actual_volume AS data 
FROM (VALUES 
    ('北投區', 0.688, 41304),
    ('文山區', 0.584, 31530),
    ('內湖區', 0.529, 14272),
    ('八里區', 0.900, 54000),
    ('新店區', 0.750, 45000),
    ('樹林區', 0.633, 38000)
) AS t(district, capacity_ratio, actual_volume)
ORDER BY x_axis
$q$
WHERE index = 'incinerator_capacity';

COMMIT;

-- +goose Down
-- TODO: 視需要填寫回滾 SQL
