-- +goose NO TRANSACTION
-- 組件顯示名稱：廚餘（雙北）→ 廚餘回收量統計

-- +goose Up
SET search_path TO public;

UPDATE public.components
SET name = '廚餘回收量統計'
WHERE index = 'metro_kitchen_waste_map_mvp';

-- +goose Down
SET search_path TO public;

UPDATE public.components
SET name = '廚餘（雙北）'
WHERE index = 'metro_kitchen_waste_map_mvp';
