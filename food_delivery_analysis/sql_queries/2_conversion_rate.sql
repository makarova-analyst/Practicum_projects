-- Название: Расчёт Conversion Rate (CR)
-- Проект: Анализ сервиса доставки еды «Всё.из.кафе»

SELECT 
    ae.log_date,
    ROUND(COUNT(DISTINCT ae.user_id) filter (WHERE ae.event ='order')/  -- Пользователи с заказами
          COUNT(DISTINCT ae.user_id)::numeric, 2) AS CR                 -- Все уникальные пользователи за день
FROM analytics_events AS ae
JOIN cities AS c ON ae.city_id = c.city_id
WHERE c.city_name = 'Саранск'
AND ae.log_date BETWEEN '2021-05-01' AND '2021-06-30'
GROUP BY ae.log_date
ORDER BY ae.log_date ASC;
