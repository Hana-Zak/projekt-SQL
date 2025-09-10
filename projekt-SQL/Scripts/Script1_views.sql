SELECT code, name
FROM czechia_payroll_value_type
ORDER BY name;

SELECT code, name
FROM czechia_payroll_calculation
ORDER BY name;

SELECT code, name
FROM czechia_payroll_unit
ORDER BY name;

CREATE OR REPLACE VIEW v_payroll_clean AS
SELECT
    p.payroll_year             AS "year",
    p.industry_branch_code     AS industry_code,
    ib.name                    AS industry_name,
    p.value                    AS avg_monthly_wage_czk
FROM czechia_payroll p
JOIN czechia_payroll_industry_branch ib ON ib.code = p.industry_branch_code
WHERE p.value_type_code = 5958
  AND p.calculation_code = 100
  AND p.unit_code       = 200;

SELECT * FROM v_payroll_clean;
SELECT COUNT(*) FROM v_payroll_clean;


CREATE OR REPLACE VIEW v_payroll_year_industry AS
SELECT
    "year",
    industry_code,
    industry_name,
    AVG(avg_monthly_wage_czk) AS avg_monthly_wage_czk
FROM v_payroll_clean
GROUP BY "year", industry_code, industry_name;

SELECT * FROM v_payroll_year_industry;


CREATE OR REPLACE VIEW v_price_clean AS
SELECT
    EXTRACT(YEAR FROM cp.date_from)::int AS "year",
    cp.category_code                     AS category_code,
    pc.name                              AS category_name,
    AVG(cp.value)                        AS avg_price_czk
FROM czechia_price cp
JOIN czechia_price_category pc ON pc.code = cp.category_code
GROUP BY 1, 2, 3;

SELECT * FROM v_price_clean;


CREATE OR REPLACE VIEW v_common_years AS
SELECT DISTINCT p."year"
FROM v_payroll_year_industry p
JOIN v_price_clean c ON c."year" = p."year";

SELECT COUNT(*) AS common_years,
       MIN("year") AS first_year,
       MAX("year") AS last_year
FROM v_common_years;

