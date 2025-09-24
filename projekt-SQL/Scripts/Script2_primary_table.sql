-- Primární tabulka: mzdy a ceny potravin

CREATE TABLE t_hana_zakova_project_SQL_primary_final AS
WITH wages AS (
    SELECT
        p.payroll_year AS year,
        p.industry_branch_code AS industry_code,
        ib.name AS industry_name,
        ROUND(AVG(p.value)::numeric, 2) AS avg_monthly_wage_czk
    FROM czechia_payroll p
    JOIN czechia_payroll_industry_branch ib 
         ON ib.code = p.industry_branch_code
    JOIN czechia_payroll_value_type vt 
         ON vt.code = p.value_type_code
    JOIN czechia_payroll_unit u 
         ON u.code = p.unit_code
    JOIN czechia_payroll_calculation c 
         ON c.code = p.calculation_code
    WHERE vt.code = 5958      -- průměrná hrubá mzda na zaměstnance
      AND u.code = 200        -- jednotka Kč
      AND c.code = 200        -- přepočtený (správná kalkulace)
    GROUP BY p.payroll_year, p.industry_branch_code, ib.name
),
prices AS (
    SELECT
        EXTRACT(YEAR FROM cp.date_from)::int AS year,
        cp.category_code,
        pc.name AS category_name,
        ROUND(AVG(cp.value)::numeric, 2) AS avg_price_czk
    FROM czechia_price cp
    JOIN czechia_price_category pc 
         ON pc.code = cp.category_code
    GROUP BY EXTRACT(YEAR FROM cp.date_from), cp.category_code, pc.name
),
common_years AS (
    SELECT DISTINCT w.year
    FROM wages w
    JOIN prices p ON p.year = w.year
)
SELECT
    w.year,
    w.industry_code,
    w.industry_name,
    w.avg_monthly_wage_czk,
    p.category_code,
    p.category_name,
    p.avg_price_czk,
    ROUND((w.avg_monthly_wage_czk / NULLIF(p.avg_price_czk,0))::numeric, 2) AS units_affordable
FROM wages w
JOIN prices p ON p.year = w.year
JOIN common_years y ON y.year = w.year
ORDER BY w.year, w.industry_code, p.category_code;


SELECT *
FROM t_hana_zakova_project_SQL_primary_final;

-- jaké roky obsahuje
SELECT MIN("year") AS first_year, MAX("year") AS last_year
FROM t_hana_zakova_project_SQL_primary_final;









