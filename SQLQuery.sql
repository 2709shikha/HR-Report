CREATE DATABASE HR;

USE HR;

SELECT *
FROM HR_Data;

SELECT termdate
FROM HR_Data
ORDER BY termdate DESC;

-- fix termdate formatting
-- 1) convert dates to yyyy-MM-dd
-- 2) create new column new_termdate

UPDATE HR_Data
SET termdate = FORMAT(CONVERT(DATETIME, LEFT(termdate, 19), 120), 'yyyy-MM-dd');

ALTER TABLE HR_Data
ADD new_termdate DATE;

--copy converted time values from termdate to new_termdate

UPDATE HR_Data
SET new_termdate = CASE WHEN termdate IS NOT NULL AND ISDATE(termdate) = 1 
THEN CAST(termdate AS DATETIME)ELSE NULL END;

-- create new column "age"

ALTER TABLE HR_Data
ADD age nvarchar(50);

-- populate new column with age

UPDATE HR_Data
SET age = DATEDIFF(YEAR, birthdate, GETDATE());

SELECT age FROM HR_Data;

-- QUESTIONS TO ANSWER FROM THE DATA
-- 1) What's the age distribution in the company?
     --age distribution

SELECT MIN(age)AS Youngest, MAX(age)AS Oldest FROM HR_Data;

	 --age group distribution

SELECT age_group,
COUNT(*) AS COUNT
FROM
(SELECT
CASE
WHEN age <= 21 AND age <= 30 THEN '21 to 30'
WHEN age <= 31 AND age <= 40 THEN '31 to 40'
WHEN age <= 41 AND age <= 50 THEN '41 to 50'
ELSE '50+'
END AS age_group
FROM HR_Data
WHERE new_termdate IS NULL)AS subquery
GROUP BY age_group
ORDER BY age_group;

      -- age group by gender

SELECT age_group,gender,
COUNT(*) AS COUNT
FROM
(SELECT
CASE
WHEN age <= 21 AND age <= 30 THEN '21 to 30'
WHEN age <= 31 AND age <= 40 THEN '31 to 40'
WHEN age <= 41 AND age <= 50 THEN '41 to 50'
ELSE '50+'
END AS age_group,gender
FROM HR_Data
WHERE new_termdate IS NULL)AS subquery
GROUP BY age_group,gender
ORDER BY age_group,gender;

-- 2) What's the gender breakdown in the company?

SELECT gender,
COUNT(gender)AS COUNT
FROM HR_Data
WHERE new_termdate IS NULL
GROUP BY gender
ORDER BY gender;

-- 3) How does gender vary across departments and job titles?

SELECT department, gender,
COUNT(gender)AS COUNT
FROM HR_Data
WHERE new_termdate IS NULL
GROUP BY department, gender
ORDER BY department, gender;

-- job titles

SELECT department,jobtitle, gender,
COUNT(gender)AS COUNT
FROM HR_Data
WHERE new_termdate IS NULL
GROUP BY department,jobtitle,gender
ORDER BY department,jobtitle,gender;


-- 4) What's the race distribution in the company?

SELECT race,
COUNT(*)AS COUNT
FROM HR_Data
WHERE new_termdate IS NULL
GROUP BY race
ORDER BY COUNT DESC;

-- 5) What's the average length of employment in the company?

SELECT 
AVG(DATEDIFF(YEAR, hire_date, new_termdate))AS tenure
FROM HR_Data
WHERE new_termdate IS NOT NULL AND new_termdate <= GETDATE();

-- 6) Which department has the highest turnover rate?
   -- get total count
   -- get terminated count
   -- terminated count/total count

SELECT department,total_count,terminated_count,
(ROUND((CAST(terminated_count AS FLOAT)/total_count), 2)) *100 AS turnover_rate
FROM
(SELECT department,
COUNT(*)AS total_count,
SUM(CASE
WHEN new_termdate IS NOT NULL AND new_termdate <= GETDATE() THEN 1 ELSE 0
END)AS terminated_count
FROM HR_Data
GROUP BY department
)AS subquery
ORDER BY turnover_rate DESC;

-- 7) What is the tenure distribution for each department?

SELECT department,
AVG(DATEDIFF(YEAR, hire_date, new_termdate))AS tenure
FROM HR_Data
WHERE new_termdate IS NOT NULL AND new_termdate <= GETDATE()
GROUP BY department
ORDER BY tenure DESC;

-- 8) How many employees work remotely for each department?

SELECT location,
COUNT(*)AS COUNT
FROM HR_Data
WHERE new_termdate IS NULL
GROUP BY location;

-- 9) What's the distribution of employees across different states?

SELECT location_state,
COUNT(*)AS COUNT
FROM HR_Data
WHERE new_termdate IS NULL
GROUP BY location_state
ORDER BY COUNT DESC;

-- 10) How are job titles distributed in the company?

SELECT jobtitle,
COUNT(*)AS COUNT
FROM HR_Data
WHERE new_termdate IS NULL
GROUP BY jobtitle
ORDER BY COUNT DESC;

-- 11) How have employee hire counts varied over time?
    -- calculate hires
	-- calculate terminations
	-- (hires-terminations)/hires percent hire change

SELECT hire_year,hires,terminations,hires-terminations AS net_change,
(ROUND(CAST(hires-terminations AS FLOAT)/hires, 2))*100 AS percent_hire_change
FROM
(SELECT YEAR(hire_date)AS hire_year,
COUNT(*)AS hires,
SUM(CASE
WHEN new_termdate IS NOT NULL AND new_termdate <= GETDATE() THEN 1 ELSE 0
END
)AS terminations
FROM HR_Data
GROUP BY YEAR(hire_date)
)AS subquery
ORDER BY percent_hire_change;


