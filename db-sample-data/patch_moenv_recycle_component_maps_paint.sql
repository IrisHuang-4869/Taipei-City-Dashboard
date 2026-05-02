-- 僅更新 MOENV 八大回收圖層的 map paint（較小半徑、無白邊）。
-- 若已在資料庫建立 moenv_wr_recycle_* 圖層，執行此檔即可，不必重跑 import_moenv_recycle_incremental.sql。
-- 依 index 更新，與 component_maps.id 是否為 111–118 無關。

BEGIN;

UPDATE component_maps SET paint = '{"circle-color":"#E170A6","circle-opacity":0.85,"circle-radius":2}'::json
WHERE index = 'moenv_wr_recycle_6ca8d697f6';
UPDATE component_maps SET paint = '{"circle-color":"#24B0DD","circle-opacity":0.85,"circle-radius":2}'::json
WHERE index = 'moenv_wr_recycle_7b805c8fa1';
UPDATE component_maps SET paint = '{"circle-color":"#56B96D","circle-opacity":0.85,"circle-radius":2}'::json
WHERE index = 'moenv_wr_recycle_6a4bc66658';
UPDATE component_maps SET paint = '{"circle-color":"#F8CF58","circle-opacity":0.85,"circle-radius":2}'::json
WHERE index = 'moenv_wr_recycle_014ce45e54';
UPDATE component_maps SET paint = '{"circle-color":"#F5AD4A","circle-opacity":0.85,"circle-radius":2}'::json
WHERE index = 'moenv_wr_recycle_8863327e9b';
UPDATE component_maps SET paint = '{"circle-color":"#9DC56E","circle-opacity":0.85,"circle-radius":2}'::json
WHERE index = 'moenv_wr_recycle_c5e75de7e7';
UPDATE component_maps SET paint = '{"circle-color":"#8B5CF6","circle-opacity":0.85,"circle-radius":2}'::json
WHERE index = 'moenv_wr_recycle_e62fbe91a5';
UPDATE component_maps SET paint = '{"circle-color":"#ED6A45","circle-opacity":0.85,"circle-radius":2}'::json
WHERE index = 'moenv_wr_recycle_4554828c57';

COMMIT;
