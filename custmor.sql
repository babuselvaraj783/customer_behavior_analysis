select * from customer;


-- what is the total revenue gentrated by male vs female

select gender , sum(purchase_amount) as revenue from customer
group by gender;

-- which customer used a discount but still more then the average amount

select customer_id,purchase_amount from customer
where discount_applied ='Yes' and purchase_amount >=(select Avg(purchase_amount) from customer);

--Which are the top 5 product which avergae review rating

 select item_purchased, Round(Avg(review_rating::numeric),2) as "AVG Product Rating"from customer
 group by item_purchased
 order by avg(review_rating) desc
 limit 5;

--compare the average purchase Amounts between standerd and express shipping

select shipping_type, Round(avg(purchase_amount),2) from customer
where shipping_type in ('Standard','Express')
group by shipping_type;

--Do subscribed customers spend more?compare average spend and total revenue
--between subscibers and subscribers

select subscription_status, 
count(customer_id) as total_customers,
Round(Avg(purchase_amount),2) as avg_spend,
Round(sum(purchase_amount),2) as total_revenue
from customer
group by subscription_status
order by total_revenue,avg_spend desc ;

-- which 5 product have the highest persentage of puschases with discounts applied?

select item_purchased , 
Round(100 * sum(case when discount_applied = 'Yes' then 1 else 0 end)/count(*),2)as discount_rate
from customer
group by item_purchased
order by discount_rate desc
limit 5 ; 


-- segement customers into new , and loyal based on their total number of previous 
--purchases, and show the count of each segment 

with customer_type as (
select customer_id,previous_purchases,
CASE
	WHEN previous_purchases = 1 then 'New'
	WHEN previous_purchases between 2 and 10 then 'Returning'
	ELSE 'LOYAL'
	END AS customer_segment
from customer
)
select customer_segment, count(*) as "Number of customers"
from customer_type
group by customer_segment

--what are the top 3 most purchased products with each category?
WITH item_counts AS (
    SELECT category,
           item_purchased,
           COUNT(customer_id) AS total_orders,
           ROW_NUMBER() OVER (PARTITION BY category ORDER BY COUNT(customer_id) DESC) AS item_rank
    FROM customer
    GROUP BY category, item_purchased
)
SELECT item_rank,category, item_purchased, total_orders
FROM item_counts
WHERE item_rank <=3;
 
--. Are customers who are repeat buyers (more than 5 previous purchases) also likely to subscribe?
SELECT subscription_status,
       COUNT(customer_id) AS repeat_buyers
FROM customer
WHERE previous_purchases > 5
GROUP BY subscription_status;

--Q10. What is the revenue contribution of each age group? 
SELECT 
    age_group,
    SUM(purchase_amount) AS total_revenue
FROM customer
GROUP BY age_group
ORDER BY total_revenue desc;


