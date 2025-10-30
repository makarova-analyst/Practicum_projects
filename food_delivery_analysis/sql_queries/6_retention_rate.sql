/*
Название: Расчёт Retention Rate
Проект: Анализ сервиса доставки еды «Всё.из.кафе»
Описание: Определим какой процент пользователей возвращается в приложение в течение первой недели после регистрации и в какие дни. 
*/

-- Выбираем новых пользователей (первое посещение) за период с 1 мая по 24 июня 2021 года (для корректного расчета недельного Retention)
WITH new_users AS (                                                      
    SELECT DISTINCT                                          
        first_date,                                          
        user_id                                              
    FROM analytics_events
    JOIN cities 
        ON analytics_events.city_id = cities.city_id
    WHERE first_date BETWEEN '2021-05-01' AND '2021-06-24'
        AND city_name = 'Саранск'
),
-- Выбираем всех активных пользователей за весь период анализа (май-июнь 2021)
active_users AS (                                             
    SELECT DISTINCT 
        log_date,
        user_id
    FROM analytics_events
    JOIN cities 
        ON analytics_events.city_id = cities.city_id
    WHERE log_date BETWEEN '2021-05-01' AND '2021-06-30'
        AND city_name = 'Саранск'
),
-- Для расчета дней с момента первого посещения соединяем новых пользователей с их активностью
daily_retention AS (
    SELECT 
        new_users.user_id,
        first_date,
        log_date::date - first_date::date AS day_since_install  -- Количество дней с момента установки
    FROM new_users
    JOIN active_users 
        ON new_users.user_id = active_users.user_id
        AND log_date >= first_date  -- Учитываем только активность после первого посещения
)
-- Финальный запрос: расчет Retention Rate по дням
SELECT 
    day_since_install,  -- День с момента первого посещения (0-7)
    COUNT(DISTINCT user_id) AS retained_users,  -- Количество вернувшихся пользователей
    ROUND(COUNT(DISTINCT user_id)::numeric / 
        MAX(COUNT(DISTINCT user_id)) OVER (ORDER BY day_since_install), 2) AS retention_rate  -- Коэффициент удержания (доля от максимального количества)
FROM daily_retention
WHERE day_since_install < 8  -- Ограничиваем анализ первой неделей (7 дней) 
GROUP BY day_since_install
ORDER BY day_since_install ASC;
