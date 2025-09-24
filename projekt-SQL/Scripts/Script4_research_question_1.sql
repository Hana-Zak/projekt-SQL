-- 1) Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?

-- přehled meziročních změn mezd pro všechna odvětví
WITH wages_only AS (
    SELECT DISTINCT
        industry_name,
        "year",
        avg_monthly_wage_czk
    FROM t_hana_zakova_project_SQL_primary_final
),
wage_changes AS (
    SELECT
        industry_name,
        "year",
        avg_monthly_wage_czk,
        LAG(avg_monthly_wage_czk) OVER (
            PARTITION BY industry_name ORDER BY "year"
        ) AS prev_year_wage,
        ROUND(
            (avg_monthly_wage_czk - LAG(avg_monthly_wage_czk) OVER (
                PARTITION BY industry_name ORDER BY "year"
            ))
            / NULLIF(LAG(avg_monthly_wage_czk) OVER (
                PARTITION BY industry_name ORDER BY "year"
            ),0) * 100,2
        ) AS yoy_change_percent
    FROM wages_only
)
SELECT *
FROM wage_changes
ORDER BY industry_name, "year";


-- jen roky s poklesem
WITH wage_changes AS (
    SELECT
        industry_name,
        "year",
        avg_monthly_wage_czk,
        LAG(avg_monthly_wage_czk) OVER (PARTITION BY industry_name ORDER BY "year") AS prev_year_wage,
        ROUND(
            (avg_monthly_wage_czk - LAG(avg_monthly_wage_czk) OVER (PARTITION BY industry_name ORDER BY "year"))
            / NULLIF(LAG(avg_monthly_wage_czk) OVER (PARTITION BY industry_name ORDER BY "year"),0) * 100,2
        ) AS yoy_change_percent
    FROM t_hana_zakova_project_SQL_primary_final
)
SELECT *
FROM wage_changes
WHERE yoy_change_percent < 0   
ORDER BY industry_name, "year";


-- souhrn poklesů mezd podle odvětví
WITH wages_only AS (
    SELECT DISTINCT
        industry_name,
        "year",
        avg_monthly_wage_czk
    FROM t_hana_zakova_project_SQL_primary_final
),
wage_changes AS (
    SELECT
        industry_name,
        "year",
        avg_monthly_wage_czk,
        LAG(avg_monthly_wage_czk) OVER (
            PARTITION BY industry_name ORDER BY "year"
        ) AS prev_year_wage,
        ROUND(
            (avg_monthly_wage_czk - LAG(avg_monthly_wage_czk) OVER (
                PARTITION BY industry_name ORDER BY "year"
            ))
            / NULLIF(LAG(avg_monthly_wage_czk) OVER (
                PARTITION BY industry_name ORDER BY "year"
            ),0) * 100,2
        ) AS yoy_change_percent
    FROM wages_only
)
SELECT
    industry_name,
    COUNT(*) FILTER (WHERE yoy_change_percent < 0) AS times_declined
FROM wage_changes
GROUP BY industry_name
ORDER BY times_declined DESC, industry_name;


