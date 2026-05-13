-- Data Cleaning


SELECT *
FROM layoffs;

#Typical steps to take when cleaning data
-- 1. Remove duplicates
-- 2. Standardise data
# remove any spelling errors or anything like that
-- 3. Null Values or Blank Values
# remove any unnecessary null values by populating in necessary data where possible
-- 4. Remove Any Columns
# Don't alter or change the raw dataset unless necessary to. make a backup or copy that you will work on first

CREATE TABLE layoffs_staging
LIKE layoffs;
#Creating a new table to work from

SELECT *
FROM layoffs_staging;

INSERT layoffs_staging
SELECT *
FROM layoffs;

#Populating the new table with the raw data that we are going to work on
# THis is so that if any mistakes are done we still have the raw data as backup

# notice that there is no ID column to identify unique rows

SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company,industry,total_laid_off,percentage_laid_off,`date`) AS row_numb
FROM layoffs_staging;

#trying to identify duplicated rows by creating a row numb partitioning by the selectedd columns above

#because we are not directly updating the table to create the row_numb column above, we'll have to make it

WITH duplicate_cte AS
(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company,location ,industry,total_laid_off,percentage_laid_off,`date` 
,stage ,country ,funds_raised_millions) AS row_numb
FROM layoffs_staging
)
SELECT *
FROM duplicate_cte
WHERE row_numb > 1;

SELECT *
FROM layoffs_staging
WHERE company = 'Hibob';
# checking to confirm some of the duplicates
# But with the company Oda the country and funds_raised_millions were not checked so we made a mistake
# So make the partition acording to every single column

WITH duplicate_cte AS
(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company,location ,industry,total_laid_off,percentage_laid_off,`date` 
,stage ,country ,funds_raised_millions) AS row_numb
FROM layoffs_staging
)
DELETE
FROM duplicate_cte
WHERE row_numb > 1;

#this would've worked on microsoft SQL but we will have to do something different
#the best thing to do in this case is to create the row_numb column in a new table

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
  `row_numb` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


SELECT * 
FROM layoffs_staging2
WHERE row_numb > 1;

INSERT INTO layoffs_staging2
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company,location ,industry,total_laid_off,percentage_laid_off,`date` 
,stage ,country ,funds_raised_millions) AS row_numb
FROM layoffs_staging;

#inserting the rawdata with the row numb in the new staging table

DELETE
FROM layoffs_staging2
WHERE row_numb > 1;

SELECT * 
FROM layoffs_staging2;

-- Standardising data

SELECT company,TRIM(company)
FROM layoffs_staging2;

#when looking at Included Health you can notice that there is a space at the start instead of starting with 'I'
#I have to fix that

UPDATE layoffs_staging2
SET company = TRIM(company);

SELECT DISTINCT industry
FROM layoffs_staging2
ORDER BY 1;

#when looking at 'Crypto','Crypto Currency' and 'Crypto Currency' it's the same thing

SELECT *
FROM layoffs_staging2
WHERE industry LIKE 'Crypto%';

UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'crypto%';

#Update the the table so that where in industry there is something that starts with crypto.. to be set to 'Crypto' only

# When cleaning data, try to check every column distinctly to see if you can spot some issues or inconsinstensies

SELECT *
FROM layoffs_staging2
WHERE country LIKE 'United States%';

# Looks like there is a 'United States' and a 'United States.'

SELECT DISTINCT country, TRIM(TRAILING '.' FROM country)
FROM layoffs_staging2
WHERE country LIKE 'United States%';

#trying to see if TRAILING will remove the fullstop at the end of United States

# Trailing helps with specific trailing characters that need to be removed at the end during a string manipulation

UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';

#Check on the data types that are used on every column and set them to the right one
# on the 'date' text type is used when it is supposed to be the 'date' type, this must be fixed for when visualisation of data will be done

#we are going to try to format it to m/d/y (america)

SELECT `date`,
STR_TO_DATE( `date`, '%m/%d/%Y')
FROM layoffs_staging2;

#when formating using STR_TO_DATE()
#the first parameter is the column name you will be formating then the second parameter will be the date sequence it will follow or the format you want it in
#%m = month in a two digit numeric value
#%M = returns the full name of the month
#%d = day in two numerical digits
#%Y = Year in four numerical digits
 
UPDATE layoffs_staging2
SET `date` = STR_TO_DATE( `date`, '%m/%d/%Y');

SELECT `date`
FROM layoffs_staging2;

#when checking the table details the data type for 'date' is still text all we did was format the text
#we still need to update the column data type from text to date

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

SELECT *
FROM layoffs_staging2;

-- removing nulls

#when deleting/removing nulls we first have to consider if it's okay for that column to have nulls like total laid off and percentage laid off
#sometimes its okay for each one to have a null but if both are null then it might be a problem

SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS null
AND percentage_laid_off IS null;

SELECT *
FROM layoffs_staging2
WHERE industry IS null;

#for some of these they have companies that aren't blank so we should try to populate them where possible

SELECT *
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
WHERE  t1.industry IS NULL
AND t2.industry IS NOT NULL;

# sometimes it helps to set empty data into nulls when trying to update them

UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = '';

UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;

#IT would be possible to populate total laid off where it's blank if we had the total amount of employees in the company

ALTER TABLE layoffs_staging2
DROP COLUMN row_numb;

DELETE
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND  percentage_laid_off IS NULL;

# I believe the table will be used in cases where we want to see the trends of companies being laid off and the columns 'total_laid_off' and ' percentage_laid_off' are most crusiall to this table
# that is why the rows where both datasets are blank are deleted
















































