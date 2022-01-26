-- 1. Provide the name of the sales_rep in each region with the largest amount of total_amt_usd sales.

-- first find top sales rep by usd sales

with sales_rep_total as (
    select s.id sales_id, s.name sales_name, r.id region_id, r.name region_name, sum(o.total_amt_usd) total_sales 
    from sales_reps s
    join region r on r.id = s.region_id
    join accounts a on a.sales_rep_id = s.id
    join orders o on o.account_id = a.id 
    group by 1,2,3,4
), 

-- find region with max sales 

region_max as (
    select region_id, region_name, max(total_sales) total
    from sales_rep_total
    group by 1,2
)

-- add back sales rep name

select s.sales_name, s.region_name, region_max.total 
from region_max 
join sales_rep_total s on s.region_id = region_max.region_id and s.total_sales = region_max.total  




-- 2. For the region with the largest sales total_amt_usd, how many total orders were placed?

-- find region with largest sales

with region_sales as (
    select r.name, sum(o.total_amt_usd) total_amt, count(o.total) orders 
    from region r
    join sales_reps s on s.region_id = r.id 
    join accounts a on a.sales_rep_id = s.id 
    join orders o on o.account_id = a.id 
    group by 1
    order by 2 desc 
)

-- find orders where total_sales and region matches 

select *
from region_sales 
limit 1 




-- 3. How many accounts had more total purchases than the account name which has bought the most standard_qty paper throughout their lifetime as a customer?

-- find account that bought most standard_qty

with greatest_standard_qty as (
    select a.id, a.name, sum(standard_qty) standard_qty
    from accounts a 
    join orders o on o.account_id = a.id 
    group by 1,2 
    order by 3 desc
    limit 1 
)

-- find accounts with greater total purchases than account above

select a.name, sum(o.total) total 
from accounts a 
join orders o on o.account_id = a.id 
group by 1
having sum(o.total) > ( 
    select standard_qty from greatest_standard_qty
)




-- 4. For the customer that spent the most (in total over their lifetime as a customer) total_amt_usd, how many web_events did they have for each channel?

-- find total spent by customer

with biggest_customer as (
    select a.id, a.name, sum(o.total_amt_usd) total_usd 
    from accounts a 
    join orders o on o.account_id = a.id
    group by 1,2
    order by 3 desc 
    limit 1
)

-- find web events by channel for that customer

select a.id, channel, count(occurred_at)
from accounts a
join web_events w on w.account_id = a.id 
group by 1,2
having a.id = (
    select id from biggest_customer
)




-- 5. What is the lifetime average amount spent in terms of total_amt_usd for the top 10 total spending accounts?

-- find top 10 accounts

with top_10 as (
    select a.name, sum(o.total_amt_usd) total_usd
    from accounts a
    join orders o on o.account_id = a.id 
    group by 1
    limit 10
)

-- find avg amount spent

select avg(total_usd)
from top_10




-- 6. What is the lifetime average amount spent in terms of total_amt_usd, including only the companies that spent more per order, on average, than the average of all orders.

-- first find avg of orders

with avg_order as (
    select avg(o.total_amt_usd)
    from orders o 
),

-- find co's that spend more than avg

companies_more_than_avg as (
    select a.name, avg(o.total_amt_usd) co_avg 
    from accounts a 
    join orders o on o.account_id = a.id 
    group by 1 
    having avg(o.total_amt_usd) > (
        select avg from avg_order 
    )
)

-- find avg of this 

select avg(co_avg)
from companies_more_than_avg 