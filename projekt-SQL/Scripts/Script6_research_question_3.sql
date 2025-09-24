-- Q3: Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)?

SELECT
    category_name,
    ROUND(AVG(yoy_growth_percent)::numeric, 2) AS avg_yoy_growth_percent
FROM (
    SELECT
        category_name,
        "year",
        ROUND(((avg_price_czk - prev_price) / NULLIF(prev_price,0) * 100)::numeric, 2) AS yoy_growth_percent
    FROM (
        SELECT
            category_name,
            "year",
            avg_price_czk,
            LAG(avg_price_czk) OVER (PARTITION BY category_name ORDER BY "year") AS prev_price
        FROM t_hana_zakova_project_SQL_primary_final
    ) AS price_changes
    WHERE prev_price IS NOT NULL
) AS price_growth
GROUP BY category_name
ORDER BY avg_yoy_growth_percent ASC;
