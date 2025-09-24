-- Q2: Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd?

SELECT
    fp.category_name,
    MIN(fp.year) AS first_year,
    MAX(fp.year) AS last_year,
    ROUND(MIN(w.national_avg_wage / fp.avg_price), 0) AS affordable_first_year,
    ROUND(MAX(w.national_avg_wage / fp.avg_price), 0) AS affordable_last_year
FROM (
    SELECT
        year,
        AVG(avg_monthly_wage_czk) AS national_avg_wage
    FROM t_hana_zakova_project_SQL_primary_final
    GROUP BY year
) w
JOIN (
    SELECT
        year,
        category_name,
        AVG(avg_price_czk) AS avg_price
    FROM t_hana_zakova_project_SQL_primary_final
    WHERE LOWER(category_name) LIKE '%mléko%'
       OR LOWER(category_name) LIKE '%chléb%'
    GROUP BY year, category_name
) fp
ON w.year = fp.year
GROUP BY fp.category_name
ORDER BY fp.category_name;

