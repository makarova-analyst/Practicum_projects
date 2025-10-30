-- Название: Расчёт DAU
-- Проект: Анализ сервиса доставки еды «Всё.из.кафе»
-- Описание: Расчёт ежедневного количества активных пользователей в Саранске за май-июнь 2021 года

SELECT
    ae.log_date,
    COUNT(DISTINCT ae.user_id) AS DAU
FROM analytics_events AS ae
JOIN cities AS c ON ae.city_id = c.city_id
WHERE c.city_name = 'Саранск'
AND ae.event = 'order'
AND ae.log_date BETWEEN '2021-05-01' AND '2021-06-30'
GROUP BY ae.log_date
ORDER BY ae.log_date ASC;
