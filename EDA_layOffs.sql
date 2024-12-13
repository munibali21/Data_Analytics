SELECT *
FROM layoffs_staging2;

SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off=1
ORDER BY funds_raised_millions DESC;
-- companies with most laid offs
SELECT company,SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;

-- max and min dates
SELECT MIN(`date`),MAX(`date`)
FROM layoffs_staging2;

-- industries with most laid offs
SELECT industry,SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY industry
ORDER BY 2 DESC;
-- countries where most of the laid offs
SELECT country,SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY country
ORDER BY 2 DESC;
-- year wise laid offs
SELECT YEAR(`date`),SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY YEAR(`date`)
ORDER BY 1 DESC;
-- which stage has most laid offs
SELECT stage,SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY stage
ORDER BY 2 DESC;

SELECT company,AVG(percentage_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;
-- which month has the most laid offs
SELECT SUBSTRING(`date`,1,7) AS `MONTH`,SUM(total_laid_off)
FROM layoffs_staging2
WHERE SUBSTRING(`date`,1,7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1 ASC;
-- creating CTE for calculating total laid off rolling total
WITH rolling_total AS
(
SELECT SUBSTRING(`date`,1,7) AS `MONTH`,SUM(total_laid_off) AS sum_total_laid_off
FROM layoffs_staging2
WHERE SUBSTRING(`date`,1,7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1 ASC
)

SELECT `MONTH`,sum_total_laid_off,SUM(sum_total_laid_off) OVER (ORDER BY `MONTH`) AS rolling_off
FROM rolling_total;

SELECT company,YEAR(`date`),SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company,YEAR(`date`);
-- creating CTE to filter out top 5 companies per year with most laid offs
WITH company_year(company,years,total_laid_off) AS
(
SELECT company,YEAR(`date`),SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company,YEAR(`date`)
),
company_ranking AS
(
SELECT *,DENSE_RANK()OVER(PARTITION BY years ORDER BY total_laid_off DESC) AS ranking
FROM company_year
WHERE years IS NOT NULL
)
SELECT *
FROM company_ranking 
WHERE ranking <=5;

SELECT company,YEAR(`date`),SUM(funds_raised_millions)
FROM layoffs_staging2
GROUP BY company,YEAR(`date`)
ORDER BY 3 DESC;
WITH funds_raised(company,years,total_funds_raised) AS
(
SELECT company,YEAR(`date`),SUM(funds_raised_millions)
FROM layoffs_staging2
GROUP BY company,YEAR(`date`)
ORDER BY 3 DESC
),
rank_funds AS(
SELECT *,DENSE_RANK()OVER(PARTITION BY years ORDER BY total_funds_raised DESC) AS ranking
FROM funds_raised
)
SELECT *
FROM rank_funds
WHERE ranking<=5
AND years IS NOT NULL
AND total_funds_raised IS NOT NULL;

SELECT industry,AVG(percentage_laid_off)
FROM layoffs_staging2
GROUP BY industry
ORDER BY 2 DESC;

SELECT country,YEAR(`date`),AVG(percentage_laid_off)
FROM layoffs_staging2
GROUP BY country,YEAR(`date`)
ORDER BY 3 DESC;

WITH country_laid_off(country,years,avg_percet_laidoff) AS
(
SELECT country,YEAR(`date`),AVG(percentage_laid_off)
FROM layoffs_staging2
GROUP BY country,YEAR(`date`)
ORDER BY 3 DESC
),
country_rank AS
(
SELECT *,DENSE_RANK()OVER(PARTITION BY years ORDER BY avg_percet_laidoff) AS ranking
FROM country_laid_off
)
SELECT *
FROM country_rank
WHERE ranking<=5
AND years IS NOT NULL
AND avg_percet_laidoff IS NOT NULL;

