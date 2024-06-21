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
