﻿--------------------------------------------------------DATA CLEANING--------------------------------------------------------

--	1. CUSTOMERS
select * from OlistData..customers

--checking diacritics and/or special characters
select customer_city, customer_state
from OlistData..customers
where customer_city like '%[çáéíóúâêôãõàòèìùïü£!@#$%&*(){}\|;:/?.,><~`]%'

--checking leading and/or trailing and/or double spaces
select customer_city
from OlistData..customers
where customer_city like ' %' or customer_city like '% ' or customer_city like '%  %'



--	2. GEOLOCATION
select * from OlistData..geolocation

--checking if there are leading and/or trailing and/or double spaces
select geolocation_city
from OlistData..geolocation
where geolocation_city like ' %' or geolocation_city like '% ' or geolocation_city like '%  %'

--checking diacritics and/or special characters
select distinct geolocation_city
from OlistData..geolocation
where geolocation_city like '%[çáéíóúâêôãõàòèìùïü£]%' or geolocation_city like '%[!@#$%&*(){}\|;:/?.,><~`]%'

--replacing diacritics
update OlistData..geolocation
set geolocation_city = TRANSLATE(geolocation_city, 'çáéíóúâêôãõàòèìùïü', 'caeiouaeoaoaoeiuiu')

update OlistData..geolocation
set geolocation_city = (
case
	when geolocation_city like '.%' then SUBSTRING(geolocation_city, 4, LEN(geolocation_city))
	when geolocation_city like '*%' then SUBSTRING(geolocation_city, 3, LEN(geolocation_city))
	when geolocation_city like '´%' then SUBSTRING(geolocation_city, 2, LEN(geolocation_city))
	when geolocation_city like '[0-9]%' then ltrim(SUBSTRING(geolocation_city, 4, LEN(geolocation_city)))
	when geolocation_city like '%maceia%' then REPLACE(geolocation_city, 'maceia³', 'maceio')
	when geolocation_city like '%maceió%' then REPLACE(geolocation_city, 'maceió', 'maceio')
	when geolocation_city like '%,%' then PARSENAME(REPLACE(geolocation_city, ',','.'), 3)
	when geolocation_city like '%3' then SUBSTRING(geolocation_city, 1, CHARINDEX('3', geolocation_city)-4)
	when geolocation_city like '%2' then SUBSTRING(geolocation_city, 1, CHARINDEX('2', geolocation_city)-2)
	when geolocation_city like '%[%]%' then REPLACE(geolocation_city, '%26apos%3b', '''')
	when geolocation_city like '%_ doeste' then REPLACE(geolocation_city, 'doeste', 'd''oeste')
	when geolocation_city like '%_ dagua _%' then REPLACE(geolocation_city, 'dagua', 'd''agua')
	when geolocation_city like '%_ davila' then REPLACE(geolocation_city, 'davila', 'd''avila')
	when geolocation_city like '%_ dalho%' then REPLACE(geolocation_city, 'dalho', 'd''alho')
	when geolocation_city like '%_ dalianca%' then REPLACE(geolocation_city, 'dalianca', 'd''alianca')
	when geolocation_city like '%tamoios%' then SUBSTRING(geolocation_city, CHARINDEX('(', geolocation_city)+1, 9)
	when geolocation_city like '%(%' then SUBSTRING(geolocation_city, 1, CHARINDEX('(', geolocation_city)-2)
	when geolocation_city like '%£%' then REPLACE(geolocation_city, '£', '')
	when geolocation_city like '% ' then TRIM(geolocation_city)
	when geolocation_city like '%  %' then REPLACE(geolocation_city, '  ', ' ')
	when geolocation_city like '%limeira d _%' then REPLACE(geolocation_city, 'd', 'do')
	when geolocation_city like '%_ mg%' then SUBSTRING(geolocation_city, 1, CHARINDEX('mg', geolocation_city)-2)
	when geolocation_city like '%_ d _%' then REPLACE(geolocation_city, 'd ', 'd''')
	when geolocation_city like '%[,.@/$%&-!?@(){};:]%' then REPLACE(geolocation_city, '&oacute;', 'o')
	when geolocation_city like '%olhos-d %' then REPLACE(geolocation_city, '-d ', ' d''')
	when geolocation_city like '%olho-d %' then REPLACE(geolocation_city, 'd ', 'd''')
	when geolocation_city like '%pingo-d %' then REPLACE(geolocation_city, 'd ', 'd''')
	when geolocation_city like '%_-es%' then SUBSTRING(geolocation_city, 1, CHARINDEX('-', geolocation_city)-1)
	when geolocation_city like '%_ - alto%' then SUBSTRING(geolocation_city, 1, CHARINDEX('-', geolocation_city)-2)
	when geolocation_city like '%`%' then REPLACE(geolocation_city, '`', '''')
	else geolocation_city
end)



--	3. ORDER_ITEMS
select * from OlistData..order_items

--splitting shipping_limit_date by date and time
ALTER TABLE order_items
ADD date_shipping_limit date
ALTER TABLE order_items
ADD time_shipping_limit time(0)
ALTER TABLE order_items
DROP COLUMN date_shipping_limit
ALTER TABLE order_items
ALTER COLUMN shipping_limit_date date
UPDATE OlistData..order_items
set time_shipping_limit = CONVERT(time(0), shipping_limit_date)

--formatting price and freight_value to two decimal points
UPDATE OlistData..order_items
SET price = ROUND(price, 2), freight_value = ROUND(freight_value, 2)



--	4. ORDER_PAYMENTS
select * from OlistData..order_payments

--checking leading and/or tailing and/or double spaces
select *
from OlistData..order_payments
where payment_type like ' %' or payment_type like '%  %' or payment_type like '% '

--formatting payment_value to two decimal points
UPDATE OlistData..order_payments
SET payment_value = ROUND(payment_value, 2)



--	5. ORDER_REVIEWS
select * from OlistData..order_reviews

--checking duplicates
select review_id, order_id, count(*)
from OlistData..order_reviews
group by review_id, order_id
having COUNT(*) > 1
order by review_id

--splitting date and time
alter table order_reviews
alter column review_creation_date date
alter table order_reviews
alter column review_answer_timestamp date

alter table order_reviews
add review_answer_time time(0)
update order_reviews
set review_answer_time = CONVERT(time(0), review_answer_timestamp)



--	6. ORDERS
select * from OlistData..orders

--checking leading and/or trailing and/or double spaces
select *
from OlistData..orders
where order_status like ' %' or order_status like '%  %' or order_status like '% '

--splitting date and time from timestamp
ALTER TABLE orders
ADD order_purchase_date date,
order_purchase_time time(0),
order_approved_date date,
order_approved_time time(0),
order_deliv_carrier_date date,
order_delivered_carrier_time time(0),
order_deliv_customer_date date,
order_delivered_customer_time time(0),
order_est_delivery_date date,
order_estimated_delivery_time time(0)
ALTER TABLE orders
DROP COLUMN order_estimated_delivery_time
ALTER TABLE orders
DROP COLUMN order_purchase_date, order_approved_date, order_deliv_carrier_date,
order_deliv_customer_date, order_est_delivery_date

--change column data type
ALTER TABLE orders
ALTER COLUMN order_purchase_timestamp date
ALTER TABLE orders
ALTER COLUMN order_approved_at date
ALTER TABLE orders
ALTER COLUMN order_delivered_carrier_date date
ALTER TABLE orders
ALTER COLUMN order_delivered_customer_date date
ALTER TABLE orders
ALTER COLUMN order_estimated_delivery_date date

UPDATE OlistData..orders
set order_purchase_time = CONVERT(time(0), order_purchase_date),
order_approved_time = CONVERT(time(0), order_approved_at),
order_delivered_carrier_time = CONVERT(time(0), order_delivered_carrier_date),
order_delivered_customer_time = CONVERT(time(0), order_delivered_customer_date)



--	7. PRODUCT_CATEGORY_NAME_TRANS
select * from OlistData..product_category_name_trans

--checking leading and/or tailing and/or double spaces
select *
from OlistData..product_category_name_trans
where product_category_name like ' %' or product_category_name like '%  %' or product_category_name like '% ' or
product_category_name_english like ' %' or product_category_name_english like '%  %' or product_category_name_english like '% '

--delete first row (header)
select *
from OlistData..product_category_name_trans
where product_category_name like '%category%'

delete from OlistData..product_category_name_trans
where product_category_name like '%category%'

--insert 3 values into trans table
insert into OlistData..product_category_name_trans (product_category_name, product_category_name_english)
values ('no category', 'no_category'), ('pc_gamer', 'pc_games'), ('portateis_cozinha_e_preparadores_de_alimentos', 'kitchen_portables_and_food_preparators')



--	8. PRODUCTS
select * from OlistData..products

--checking leading and/or tailing and/or double spaces
select *
from OlistData..products
where product_category_name like ' %' or product_category_name like '%  %' or product_category_name like '% '

--filling null values on product_category_name
UPDATE OlistData..products
SET product_category_name = ISNULL(product_category_name, 'no category')

select product_name_length, coalesce(product_name_length, 0), coalesce(product_description_length, 0),
coalesce(product_photos_qty, 0), coalesce(product_weight_g, 0), coalesce(product_length_cm, 0),
coalesce(product_height_cm, 0), coalesce(product_width_cm, 0)
from OlistData..products
where product_weight_g is null

--convert product_category_name to english
ALTER TABLE products
ADD product_category_name_eng nvarchar(50)

update OlistData..products
set product_category_name_eng = trans.product_category_name_english
from OlistData..products prod
join OlistData..product_category_name_trans trans
	on prod.product_category_name = trans.product_category_name

	--drop old column
alter table products
drop column product_category_name

--filling null values
UPDATE OlistData..products
SET product_name_length = COALESCE(product_name_length, 0),
product_description_length = COALESCE(product_description_length, 0),
product_photos_qty = COALESCE(product_photos_qty, 0),
product_weight_g = COALESCE(product_weight_g, 0),
product_length_cm = COALESCE(product_length_cm, 0),
product_height_cm = COALESCE(product_height_cm, 0),
product_width_cm = COALESCE(product_width_cm, 0)



--	9. SELLERS
select * from OlistData..sellers

--checking diacritics and/or special characters
select *
from OlistData..sellers
where seller_city like '%[çáéíóúâêôãõàòèìùïü£!@#$%&*(){}\|;:/?.,><~`0-9]%'

--checking leading and/or tailing and/or double spaces
select *
from OlistData..sellers
where seller_city like ' %' or seller_city like '%  %' or seller_city like '% '

--standardized seller_city
update OlistData..sellers
set seller_city = (
case
	when seller_city like '%/%' then trim(SUBSTRING(seller_city, 1, CHARINDEX('/', seller_city)-1))
	when seller_city like '%\%' then trim(SUBSTRING(seller_city, 1, CHARINDEX('\', seller_city)-1))
	when seller_city like '%,%' then SUBSTRING(seller_city, 1, CHARINDEX(',', seller_city)-1)
	when seller_city like '%-%' then trim(SUBSTRING(seller_city, 1, CHARINDEX('-', seller_city)-1))
	when seller_city like '%_sp' then SUBSTRING(seller_city, 1, CHARINDEX('sp', seller_city)-2)
	when seller_city = 'sp' then REPLACE(seller_city, 'sp', 'sao paulo')
	when seller_city like '%(%' then SUBSTRING(seller_city, 1, CHARINDEX('(', seller_city)-2)
	when seller_city like '%[0-9]%' then REPLACE(seller_city, '04482255', 'rio de janeiro')
	when seller_city like '%@%' then REPLACE(seller_city, 'vendas@creditparts.com.br', 'maringa')
	when seller_city = 'sbc' then REPLACE(seller_city, 'sbc', 'sao bernardo do campo')
	when seller_city like '%  %' then REPLACE(seller_city, '  ', ' ')
	else seller_city
end)





-----------------------------------------------------ANSWERING QUESTION-----------------------------------------------------

/*	Q1: what is the total revenue generated by olist and
		how has it changed over time?	*/
--total revenue
select round(sum(payment_value), 2) as total_revenue
from OlistData..order_payments op
join OlistData..orders ord
	on op.order_id = ord.order_id
where ord.order_status <> 'canceled' --and ord.order_status <> 'created'

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
select year(order_purchase_date) year, datepart(quarter, order_purchase_date) quarter,
round(sum(payment_value), 2) total_revenue
from OlistData..orders ord
join OlistData..order_payments pay
on ord.order_id = pay.order_id
where ord.order_status <> 'canceled'
group by year(order_purchase_date), datepart(quarter, order_purchase_date)
order by 1, 2

/*	Q2: how many orders were placed on olist and
		how does this vary by month or season?	*/
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

/*	Q3: what are the most popular product categories on olist and
		how do their sales volumes compare to each other?	*/
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

/*	Q4: what is the average order value (aov) on olist and
		how do their sales volumes compare to each other?	*/
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

/*	Q5: how many sellers are active on olist and
		how does this number change over time?	*/
SELECT YEAR(ord.order_purchase_date) year, COUNT(DISTINCT it.seller_id) active_sellers,
MIN(ord.order_purchase_date) first_order, MAX(ord.order_purchase_date) last_order,
COUNT(DISTINCT ord.order_id) orders_count, COUNT(DISTINCT it.product_id) products_listed
FROM OlistData..orders ord
JOIN OlistData..order_items it ON it.order_id = ord.order_id
WHERE order_status <> 'canceled'
GROUP BY YEAR(ord.order_purchase_date)
HAVING DATEDIFF(MONTH, MIN(order_purchase_date), MAX(order_purchase_date)) >= 3
ORDER BY 1

/*	Q6: what is the distribution of seller ratings on olist and
		how does this impact sales performance?	*/
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

/*	Q7: how many customers have made repeat purchases on olist and
		what percentage of total sales do they account for?	*/
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

/*	Q8: what is the average customer rating for products sold on olist and
		how does this impact sales performance?	*/
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

/*	Q9: what is the average order cancellation rate on olist and
		how does this impact seller performance?	*/
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

/*	Q10: what are the top-selling products on olist and
		 how have their sales trends changed over time?	*/
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

/*	Q11: which payment methods are the most commonly used by olist customers and
		 how does this vary by product category or geographic region?	*/
select * from OlistData..order_payments
select * from OlistData..products
select * from OlistData..order_items
select order_id, count(*) from OlistData..order_items group by order_id having count(*)>1 order by 2 desc
select order_id, count(*) from OlistData..order_payments group by order_id having count(*)>1 order by 2 desc
select * from OlistData..order_items where order_id = '8272b63d03f5f79c56e9e4120aec44ef'
select * from OlistData..order_payments where order_id = 'fa65dad1b0e818e3ccc5cb0e39231352'
select * from OlistData..order_payments where order_id = '8272b63d03f5f79c56e9e4120aec44ef'
select * from OlistData..customers
select distinct customer_state from OlistData..customers
select * from OlistData..orders
select order_id, count(*) from OlistData..orders group by order_id having count(*)>1 order by 2 desc
select * from OlistData..geolocation

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

/*	Q12: how do customers reviews and rating affect sales and product performance on olist?	*/
SELECT rev.review_score, COUNT(it.order_id) products_sold, ROUND(SUM(pay.payment_value), 2) total_revenue
FROM OlistData..order_items it
JOIN OlistData..order_reviews rev ON rev.order_id = it.order_id
JOIN OlistData..order_payments pay ON pay.order_id = it.order_id
JOIN OlistData..orders ord ON ord.order_id = it.order_id
WHERE ord.order_status <> 'canceled'
GROUP BY rev.review_score
ORDER BY 3 desc

/*	Q13: which product categories have the highest profit margins on olist and
		 how the company increase profitability across different categories?	*/
SELECT prod.product_category_name_eng, ROUND(SUM(it.price), 2) total_price,
ROUND(SUM(it.freight_value), 2) total_shipping_cost, ROUND(SUM(pay.payment_value), 2) total_revenue,
ROUND(SUM(pay.payment_value - it.freight_value), 2) net_profit,
ROUND(SUM(pay.payment_value - it.freight_value)/SUM(pay.payment_value) * 100, 2) profit_margin
FROM OlistData..order_items it
JOIN OlistData..products prod ON prod.product_id = it.product_id
JOIN OlistData..order_payments pay ON pay.order_id = it.order_id
GROUP BY prod.product_category_name_eng
ORDER BY 6 desc

/*	Q14: how does olist's marketing spend and channel mix impact sales and customer acquisition costs and
		 how can the company optimize its marketing strategy to increase roi?	*/
/*	Q15: geolocation having high customer density, calculate customer retention rate according to geolocations?	*/
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