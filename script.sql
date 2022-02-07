--view first 10 results in Fred's database
SELECT * FROM store LIMIT 10;

--calculate number of distinct orders
SELECT COUNT(DISTINCT(order_id)) 
FROM store;

--calculate number of distinct customers who made orders
SELECT COUNT(DISTINCT(customer_id)) 
FROM store;

/*inspect repeated data*/
--check how many times customer with id 1 has ordered
SELECT customer_id, customer_email, customer_phone from store WHERE customer_id = 1;

--check how many times customer with id 1 has ordered item_1
SELECT item_1_id, item_1_name, item_1_price FROM store WHERE item_1_id = 4;


--NORMALIZING DATATABASE (store)

--create customers table according to normalized schema
CREATE TABLE customers AS
SELECT DISTINCT customer_id, customer_phone, customer_email FROM store;

--make customer_id PRIMARY key of customers table
ALTER TABLE customers
ADD PRIMARY KEY (customer_id);

--create items table according to normalized schema
CREATE TABLE items AS
SELECT DISTINCT item_1_id as item_id, item_1_name as name, item_1_price as price 
FROM store
UNION
SELECT DISTINCT item_2_id as item_id, item_2_name as name, item_2_price as price
FROM store
WHERE item_2_id IS NOT NULL
UNION
SELECT DISTINCT item_3_id as item_id, item_3_name as name, item_3_price as price
FROM store
WHERE item_3_price IS NOT NULL;


--designate the item_id column of itemsw table as the primary key
ALTER TABLE items
ADD PRIMARY KEY (item_id);

--create orders_items table according to normalized schema
CREATE TABLE orders_items AS
SELECT order_id, item_1_id as item_id 
FROM store
UNION ALL
SELECT order_id, item_2_id as item_id
FROM store
WHERE item_2_id IS NOT NULL
UNION ALL
SELECT order_id, item_3_id as item_id
FROM store
WHERE item_3_id IS NOT NULL;

--create orders table according to normalized schema
CREATE TABLE orders AS
SELECT order_id, order_date, customer_id
FROM store;

--designate the order_id column of orders table as the primary key
ALTER TABLE orders
ADD PRIMARY KEY (order_id);

--designate the customer_id column of orders table as the foreign key in orders table
ALTER TABLE orders
ADD FOREIGN KEY (customer_id) 
REFERENCES customers(customer_id);

--designate the item_id column of orders table as the foreign key in orders table
ALTER TABLE orders_items
ADD FOREIGN KEY (item_id) 
REFERENCES items(item_id);


-- QUERYING THE DATABASE
--selecting the emails of all customers who made an order after July 25, 2019 from not normalized database 
SELECT customer_email
FROM store
WHERE order_date > '2019-08-25';

--selecting the emails of all customers who made an order after July 25, 2019 from normalized database 
SELECT customer_email
FROM customers, orders
WHERE customers.customer_id = orders.customer_id
AND
orders.order_date > '2019-08-25';


--querying original store table to return the number of orders containing each unique item
WITH all_items AS (
SELECT item_1_id as item_id 
FROM store
UNION ALL
SELECT item_2_id as item_id
FROM store
WHERE item_2_id IS NOT NULL
UNION ALL
SELECT item_3_id as item_id
FROM store
WHERE item_3_id IS NOT NULL
)
SELECT item_id, COUNT(*)
FROM all_items
GROUP BY item_id;


--querying normalized database tables to return the number of orders containing each unique item.
SELECT item_id, COUNT(*)
FROM orders_items
GROUP BY item_id;