-- creating table restaurant_menu

create table restaurant_menu
(
    menu_item_id int not null primary key,
	item_name varchar(50),
	category varchar(50),
	price numeric(5,2)
);

-- adding data into restaurant_menu table
copy restaurant_menu(menu_item_id, item_name, category, price)
from 'D:\menu_items.csv'
csv header;

select * from restaurant_menu;

--creating table orders
create table orders
(
    orders_details_id int not null primary key,
	order_id int,
	order_date date,
	order_time time,
	item_id  int
);
set datestyle= 'MDY';

--adding data into order table
copy orders(orders_details_id, order_id, order_date, order_time, item_id)
from 'D:\order_details.csv'
with(format csv, header true, null 'NULL');

select * from orders;

--Q1. No of items, most expensive item, least expensive item on restaurant_menu
-- total items
select count(*) as total_items from restaurant_menu;

--most expensive item
select item_name, max(price) as most_expensive_item from restaurant_menu
group by item_name
order by most_expensive_item desc limit 1;

--least expensive item
select item_name, min(price) as least_expensive_item from restaurant_menu
group by item_name
order by least_expensive_item asc limit 1;


--Q2. category wise no of dishes and their average price
select category, count(*) as no_of_dishes, round(avg(price),2) as avg_price from restaurant_menu
group by category;


--Q3. No of Italian dishes , most expensive and least expensive Italian dishes on the menu
select count(*) as total_Italian_dishes from restaurant_menu
where category = 'Italian';

--most expensive italian dish
select item_name, max(price) as most_expensive_dish from restaurant_menu
where category = 'Italian'
group by item_name
order by most_expensive_dish desc limit 1;

--least expensive italian dish
select item_name, min(price) as least_expensive_dish from restaurant_menu
where category = 'Italian'
group by item_name
order by least_expensive_dish asc limit 1;


--Q4. date range of orders table
select min(order_date) as first_order_date,
       max(order_date) as last_order_date,
       max(order_date)- min(order_date) as date_range 
from orders;


--Q5. total orders made within this date range
select count(distinct order_id) as total_orders,
       min(order_date) as first_order_date,
	   max(order_date) as last_order_date
from orders;

-- total items ordered within this date range
select count(item_id) as total_item_ordered,
       min(order_date) as first_order_date,
	   max(order_date) as last_order_date
from orders;


--Q6. total orders and no of items ordered from orders table
--total orders
select count(distinct order_id) as total_orders from orders;

--total items ordered
select count(item_id) as total_items_ordered from orders;


--Q7. orders having most no of items
select order_id, count(item_id) as total_items from orders
group by order_id
order by count(item_id) desc limit 1 ;


--Q8. no of orders having more than 12 items
select count(*) as total_orders 
   from 
     (select order_id from orders
	  where item_id is not null
	  group by order_id
	  having count(item_id)>12
	  ) as subquery;


--joining restaurant_menu table with orders table
select m.menu_item_id, m.item_name, m.category, m.price, 
       o.orders_details_id, o.order_id,o.order_date,o.order_time
from restaurant_menu m
join orders o
on  m.menu_item_id= o.item_id;


--Q9. most ordered item with category
select m.menu_item_id, m.item_name, m.category, count(o.item_id) as most_ordered_item
from restaurant_menu m
join orders o
on m.menu_item_id= o.item_id
group by m.menu_item_id
order by most_ordered_item desc limit 1;


--Q10. least ordered item with category
select m.menu_item_id, m.item_name, m.category, count(o.item_id) as least_ordered_item
from restaurant_menu m
join orders o
on m.menu_item_id= o.item_id
group by m.menu_item_id
order by least_ordered_item asc limit 1;


--Q11. top 5 orders that spent most money
select o.order_id, sum(m.price) as total_spent,
       string_agg(m.item_name, ', ' order by m.item_name) as items_purchased
from orders o
join  restaurant_menu m
on o.item_id= m.menu_item_id
group by o.order_id
order by total_spent desc limit 5;


--Q12. highest spend order with items purchased in the order
select o.order_id, o.order_date,
       count(o.item_id) as no_of_items,
	    string_agg(m.item_name, ', ') as items_purchased,
       sum(m.price) as total_spent
from orders o
join restaurant_menu m
  on o.item_id = m.menu_item_id
group by o.order_id, o.order_date
order by total_spent desc limit 1;







