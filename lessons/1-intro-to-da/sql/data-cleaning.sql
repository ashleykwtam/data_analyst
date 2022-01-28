-- LEFT & RIGHT 

/* In the accounts table, there is a column holding the website for each company. The last three digits specify what type of web address they are using. 
A list of extensions (and pricing) is provided here. Pull these extensions and provide how many of each website type exist in the accounts table. */ 

select a.name, a.website, right(a.website, 3) as extensions
from accounts a 

select right(a.website, 3) as ext, count(*)
from accounts a 
group by 1



-- Use the accounts table to pull the first letter of each company name to see the distribution of company names that begin with each letter (or number). 

select left(name, 1) first_letter, count(*)
from accounts a 
group by 1
order by 2 desc



/* Use the accounts table and a CASE statement to create two groups: one group of company names that start with a number 
and a second group of those company names that start with a letter. What proportion of company names start with a letter? */

with co_names as (
select 
    case when left(name, 1) IN ('0','1','2','3','4','5','6','7','8','9') then 'numeric'
    else 'alpha'
    end as first_letter
from accounts a 
)

select *, count(*)
from co_names 
group by 1 



-- Consider vowels as a, e, i, o, and u. What proportion of company names start with a vowel, and what percent start with anything else?

select sum(vowel) vowel, sum(consonant) consonant from (
    select name, 
        case when left(upper(name), 1) in ('A', 'E', 'I', 'O', 'U') then 1 else 0 end as vowel,
        case when left(upper(name), 1) not in ('A', 'E', 'I', 'O', 'U') then 1 else 0 end as consonant
    from accounts 
) sub





-- POSITION, STRPOS, LOWER, UPPER 
