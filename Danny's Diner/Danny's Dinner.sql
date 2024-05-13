
CREATE DATABASE dannys_diner;
USE dannys_diner;

CREATE TABLE sales (
  customer_id VARCHAR(1),
  order_date DATE,
  product_id INTEGER
);

INSERT INTO sales
  (customer_id, order_date, product_id)
VALUES
  ('A', '2021-01-01', 1),
  ('A', '2021-01-01', 2),
  ('A', '2021-01-07', 2),
  ('A', '2021-01-10', 3),
  ('A', '2021-01-11', 3),
  ('A', '2021-01-11', 3),
  ('B', '2021-01-01', 2),
  ('B', '2021-01-02', 2),
  ('B', '2021-01-04', 1),
  ('B', '2021-01-11', 1),
  ('B', '2021-01-16', 3),
  ('B', '2021-02-01', 3),
  ('C', '2021-01-01', 3),
  ('C', '2021-01-01', 3),
  ('C', '2021-01-07', 3);
 

CREATE TABLE menu (
  product_id INTEGER,
  product_name VARCHAR(5),
  price INTEGER
);

INSERT INTO menu
  (product_id, product_name, price)
VALUES
  (1, 'sushi', 10),
  (2, 'curry', 15),
  (3, 'ramen', 12);
  

CREATE TABLE members (
  customer_id VARCHAR(1),
  join_date DATE
);

INSERT INTO members
  (customer_id, join_date)
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');


select * from  sales;
select * from menu;
select * from members;

-- What is the total amount each customer spent at the restaurant?
select s.customer_id, sum(price) from sales s
join menu m
on s.product_id=m.product_id
group by s.customer_id;

-- How many days has each customer visited the restaurant?
select customer_id,count(distinct  order_date) 
from sales
group by customer_id;

-- What was the first item from the menu purchased by each customer?
SELECT customer_id, order_date, product_id
FROM (
  SELECT 
    customer_id, 
    order_date, 
    product_id, 
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date) AS row_num
  FROM sales
) AS ranked_sales
WHERE row_num = 1
ORDER BY order_date;

-- What is the most purchased item on the menu and how many times was it purchased by all customers?
select s.product_id,m.product_name,count(s.product_id) 
from sales s
inner join menu m
on s.product_id=m.product_id
group by s.product_id;

-- Which item was the most popular for each customer?
SELECT
    customer_id,
    product_name AS most_popular_item,
    MAX(product_count) AS total_orders
FROM (
    SELECT
        s.customer_id,
        s.product_id,
        m.product_name,
        COUNT(s.product_id) AS product_count
    FROM 
        sales s
    INNER JOIN 
        menu m ON s.product_id = m.product_id
    GROUP BY 
        s.customer_id, s.product_id
) AS table2
group by customer_id;


-- Which item was purchased first by the customer after they became a member?

SELECT 
    s.customer_id, 
    MIN(s.order_date) AS first_purchase_date, 
    s.product_id, 
    m.product_name
FROM 
    sales s
INNER JOIN 
    menu m ON s.product_id = m.product_id
INNER JOIN 
    members me ON s.customer_id = me.customer_id
WHERE 
    s.order_date > me.join_date
GROUP BY 
    s.customer_id;
    
-- Which item was purchased just before the customer became a member?
select * from sales;
select * from members;
SELECT 
    s.customer_id, 
    max(s.order_date) AS last_purchase_date, 
    s.product_id, 
    m.product_name
FROM 
    sales s
INNER JOIN 
    menu m ON s.product_id = m.product_id
INNER JOIN 
    members me ON s.customer_id = me.customer_id
WHERE 
    s.order_date < me.join_date
GROUP BY 
    s.customer_id;

-- What is the total items and amount spent for each member before they became a member?

select * from sales;
select * from menu;
SELECT 
    s.customer_id, 
    count(s.product_id) as total_items,
    sum(m.price) as amount_spend
FROM 
    sales s
INNER JOIN 
    menu m ON s.product_id = m.product_id
INNER JOIN 
    members me ON s.customer_id = me.customer_id
WHERE 
    s.order_date < me.join_date
GROUP BY 
    s.customer_id;

-- If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?


SELECT
    s.customer_id,
    SUM(
        CASE 
            WHEN m.product_name = 'sushi' THEN 2 * m.price
            ELSE m.price
        END
    ) * 10 AS total_points
FROM
    sales s
INNER JOIN
    menu m ON s.product_id = m.product_id
GROUP BY
    s.customer_id;

-- In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
WITH JoinedCustomers AS (
  SELECT 
    s.customer_id,
    m.price,
    m.product_name,
    m.product_id,
    c.join_date
  FROM 
    sales s
  JOIN 
    menu m ON s.product_id = m.product_id
  JOIN 
    members c ON s.customer_id = c.customer_id
)
SELECT 
  customer_id,
  SUM(CASE WHEN order_date <= DATE_ADD(join_date, INTERVAL 7 DAY) THEN 2 * price ELSE price END) AS total_points
FROM 
  JoinedCustomers
WHERE 
  order_date <= '2021-01-31'
GROUP BY 
  customer_id;

