WITH limits AS (   -- Определим аномальные значения (выбросы) по значению перцентилей:                        ЗАДАЧА №1
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
total_info_on_category AS (  -- Присвоим категорию по региону и дням публикации объявлений без выбросов и рассчитаем стоимость квадратного метра
    SELECT
        CASE
            WHEN c.city = 'Санкт-Петербург' THEN 'Санкт-Петербург'     -- Категория региона
            ELSE 'ЛенОбл'
        END AS region,
        CASE                                                           -- Сегмент активности объявления                      
            WHEN a.days_exposition BETWEEN 1 AND 30 THEN 'до месяца'
            WHEN a.days_exposition BETWEEN 31 AND 90 THEN 'до трех месяцев'
            WHEN a.days_exposition BETWEEN 91 AND 180 THEN 'до полугода'
            WHEN a.days_exposition >= 181 THEN 'более полугода'
        END AS segment,
        f.id,
        f.total_area,
        f.floor,
        f.balcony,
        a.days_exposition,
        a.last_price,
        a.last_price / f.total_area AS cost_one_metre,                  -- Цена за квадратный метр
        f.ceiling_height,
        f.rooms
    FROM real_estate.flats AS f
    LEFT JOIN real_estate.advertisement AS a USING(id)
    LEFT JOIN real_estate.city AS c USING(city_id)
    LEFT JOIN real_estate.type AS t USING(type_id)
    WHERE t.type = 'город' AND a.days_exposition IS NOT NULL AND f.id IN (SELECT * FROM filtered_id)
),
agg AS (
    SELECT
        region,
        segment,
        COUNT(id) AS count_exposition,
        ROUND(AVG(total_area)::NUMERIC, 2) AS avg_area,
        ROUND(AVG(cost_one_metre)::NUMERIC, 2) AS avg_cost_one_metre,
        ROUND(AVG(ceiling_height)::NUMERIC, 2) AS avg_ceiling_height,
        PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY rooms) AS mediana_rooms,
        PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY balcony) AS mediana_balcony,
        PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY floor) AS mediana_floor
    FROM total_info_on_category
    WHERE segment IS NOT NULL
    GROUP BY region, segment
),
agg_with_total AS (
    SELECT
        *,
        SUM(count_exposition) OVER (PARTITION BY segment) AS total_by_segment
    FROM agg
)
SELECT
    region,
    segment,
    count_exposition,
    ROUND(count_exposition::numeric / total_by_segment * 100, 2) AS share_piter_percent, -- Доля каждого сегмента активности в разрезе региона в %
    avg_area,
    avg_cost_one_metre,
    avg_ceiling_height,
    mediana_rooms,
    mediana_balcony,
    mediana_floor
FROM agg_with_total
ORDER BY region DESC, segment;
