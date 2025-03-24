SELECT 'hello';

SELECT 
    *,
    confirmed - recovered / 2 AS new_column
FROM covid19_basic cb 
ORDER BY 
    date DESC;
--fdgg
--gdefee
---feefef

SELECT 'hello';


SELECT
	name,
	provider_type
FROM healthcare_provider hp
ORDER BY name ASC;
