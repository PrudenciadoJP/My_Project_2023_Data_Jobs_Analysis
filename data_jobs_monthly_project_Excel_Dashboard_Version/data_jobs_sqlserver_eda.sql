USE data_jobs_worksheet;

--view information about the table
EXEC sp_help 'job_data_final$';

--index is a database object that improves the speed of data retrieval operations on a table.
CREATE CLUSTERED INDEX IX_TableName_ColumnName
ON job_data_final$ (job_id,job_title_short, job_location,job_via, job_posted_date);

--1.	What are the top 10 most in-demand skills for data-related jobs in 2023?
SELECT TOP 10 job_skills,
		COUNT(job_skills) AS num_of_jobs
FROM data_jobs_job_skills$ AS tble1
GROUP BY job_skills
ORDER BY num_of_jobs DESC;

--2.	Top 10 companies offered the highest average adjusted salary for data jobs in 2023?
SELECT	TOP 10 company_name,
		ROUND(AVG(adjusted_salary_year_avg),2) AS avg_offered_salary
FROM job_data_final$
GROUP BY company_name
ORDER BY avg_offered_salary DESC;

--3.	What percentage of data jobs offered health insurance benefits?
SELECT job_health_insurance,
       COUNT(job_health_insurance) AS total_jobs,
       ROUND(COUNT(job_health_insurance) * 100.0 / (SELECT COUNT(*) FROM job_data_final$),2) AS percentage
FROM job_data_final$
GROUP BY job_health_insurance;


--4.	How many data jobs were work-from-home opportunities by country?
SELECT job_country,
		COUNT(CASE WHEN job_work_from_home = 1 THEN 1 END) AS Work_from_home,
		COUNT(job_work_from_home) AS total_count,
		(CAST(COUNT(CASE WHEN job_work_from_home = 1 THEN 1 END) AS FLOAT) * 100 / COUNT(job_work_from_home)) AS percentage
FROM dbo.job_data_final$
GROUP BY job_country
ORDER BY Work_from_home DESC;

--5.	What is the distribution of data jobs by job location and job schedule?
SELECT tble1.job_location,
		COUNT(CASE WHEN tble2.value = 'Full-time' THEN 1 END) AS full_time_total,
		COUNT(CASE WHEN tble2.value = 'Part-time' THEN 1 END) AS Part_time_total,
		COUNT(CASE WHEN tble2.value NOT IN ('Full-time', 'Part-time') THEN 1 END) AS others,
		COUNT(CASE WHEN tble2.value IS NOT NULL THEN 1 END) AS total_jobs
FROM job_data_final$ AS tble1
INNER JOIN data_jobs_schedule$ AS tble2
ON tble1.job_id = tble2.job_id
WHERE tble1.job_location IS NOT NULL
GROUP BY tble1.job_location
ORDER BY total_jobs DESC;

--6.	What are the trends in average salary rates based on remote vs. onsite jobs?
SELECT job_work_from_home,
		ROUND(AVG(adjusted_salary_year_avg), 2) AS average_salary
FROM job_data_final$
GROUP BY job_work_from_home;
--7.	Which job titles are most commonly associated with the highest salaries?
SELECT	job_title_short,
		ROUND(AVG(adjusted_salary_year_avg), 2) AS avg_highest_salaries
FROM job_data_final$
GROUP BY job_title_short
ORDER BY avg_highest_salaries DESC;
--8.	What is the average job posting frequency per month in 2023?
WITH cte AS (
SELECT	DATENAME(MONTH,job_posted_date) AS month,
		COUNT(job_posted_date) AS job_posting_count
FROM job_data_final$
GROUP BY DATENAME(MONTH,job_posted_date)
)
	SELECT month,
			AVG(job_posting_count) AS avg_job_posting
	FROM cte
	GROUP BY month
	ORDER BY avg_job_posting DESC;

--9.	What is the average job posting frequency per weekday in 2023?
SELECT	DATENAME(WEEKDAY,job_posted_date) AS week_day,
		COUNT(job_posted_date) AS job_posting_count
FROM job_data_final$
GROUP BY DATENAME(WEEKDAY,job_posted_date)
ORDER BY job_posting_count DESC;

SELECT * FROM data_jobs_job_skills$;

SELECT * FROM data_jobs_schedule$;

SELECT * FROM job_data_final$;