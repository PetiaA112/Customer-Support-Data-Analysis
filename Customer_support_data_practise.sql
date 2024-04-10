 
 
                                 -- Objective: Analyze customer support performance metrics to identify areas of improvement




  ----------------------------------------------------------------------------------------------------------------------
-- 1. Data Collection and Preparation
-- Extract the dataset from the provided source.
-- Preprocess the data to handle missing values and inconsistencies.
-- Perform exploratory data analysis to understand the distribution of variables.
select COUNT( distinct Unique_id)
from Customer_support_data -- total number of requests 85907 

select  Issue_reported_at,
count(Unique_id) over (partition by Issue_reported_at order by Issue_reported_at asc ) as number_of_repors_daily
from Customer_support_data
group by Issue_reported_at, Unique_id -- number of reports daily

select count(Unique_id) as number_of_requests , category
from Customer_support_data
group by category
order by number_of_requests desc  -- number of requests by category

select count(Unique_id) number_of_requests, channel_name
from Customer_support_data
group by channel_name
order by number_of_requests desc -- number of requesst by channel name

select CSAT_Score  ,count(Unique_id) as number_of_requests 
from Customer_support_data
group by CSAT_Score
order by CSAT_Score asc -- destribution of requests by CSAT_Score

select  avg(DATEDIFF(hour, Issue_reported_at, issue_responded))
from Customer_support_data -- average waitning time for customer support
----------------------------------------------------------------------------------------------------------------------


-- 2. Key Performance Indicators (KPIs) Calculation
 -- Calculate average handling time for each category and sub-category.
 select connected_handling_time as avg_handling_time, Product_category, Sub_category
  from Customer_support_data
  where connected_handling_time is not null and Product_category is not null
  group by Product_category, Sub_category, connected_handling_time
-- Compute CSAT (Customer Satisfaction) scores for different channels and categories.
select channel_name, category, CSAT_Score
from Customer_support_data
group by channel_name, category, CSAT_Score
order by channel_name desc, CSAT_Score desc
-- Analyze the distribution of issues reported and responded to
select  DATENAME(DW,issue_responded) day_of_the_week, cast(count(Unique_id) as decimal) /
( select count(Unique_id) from Customer_support_data ) as percent_of_total_requests
from Customer_support_data
group by  DATENAME(DW,issue_responded)

select datepart(hour,issue_responded)as hour_of_the_day,  count(Unique_id) as number_of_requests
from Customer_support_data
group by  datepart(hour,issue_responded)
order by datepart(hour,issue_responded) asc
----------------------------------------------------------------------------------------------------------------------


 
-- 3.  Performance Comparison
 -- Compare handling times across different agent shifts.
 select avg(connected_handling_time) as avg_handling_time,
 max(connected_handling_time) as max_handling_time,
min(connected_handling_time) as min_handling_time,
sum(connected_handling_time) as total_handling_time,
Agent_Shift
from Customer_support_data
where connected_handling_time is not null
group by Agent_Shift
 -- Analyze CSAT scores based on tenure buckets and supervisor assignments.
select Supervisor, count(CSAT_Score) as count_CSAT_score_above_avg
 from Customer_support_data
 where CSAT_Score > ( select avg(CSAT_Score) from Customer_support_data) 
 group by Supervisor
 order by  count_CSAT_score_above_avg desc

 select Supervisor, count(CSAT_Score) as count_CSAT_score_below_avg
 from Customer_support_data
 where CSAT_Score < ( select avg(CSAT_Score) from Customer_support_data) 
 group by Supervisor
 order by  count_CSAT_score_below_avg desc 
 
 select Tenure_Bucket, count(CSAT_Score) as count_CSAT_score_above_avg
 from Customer_support_data
 where CSAT_Score > ( select avg(CSAT_Score) from Customer_support_data) 
 group by Tenure_Bucket
 order by  count_CSAT_score_above_avg desc
 
 select Tenure_Bucket, count(CSAT_Score) as count_CSAT_score_below_avg
 from Customer_support_data
 where CSAT_Score < ( select avg(CSAT_Score) from Customer_support_data) 
 group by Tenure_Bucket
 order by  count_CSAT_score_below_avg desc
 ----------------------------------------------------------------------------------------------------------------------


-- Identify common reasons for delayed responses or low CSAT scores.


-- Analysis on  delayed responses

-- Delayed respomse Analysis
	-- Calculate average response time
DECLARE @avg_response_time FLOAT;

SELECT @avg_response_time = AVG(DATEDIFF(HOUR, issue_reported_at, issue_responded))
FROM Customer_support_data;

-- Identify common reasons for delayed responses or low CSAT scores
SELECT
    channel_name,
    CASE
        WHEN DATEDIFF(HOUR, issue_reported_at, issue_responded) > @avg_response_time THEN 'Delayed Response'
        ELSE 'Timely Response'
    END AS response_status,
    COUNT(*) AS count_cases
FROM
    Customer_support_data
GROUP BY
    channel_name,
    CASE
        WHEN DATEDIFF(HOUR, issue_reported_at, issue_responded) > @avg_response_time THEN 'Delayed Response'
        ELSE 'Timely Response'
    END; -- channnel name


declare @avg_response float;
--------------------------
select @avg_response = avg(DATEDIFF(hour, Issue_reported_at,issue_responded))
from Customer_support_data;
----------------------------------------
select 
Agent_Shift,
case 
when DATEDIFF(hour, Issue_reported_at,issue_responded) > @avg_response then 'Delayed Response'
else 'Timely Response'
end as response_status,
count(*) as count_cases
from Customer_support_data
group by Agent_Shift,
case 
when DATEDIFF (hour, Issue_reported_at, issue_responded) > @avg_response then 'Delayed Response'
else 'Timely Response'
end; -- Agent - shift


declare @avg_response float;
--------------------------
select @avg_response = avg(DATEDIFF(hour, Issue_reported_at,issue_responded))
from Customer_support_data;
----------------------------------------
select 
Tenure_Bucket,
case 
when DATEDIFF(hour, Issue_reported_at,issue_responded) > @avg_response then 'Delayed Response'
else 'Timely Response'
end as response_status,
count(*) as count_cases
from Customer_support_data
group by Tenure_Bucket,
case 
when DATEDIFF (hour, Issue_reported_at, issue_responded) > @avg_response then 'Delayed Response'
else 'Timely Response'
end; --Tenure Bucket


-- Analysis on  CSAT 
select Top 1 channel_name , count(CSAT_Score) as low_CSAT_score_count
from Customer_support_data
where CSAT_Score  = 1
group by channel_name
Order by low_CSAT_score_count desc

select Top 1 Agent_Shift, count(CSAT_Score) as low_CSAT_score_count
from Customer_support_data
where CSAT_Score  = 1
group by Agent_Shift
Order by low_CSAT_score_count desc

select Top 1  connected_handling_time , count(CSAT_Score) as low_CSAT_score_count
from Customer_support_data
where CSAT_Score  = 1 and connected_handling_time is not null
group by connected_handling_time
Order by low_CSAT_score_count desc

select Top 1 Supervisor, count(CSAT_Score) as low_CSAT_score_count
from Customer_support_data
where CSAT_Score  = 1
group by Supervisor
Order by low_CSAT_score_count desc

select Top 1 Tenure_Bucket , count(CSAT_Score) as low_CSAT_score_count
from Customer_support_data
where CSAT_Score  = 1
group by Tenure_Bucket
Order by low_CSAT_score_count desc ;

 with csat_score as
 (
 select  datediff(MINUTE, Issue_reported_at,issue_responded) as minute_response, CSAT_score
 from Customer_support_data
 )
 select Top 1 minute_response, 
   count(case when CSAT_score = 1 then 1 else null end ) as 'low_CSAT_score_count'
 from csat_score
 group by minute_response
 order by  low_CSAT_score_count desc ;
 


 -- for the further analysis count of total record will be made to understand main factors for low CSAT score ( to understand if count of Low CSAT score affected total number of records )


 -- finding the percentage of Low CSAT score responses compared to total count of responses
select   cast( 8745 as decimal ) / count(*)  * 100 as percentage_Low_CSAT_score_count_to_total_count
from Customer_support_data
where channel_name =  'Inbound'  -- 12.83 %
 
select  cast(5895 as decimal ) / count(*) * 100  as  percentage_Low_CSAT_score_count_to_total_count
from Customer_support_data
where Agent_Shift =  'Morning'  -- 14 %

select   cast( 3882 as decimal ) / count(*)  * 100  as percentage_Low_CSAT_score_count_to_total_count 
from Customer_support_data
where Tenure_Bucket =  '>90'  -- 12.66 %

select  cast(841 as decimal )  /  count(*)  * 100 as percentage_Low_CSAT_score_count_to_total_count   
from Customer_support_data
where minute_response =  '1' -- 7 %
                               
select cast( 664 as decimal ) / count(*)   * 100 as percentage_Low_CSAT_score_count_to_total_count
from Customer_support_data
where Supervisor =  'Zoe Yamamoto'   -- 18 %

-- Supervisor Zoe Yamamoto has the highest % of Low CSAT score count of Total responses

with low_csat as
(
select *
from Customer_support_data
where  Supervisor =  'Zoe Yamamoto' and CSAT_Score = 1
)
select   Agent_Shift  ,count(CSAT_Score) as Low_CSAT_count
from low_csat
group by Agent_Shift 
order by Low_CSAT_count desc -- Morning  Agent Shift 565


with low_csat as
(
select *
from Customer_support_data
where  Supervisor =  'Zoe Yamamoto' and CSAT_Score = 1
)
select   channel_name  ,count(CSAT_Score) as Low_CSAT_count
from low_csat
group by channel_name 
order by Low_CSAT_count desc -- Inbound channel type 437


with low_csat as
(
select *
from Customer_support_data
where  Supervisor =  'Zoe Yamamoto' and CSAT_Score = 1
)
select   Manager  ,count(CSAT_Score) as Low_CSAT_count
from low_csat
group by Manager 
order by Low_CSAT_count desc   -- John Smith	392 
                  
				  
with low_csat as
(
select *
from Customer_support_data
where  Supervisor =  'Zoe Yamamoto' and CSAT_Score = 1
)
select   Tenure_Bucket  ,count(CSAT_Score) as Low_CSAT_count
from low_csat
group by Tenure_Bucket 
order by Low_CSAT_count desc   -- >90	437 



with low_csat as
(
select *
from Customer_support_data
where  Supervisor =  'Zoe Yamamoto' and CSAT_Score = 1
)
select   category  ,count(CSAT_Score) as Low_CSAT_count
from low_csat
group by category 
order by Low_CSAT_count desc  -- category Returns	319
 ----------------------------------------------------------------------------------------------------------------------



-- Investigate the impact of specific product categories on handling times and customer satisfaction.


select  Product_category ,count(connected_handling_time) as count_handling_time_above_avg
from Customer_support_data
where connected_handling_time is not null and Product_category is not null and
connected_handling_time > (
select avg(connected_handling_time)
from Customer_support_data
where   connected_handling_time is not null and Product_category is not null 
)
group by Product_category
order by count_handling_time_above_avg desc --  Category Electronics has the highest count of handling time above avg of  35
 -- LifeStyle	2
 -- Mobile	1
 -- Home Appliences	1
 -- Books & General merchandise	1

-- calculating % of total count of  handling time abvoe avg by Product Category



select   cast( 35   as decimal ) / count(connected_handling_time) * 100 as percent_of_total
from Customer_support_data
where connected_handling_time is not null and Product_category is not null  -- Electronics 33 %

-- Product category dont have significant effect on handling time  except from Electronic which has highest % of handling time above avg which possibly been affected by total number of records


 
 -- calculating the % proportion of scat score above avg to the total number of scores 
  select Product_category ,cast(count(CSAT_Score) as decimal)  / (select count(*) from Customer_support_data where Product_category is not null ) * 100 as percentage_of_csat_score_above_avg
 from Customer_support_data
 where Product_category is not null and
 CSAT_Score > (
 select avg(CSAT_Score)
 from Customer_support_data
 )
 group by Product_category
 order by percentage_of_csat_score_above_avg   desc

