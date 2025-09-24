-- Sekundární tabulka

CREATE TABLE t_hana_zakova_project_SQL_secondary_final AS
SELECT
    e.country,                     
    c.continent,
    e.year,
    e.gdp,
    e.gini,
    e.population
FROM economies e
JOIN countries c ON c.country = e.country 
JOIN (SELECT DISTINCT "year" FROM t_hana_zakova_project_SQL_primary_final) y
     ON y.year = e.year
WHERE c.continent = 'Europe'
ORDER BY e.year, e.country;

--kontrola
SELECT * FROM t_hana_zakova_project_SQL_secondary_final;
