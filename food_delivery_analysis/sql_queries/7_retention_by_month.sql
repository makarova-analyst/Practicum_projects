-- Сравнение Retention Rate по месяцам для когортного анализа
-- Проект: Анализ сервиса доставки еды «Всё.из.кафе»

WITH new_users AS (
    -- Выбираем новых пользователей с разбивкой по месяцам первой активности
    -- за период с 1 мая по 24 июня 2021 года
    SELECT DISTINCT 
        first_date, 
        user_id,
        CAST(DATE_TRUNC('month', first_date) AS date) AS "Месяц"  -- Группируем по месяцам для когортного анализа
    FROM analytics_events
    JOIN cities ON analytics_events.city_id = cities.city_id
    WHERE first_date BETWEEN '2021-05-01' AND '2021-06-24'  -- Ограничение для корректного недельного анализа
        AND city_name = 'Саранск'  
),

active_users AS (
    -- Выбираем всех активных пользователей за весь период анализа
    SELECT DISTINCT 
        log_date, 
        user_id
    FROM analytics_events
    JOIN cities ON analytics_events.city_id = cities.city_id
    WHERE log_date BETWEEN '2021-05-01' AND '2021-06-30'  -- Полный период анализа
        AND city_name = 'Саранск'  
),

daily_retention AS (
    -- Соединяем новых пользователей с их последующей активностью
    -- для расчета дней с момента первого посещения по когортам
    SELECT 
        new_users.user_id,
        first_date,
        log_date::date - first_date::date AS day_since_install,  -- Количество дней с момента первого посещения
        "Месяц"  -- Месяц когорты (май или июнь)
    FROM new_users
    JOIN active_users ON new_users.user_id = active_users.user_id
        AND log_date >= first_date  -- Учитываем только активность после первого посещения
)

-- Финальный запрос: расчет Retention Rate по когортам и дням
SELECT 
    "Месяц",                          -- Месяц когорты
    day_since_install,                -- День с момента первого посещения (0-7)
    COUNT(DISTINCT user_id) AS retained_users,  -- Количество вернувшихся пользователей
    ROUND(
        (1.0 * COUNT(DISTINCT user_id) / 
        MAX(COUNT(DISTINCT user_id)) OVER (
            PARTITION BY "Месяц" 
            ORDER BY day_since_install
        ))::numeric, 
        2
    ) AS retention_rate  -- Коэффициент удержания в рамках каждой когорты
FROM daily_retention
WHERE day_since_install < 8  -- Ограничиваем анализ первой неделей (0-7 дней)
GROUP BY "Месяц", day_since_install  -- Группируем по когорте и дню
ORDER BY "Месяц", day_since_install;  -- Сортируем по месяцу и дню 
