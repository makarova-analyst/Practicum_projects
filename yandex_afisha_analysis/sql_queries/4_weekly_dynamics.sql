-- 4. Недельная динамика метрик (RUB)
SELECT
    DATE(DATE_TRUNC('week', created_dt_msk)) AS week,  -- выделяем неделю из даты
    SUM(revenue) AS total_revenue,          -- суммарная выручка
    COUNT(order_id) AS total_orders,        -- число заказов 
    COUNT(DISTINCT user_id) AS total_users, -- уникальное число клиентов
    SUM(revenue) / COUNT(order_id) AS revenue_per_order -- средняя стоимость одного заказа
FROM afisha.purchases
WHERE currency_code = 'rub'
GROUP BY DATE_TRUNC('week', created_dt_msk)
ORDER BY week ASC;
