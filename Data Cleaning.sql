SELECT *
FROM layoffs;

-- Delete Duplicates --

CREATE TABLE layoffs_staging
LIKE layoffs;

INSERT layoffs_staging
SELECT *
FROM layoffs;

SELECT *
FROM layoffs_staging;

# Create copy of layoffs_staging with added row_num column
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

# Fill in table and include row numbers, where duplicates have row_num > 1
INSERT layoffs_staging2
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, 
country, funds_raised_millions) AS row_num
FROM layoffs_staging;

# Delete duplicates
DELETE
FROM layoffs_staging2
WHERE row_num > 1;

SELECT *
FROM layoffs_staging2
WHERE row_num > 1;



-- Standardize Data Non-NULL/Blank --

SELECT *
FROM layoffs_staging2;

# Look at columns to find anything to standardize
SELECT DISTINCT company
FROM layoffs_staging2
ORDER BY 1;

SELECT DISTINCT location
FROM layoffs_staging2
ORDER BY 1;

SELECT DISTINCT industry
FROM layoffs_staging2
ORDER BY 1;

SELECT `date`
FROM layoffs_staging2;

SELECT DISTINCT country
FROM layoffs_staging2
ORDER BY 1;


# Remove whitespace from the company names
UPDATE layoffs_staging2
SET company = TRIM(company);

# Find the most common label for crypto based industry
SELECT *
FROM layoffs_staging2
WHERE industry LIKE 'Crypto%';

# Standardize crypto label
UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

# Remove period at the end of some US country labels
UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';

SELECT `date`, 
STR_TO_DATE(`date`, '%m/%d/%Y')
FROM layoffs_staging2;

# Update date to standard SQL form
UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

# Change data column from text data type to date data type
ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;



-- Standardize Data IS NULL/Blank --

SELECT *
FROM layoffs_staging2
WHERE industry IS NULL
OR industry = '';

SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL;




