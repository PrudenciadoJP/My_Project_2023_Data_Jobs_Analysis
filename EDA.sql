-- Creating Database
DROP DATABASE IF EXISTS data_jobs_eda_project;
CREATE DATABASE data_jobs_eda_project;

USE data_jobs_eda_project;

-- Change Database Table Name
EXEC SP_RENAME 'job_data_cleaning$ExternalData_1', 'data_jobs';
EXEC SP_RENAME 'dbo.jobs_skills_cleaning$ExternalData_2', 'jobs_skills';

-- Creating an index for table data_jobs and jobs_skills for faster joins and querying
CREATE INDEX idx_job_table ON data_jobs (job_id, job_title_short, _salary_year_avg, _salary_hour_avg, job_setup)
CREATE INDEX idx_job_id_jobs_skills ON jobs_skills (job_id);

--Table Analysis
--1.	Total number of rows and columns in the dataset.
--2.	The range and scope of the data.
SELECT COUNT(*) rows_count -- counting the number of rows in the table.
FROM data_jobs; -- 32671 number of rows

SELECT	MIN(FORMAT(job_posted_date,'yyyy-mm-dd')) min_date, -- Year 2023 Janruary 1 to December 31
		MAX(FORMAT(job_posted_date, 'yyyy-mm-dd')) max_date,
		MIN(_salary_year_avg) min_salary, -- Salary range
		MAX(_salary_year_avg) max_salary
	FROM data_jobs;

-- DIstinct Data Jobs Role
SELECT DISTINCT job_title_short -- 10 Distinct data jobs related
FROM data_jobs;

EXEC SP_HELP data_jobs; -- display information about the table.
						-- 19 columns
SELECT COUNT(*) rows_count
FROM jobs_skills; -- 167266 number of rows

EXEC SP_HELP jobs_skills; -- 3 columns

--Data-Related Jobs Analysis
--1.	Types of data-related jobs available and the most popular roles.
SELECT	job_title_short,
		COUNT(job_title_short) number_of_job_posted -- Most popular posted data jobs is data analyst
FROM data_jobs
GROUP BY job_title_short
ORDER BY number_of_job_posted DESC;

--2.	Percentage of work-from-home vs. onsite jobs and salary comparison.
SELECT	job_setup,
		ROUND(AVG(CASE WHEN salary_rate = 'year' THEN _salary_year_avg END), 0) AS year_avg_salary,
		ROUND(AVG(CASE WHEN salary_rate = 'hour' THEN _salary_hour_avg END), 0) AS hour_avg_salary,
		CONCAT(ROUND(CAST(COUNT(job_id) AS FLOAT) / (SELECT COUNT(*) FROM data_jobs) * 100, 0), '%') AS percentage_of_job_setup
FROM data_jobs
GROUP BY job_setup;

--3.	Percentage of jobs offering health insurance and salary comparison.
SELECT	CASE WHEN job_health_insurance = 0 THEN 'No Insurance'
		ELSE 'With Insurance' END job_health_insurance,
		ROUND(AVG(CASE WHEN salary_rate = 'year' THEN _salary_year_avg END), 0) AS year_avg_salary,
		ROUND(AVG(CASE WHEN salary_rate = 'hour' THEN _salary_hour_avg END), 0) AS hour_avg_salary,
		CONCAT(ROUND(CAST(COUNT(job_health_insurance) AS FLOAT) / (SELECT COUNT(*) FROM data_jobs) * 100, 0), '%') AS percentage
FROM data_jobs
GROUP BY job_health_insurance;

--Salary Analysis
--1.	Average yearly/hourly salaries for data-related jobs.
SELECT	job_title_short,
		ROUND(AVG(CASE WHEN salary_rate = 'year' THEN _salary_year_avg END), 0) AS avg_salary_year,
		ROUND(AVG(CASE WHEN salary_rate = 'hour' THEN _salary_hour_avg END), 0) AS avg_salary_hour
FROM data_jobs
GROUP BY job_title_short
ORDER BY avg_salary_year DESC;

--2.	The correlation between job positions and salary levels is not directly displayed.
--		but is represented visually using a Power BI graph for better interpretation and insights.
SELECT	job_title_short,
		ROUND(AVG(CASE WHEN salary_rate = 'year' THEN _salary_year_avg END), 0) AS avg_salary_year,
		ROUND(AVG(CASE WHEN salary_rate = 'hour' THEN _salary_hour_avg END), 0) AS avg_salary_hour,
		COUNT(*) jobs_posted
FROM data_jobs
GROUP BY job_title_short
ORDER BY avg_salary_year DESC, avg_salary_hour DESC;

--3.	Impact of multiple technical skills on yearly salaries.
WITH cte AS (
SELECT	job_title_short,
		AVG(Skills_count) AS avg_skill_count
		FROM	(SELECT	job_id,
		job_title_short,
		COUNT(job_skills) AS Skills_count
FROM jobs_skills
GROUP BY job_id,	job_title_short) AS skills_table
GROUP BY job_title_short
),
	cte2 AS	(
	SELECT	job_title_short,
			AVG(CASE WHEN salary_rate = 'year' THEN _salary_year_avg END) AS year_avg_salary,
			AVG(CASE WHEN salary_rate = 'hour' THEN _salary_hour_avg END) AS hour_avg_salary
	FROM data_jobs
	GROUP BY job_title_short
)
	SELECT	c1.job_title_short,
			c1.avg_skill_count,
			ROUND(c2.year_avg_salary, 0) AS avg_year_salary,
			ROUND(c2.hour_avg_salary, 0) AS hour_avg_salary
	FROM cte AS c1
	INNER JOIN cte2 AS c2
	ON c1.job_title_short = c2.job_title_short;

--Job Platform Analysis
--1.	Top 10 most popular job platforms for data-related jobs.
SELECT	job_platform,
		COUNT(job_id) number_of_jobspost
FROM data_jobs
GROUP BY job_platform
ORDER BY number_of_jobspost DESC;

--Date and Time Analysis
--1.	Distribution of job postings by month, weekday, and time.
-- Couting job posted based on month
SELECT	DATENAME(MONTH, job_posted_date) Month,
		COUNT(job_id) number_of_posted_jobs
FROM data_jobs
GROUP BY DATENAME(MONTH, job_posted_date)
ORDER BY number_of_posted_jobs DESC;

-- Couting job posted based on weekday
SELECT	DATENAME(WEEKDAY, job_posted_date) weekdays,
		COUNT(job_id) number_of_posted_jobs
FROM data_jobs
GROUP BY DATENAME(WEEKDAY, job_posted_date)
ORDER BY number_of_posted_jobs DESC;

-- Couting job posted based on time
WITH cte AS (
	SELECT
		CASE 
			WHEN CAST(job_posted_date AS TIME) BETWEEN '00:00:00' AND '06:59:59' THEN '12 to 06 AM' 
			WHEN CAST(job_posted_date AS TIME) BETWEEN '07:00:00' AND '11:59:59' THEN '07 to 11 AM'
			WHEN CAST(job_posted_date AS TIME) BETWEEN '12:00:00' AND '18:59:59' THEN '12 to 06 PM' 
			WHEN CAST(job_posted_date AS TIME) BETWEEN '19:00:00' AND '23:59:59' THEN '07 to 12 PM' 
		END AS Time_Category,
		job_id
FROM data_jobs
)
	SELECT	Time_Category,
			COUNT(job_id) count_job_postings
	FROM cte
	GROUP BY Time_Category
	ORDER BY count_job_postings DESC;

--Country Analysis
--1.	Countries with the highest number of job postings.

SELECT	job_country,
		COUNT(job_id) job_postings
FROM data_jobs
GROUP BY job_country
ORDER BY job_postings DESC;

-- What are the popular technical skills required for data-related jobs, and do these skills correlate with higher-paying roles?
SELECT	TOP (10) skills.job_skills,
		COUNT(skills.job_skills) number_of_jobposted,
		ROUND(AVG(CASE WHEN jobs.salary_rate = 'year' THEN _salary_year_avg END), 0) AS avg_year_sal,
		ROUND(AVG(CASE WHEN jobs.salary_rate = 'hour' THEN _salary_hour_avg END), 0) AS avg_hour_sal,
		ROUND(CAST(COUNT(skills.job_skills) AS FLOAT) / (SELECT COUNT(*) FROM jobs_skills) * 100, 0) AS skills_likelihood
FROM jobs_skills AS skills
INNER JOIN data_jobs AS jobs
ON skills.job_id = jobs.job_id
GROUP BY job_skills
ORDER BY skills_likelihood DESC;