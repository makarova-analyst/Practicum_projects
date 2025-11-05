-- 2. Распределение выручки по устройствам (RUB)
SELECT
    device_type_canonical,         -- тип устройства
    SUM(revenue) AS total_revenue, -- общая выручка с заказов
    COUNT(order_id) AS total_orders,  -- количество заказов
    AVG(revenue) AS avg_revenue_per_order,  -- средняя стоимость заказа
    ROUND(SUM(revenue::numeric) / SUM(SUM(revenue::numeric)) OVER(), 3) AS revenue_share  -- доля выручки для каждого устройства
FROM afisha.purchases
WHERE currency_code = 'rub'
GROUP BY device_type_canonical
ORDER BY revenue_share DESC;
