-- Exploratory Data Analysis (EDA)

/*
	Normally when we start the EDA process we have some idea of what we are looking for
    but here we are jsut going to explore the data and find trends or patterns or 
    anything interesting like outliers.alter
    
    Let me give the idea of dataset what this data is about.
    The dataset contains every day layoffs (number of people who lost the jobs) over 3 years from 2020 to 2023.
    Dataset also contains which company of which industry in which country people were laid off every day.
*/

SELECT *
FROM world_layoffs.layoffs_staging2;

-- Easier Queries and summarizing data

-- let's look at the date range
SELECT MAX(`date`) AS max_date, MIN(`date`) AS min_date
FROM world_layoffs.layoffs_staging2;
-- This dataset contains data from 6th March 2020 to 11th March 2023 (Almost 3 years period)

-- let's look at total laid off over 3 years and max and min laid off in a day.
SELECT
SUM(total_laid_off) AS total_laid_off,
MAX(total_laid_off) AS max_laid_off_in_a_day,
MIN(total_laid_off) AS min_laid_off_in_a_day
FROM world_layoffs.layoffs_staging2
WHERE total_laid_off IS NOT NULL;
/*
	1. In these three years total 383,659 people were laid off
    2. Maximum 12000 people were laid off in a day
    3. Minimum 3 people were laid off in a day
*/

-- Let's group the data by company and summarize the data for each company
SELECT company,
SUM(total_laid_off) AS total_laid_off,
MAX(total_laid_off) AS max_laid_off_in_a_day,
MIN(total_laid_off) AS min_laid_off_in_a_day
FROM world_layoffs.layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;
/*
	Top 3 companies with highest total laidoff in these years are:
		1. 'Amazon', '18150', '10000', '150'
        2. 'Google', '12000', '12000', '12000'
		3. 'Meta', '11000', '11000', '11000'
*/


-- Let's group data by industry
SELECT industry,
SUM(total_laid_off) AS total_laid_off,
MAX(total_laid_off) AS max_laid_off_in_a_day,
MIN(total_laid_off) AS min_laid_off_in_a_day
FROM world_layoffs.layoffs_staging2
GROUP BY industry
ORDER BY 2 DESC;
/*
	Top 5 industries with highest total laidoff in these 3 years are:
		1. 'Consumer', '45182', '12000', '5'
		2. 'Retail', '43613', '10000', '3'
		3. 'Other', '36289', '10000', '8'
		4. 'Transportation', '33748', '3700', '7'
		5. 'Finance', '28344', '2000', '5'
*/

-- Now, by location
SELECT location,
SUM(total_laid_off) AS total_laid_off,
MAX(total_laid_off) AS max_laid_off_in_a_day,
MIN(total_laid_off) AS min_laid_off_in_a_day
FROM world_layoffs.layoffs_staging2
GROUP BY location
ORDER BY 2 DESC;
/*
	Top 5 companies with highest total laidoff in these 3 years are:
		1. SF Bay Area	125631	12000	5
		2. Seattle	34743	10000	5
		3. New York City	29364	3900	3
		4. Bengaluru	21787	2500	6
		5. Amsterdam	17140	6000	150
*/


-- Now, Let's look at the country to see which countries have more layoffs
SELECT country,
SUM(total_laid_off) AS total_laid_off,
MAX(total_laid_off) AS max_laid_off_in_a_day,
MIN(total_laid_off) AS min_laid_off_in_a_day
FROM world_layoffs.layoffs_staging2
GROUP BY country
ORDER BY 2 DESC;
-- United States has most layoffs in these 3 years
/*
	Top 5 companies with highest total laidoff in these 3 years are:
		1. 'United States', '254874', '12000', '3'
		2. 'India', '35993', '2500', '6'
		3. 'Netherlands', '17220', '6000', '80'
		4. 'Sweden', '11264', '8500', '12'
		5. 'Brazil', '10391', '1300', '4'
*/

-- Look at stage column
SELECT stage,
SUM(total_laid_off) AS total_laid_off,
MAX(total_laid_off) AS max_laid_off_in_a_day,
MIN(total_laid_off) AS min_laid_off_in_a_day
FROM world_layoffs.layoffs_staging2
GROUP BY stage
ORDER BY 2 DESC;
/*
	Top 5 companies with highest total laidoff in these 3 years are:
		Post-IPO	204132	12000	16
		Unknown		40716	3000	5
		Acquired	27576	4375	10
		Series C	20017	1500	5
		Series D	19225	800		7
*/

-- Let's look at total_laid_off in each year, and see which year has most layoffs
SELECT YEAR(`date`) AS 'year',
SUM(total_laid_off) AS total_laid_off,
MAX(total_laid_off) AS max_laid_off_in_a_day,
MIN(total_laid_off) AS min_laid_off_in_a_day
FROM world_layoffs.layoffs_staging2
WHERE YEAR(`date`) IS NOT NULL
GROUP BY 1
ORDER BY 2 DESC;

SELECT YEAR(date), SUM(total_laid_off)
FROM world_layoffs.layoffs_staging2
GROUP BY YEAR(date)
ORDER BY 1 ASC;
/*
 year, total_laid_off, max_laid_off_in_a_day, min_laid_off_in_a_day
'2022', '160661', '11000', '5'
'2023', '125677', '12000', '8'
'2020', '80998', '4375', '3'
'2021', '15823', '2434', '13'

	2022 has highest layoffs followed by 2023, 2020, and 2021
    Note: 2023 layoffs only contains 3 months of data
*/


-- Advanced Queries

/*
	Earlier we only looked at single columns such as companies, industries, stages.
    Now let's look at those columns per year and then per month
*/

WITH company_year AS
(
	SELECT company, YEAR(`date`) as years,
		SUM(total_laid_off) AS total_laid_off
	FROM world_layoffs.layoffs_staging2
    GROUP BY company, years
),
company_year_ranking AS
(
	SELECT *, DENSE_RANK() OVER(PARTITION BY years ORDER BY total_laid_off DESC) AS ranking
    FROM company_year
)
SELECT company, years, total_laid_off, ranking
FROM company_year_ranking
WHERE ranking <= 5
AND years IS NOT NULL
ORDER BY years ASC, total_laid_off DESC;
/*
	The above query will report top 5 companies with most layoffs each year.
    E.g:
    1. In 2020 Uber has most layoffs with 7525 total
    2. In 2021 Bytendance has most layoffs with 3600 total
    3. In 2022 Meta has most layoffs with 11000 total
    4. In 2023 Google has most layoffs with 12000 total
*/

-- Rolling Total of Layoffs Per Month

-- The below query will calculate total laid off per month then use it to calculate rolling total per month
SELECT SUBSTRING(`date`, 1, 7) AS dates, SUM(total_laid_off) AS total_laid_off_per_month
FROM world_layoffs.layoffs_staging2
WHERE SUBSTRING(`date`, 1, 7) IS NOT NULL
GROUP BY dates
ORDER BY dates ASC;

WITH monthly_laid_off AS
(
	SELECT SUBSTRING(`date`, 1, 7) AS dates, SUM(total_laid_off) AS total_laid_off_per_month
	FROM world_layoffs.layoffs_staging2
	GROUP BY dates
	ORDER BY dates ASC
)
SELECT dates, total_laid_off_per_month,
	SUM(total_laid_off_per_month) OVER(ORDER BY dates ASC) AS rolling_total_layoffs
FROM monthly_laid_off
ORDER BY dates ASC;