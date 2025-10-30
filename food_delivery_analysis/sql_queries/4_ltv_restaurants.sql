/*
Название: Расчёт LTV ресторанов
Проект: Анализ сервиса доставки еды «Всё.из.кафе»
Описание: Определите три ресторана из Саранска с наибольшим LTV с начала мая до конца июня 2021 года.
*/
-- Рассчитываем величину комиссии с каждого заказа, отбираем заказы по дате и городу
WITH orders AS
    (SELECT analytics_events.rest_id,
            analytics_events.city_id,
            revenue * commission AS commission_revenue
     FROM analytics_events
     JOIN cities ON analytics_events.city_id = cities.city_id
     WHERE revenue IS NOT NULL
         AND log_date BETWEEN '2021-05-01' AND '2021-06-30'
         AND city_name = 'Саранск')
-- Рассчитываем  LTV
SELECT
    p.rest_id,
    p.chain AS "Название сети",
    p.type AS "Тип кухни",
    ROUND(SUM(o.commission_revenue)::numeric, 2) AS LTV
FROM orders o 
JOIN partners p ON o.rest_id = p.rest_id AND o.city_id = p.city_id
GROUP BY p.rest_id, p.chain, p.type
ORDER BY LTV DESC
LIMIT 3;
