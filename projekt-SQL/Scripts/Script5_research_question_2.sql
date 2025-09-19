-- Q2: Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd?
SELECT
    category_name,
    MIN("year") AS first_year,
    MAX("year") AS last_year,
    ROUND(MIN(units_affordable)) AS affordable_first_year,
    ROUND(MAX(units_affordable)) AS affordable_last_year
FROM t_hana_zakova_project_SQL_primary_final
WHERE LOWER(category_name) LIKE '%mlék%'
   OR LOWER(category_name) LIKE '%chléb%'
GROUP BY category_name
ORDER BY category_name;
