/*	what is the total revenue generated by olist and how has it changed over time?	*/
--total revenue
SELECT round(sum(payment_value), 2) AS total_revenue
FROM OlistData..order_payments op
JOIN OlistData..orders ord
	ON op.order_id = ord.order_id
WHERE ord.order_status <> 'canceled' --and ord.order_status <> 'created'

--total revenue per month
SELECT YEAR(order_purchase_date) year, MONTH(order_purchase_date) month,
ROUND(SUM(payment_value), 2) total_revenue
FROM OlistData..orders ord
JOIN OlistData..order_payments pay
	ON ord.order_id = pay.order_id
WHERE ord.order_status <> 'canceled' --and ord.order_status <> 'created'
GROUP BY YEAR(order_purchase_date), MONTH(order_purchase_date)
ORDER BY 1, 2

--total revenue per quarter
SELECT YEAR(order_purchase_date) year, datepart(quarter, order_purchase_date) quarter,
round(sum(payment_value), 2) total_revenue
FROM OlistData..orders ord
JOIN OlistData..order_payments pay
ON ord.order_id = pay.order_id
WHERE ord.order_status <> 'canceled'
GROUP BY YEAR(order_purchase_date), datepart(quarter, order_purchase_date)
ORDER BY 1, 2

/*	how many orders were placed on olist and how does this vary by month or season?	*/
--total orders placed
SELECT COUNT(order_id) total_orders
FROM OlistData..orders

--total orders placed per month
SELECT YEAR(order_purchase_date) year, MONTH(order_purchase_date) month, DATENAME(MONTH, order_purchase_date) month_name,
COUNT(order_id) orders_count,
SUM(COUNT(order_id)) OVER (PARTITION BY YEAR(order_purchase_date) ORDER BY MONTH(order_purchase_date)) total_orders
FROM OlistData..orders
GROUP BY YEAR(order_purchase_date), MONTH(order_purchase_date), DATENAME(MONTH, order_purchase_date)
ORDER BY 1, 2

--total orders placed per quarter
SELECT YEAR(order_purchase_date) year, DATEPART(QUARTER, order_purchase_date) quarter, COUNT(order_id) total_orders
FROM OlistData..orders
GROUP BY YEAR(order_purchase_date), DATEPART(QUARTER, order_purchase_date)
ORDER BY 1, 2

/*	what are the most popular product categories on olist and how do their sales volumes compare to each other?	*/
SELECT prod.product_category_name_eng, COUNT(it.order_id) orders_count, ROUND(SUM(pay.payment_value), 2) total_revenue
FROM OlistData..products prod
JOIN OlistData..order_items it
	ON it.product_id = prod.product_id
JOIN OlistData..orders ord
	ON ord.order_id = it.order_id
JOIN OlistData..order_payments pay
	ON pay.order_id = ord.order_id
WHERE ord.order_status <> 'canceled'
GROUP BY prod.product_category_name_eng
ORDER BY 2 desc

/*	what is the average order value (aov) on olist and how do their sales volumes compare to each other?	*/
--aov by category
SELECT prod.product_category_name_eng, ROUND(SUM(pay.payment_value)/COUNT(it.order_id), 2) AOV,
COUNT(it.order_id) orders_count
FROM OlistData..products prod
JOIN OlistData..order_items it
	ON it.product_id = prod.product_id
JOIN OlistData..orders ord
	ON ord.order_id = it.order_id
JOIN OlistData..order_payments pay
	ON pay.order_id = ord.order_id
WHERE ord.order_status <> 'canceled'
GROUP BY prod.product_category_name_eng
ORDER BY 2 desc

--aov by payment type
SELECT pay.payment_type, ROUND(AVG(pay.payment_value), 2) AOV, COUNT(pay.order_id) orders_count
FROM OlistData..order_payments pay
JOIN OlistData..orders ord
	on ord.order_id = pay.order_id
WHERE ord.order_status <> 'canceled'
GROUP BY pay.payment_type
ORDER BY 2 desc

/*	how many sellers are active on olist and how does this number change over time?	*/
SELECT YEAR(ord.order_purchase_date) year, COUNT(DISTINCT it.seller_id) active_sellers,
MIN(ord.order_purchase_date) first_order, MAX(ord.order_purchase_date) last_order,
COUNT(DISTINCT ord.order_id) orders_count, COUNT(DISTINCT it.product_id) products_listed
FROM OlistData..orders ord
JOIN OlistData..order_items it ON it.order_id = ord.order_id
WHERE order_status <> 'canceled'
GROUP BY YEAR(ord.order_purchase_date)
HAVING DATEDIFF(MONTH, MIN(order_purchase_date), MAX(order_purchase_date)) >= 3
ORDER BY 1

/*	what is the distribution of seller ratings on olist and how does this impact sales performance?	*/
select count(distinct order_id) from OlistData..order_items
select count(distinct order_id) from OlistData..order_reviews
select count(order_id) from OlistData..order_reviews
select order_id, count(*) from OlistData..order_reviews group by order_id having count(order_id) > 1
select order_id, count(*) from OlistData..order_reviews group by order_id having count(order_id) > 1 order by 1
select order_id, payment_value from OlistData..order_payments order by 1
select * from OlistData..order_reviews rev
join OlistData..orders ord on ord.order_id = rev.order_id
where order_status = 'canceled'

SELECT rev.review_score, COUNT(ord.order_id) orders_count,
ROUND(SUM(pay.payment_value), 2) total_revenue, ROUND(AVG(pay.payment_value), 2) avg_revenue
FROM OlistData..order_reviews rev
JOIN OlistData..orders ord ON ord.order_id = rev.order_id
JOIN OlistData..order_payments pay ON pay.order_id = rev.order_id
GROUP BY rev.review_score
ORDER BY 1
SELECT rev.review_score, COUNT(DISTINCT ord.order_id) orders_count,
ROUND(SUM(pay.payment_value), 2) total_revenue, ROUND(SUM(pay.payment_value)/COUNT(DISTINCT ord.order_id), 2) avg_revenue
FROM OlistData..order_reviews rev
JOIN OlistData..orders ord ON ord.order_id = rev.order_id
JOIN OlistData..order_payments pay ON pay.order_id = rev.order_id
WHERE ord.order_status <> 'canceled'
GROUP BY rev.review_score
ORDER BY 1
SELECT rev.review_score, COUNT(DISTINCT ord.order_id) orders_count
FROM OlistData..order_reviews rev
JOIN OlistData..orders ord ON ord.order_id = rev.order_id
GROUP BY rev.review_score
ORDER BY 1
SELECT rev.review_score, COUNT(DISTINCT it.order_id) orders_count
FROM OlistData..order_reviews rev
JOIN OlistData..order_items it ON it.order_id = rev.order_id
GROUP BY rev.review_score
ORDER BY 1
SELECT rev.review_score, COUNT(DISTINCT it.order_id) orders_count,
ROUND(SUM(pay.payment_value), 2) total_revenue, ROUND(SUM(pay.payment_value)/COUNT(DISTINCT it.order_id), 2) avg_revenue
FROM OlistData..order_reviews rev
JOIN OlistData..order_items it ON it.order_id = rev.order_id
JOIN OlistData..order_payments pay ON pay.order_id = rev.order_id
GROUP BY rev.review_score
ORDER BY 1

--further details (rating score per seller)
SELECT it.seller_id, rev.review_score, COUNT(rev.review_score) review_count,
ROUND(SUM(pay.payment_value), 2) total_revenue, ROUND(SUM(pay.payment_value)/COUNT(DISTINCT it.order_id), 2) avg_revenue
FROM OlistData..sellers sel
JOIN OlistData..order_items it ON it.seller_id = sel.seller_id
JOIN OlistData..order_reviews rev ON rev.order_id = it.order_id
JOIN OlistData..order_payments pay ON pay.order_id = rev.order_id
GROUP BY it.seller_id, rev.review_score
ORDER BY 1, 2

/*	how many customers have made repeat purchases on olist and what percentage of total sales do they account for?	*/
--repeated customers' detail
SELECT cus.customer_unique_id, COUNT(DISTINCT ord.customer_id) purchase_count, SUM(pay.payment_value) total_spent
FROM OlistData..customers cus
JOIN OlistData..orders ord ON ord.customer_id = cus.customer_id
JOIN OlistData..order_payments pay ON pay.order_id = ord.order_id
GROUP BY cus.customer_unique_id
HAVING COUNT(DISTINCT ord.customer_id) > 1
ORDER BY 2 desc

--number of repeated customers and their sales percentage
WITH cte_repcust as (
SELECT cus.customer_unique_id, COUNT(DISTINCT ord.customer_id) purchase_count, SUM(pay.payment_value) total_spent
FROM OlistData..customers cus
JOIN OlistData..orders ord ON ord.customer_id = cus.customer_id
JOIN OlistData..order_payments pay ON pay.order_id = ord.order_id
GROUP BY cus.customer_unique_id
HAVING COUNT(DISTINCT ord.customer_id) > 1)
SELECT COUNT(cte_repcust.customer_unique_id) no_of_repeated_customers, ROUND(SUM(total_spent)/
(SELECT SUM(payment_value) FROM OlistData..order_payments)*100, 3) sales_percentage_of_repeated_customers
FROM cte_repcust

/*	what is the average customer rating for products sold on olist and how does this impact sales performance?	*/
SELECT prod.product_category_name_eng, AVG(rev.review_score) avg_rating, COUNT(DISTINCT ord.order_id) products_sold,
ROUND(SUM(pay.payment_value), 2) total_revenue, ROUND(SUM(pay.payment_value)/COUNT(DISTINCT ord.order_id), 2) avg_revenue
FROM OlistData..order_items it
JOIN OlistData..orders ord ON ord.order_id = it.order_id
JOIN OlistData..order_reviews rev ON rev.order_id = it.order_id
JOIN OlistData..products prod ON prod.product_id = it.product_id
JOIN OlistData..order_payments pay ON pay.order_id = it.order_id
WHERE ord.order_status <> 'canceled'
GROUP BY prod.product_category_name_eng
ORDER BY 4 desc

/*	what is the average order cancellation rate on olist and how does this impact seller performance?	*/
SELECT ROUND((SELECT CAST(COUNT(*) as float) FROM OlistData..orders WHERE order_status = 'canceled')
/COUNT(*) * 100, 2) avg_cancellation_rate,
(SELECT SUM(payment_value)
FROM OlistData..order_payments pay
JOIN OlistData..orders ord ON ord.order_id = pay.order_id
WHERE ord.order_status = 'canceled') amount_lost
FROM OlistData..orders
SELECT ROUND(CAST(COUNT(CASE WHEN order_status = 'canceled' THEN 1 END) as float)/COUNT(*) * 100, 2)
FROM OlistData..orders

select count(order_id)
from OlistData..orders
where order_status = 'canceled'

/*	what are the top-selling products on olist and how have their sales trends changed over time?	*/
--top selling products per year and quarter
SELECT prod.product_category_name_eng, ROUND(SUM(payment_value), 2) total_revenue,
COUNT(it.product_id) products_sold, YEAR(ord.order_purchase_date) year,
DATEPART(QUARTER, ord.order_purchase_date) quarter
FROM OlistData..order_items it
JOIN OlistData..products prod ON prod.product_id = it.product_id
JOIN OlistData..orders ord ON ord.order_id = it.order_id
JOIN OlistData..order_payments pay ON pay.order_id = ord.order_id
WHERE order_status <> 'canceled'
GROUP BY prod.product_category_name_eng, YEAR(ord.order_purchase_date), DATEPART(QUARTER, ord.order_purchase_date)
ORDER BY 3 desc

/*	which payment methods are the most commonly used by olist customers and how does this vary by product category or geographic region?	*/
--most commonly used payment type
SELECT payment_type, COUNT(DISTINCT order_id) orders_count
FROM OlistData..order_payments
GROUP BY payment_type
ORDER BY 2 desc

--by product category
SELECT prod.product_category_name_eng, pay.payment_type, COUNT(DISTINCT it.order_id) orders_count
FROM OlistData..order_payments pay
JOIN OlistData..order_items it ON it.order_id = pay.order_id
JOIN OlistData..products prod ON prod.product_id = it.product_id
GROUP BY prod.product_category_name_eng, pay.payment_type
ORDER BY 3 desc

--by geographic region
	--by state
SELECT cus.customer_state, pay.payment_type, COUNT(DISTINCT ord.order_id) orders_count
FROM OlistData..orders ord
JOIN OlistData..order_payments pay ON pay.order_id = ord.order_id
JOIN OlistData..customers cus ON cus.customer_id = ord.customer_id
JOIN OlistData..geolocation geo ON geo.geolocation_zip_code_prefix = cus.customer_zip_code_prefix
GROUP BY cus.customer_state, pay.payment_type
ORDER BY 3 desc

SELECT geo.geolocation_state, pay.payment_type, COUNT(DISTINCT ord.order_id) orders_count
FROM OlistData..orders ord
JOIN OlistData..order_payments pay ON pay.order_id = ord.order_id
JOIN OlistData..customers cus ON cus.customer_id = ord.customer_id
JOIN OlistData..geolocation geo ON geo.geolocation_zip_code_prefix = cus.customer_zip_code_prefix
GROUP BY geo.geolocation_state, pay.payment_type
ORDER BY 3 desc
	--by city
SELECT cus.customer_city, pay.payment_type, COUNT(DISTINCT ord.order_id) orders_count
FROM OlistData..orders ord
JOIN OlistData..order_payments pay ON pay.order_id = ord.order_id
JOIN OlistData..customers cus ON cus.customer_id = ord.customer_id
JOIN OlistData..geolocation geo ON geo.geolocation_zip_code_prefix = cus.customer_zip_code_prefix
GROUP BY cus.customer_city, pay.payment_type
ORDER BY 3 desc

SELECT geo.geolocation_state, pay.payment_type, COUNT(DISTINCT ord.order_id) orders_count
FROM OlistData..orders ord
JOIN OlistData..order_payments pay ON pay.order_id = ord.order_id
JOIN OlistData..customers cus ON cus.customer_id = ord.customer_id
JOIN OlistData..geolocation geo ON geo.geolocation_zip_code_prefix = cus.customer_zip_code_prefix
GROUP BY geo.geolocation_state, pay.payment_type
ORDER BY 3 desc

/*	how do customers reviews and rating affect sales and product performance on olist?	*/
SELECT rev.review_score, COUNT(it.order_id) products_sold, ROUND(SUM(pay.payment_value), 2) total_revenue
FROM OlistData..order_items it
JOIN OlistData..order_reviews rev ON rev.order_id = it.order_id
JOIN OlistData..order_payments pay ON pay.order_id = it.order_id
JOIN OlistData..orders ord ON ord.order_id = it.order_id
WHERE ord.order_status <> 'canceled'
GROUP BY rev.review_score
ORDER BY 3 desc

/*	which product categories have the highest profit margins on olist and how the company increase profitability across different categories?	*/
SELECT prod.product_category_name_eng, ROUND(SUM(it.price), 2) total_price,
ROUND(SUM(it.freight_value), 2) total_shipping_cost, ROUND(SUM(pay.payment_value), 2) total_revenue,
ROUND(SUM(pay.payment_value - it.freight_value), 2) net_profit,
ROUND(SUM(pay.payment_value - it.freight_value)/SUM(pay.payment_value) * 100, 2) profit_margin
FROM OlistData..order_items it
JOIN OlistData..products prod ON prod.product_id = it.product_id
JOIN OlistData..order_payments pay ON pay.order_id = it.order_id
GROUP BY prod.product_category_name_eng
ORDER BY 6 desc

/*	geolocation having high customer density, calculate customer retention rate according to geolocations?	*/
select * from customers
select customer_unique_id, count(*) from OlistData..customers group by customer_unique_id order by 2 desc
select * from OlistData..orders

--total customers per state
SELECT customer_state, COUNT(DISTINCT customer_id) total_customers
FROM OlistData..customers
GROUP BY customer_state
ORDER BY 2 desc

SELECT cus.customer_unique_id, cus.customer_state, COUNT(ord.order_id) orders_count
FROM OlistData..customers cus
JOIN OlistData..orders ord ON ord.customer_id = cus.customer_id
GROUP BY cus.customer_unique_id, cus.customer_state
HAVING COUNT(ord.order_id) > 1
ORDER BY 3 desc

SELECT geo.geolocation_state, COUNT(DISTINCT cus.customer_unique_id) customers_count,
COUNT(DISTINCT ord.order_id) orders_count
FROM OlistData..orders ord
JOIN OlistData..customers cus ON cus.customer_id = ord.customer_id
JOIN OlistData..geolocation geo ON geo.geolocation_zip_code_prefix = cus.customer_zip_code_prefix
GROUP BY geo.geolocation_state
ORDER BY 2 desc
