select * from hr;
alter table hr
change column ï»¿id emp_id varchar(20) null;

describe hr;

select termdate from hr;

set sql_safe_updates = 0;

update hr
set hire_date = case 
when hire_date like'%/%' then date_format(str_to_date(hire_date,'%m/%d/%Y'),'%Y-%m-%d')
when hire_date like'%-%' then date_format(str_to_date(hire_date,'%m-%d-%Y'),'%Y-%m-%d')
else null
end;

alter table hr
modify column birthdate date;

UPDATE hr
SET termdate = IF(termdate IS NOT NULL AND termdate != '', date(str_to_date(termdate, '%Y-%m-%d %H:%i:%s UTC')), '0000-00-00')
WHERE true;

SELECT termdate from hr;
SET sql_mode = 'ALLOW_INVALID_DATES';

ALTER TABLE hr
MODIFY COLUMN hire_date DATE;

alter table hr
add column age int;

update hr
set age = timestampdiff(year, birthdate, CURDATE());

SELECT min(AGE) AS YOUNGEST,
max(AGE) AS OLDEST
FROM HR;

SELECT count(*) FROM HR WHERE AGE<18;

-- QUESTIONS

-- 1. WHAT IS THE GENDER BREAKDOWN OF EMPLOYEES IN THE COMPANY?
SELECT GENDER, COUNT(*) AS COUNT
FROM HR
WHERE AGE > 18 AND TERMDATE= '0000-00-00'
group by GENDER;
-- 2. WHAT IS THE RACE/ETHNICITY BREAKDOWN OF EMPLOYEES IN THE COMPANY?
SELECT RACE, COUNT(*) AS COUNT
FROM HR
WHERE AGE > 18 AND TERMDATE= '0000-00-00'
GROUP BY RACE
order by COUNT(*) DESC;
-- 3. WHAT IS THE AGE DISTRIBUTION OF EMPLOYEES IN THE COMPANY?
SELECT min(AGE) AS YOUNGEST, max(AGE) AS OLDEST
FROM HR
WHERE AGE >= 18 AND TERMDATE= '0000-00-00';

SELECT 
	CASE
		WHEN AGE>=18 AND AGE<=24 THEN '18-24'
        WHEN AGE>=25 AND AGE<=34 THEN '25-34'
        WHEN AGE>=35 AND AGE<=44 THEN '35-44'
        WHEN AGE>=45 AND AGE<=54 THEN '45-54'
        WHEN AGE>=55 AND AGE<=64 THEN '55-64'
        else '65+'
	end as age_group,
    count(*) as count
from hr
WHERE AGE >= 18 AND TERMDATE= '0000-00-00'
group by age_group
order by age_group asc;

SELECT 
	CASE
		WHEN AGE>=18 AND AGE<=24 THEN '18-24'
        WHEN AGE>=25 AND AGE<=34 THEN '25-34'
        WHEN AGE>=35 AND AGE<=44 THEN '35-44'
        WHEN AGE>=45 AND AGE<=54 THEN '45-54'
        WHEN AGE>=55 AND AGE<=64 THEN '55-64'
        else '65+'
	end as age_group, gender,
    count(*) as count
from hr
WHERE AGE >= 18 AND TERMDATE= '0000-00-00'
group by age_group, gender
order by age_group, gender asc;


-- 4. HOW MANY EMPLOYEES WORK AT HEADQUARTERS VERSUS REMOTE LOCATION?

select location, count(*) as count
from hr
WHERE AGE >= 18 AND TERMDATE= '0000-00-00'
group by location;

-- 5. What is the average length of employment for employees who have been terminated?
select
avg(datediff(termdate, hire_date))/365 as avg_length_employment
from hr
where termdate <=curdate() and termdate <>'0000-00-00' and age >=18;

-- 6. How does the gender distribution vary across departments?
select department, gender, count(*) as count
from hr
WHERE AGE >= 18 AND TERMDATE= '0000-00-00'
group by department, gender
order by department;

-- 7. What is the distribution of job titles across the company?
select JOBTITLE, count(*) AS COUNT
from hr
WHERE AGE >= 18 AND TERMDATE= '0000-00-00'
group by JOBTITLE
order by JOBTITLE DESC;

-- 8. WHICH DEPARTMENT HAS THE HIGHEST TURNOVER RATE?
select department,
	total_count,
    terminated_count,
    terminated_count/total_count AS termination_rate
FROM (
	select department,
    count(*) as total_count,
    sum(case when termdate <> '0000-00-00' and termdate <=curdate() then 1 else 0 end) as terminated_count
    from hr
    group by department) as subquery
order by termination_rate desc;

select department,
	count(*) as total_count,
    sum(case when termdate <> '0000-00-00' and termdate <=curdate() then 1 else 0 end) as terminated_count,
    terminated_count/total_count AS termination_rate
FROM hr
group by department
order by termination_rate desc;
    
-- 9. What is the distribution of employees across locations by city and state?
select location_state, location_city, count(*) as COUNT
from hr
where termdate = '0000-00-00'
group by location_state, location_city
order by count desc;

-- 10. How was the company's employee count change over time based on hire and term dates?
select	
year,
hires,
terminations,
hires-terminations as net_change,
round((hires-terminations)/hires*100,2) AS net_change_rate
from(
select year(hire_date) as year,
count(*) as hires,
sum(case when termdate <> '0000-00-00' and termdate <=curdate() then 1 else 0 end) as terminations
from hr
group by year(hire_date)
) as subquery
order by year asc;

-- 11. What is the tenure distribution for each department?
select department, round(avg(datediff(termdate, hire_date)/365),0) as avg_tenure
from hr
where termdate <=curdate() and termdate <> '0000-00-00'
group by department
order by avg_tenure desc;
