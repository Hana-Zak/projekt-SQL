-- Primární tabulka: mzdy a ceny potravin
CREATE TABLE t_hana_zakova_project_SQL_primary_final AS
SELECT
    p."year",
    p.industry_code,
    p.industry_name,
    p.avg_monthly_wage_czk,
    c.category_code,
    c.category_name,
    c.avg_price_czk,
    (p.avg_monthly_wage_czk / NULLIF(c.avg_price_czk,0)) AS units_affordable
FROM v_payroll_year_industry p
JOIN v_price_clean c
  ON p."year" = c."year";


SELECT * FROM t_hana_zakova_project_SQL_primary_final;

-- kontrola dat
-- kolik řádků má tabulka
SELECT COUNT(*) FROM t_hana_zakova_project_SQL_primary_final;

-- jaké roky obsahuje
SELECT MIN("year") AS first_year, MAX("year") AS last_year
FROM t_hana_zakova_project_SQL_primary_final;
