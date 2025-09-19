-- Q5: Má výška HDP vliv na změny ve mzdách a cenách potravin? Neboli, pokud HDP vzroste výrazněji v jednom roce, projeví se to na cenách potravin či mzdách ve stejném nebo následujícím roce výraznějším růstem?

-- HDP vs mzdy (ČR)
SELECT 
    corr(e.gdp, w.avg_wage) AS corr_gdp_wages
FROM t_hana_zakova_project_SQL_secondary_final e
JOIN (
    SELECT "year", AVG(avg_monthly_wage_czk) AS avg_wage
    FROM t_hana_zakova_project_SQL_primary_final
    GROUP BY "year"
) w ON e.year = w."year"
WHERE e.country = 'Czech Republic';

-- HDP vs ceny potravin
SELECT 
    corr(e.gdp, p.avg_price) AS corr_gdp_prices
FROM t_hana_zakova_project_SQL_secondary_final e
JOIN (
    SELECT "year", AVG(avg_price_czk) AS avg_price
    FROM t_hana_zakova_project_SQL_primary_final
    GROUP BY "year"
) p ON e.year = p."year"
WHERE e.country = 'Czech Republic';


