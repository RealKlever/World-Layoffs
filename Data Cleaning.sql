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


-- Standardize Data --

SELECT *
FROM layoffs_staging2;

# Remove whitespace from the company names
UPDATE layoffs_staging2
SET company = TRIM(company);

# Look at industry to see any repeated/renamed labels
SELECT DISTINCT(industry)
FROM layoffs_staging2
ORDER BY 1;

# Find the most common label for crypto based industry
SELECT *
FROM layoffs_staging2
WHERE industry LIKE 'Crypto%';

# Standardize crypto label
UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';




