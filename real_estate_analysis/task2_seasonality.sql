-- Определим аномальные значения (выбросы) по значению перцентилей:                                  Задача №2
WITH limits AS (
    SELECT  
        PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY total_area) AS total_area_limit,
        PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY rooms) AS rooms_limit,
        PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY balcony) AS balcony_limit,
        PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY ceiling_height) AS ceiling_height_limit_h,
        PERCENTILE_DISC(0.01) WITHIN GROUP (ORDER BY ceiling_height) AS ceiling_height_limit_l
    FROM real_estate.flats     
),
-- Найдём id объявлений, которые не содержат выбросы:
filtered_id AS(
    SELECT id
    FROM real_estate.flats  
    WHERE 
        total_area < (SELECT total_area_limit FROM limits)
        AND (rooms < (SELECT rooms_limit FROM limits) OR rooms IS NULL)
        AND (balcony < (SELECT balcony_limit FROM limits) OR balcony IS NULL)
        AND ((ceiling_height < (SELECT ceiling_height_limit_h FROM limits)
            AND ceiling_height > (SELECT ceiling_height_limit_l FROM limits)) OR ceiling_height IS NULL)
    ),
-- CTE по дате публикации
publish_stats AS (
    SELECT
        TO_CHAR(DATE_TRUNC('month', a.first_day_exposition)::date, 'Month YYYY') AS start_month,
        COUNT(a.id) AS total_adv,
        ROUND(AVG(a.last_price / f.total_area)::numeric, 2) AS avg_meter_cost,
        ROUND(AVG(f.total_area)::numeric, 2) AS avg_total_area
    FROM real_estate.advertisement a
    JOIN real_estate.flats f USING(id)
    JOIN real_estate.city c USING(city_id)
    JOIN real_estate.type t USING(type_id) 
     WHERE f.id IN (SELECT * FROM filtered_id)
     AND t.type = 'город' -- Фильтрация по типу город                       
     AND a.first_day_exposition BETWEEN '2015-01-01' AND '2019-01-01'
    GROUP BY start_month
),
-- CTE по дате снятия
unpublish_stats AS (
    SELECT
        TO_CHAR(DATE_TRUNC('month', a.first_day_exposition + a.days_exposition * INTERVAL '1 day')::date, 'Month YYYY') AS end_month,
        COUNT(a.id) AS total_adv,
        ROUND(AVG(a.last_price / f.total_area)::numeric, 2) AS avg_meter_cost,
        ROUND(AVG(f.total_area)::numeric, 2) AS avg_total_area
    FROM real_estate.advertisement a
    JOIN real_estate.flats f USING(id)
    JOIN real_estate.city c USING(city_id)
    JOIN real_estate.type t USING(type_id) 
    WHERE t.type = 'город' AND a.days_exposition IS NOT NULL
      AND a.first_day_exposition BETWEEN '2015-01-01' AND '2019-01-01'
    GROUP BY end_month
)
-- Финальный SELECT по дате публикации
SELECT
    'Публикация' AS type,
    start_month AS month,
    total_adv,
    ROUND(100.0 * total_adv / SUM(total_adv) OVER(), 2) AS total_adv_share,
    RANK() OVER(ORDER BY total_adv DESC) AS month_rank,
    avg_meter_cost,
    avg_total_area
FROM publish_stats
UNION ALL
-- Финальный SELECT по дате снятия
SELECT
    'Снятие' AS type,
    end_month AS month,
    total_adv,
    ROUND(100.0 * total_adv / SUM(total_adv) OVER(), 2) AS total_adv_share,
    RANK() OVER(ORDER BY total_adv DESC) AS month_rank,
    avg_meter_cost,
    avg_total_area
FROM unpublish_stats
ORDER BY type, month;
