-- Q4: Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?

SELECT
    p."year",
    p.price_yoy AS price_growth,
    w.wage_yoy AS wage_growth,
    ROUND((p.price_yoy - w.wage_yoy)::numeric, 2) AS difference
FROM (
    SELECT
        "year",
        avg_price,
        LAG(avg_price) OVER (ORDER BY "year") AS prev_price,
        ROUND(((avg_price - LAG(avg_price) OVER (ORDER BY "year")) 
              / NULLIF(LAG(avg_price) OVER (ORDER BY "year"),0) * 100)::numeric, 2) AS price_yoy
    FROM (
        SELECT
            "year",
            ROUND(AVG(avg_price_czk)::numeric, 2) AS avg_price
        FROM t_hana_zakova_project_SQL_primary_final
        GROUP BY "year"
    ) AS p1
) AS p
JOIN (
    SELECT
        "year",
        avg_wage,
        LAG(avg_wage) OVER (ORDER BY "year") AS prev_wage,
        ROUND(((avg_wage - LAG(avg_wage) OVER (ORDER BY "year")) 
              / NULLIF(LAG(avg_wage) OVER (ORDER BY "year"),0) * 100)::numeric, 2) AS wage_yoy
    FROM (
        SELECT
            "year",
            ROUND(AVG(avg_monthly_wage_czk)::numeric, 2) AS avg_wage
        FROM t_hana_zakova_project_SQL_primary_final
        GROUP BY "year"
    ) AS w1
) AS w
ON p."year" = w."year"
WHERE (p.price_yoy - w.wage_yoy) > 10
ORDER BY p."year";


-- meziroční růst cen vs. růst mezd pro všechny roky

SELECT
    p."year",
    p.price_yoy AS price_growth,
    w.wage_yoy AS wage_growth,
    ROUND((p.price_yoy - w.wage_yoy)::numeric, 2) AS difference
FROM (
    SELECT
        "year",
        avg_price,
        LAG(avg_price) OVER (ORDER BY "year") AS prev_price,
        ROUND(((avg_price - LAG(avg_price) OVER (ORDER BY "year")) 
              / NULLIF(LAG(avg_price) OVER (ORDER BY "year"),0) * 100)::numeric, 2) AS price_yoy
    FROM (
        SELECT
            "year",
            ROUND(AVG(avg_price_czk)::numeric, 2) AS avg_price
        FROM t_hana_zakova_project_SQL_primary_final
        GROUP BY "year"
    ) p1
) p
JOIN (
    SELECT
        "year",
        avg_wage,
        LAG(avg_wage) OVER (ORDER BY "year") AS prev_wage,
        ROUND(((avg_wage - LAG(avg_wage) OVER (ORDER BY "year")) 
              / NULLIF(LAG(avg_wage) OVER (ORDER BY "year"),0) * 100)::numeric, 2) AS wage_yoy
    FROM (
        SELECT
            "year",
            ROUND(AVG(avg_monthly_wage_czk)::numeric, 2) AS avg_wage
        FROM t_hana_zakova_project_SQL_primary_final
        GROUP BY "year"
    ) w1
) w
ON p."year" = w."year"
ORDER BY p."year";


