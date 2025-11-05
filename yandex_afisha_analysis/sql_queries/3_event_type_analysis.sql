-- 3. Распределение выручки по типам мероприятий (RUB)
SELECT
    event_type_main,                  -- тип мероприятия
    SUM(revenue) AS total_revenue,    -- общая выручка с заказов
    COUNT(order_id) AS total_orders,  -- количество заказов
    AVG(revenue) AS avg_revenue_per_order, -- средняя стоимость заказа 
    COUNT(DISTINCT event_name_code) AS total_event_name,  -- уникальное число событий 
    AVG(p.tickets_count) AS avg_tickets, -- среднее число билетов в заказе
    SUM(revenue)/SUM(tickets_count) AS avg_ticket_revenue, -- средняя выручка с одного билета
    ROUND(SUM(p.revenue::numeric) / SUM(SUM(p.revenue::numeric)) OVER(), 3) AS revenue_share -- доля выручки от общего значения 
FROM afisha.purchases p
JOIN afisha.events e ON p.event_id = e.event_id
WHERE p.currency_code = 'rub'
GROUP BY event_type_main
ORDER BY total_orders DESC;
