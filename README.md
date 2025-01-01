# My_Project_2023_Data_Jobs_Analysis
## Project Overview
As an aspiring data analyst and former job seeker, I created this project to provide valuable insights into data-related careers. By analyzing it using my skills in Excel (Power Query, Data Analysis Tool), ETL, Power BI (DAX, Data Visualization), and Structured Query Language (SQL). The dataset used for this analysis is sourced from GitHub Luke Barousse, I explored key aspects such as the types of available data jobs, required technical skills, optimal times to apply, the correlation between skills and salary, and popular job posting platforms.

![alt text](https://github.com/PrudenciadoJP/My_Project_2023_Data_Jobs_Analysis/blob/main/image/GifDatajobs.gif)

### The goal of this project is to provide an in-depth analysis of:
- Various types of data analyst careers.
- Required technical skills.
- Salary ranges and influencing factors.
- Popular job posting platforms.
- Patterns in job postings based on dates and time.

### Problem Statement

1.	What types of data-related jobs are available in the market, and which were most in demand in 2023?
2.	What are the popular technical skills required for data-related jobs?
3.	Does having multiple technical skills lead to higher salaries and better job qualifications?
4.	What are the best months, weekdays, and times for applicants to apply for work?
5.	What are the top 5 websites to apply for data-related jobs?

Data Overview
- Dataset Source: [GitHub](https://github.com/lukebarousse/Excel_Data_Analytics_Course/tree/main/0_Resources/Datasets)
- File Size: 3,754 KB
Data Structure:
- job_title_short, job_title, job_location, job_via, job_schedule_type, job_work_from_home, search_location, job_posted_date, job_no_degree_mention, job_health_insurance, job_country, salary_rate, salary_year_avg, salary_hour_avg, company_name, job_skills.

### Exploratory Data Analysis (EDA) Questions
Table Analysis

1.	Total number of rows and columns in the dataset.
2.	The range and scope of the data.

Data-Related Jobs Analysis

1.	Types of data-related jobs available and the most popular roles.
2.	Percentage of work-from-home vs. onsite jobs.
3.	Percentage of jobs offering health insurance.

Salary Analysis

1.	Average yearly/hourly salaries for data-related jobs.
2.	Correlation between job positions and salary levels.
3.	Impact of multiple technical skills on yearly salaries.
4.	Comparison of average yearly salaries for work-from-home and onsite jobs.
5.	Average yearly salary for jobs offering insurance vs. those without.

Job Platform Analysis

1.	Top 5 most popular job platforms for data-related jobs.

Date and Time Analysis
1.	Distribution of job postings by month, weekday, and time.

Country Analysis
1.	Countries with the highest number of job postings.

### Tools and Their Applications
- Excel: Used for data cleaning and basic analysis
- SQL Server Management: Utilized for performing Exploratory Data Analysis (EDA) and querying data to gain deeper insights.
- Power BI: Applied for Extract, Transform, and Load (ETL) processes, data visualization, data cleaning, and creating Data Analysis Expressions (DAX)

### Extract Transform and Load Data Using Excel
Extract 
- The data was extracted by downloading it from GitHub and importing it into an Excel workbook.

Transform
The data was transformed using Excel's Power Query for cleaning. This includes:
- Removing Duplicates
- Standardize Data 
- Removing Blank and Null data
- Removing Unnecessary Data

Tables Used:
Job_data table

![image](https://github.com/user-attachments/assets/e7e10e0a-c574-4255-a992-7d27f3c2e897)

Jobs_skills table

![image](https://github.com/user-attachments/assets/3f498aea-5475-40a3-b731-55e3a46da781)

Load
After transforming the data, the cleaned data was loaded into a new Excel workbook for further use.

![image](https://github.com/user-attachments/assets/159cd566-3429-451b-9885-cc1ac376edcc)

### Descriptive Analysis Using Excel
- I utilized Excel's Descriptive Analysis tool to obtain key statistical metrics for salary data. This included insights into the mean, median, standard deviation, and range for yearly and hourly salaries.

![image](https://github.com/user-attachments/assets/718539ad-5af1-435b-9c8b-1740355e6a8f)

### Explanatory Data Analysis Using SQL Server Management

- I created a database and then used the SQL Server Import and Export Wizard to import the datasets from the Excel file.

~~~
-- Creating Database

DROP DATABASE IF EXISTS data_jobs_eda_project;


CREATE DATABASE data_jobs_eda_project;
~~~

-	To optimize performance, I created an index for faster and more efficient querying, as the dataset contained a large volume of data and takes minutes to load.

~~~
-- Creating an index for table data_jobs and jobs_skills for faster joins and querying

CREATE INDEX idx_job_table ON data_jobs (job_id, job_title_short, _salary_year_avg, _salary_hour_avg, job_setup)
CREATE INDEX idx_job_id_jobs_skills ON jobs_skills (job_id);
~~~

- Table analysis, this code displays the information about the table.

~~~
--Table Analysis
--1.	Total number of rows and columns in the dataset.
--2.	The range and scope of the data.

SELECT COUNT(*) rows_count -- counting the number of rows in the table.
FROM data_jobs; -- 32671 number of rows


SELECT MIN(FORMAT(job_posted_date, 'yyyy-mm-dd')) min_date, -- Year 2023 Janruary 1 to December 31
 MAX(FORMAT(job_posted_date, 'yyyy-mm-dd')) max_date,
 MIN(_salary_year_avg) min_salary, -- Salary range
 MAX(_salary_year_avg) max_salary
FROM data_jobs;

-- Distinct Data Jobs Role

SELECT DISTINCT job_title_short -- 10 Distinct data jobs related
FROM data_jobs;

EXEC SP_HELP data_jobs; -- display information about the table.
 -- 19 columns

SELECT COUNT(*) rows_count
FROM jobs_skills; -- 167266 number of rows

EXEC SP_HELP jobs_skills; -- 3 columns
~~~

- Display data-related jobs and number of jobs posted in the dataset

~~~
--Data-Related Jobs Analysis
--1.	Types of data-related jobs available and the most popular roles.

SELECT job_title_short,
       COUNT(job_title_short) number_of_job_posted -- Most popular posted data jobs is data analyst
FROM data_jobs
GROUP BY job_title_short
ORDER BY number_of_job_posted DESC;
~~~

- This displays the percentage of work-from-home and onsite jobs in the dataset and the average year and hourly salary for work-from-home and onsite jobs.

~~~
--2.	Percentage of work-from-home vs. onsite jobs and salary comparison.

SELECT job_setup,
       ROUND(AVG(CASE
                     WHEN salary_rate = 'year' THEN _salary_year_avg
                 END), 0) AS year_avg_salary,
       ROUND(AVG(CASE
                     WHEN salary_rate = 'hour' THEN _salary_hour_avg
                 END), 0) AS hour_avg_salary,
       CONCAT(ROUND(CAST(COUNT(job_id) AS FLOAT) /
                      (SELECT COUNT(*)
                       FROM data_jobs) * 100, 0), '%') AS percentage_of_job_setup
FROM data_jobs
GROUP BY job_setup;
~~~

- This displays the percentage of jobs that offer Insurance and not Insured companies in the dataset as well the average year and hour salary for work-from-home and onsite jobs.

~~~
--3.	Percentage of jobs offering health insurance and salary comparison.

SELECT CASE
           WHEN job_health_insurance = 0 THEN 'No Insurance'
           ELSE 'With Insurance'
       END job_health_insurance,
       ROUND(AVG(CASE
                     WHEN salary_rate = 'year' THEN _salary_year_avg
                 END), 0) AS year_avg_salary,
       ROUND(AVG(CASE
                     WHEN salary_rate = 'hour' THEN _salary_hour_avg
                 END), 0) AS hour_avg_salary,
       CONCAT(ROUND(CAST(COUNT(job_health_insurance) AS FLOAT) /
                      (SELECT COUNT(*)
                       FROM data_jobs) * 100, 0), '%') AS percentage
FROM data_jobs
GROUP BY job_health_insurance;
~~~

- This Displays the Average year/hour salaries for data-related jobs

~~~
--Salary Analysis
--1.	Average yearly/hourly salaries for data-related jobs.

SELECT job_title_short,
       ROUND(AVG(CASE
                     WHEN salary_rate = 'year' THEN _salary_year_avg
                 END), 0) AS avg_salary_year,
       ROUND(AVG(CASE
                     WHEN salary_rate = 'hour' THEN _salary_hour_avg
                 END), 0) AS avg_salary_hour
FROM data_jobs
GROUP BY job_title_short
ORDER BY avg_salary_year DESC;
~~~

- To summarize average salary levels (yearly and hourly) and the number of job postings for each job title.  While it doesn't compute a direct correlation, the results can be visualized in Power BI for better interpretation of trends

~~~
--2.	The correlation between job positions and salary levels is not directly displayed.
--		but is represented visually using a Power BI graph for better interpretation and insights.

SELECT job_title_short,
       ROUND(AVG(CASE
                     WHEN salary_rate = 'year' THEN _salary_year_avg
                 END), 0) AS avg_salary_year,
       ROUND(AVG(CASE
                     WHEN salary_rate = 'hour' THEN _salary_hour_avg
                 END), 0) AS avg_salary_hour,
       COUNT(*) jobs_posted
FROM data_jobs
GROUP BY job_title_short
ORDER BY avg_salary_year DESC,
         avg_salary_hour DESC;
~~~

- Combines information about the average number of skills required for each job position and the average salary levels (both yearly and hourly). Provides a holistic view of how skill requirements relate to salary levels for each job title.

~~~
--3.	Impact of multiple technical skills on yearly salaries.
WITH cte AS
  (SELECT job_title_short,
          AVG(Skills_count) AS avg_skill_count
   FROM
     (SELECT job_id,
             job_title_short,
             COUNT(job_skills) AS Skills_count
      FROM jobs_skills
      GROUP BY job_id,
               job_title_short) AS skills_table
   GROUP BY job_title_short),
     cte2 AS
  (SELECT job_title_short,
          AVG(CASE
                  WHEN salary_rate = 'year' THEN _salary_year_avg
              END) AS year_avg_salary,
          AVG(CASE
                  WHEN salary_rate = 'hour' THEN _salary_hour_avg
              END) AS hour_avg_salary
   FROM data_jobs
   GROUP BY job_title_short)
SELECT c1.job_title_short,
       c1.avg_skill_count,
       ROUND(c2.year_avg_salary, 0) AS avg_year_salary,
       ROUND(c2.hour_avg_salary, 0) AS hour_avg_salary
FROM cte AS c1
INNER JOIN cte2 AS c2 ON c1.job_title_short = c2.job_title_short;
~~~

- Display the Top 10 most popular job platforms for data-related jobs.

~~~
--Job Platform Analysis
--1.	Top 10 most popular job platforms for data-related jobs.

SELECT job_platform,
       COUNT(job_id) number_of_jobspost
FROM data_jobs
GROUP BY job_platform
ORDER BY number_of_jobspost DESC;
~~~

- Month Distribution: Helps identify seasonal trends in job postings.
- Weekday Distribution: Provides insights into the most active days of the week for job postings.
- Time Distribution: Shows the most common timeframes for job postings, allowing job seekers to be more proactive during these hours.

~~~
--Date and Time Analysis
--1.	Distribution of job postings by month, weekday, and time.
-- Couting job posted based on month

SELECT DATENAME(MONTH, job_posted_date) MONTH,
                                        COUNT(job_id) number_of_posted_jobs
FROM data_jobs
GROUP BY DATENAME(MONTH, job_posted_date)
ORDER BY number_of_posted_jobs DESC;

-- Couting job posted based on weekday

SELECT DATENAME(WEEKDAY, job_posted_date) weekdays,
       COUNT(job_id) number_of_posted_jobs
FROM data_jobs
GROUP BY DATENAME(WEEKDAY, job_posted_date)
ORDER BY number_of_posted_jobs DESC;

-- Couting job posted based on time
WITH cte AS
  (SELECT CASE
              WHEN CAST(job_posted_date AS TIME) BETWEEN '00:00:00' AND '06:59:59' THEN '12 to 06 AM'
              WHEN CAST(job_posted_date AS TIME) BETWEEN '07:00:00' AND '11:59:59' THEN '07 to 11 AM'
              WHEN CAST(job_posted_date AS TIME) BETWEEN '12:00:00' AND '18:59:59' THEN '12 to 06 PM'
              WHEN CAST(job_posted_date AS TIME) BETWEEN '19:00:00' AND '23:59:59' THEN '07 to 12 PM'
          END AS Time_Category,
          job_id
   FROM data_jobs)
SELECT Time_Category,
       COUNT(job_id) count_job_postings
FROM cte
GROUP BY Time_Category
ORDER BY count_job_postings DESC;
~~~

- Display Countries with the highest number of job postings

~~~
--Country Analysis
--1.	Countries with the highest number of job postings.

SELECT job_country,
       COUNT(job_id) job_postings
FROM data_jobs
GROUP BY job_country
ORDER BY job_postings DESC;
~~~

### Power BI Data Visualization

1.	What types of data-related jobs are available in the market, and which were most in demand in 2023?

![image](https://github.com/user-attachments/assets/f928b490-8ee8-4c24-a68f-bed0326f9068)

Visualization Overview

Type: Stacked Bar Chart

- Y-Axis: Grouped Job Titles (e.g., Data Analyst, Data Scientist, etc.)
- X-Axis: Count of Job Postings (using DAX's COUNT() formula for aggregation).

Key Insights

- High Demand Roles:
  - Data Analyst holds the top position for job postings, indicating its popularity and demand in the market.
  - Data Scientist follows closely, showcasing consistent demand in the data field.
- Low Demand Roles:
  - Cloud Engineer has the fewest job postings, suggesting it may be an emerging or niche role compared to others.

Effect of Insights

-	Competition:
  - Roles like Data Analyst and Data Scientist are highly competitive due to their established demand and popularity.
- Emerging Opportunities:
  - Roles such as Cloud Engineer, Software Engineer, and Machine Learning Engineer offer less saturated markets and opportunities for early specialization.

Recommended Actions

- Assess Market Trends:
  - Consider the industry demand and growth trends for specific roles before making career decisions.
- Skill Alignment:
  - Focus on roles that align with your skills and long-term career interests.
- Strategic Positioning:
  - Explore emerging roles where competition is lower, such as Cloud Engineer or Machine Learning Engineer, to establish expertise in growing fields.

2.	What are the popular technical skills required for data-related jobs?

![image](https://github.com/user-attachments/assets/66bc5cb4-b3cc-4414-aefa-c3d6585042b5)

Visualization Overview

Type: Donut Chart

- Legend: Top 5 most posted skills in job requirements (e.g., SQL, Python, etc.).
- Values: Count of each skill's occurrences, converted to percentages of the grand total (using DAX's COUNT() formula).

Key Insights

- High Demand Skills:
  - SQL is the most frequently required skill, highlighting its significance in data-related roles.
  - Python is the second most sought-after skill, reinforcing its importance in data analysis, machine learning, and automation.
- Low Demand Skills:
  - Tableau ranks lowest among the top 5 skills, suggesting that while it is valuable, it is not as universally required.

Effect of Insights
- Employer Priorities:
  - SQL and Python are essential foundational skills for most data-related roles.
  - Specialized tools like Tableau may be role-specific or secondary in importance compared to programming languages.

Recommended Actions

- Skill Development:
  - Prioritize learning and mastering SQL and Python to meet the core requirements of most data-related jobs.
- Supplementary Skills:
  - Consider enhancing your skillset with tools like Tableau to diversify your expertise, particularly for roles in data visualization.
- Strategic Application:
  - Highlight your proficiency in SQL and Python on your resume and during interviews to align with employer expectations.

3.	Does having multiple technical skills lead to higher salaries and better job qualifications?

![image](https://github.com/user-attachments/assets/00e09e09-4763-443f-9547-eb53f4c1b685)

Visualization Overview

Type: Scatter Plot with a Trend Line (Dashed Line)

- Values: Unique job titles derived from job_title_short.
- X-Axis: Average annual salary for data-related jobs (calculated using CALCULATE(AVERAGE) DAX on salary_rate and salary_year_avg columns).
- Y-Axis: Average number of required skills per job (calculated by separating skills into a table and using COUNT() and AVERAGE DAX functions).

Key Insights

- Correlation Between Skills and Salary:
  - A positive correlation exists between the number of required technical skills and the average annual salary.
  - Higher salaries are associated with roles requiring more technical expertise.
- Senior Roles Demand More Skills:
  - Roles such as Senior Data Engineer exhibit higher skill requirements and offer higher compensation.

Effect of Insights

- Career Path:
  - Senior and specialized roles require advanced and diverse skill sets.
  - Compensation increases as skill complexity and breadth expand.
- Skill Gap Awareness:
  - For aspiring professionals, recognizing the skill requirements for high-level roles is critical to career planning.

Recommended Actions

- Skill Assessment:
  - Regularly evaluate your technical skills and knowledge to identify areas for improvement.
- Upskilling Focus:
  - Invest in mastering advanced and in-demand skills to position yourself for higher-paying roles.
  - Stay updated on industry trends to identify emerging skills relevant to senior positions.
- Strategic Role Targeting:
  - Consider transitioning to roles that offer opportunities to expand your technical expertise progressively.

4.	What are the best months, weekdays, and times for applicants to apply for work?

![image](https://github.com/user-attachments/assets/05617f3d-e957-4295-ab72-c205a6c1d0bf)

Visualization Overview

Line Chart (Monthly Trends)

- X-Axis: Month names for 2023 (obtained via DAX Date Hierarchy).
- Y-Axis: Count of job postings (calculated with CALCULATE(COUNT)) and highlighting max/min values using MAX and MIN DAX functions.

Best weekdays for the applicants to apply?

![image](https://github.com/user-attachments/assets/73f1c164-fc27-40b7-89de-675636599cb8)

Visualization Overview

Stacked Bar Chart (Weekday Trends)

-	Y-Axis: Weekday names (formatted using DAX FORMAT on job_posted_date).
-	X-Axis: Count of job postings (using the COUNT function).

Best time for the applicants to apply?

![image](https://github.com/user-attachments/assets/776fa9fa-f0f2-408d-ba1e-45e346672162)

Visualization Overview

Clustered Bar Chart (Time Trends)
- Y-Axis: Time categories (grouped via DAX SWITCH on formatted job_posted_date).
- X-Axis: Count of job postings (using the COUNT function).

Key Insights

By Month

-	Peak Month: August has the highest number of job postings, indicating strong employer activity and opportunities.
-	Lowest Activity: February has the fewest job postings, suggesting slower hiring activity.

By Weekday

-	Best Day: Wednesday shows the highest volume of job postings, making it the most strategic day to apply.
-	Least Active Day: Sunday has the fewest postings, suggesting minimal activity.

By Time

- Optimal Time: Jobs are most frequently posted between 12 PM and 6 PM, aligning with business hours and recruiter activity.
-	Least Active Time: Early mornings (6 AM–9 AM) have the fewest postings.
 
Effect of Insights

- Higher Competition:
  -	August and Wednesdays see significant job postings, but competition may be intense.
- Enhanced Visibility:
  -	Applying during the peak posting time (12 PM–6 PM) aligns with recruiter activity, increasing visibility.

Recommended Strategy

- Timing Your Applications:
  - Target your applications on Wednesdays in August during the 12 PM–6 PM window.
  - Submit applications early in the day to ensure they are reviewed during peak recruiter activity.
- Leverage Low-Activity Periods:
  -	Explore opportunities in low-competition months like February to increase the likelihood of standing out.
- Track Employer Activity:
  - Use insights about time and day trends to strategize follow-ups and interview scheduling.

5.	What are the top 5 websites to apply for data-related jobs?

![image](https://github.com/user-attachments/assets/ca7c7612-d3fd-4469-ac3c-165ab58af332)

Visualization Overview

Type: Clustered Bar Chart

- Y-Axis: Job Platforms (cleaned and deduplicated using transformations on the Job_Platform column).
- X-Axis: Count of job postings (calculated using the DAX COUNT function).

Key Insights:
-	LinkedIn is the leading platform for data-related job postings, offering the highest number of opportunities, Platforms like AI-Jobs.net and Indeed also provide substantial job listings, catering to both specialized and general audiences.

Effect of Insights:
- Focusing on LinkedIn increases your access to a broader range of jobs, but also exposes you to higher competition from other applicants. Using platforms with fewer listings, such as Ladders and Snagajob, may lead to less competition, potentially improving your chances for roles with fewer applicants.

Recommended Actions:
-	Primary Focus: Prioritize applying on LinkedIn, leveraging its extensive network and job listings for data-related roles, or Explore Ladders and Snagajob to identify hidden opportunities with less competition and regularly update and optimize your profiles on these platforms to improve visibility and attract recruiters.

### Conclusion
This project highlights the essential factors for navigating a data-related career. It combines data analysis and visualization to guide aspiring professionals in making informed decisions about their career paths. I hope it inspires others to embrace this field, master the necessary skills, and achieve their career goals.








