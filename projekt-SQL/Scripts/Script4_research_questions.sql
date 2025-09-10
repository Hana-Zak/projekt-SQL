-- Q1: Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?
SELECT
    industry_name,
    "year",
    avg_monthly_wage_czk,
    LAG(avg_monthly_wage_czk) OVER (PARTITION BY industry_name ORDER BY "year") AS prev_year_wage,
    ROUND(
      (avg_monthly_wage_czk - LAG(avg_monthly_wage_czk) OVER (PARTITION BY industry_name ORDER BY "year"))
      / NULLIF(LAG(avg_monthly_wage_czk) OVER (PARTITION BY industry_name ORDER BY "year"),0) * 100,2
    ) AS yoy_change_percent
FROM v_payroll_year_industry
ORDER BY industry_name, "year";

-- pokles mezd (yoy_change_percent < 0)
WITH wage_changes AS (
    SELECT
        industry_name,
        "year",
        avg_monthly_wage_czk,
        LAG(avg_monthly_wage_czk) OVER (PARTITION BY industry_name ORDER BY "year") AS prev_year_wage,
        ROUND(
          (avg_monthly_wage_czk - LAG(avg_monthly_wage_czk) OVER (PARTITION BY industry_name ORDER BY "year"))
          / NULLIF(LAG(avg_monthly_wage_czk) OVER (PARTITION BY industry_name ORDER BY "year"),0) * 100, 
          2
        ) AS yoy_change_percent
    FROM v_payroll_year_industry
)
SELECT *
FROM wage_changes
WHERE yoy_change_percent < 0
ORDER BY industry_name, "year";

-- kolikrát mzdy klesly v každém odvětví
WITH wage_changes AS (
    SELECT
        industry_name,
        "year",
        ROUND(
          (avg_monthly_wage_czk - LAG(avg_monthly_wage_czk) OVER (PARTITION BY industry_name ORDER BY "year"))
          / NULLIF(LAG(avg_monthly_wage_czk) OVER (PARTITION BY industry_name ORDER BY "year"),0) * 100, 
          2
        ) AS yoy_change_percent
    FROM v_payroll_year_industry
)
SELECT 
    industry_name,
    COUNT(*) FILTER (WHERE yoy_change_percent < 0) AS times_declined
FROM wage_changes
GROUP BY industry_name
ORDER BY times_declined DESC;


-- Q2: Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd?
SELECT
    category_name,
    MIN("year") AS first_year,
    MAX("year") AS last_year,
    MIN(units_affordable) AS affordable_first_year,
    MAX(units_affordable) AS affordable_last_year
FROM t_hana_zakova_project_SQL_primary_final
WHERE LOWER(category_name) LIKE '%mlék%' 
   OR LOWER(category_name) LIKE '%chléb%'
GROUP BY category_name;

--zaokrouhlení
SELECT
    category_name,
    MIN("year") AS first_year,
    MAX("year") AS last_year,
    ROUND(MIN(units_affordable)::numeric) AS affordable_first_year,
    ROUND(MAX(units_affordable)::numeric) AS affordable_last_year
FROM t_hana_zakova_project_SQL_primary_final
WHERE LOWER(category_name) LIKE '%mlék%' 
   OR LOWER(category_name) LIKE '%chléb%'
GROUP BY category_name;

-- Q3: Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)?

WITH price_yoy AS (
    SELECT
        category_name,
        "year",
        avg_price_czk,
        LAG(avg_price_czk) OVER (PARTITION BY category_name ORDER BY "year") AS prev_price
    FROM t_hana_zakova_project_SQL_primary_final
)
SELECT
    category_name,
    ROUND(((AVG((avg_price_czk - prev_price) / NULLIF(prev_price,0) * 100))::numeric), 2) 
        AS avg_yoy_growth_percent
FROM price_yoy
WHERE prev_price IS NOT NULL
GROUP BY category_name
ORDER BY avg_yoy_growth_percent ASC;

-- Q4: Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?

WITH wage_yoy AS (
    SELECT
        "year",
        AVG(avg_monthly_wage_czk) AS avg_wage
    FROM v_payroll_year_industry
    GROUP BY "year"
),
wage_change AS (
    SELECT
        "year",
        avg_wage,
        LAG(avg_wage) OVER (ORDER BY "year") AS prev_wage,
        ((avg_wage - LAG(avg_wage) OVER (ORDER BY "year")) 
         / NULLIF(LAG(avg_wage) OVER (ORDER BY "year"),0) * 100)::numeric AS wage_yoy
    FROM wage_yoy
),
price_yoy AS (
    SELECT
        "year",
        AVG(avg_price_czk) AS avg_price
    FROM v_price_clean
    GROUP BY "year"
),
price_change AS (
    SELECT
        "year",
        avg_price,
        LAG(avg_price) OVER (ORDER BY "year") AS prev_price,
        ((avg_price - LAG(avg_price) OVER (ORDER BY "year")) 
         / NULLIF(LAG(avg_price) OVER (ORDER BY "year"),0) * 100)::numeric AS price_yoy
    FROM price_yoy
)
SELECT
    p."year",
    ROUND(p.price_yoy,2) AS price_growth,
    ROUND(w.wage_yoy,2) AS wage_growth,
    ROUND(p.price_yoy - w.wage_yoy,2) AS difference
FROM price_change p
JOIN wage_change w ON p."year" = w."year"
WHERE (p.price_yoy - w.wage_yoy) > 10
ORDER BY p."year";

-- Q5: Má výška HDP vliv na změny ve mzdách a cenách potravin? Neboli, pokud HDP vzroste výrazněji v jednom roce, projeví se to na cenách potravin či mzdách ve stejném nebo následujícím roce výraznějším růstem?

-- HDP vs mzdy (ČR)
SELECT corr(e.gdp, w.avg_monthly_wage_czk) AS corr_gdp_wages
FROM t_hana_zakova_project_SQL_secondary_final e
JOIN (
    SELECT "year", AVG(avg_monthly_wage_czk) AS avg_monthly_wage_czk
    FROM v_payroll_year_industry
    GROUP BY "year"
) w ON w."year" = e.year
WHERE e.country = 'Czech Republic';

-- HDP vs ceny potravin
SELECT corr(e.gdp, p.avg_price_czk) AS corr_gdp_prices
FROM t_hana_zakova_project_SQL_secondary_final e
JOIN (
    SELECT "year", AVG(avg_price_czk) AS avg_price_czk
    FROM v_price_clean
    GROUP BY "year"
) p ON p."year" = e.year
WHERE e.country = 'Czech Republic';

