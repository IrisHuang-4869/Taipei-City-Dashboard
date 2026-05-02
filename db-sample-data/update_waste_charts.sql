BEGIN;

UPDATE query_charts SET query_chart = $q$
WITH pop_data(district, pop) AS (
  VALUES
  ('松山區', 189917),('信義區', 203780),('大安區', 276785),('中山區', 212959),('中正區', 148011),
  ('大同區', 118933),('萬華區', 173041),('文山區', 257551),('南港區', 112750),('內湖區', 273398),
  ('士林區', 262973),('北投區', 241551),('板橋區', 554160),('三重區', 383617),('中和區', 403982),
  ('永和區', 212456),('新莊區', 423668),('新店區', 304728),('樹林區', 180121),('鶯歌區', 88410),
  ('三峽區', 115274),('淡水區', 196236),('汐止區', 209673),('瑞芳區', 37424),('土城區', 238814),
  ('蘆洲區', 200055),('五股區', 91439),('泰山區', 77320),('林口區', 133748),('深坑區', 23528),
  ('石碇區', 7230),('坪林區', 6540),('三芝區', 22204),('石門區', 10960),('八里區', 41302),
  ('平溪區', 4216),('雙溪區', 8102),('貢寮區', 11100),('金山區', 20500),('萬里區', 21100),('烏來區', 6285)
),
kitchen_data AS (
   SELECT district, kitchen_kg FROM public.ntpc_waste_mvp
   UNION ALL
   SELECT district, kitchen_kg FROM public.tpc_kitchen_mvp
)
SELECT k.district AS x_axis,
       '人均廚餘回收量 (公斤)' AS y_axis,
       ROUND((k.kitchen_kg::numeric / p.pop), 2)::double precision AS data
FROM kitchen_data k JOIN pop_data p ON k.district = p.district
UNION ALL
SELECT k.district AS x_axis,
       '總廚餘回收量 (公噸)' AS y_axis,
       ROUND((k.kitchen_kg::numeric / 1000.0), 2)::double precision AS data
FROM kitchen_data k JOIN pop_data p ON k.district = p.district
ORDER BY x_axis
$q$
WHERE index = 'metro_kitchen_waste_map_mvp';

UPDATE query_charts SET query_chart = $q$
WITH pop_data(district, pop) AS (
  VALUES
  ('松山區', 189917),('信義區', 203780),('大安區', 276785),('中山區', 212959),('中正區', 148011),
  ('大同區', 118933),('萬華區', 173041),('文山區', 257551),('南港區', 112750),('內湖區', 273398),
  ('士林區', 262973),('北投區', 241551),('板橋區', 554160),('三重區', 383617),('中和區', 403982),
  ('永和區', 212456),('新莊區', 423668),('新店區', 304728),('樹林區', 180121),('鶯歌區', 88410),
  ('三峽區', 115274),('淡水區', 196236),('汐止區', 209673),('瑞芳區', 37424),('土城區', 238814),
  ('蘆洲區', 200055),('五股區', 91439),('泰山區', 77320),('林口區', 133748),('深坑區', 23528),
  ('石碇區', 7230),('坪林區', 6540),('三芝區', 22204),('石門區', 10960),('八里區', 41302),
  ('平溪區', 4216),('雙溪區', 8102),('貢寮區', 11100),('金山區', 20500),('萬里區', 21100),('烏來區', 6285)
),
recycling_data AS (
   SELECT district, recycling_kg FROM public.ntpc_waste_mvp
   UNION ALL
   SELECT district, recycling_kg FROM public.tpc_recycling_mvp
)
SELECT r.district AS x_axis,
       '人均資源回收量 (公斤)' AS y_axis,
       ROUND((r.recycling_kg::numeric / p.pop), 2)::double precision AS data
FROM recycling_data r JOIN pop_data p ON r.district = p.district
UNION ALL
SELECT r.district AS x_axis,
       '總資源回收量 (公噸)' AS y_axis,
       ROUND((r.recycling_kg::numeric / 1000.0), 2)::double precision AS data
FROM recycling_data r JOIN pop_data p ON r.district = p.district
ORDER BY x_axis
$q$
WHERE index = 'metro_recycling_map_mvp';

UPDATE component_charts SET unit = '' WHERE index IN ('metro_kitchen_waste_map_mvp', 'metro_recycling_map_mvp');

COMMIT;
