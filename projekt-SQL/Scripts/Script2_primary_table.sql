-- Primární tabulka: mzdy a ceny potravin
CREATE TABLE t_hana_zakova_project_SQL_primary_final AS
WITH national_wage AS (
    SELECT
        y."year",
        AVG(w.avg_monthly_wage_czk) AS avg_monthly_wage_czk
    FROM v_common_years y
    JOIN v_payroll_year_industry w USING ("year")
    GROUP BY y."year"
)
SELECT
    py."year",
    nw.avg_monthly_wage_czk,
    pc.category_code,
    pc.category_name,
    pc.avg_price_czk,
    (nw.avg_monthly_wage_czk / NULLIF(pc.avg_price_czk,0)) AS units_affordable
FROM v_common_years py
JOIN national_wage nw ON nw."year" = py."year"
JOIN v_price_clean pc  ON pc."year" = py."year"
ORDER BY py."year", pc.category_name;

SELECT * FROM t_hana_zakova_project_SQL_primary_final;

-- kontrola dat
-- kolik řádků má tabulka
SELECT COUNT(*) FROM t_hana_zakova_project_SQL_primary_final;

-- jaké roky obsahuje
SELECT MIN("year") AS first_year, MAX("year") AS last_year
FROM t_hana_zakova_project_SQL_primary_final;
