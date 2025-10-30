-- Название: Расчёт DAU
-- Проект: Анализ сервиса доставки еды «Всё.из.кафе»
-- Описание: Расчёт ежедневного количества активных пользователей в Саранске за май-июнь 2021 года

SELECT
    ae.log_date,
    COUNT(DISTINCT ae.user_id) AS DAU                    -- Количество уникальных пользователей за день
FROM analytics_events AS ae
JOIN cities AS c ON ae.city_id = c.city_id               -- Соединяем с таблицей городов для фильтрации
WHERE c.city_name = 'Саранск'                            -- Фильтр: только город Саранск
AND ae.event = 'order'                                   -- Фильтр: только события типа "заказ"
AND ae.log_date BETWEEN '2021-05-01' AND '2021-06-30'    -- Период анализа: май-июнь 2021
GROUP BY ae.log_date
ORDER BY ae.log_date ASC;
