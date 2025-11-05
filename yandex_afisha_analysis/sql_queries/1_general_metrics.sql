-- 1. Общие ключевые метрики по валютам
SELECT
    currency_code,                          
    SUM(revenue) AS total_revenue,          -- общая выручка с заказов  
    COUNT(order_id) AS total_orders,        -- количество заказов
    AVG(revenue) AS avg_revenue_per_order,  -- средняя стоимость заказа
    COUNT(DISTINCT user_id) AS total_users  -- общее число уникальных клиентов
FROM afisha.purchases
GROUP BY currency_code
ORDER BY total_revenue DESC;
