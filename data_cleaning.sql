-- Data Cleaning Project

SELECT * FROM layoffs;

/*
Create a staging table from layoffs table of raw data.
We will work in staging table and clean the data.
layoffs table with raw data remains untouched in case somethings went wrong.
*/

CREATE TABLE layoffs_staging
LIKE layoffs;

-- insert data to staging table from original table
INSERT INTO layoffs_staging
SELECT *
FROM layoffs;

-- Follow the following steps to clean data
-- 1. Check Duplicates and Remove Duplicates
-- 2. Standardize the Data
-- 3. Look at Null Values or blank values
-- 4. Remove any Columns or Rows that are not necessary


-- 1. Remove Duplicates

# first let's check for duplicates

SELECT *
FROM world_layoffs.layoffs_staging;

SELECT *,
	ROW_NUMBER() OVER(PARTITION BY company, industry, total_laid_off, `date`) AS row_num
FROM layoffs_staging;

WITH duplicate_cte AS
(
	SELECT *,
	ROW_NUMBER() OVER(PARTITION BY company, industry, total_laid_off, `date`) AS row_num
	FROM layoffs_staging
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;

-- let's look at Oda to confirm
SELECT *
FROM layoffs_staging
WHERE company = 'Oda';
-- These are all legitimate records and should not be deleted. We need to really look at every single column to be accurate.

-- These are our real duplicates
WITH duplicate_cte AS
(
	SELECT *,
	ROW_NUMBER() OVER(
    PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
	FROM layoffs_staging
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;

-- let's check for the Casper
SELECT *
FROM layoffs_staging
WHERE company = 'Casper';
-- These are the ones we want to delete where the row number is greater than 1 or 2 ...

# remove the duplicates
/*
	One solution is to create a new column and add those row numbers in.
    Then delete where row numbers are greater than 1.
    Then delete that column
*/
-- create staging 2 table like staging 1 with extra column row_num.
CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT *
FROM world_layoffs.layoffs_staging2;

-- insert data into staging 2 from staging 1 with row_num
INSERT INTO world_layoffs.layoffs_staging2
SELECT *,
	ROW_NUMBER() OVER(
    PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions
    ) AS row_num
	FROM layoffs_staging;
    
SELECT *
FROM world_layoffs.layoffs_staging2
WHERE row_num > 1;

-- now we can delete rows were row_num is greater than 1
DELETE FROM world_layoffs.layoffs_staging2
WHERE row_num >= 2;


-- 2. Standardize Data

SELECT *
FROM world_layoffs.layoffs_staging2;

-- let's look at the company column
SELECT company
FROM world_layoffs.layoffs_staging2;

-- it has some white spaces around the values
SELECT company, TRIM(company)
FROM world_layoffs.layoffs_staging2;

-- update the company column
UPDATE world_layoffs.layoffs_staging2
SET company = TRIM(company);


-- Now, let's look at industry column
SELECT DISTINCT industry
FROM world_layoffs.layoffs_staging2
ORDER BY 1;

-- It has some blank and null values
-- Also same industry with different variation values like crypto and crypto currency
SELECT *
FROM world_layoffs.layoffs_staging2
WHERE industry LIKE 'Crypto%';

-- update the crypto currency to only crypto
UPDATE world_layoffs.layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

-- let's look at location column

SELECT DISTINCT location
FROM world_layoffs.layoffs_staging2
ORDER BY 1;

SELECT *
FROM world_layoffs.layoffs_staging2
WHERE location LIKE 'Malm%';

-- update 'MalmÃ¶' to Malmo
UPDATE world_layoffs.layoffs_staging2
SET location = 'Malmo'
WHERE location LIKE 'Malm%';


-- Now, it's country term to standardize
SELECT DISTINCT country
FROM world_layoffs.layoffs_staging2
ORDER BY 1;
-- We have some "United States" and some "United States." with a period at the end.

SELECT DISTINCT country, TRIM(TRAILING '.' FROM country)
FROM world_layoffs.layoffs_staging2;

UPDATE world_layoffs.layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';


-- Now, Look at the date column. it's type is text which is not good for time series analysis and visualizations
SELECT `date`
FROM world_layoffs.layoffs_staging2;

SELECT `date`,
STR_TO_DATE(`date`, '%m/%d/%Y')
FROM world_layoffs.layoffs_staging2;

-- format the date column to actual date using str_to_date(column, format)
UPDATE world_layoffs.layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

-- Now, convert date type from text to date
ALTER TABLE world_layoffs.layoffs_staging2
MODIFY COLUMN `date` DATE;

SELECT *
FROM world_layoffs.layoffs_staging2;


-- 3. Look at Null Values or blank values

-- total_laid_off colum
SELECT total_laid_off
FROM world_layoffs.layoffs_staging2
WHERE total_laid_off IS NULL; -- 739 ROWS

-- let's look at total and percentage laid off both
SELECT *
FROM world_layoffs.layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL; -- 361 rows 

-- We will delete rows with useless data in step 4. But we will keep some null values where all of three numeric columns are not null.
-- These null values will be used in EDA phase

-- so there isn't anything I want to change with the null values

-- Now, we will deal with blank values. We encountered some blank values in text columns
SELECT *
FROM world_layoffs.layoffs_staging2
WHERE industry IS NULL
OR industry = '';

-- update the blanks to null
UPDATE world_layoffs.layoffs_staging2
SET industry = NULL
WHERE industry = '';

-- let's take look at companies where industry is null or blank
SELECT *
FROM world_layoffs.layoffs_staging2
WHERE company LIKE 'Bally%'; -- no industry

SELECT *
FROM world_layoffs.layoffs_staging2
WHERE company = 'Airbnb'; -- it's travel industry (some rows have it)

SELECT *
FROM world_layoffs.layoffs_staging2 t1
JOIN world_layoffs.layoffs_staging2 t2
ON t1.company = t2.company
WHERE (t1.industry IS NULL OR t1.industry = '')
AND t2.industry IS NOT NULL;
-- Airbnb, Carvana and Juul has some non-populated industry values which we will populate with populated industry values

-- populate those null values
UPDATE world_layoffs.layoffs_staging2 t1
JOIN world_layoffs.layoffs_staging2 t2
	ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;


-- 4. Remove unnecessary Columns and Rows

SELECT *
FROM world_layoffs.layoffs_staging2;

SELECT *
FROM world_layoffs.layoffs_staging2
WHERE total_laid_off IS NULL;

SELECT *
FROM world_layoffs.layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

-- Don't Delete any rows if you are not confident 100% to do so.
-- Try to populate rows with null values
-- To populate null values in total and percentage laid off we need some more data wich is not present
-- hence we will delete rows where total and percentage laid off is null

DELETE
FROM world_layoffs.layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

SELECT *
FROM world_layoffs.layoffs_staging2;

-- We don't need row_num, therefor delete row_num column
ALTER TABLE world_layoffs.layoffs_staging2
DROP COLUMN row_num;