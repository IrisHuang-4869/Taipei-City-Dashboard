BEGIN;

-- 更新焚化爐組件的 SQL 查詢，使其返回兩個數列（量能比率與總焚燒量）
UPDATE query_charts 
SET query_chart = $q$
SELECT district AS x_axis, 
       '處理量能比率 (%)' AS y_axis, 
       round(capacity_ratio) AS data 
FROM (VALUES 
    ('北投區', 68.84, 1800),
    ('文山區', 58.39, 1200),
    ('內湖區', 52.86, 900),
    ('八里區', 89.97, 1350),
    ('新店區', 69.56, 1500),
    ('樹林區', 62.04, 1100)
) AS t(district, capacity_ratio, total_volume)
UNION ALL
SELECT district AS x_axis, 
       '總焚燒量 (噸/日)' AS y_axis, 
       total_volume AS data 
FROM (VALUES 
    ('北投區', 68.84, 1800),
    ('文山區', 58.39, 1200),
    ('內湖區', 52.86, 900),
    ('八里區', 89.97, 1350),
    ('新店區', 69.56, 1500),
    ('樹林區', 62.04, 1100)
) AS t(district, capacity_ratio, total_volume)
ORDER BY x_axis
$q$
WHERE index = 'incinerator_capacity';

COMMIT;
