-- Название: Расчёт среднего чека
-- Проект: Анализ сервиса доставки еды «Всё.из.кафе»
-- Рассчитываем величину комиссии с каждого заказа, отбираем заказы по дате и городу
WITH orders AS
    (SELECT *,
            revenue * commission AS commission_revenue  -- Расчет комиссии сервиса с каждого заказа
     FROM analytics_events
     JOIN cities ON analytics_events.city_id = cities.city_id  -- Соединяем с городами для фильтрации
     WHERE revenue IS NOT NULL                           -- Исключаем записи без информации о выручке
         AND log_date BETWEEN '2021-05-01' AND '2021-06-30'  -- Период анализа: май-июнь 2021
         AND city_name = 'Саранск')

-- Основной запрос: агрегация метрик по месяцам
SELECT 
    CAST(DATE_TRUNC('month', log_date) AS date)   -- Выделяем месяц
 AS "Месяц",
    COUNT(DISTINCT order_id) AS "Количество заказов",  -- Общее количество уникальных заказов за месяц
    ROUND(SUM(commission_revenue)::numeric, 2) AS "Сумма комиссии",  -- Общая комиссия сервиса (доход)
    ROUND((SUM(commission_revenue) / COUNT(DISTINCT order_id))::numeric, 2) AS "Средний чек"  -- Расчет среднего чека
FROM orders
GROUP BY CAST(DATE_TRUNC('month', log_date) AS date)   -- Группируем по месяцам
ORDER BY "Месяц" ASC
