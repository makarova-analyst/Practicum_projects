/*  Название: Расчёт LTV ресторанов — самые популярные блюда
    Проект: Анализ сервиса доставки еды «Всё.из.кафе»
    Описание: Вклад пяти самых популярных блюд из двух ресторанов Саранска — «Гурманское Наслаждение» и «Гастрономический Шторм» — в общий показатель LTV. 
    Для каждого блюда выведем название ресторана, название блюда, признаки того, является ли блюдо острым, рыбным или мясным, а также значение LTV, округлённое до копеек.
*/

-- Рассчитываем величину комиссии с каждого заказа, фильтруем заказы по дате и городу
WITH orders AS
  (SELECT events.rest_id,
          events.city_id,
          events.object_id,
          revenue * commission AS commission_revenue
   FROM analytics_events AS events
   JOIN cities ON events.city_id = cities.city_id
   WHERE revenue IS NOT NULL
     AND log_date BETWEEN '2021-05-01' AND '2021-06-30'
     AND city_name = 'Саранск'), 
-- Рассчитываем два ресторана с наибольшим LTV
top_ltv_restaurants AS
  (SELECT orders.rest_id,
          chain,
          type,
          ROUND(SUM(commission_revenue)::numeric, 2) AS LTV
   FROM orders
   JOIN partners ON orders.rest_id = partners.rest_id AND orders.city_id = partners.city_id 
   GROUP BY 1, 2, 3
   ORDER BY LTV DESC
   LIMIT 2)
  -- Выводим пять блюд с максимальным LTV
SELECT chain AS "Название сети",
       dishes.name AS "Название блюда",
       spicy,
       fish,
       meat,
       ROUND(SUM(orders.commission_revenue)::numeric, 2) AS LTV
FROM orders
JOIN top_ltv_restaurants ON orders.rest_id = top_ltv_restaurants.rest_id
JOIN dishes ON orders.object_id = dishes.object_id
AND top_ltv_restaurants.rest_id = dishes.rest_id
GROUP BY 1, 2, 3, 4, 5
ORDER BY LTV DESC
LIMIT 5;
