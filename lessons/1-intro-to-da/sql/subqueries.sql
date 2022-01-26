-- 1. Provide the name of the sales_rep in each region with the largest amount of total_amt_usd sales.

-- first find usd associated with each sales rep and region

select sr.name as sales_name, r.name as region_name, sum(o.total_amt_usd) as sales
from sales_reps sr
left join accounts a on a.sales_rep_id = sr.id
left join orders o on o.account_id = a.id
left join region r on r.id = sr.region_id
group by 1,2

-- then find the max sales 

select region_name, max(sales) as max_sales
from (
    select sr.name as sales_name, r.name as region_name, sum(o.total_amt_usd) as sales
    from sales_reps sr
    left join accounts a on a.sales_rep_id = sr.id
    left join orders o on o.account_id = a.id
    left join region r on r.id = sr.region_id
    group by 1,2
) sub1
group by 1

-- match back to original table to find the sales rep name

select sub3.sales_name, sub2.region_name, sub2.max_sales
from (
    select region_name, max(sales) as max_sales
    from (
        select sr.name as sales_name, r.name as region_name, sum(o.total_amt_usd) as sales
        from sales_reps sr
        left join accounts a on a.sales_rep_id = sr.id
        left join orders o on o.account_id = a.id
        left join region r on r.id = sr.region_id
        group by 1,2
    ) sub1
    group by 1 ) sub2
join (
    select sr.name as sales_name, r.name as region_name, sum(o.total_amt_usd) as sales
    from sales_reps sr
    left join accounts a on a.sales_rep_id = sr.id
    left join orders o on o.account_id = a.id
    left join region r on r.id = sr.region_id
    group by 1,2
) sub3
on sub2.region_name = sub3.region_name and sub2.max_sales = sub3.sales 
order by 3 desc 




-- 2. For the region with the largest sales total_amt_usd, how many total orders were placed?

-- first find region with largest sales

select r.name as region_name, sum(o.total_amt_usd) total_amt
from region r
join sales_reps sr on sr.region_id = r.id
join accounts a on a.sales_rep_id = sr.id
join orders o on o.account_id = a.id 
group by 1 

-- find the region with max sales

select max(total_amt)
from (
    select r.name as region_name, sum(o.total_amt_usd) total_amt
    from region r
    join sales_reps sr on sr.region_id = r.id
    join accounts a on a.sales_rep_id = sr.id
    join orders o on o.account_id = a.id 
    group by 1 
) sub1 

-- match max to region and orders where amount matches the max

select r.name, count(o.total), sum(o.total_amt_usd) total_amt
from region r
join sales_reps sr on sr.region_id = r.id
join accounts a on a.sales_rep_id = sr.id
join orders o on o.account_id = a.id 
group by 1
having sum(o.total_amt_usd) = (
    select max(total_amt)
    from (
        select r.name as region_name, sum(o.total_amt_usd) total_amt
        from region r
        join sales_reps sr on sr.region_id = r.id
        join accounts a on a.sales_rep_id = sr.id
        join orders o on o.account_id = a.id 
        group by 1 
    ) sub1 
) 




-- 3. How many accounts had more total purchases than the account name which has bought the most standard_qty paper throughout their lifetime as a customer?

-- first find account that has bought most standard_qty

select a.name, sum(o.standard_qty) as std_qty_total 
from accounts a
join orders o on o.account_id = a.id 
group by 1
order by 2 desc
limit 1

-- find accounts with more total purchases than that account

select a.name, sum(o.total)
from accounts a
join orders o on o.account_id = a.id 
group by 1
having sum(o.total) > (select std_qty_total 
    from (
        select a.name, sum(o.standard_qty) as std_qty_total 
        from accounts a
        join orders o on o.account_id = a.id 
        group by 1
        order by 2 desc
        limit 1
    ) sub1 
)

-- count how many accounts 

select count(name)
from (
    select a.name, sum(o.total)
    from accounts a
    join orders o on o.account_id = a.id 
    group by 1
    having sum(o.total) > (select std_qty_total 
        from (
            select a.name, sum(o.standard_qty) as std_qty_total 
            from accounts a
            join orders o on o.account_id = a.id 
            group by 1
            order by 2 desc
            limit 1
        ) sub1 
    )
)




-- 4. For the customer that spent the most (in total over their lifetime as a customer) total_amt_usd, how many web_events did they have for each channel?

-- find customer that spent the most

select a.id, a.name, sum(o.total_amt_usd) as total 
from accounts a
join orders o on o.account_id = a.id 
group by 1,2
order by 3 desc
limit 1

-- now find # of web_events for each channel for that account

select channel, count(occurred_at)
from accounts a
join web_events w on w.account_id = a.id and a.id = (select id 
    from (
        select a.id, a.name, sum(o.total_amt_usd) as total 
        from accounts a
        join orders o on o.account_id = a.id 
        group by 1,2
        order by 3 desc
        limit 1
    ) sub1
)
group by 1 
order by 2 desc




-- 5. What is the lifetime average amount spent in terms of total_amt_usd for the top 10 total spending accounts?

-- find the top 10 accounts

select a.id, a.name, sum(o.total_amt_usd) as total 
from accounts a
join orders o on o.account_id = a.id 
group by 1,2
order by 3 desc
limit 10

-- find avg amount spent
select avg(total) from (
    select a.id, a.name, sum(o.total_amt_usd) as total 
    from accounts a
    join orders o on o.account_id = a.id 
    group by 1,2
    order by 3 desc
    limit 10
) sub 




-- 6. What is the lifetime average amount spent in terms of total_amt_usd, including only the companies that spent more per order, on average, than the average of all orders.

-- first find avg amount spent

select avg(o.total_amt_usd) 
from orders o 

-- find those that spent more than avg

select o.account_id, avg(o.total_amt_usd) as avg_companies_more
from orders o
group by 1
having avg(o.total_amt_usd) > (
    select avg(o.total_amt_usd) 
    from orders o   
)

-- find the avg of these accounts

select avg(avg_companies_more)
from (
    select o.account_id, avg(o.total_amt_usd) as avg_companies_more
    from orders o
    group by 1
    having avg(o.total_amt_usd) > (
        select avg(o.total_amt_usd) 
        from orders o   
    ) 
) sub