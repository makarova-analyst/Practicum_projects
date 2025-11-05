-- 5. Топ-7 регионов по выручке (RUB)
SELECT
    r.region_name AS region_name,             -- название региона
    SUM(p.revenue) AS total_revenue,          -- суммарная выручка
    COUNT(p.order_id) AS total_orders,        -- число заказов
    COUNT(DISTINCT p.user_id) AS total_users, -- уникальное число клиентов
    SUM(p.tickets_count) AS total_tickets,    -- количество проданных билетов
    SUM(p.revenue)/SUM(p.tickets_count) AS one_ticket_cost  -- средняя выручка одного билета 
FROM afisha.purchases p
JOIN afisha.events e ON p.event_id = e.event_id
JOIN afisha.city c ON e.city_id = c.city_id
JOIN afisha.regions r ON c.region_id = r.region_id
WHERE p.currency_code = 'rub'
GROUP BY r.region_name
ORDER BY total_revenue DESC
LIMIT 7;
