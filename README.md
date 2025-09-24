## **Projekt z SQL**: Analýza mezd, cen potravin a ekonomických ukazatelů v ČR



Projekt je zaměřen na analýzu životní úrovně občanů v České republice prostřednictvím vztahu mezi mzdami a cenami základních potravin. Součástí je také srovnání s vybranými ekonomickými ukazateli (HDP, GINI koeficient, populace) v evropském kontextu.



### Cíle projektu



* Vytvořit datový podklad pro analýzu životní úrovně z dostupných otevřených dat.
* Odpovědět na výzkumné otázky:



Q1: Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?

Q2: Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období?

Q3: Která kategorie potravin zdražuje nejpomaleji (má nejnižší meziroční nárůst cen)?

Q4: Existuje rok, kdy růst cen potravin převýšil růst mezd o více než 10 %?

Q5: Má HDP vliv na změny ve mzdách a cenách potravin?



### Použité SQL skripty



Script1\_views.sql – vytvoření čistících pohledů nad tabulkami mezd a cen (sjednocení názvů, filtrování průměrných hodnot, převod na roční průměry).



Script2\_primary\_table.sql – vytvoření tabulky t\_hana\_zakova\_project\_SQL\_primary\_final obsahující data mezd (po odvětvích) a cen potravin (za celou ČR) sjednocených na totožné porovnatelné období – společné roky.



Script3\_secondary\_table.sql – vytvoření tabulky t\_hana\_zakova\_project\_SQL\_secondary\_final obsahující HDP, GINI a populaci evropských zemí ve společném období.



Script4–8 – research\_questions – sada dotazů k výzkumným otázkám Q1–Q5.



### Výstupní data



* **Primární tabulka:** t\_hana\_zakova\_project\_SQL\_primary\_final



Obsahuje roky 2006–2018 (společné období pro mzdy i ceny).

Mzdy jsou dostupné po jednotlivých odvětvích, lze je ale i agregovat na celonárodní průměr.

Ceny potravin byly zprůměrovány za všechny regiony ČR → nereflektují regionální rozdíly.

Výpočet dostupnosti (units\_affordable) ukazuje, kolik jednotek dané potraviny lze koupit za průměrnou mzdu v daném roce.



* **Sekundární tabulka:** t\_hana\_zakova\_project\_SQL\_secondary\_final



Obsahuje evropské země a ukazatele HDP, GINI a populaci pro roky 2006–2018.

Některé země mají nekompletní data (např. chybějící GINI v některých letech).

Data byla převzata ze zdroje *economies* a spojena s tabulkou *countries*.



**Časové pokrytí dat**

U mezd (czechia\_payroll) a cen (czechia\_price) se nepřekrývají všechny roky. Proto byl vytvořen průnik (v\_common\_years) a výsledkem je období 2006–2018. Primární tabulka tedy obsahuje data pouze pro tyto roky.



**Chybějící hodnoty (NULL)**

Některé potravinové kategorie nemají dostupné hodnoty ve všech letech. Tyto případy byly ošetřeny pomocí funkcí NULLIF a LAG, aby se zabránilo chybám při výpočtech.



**Agregace**

Data byla transformována na národní průměry, proto výsledky nereflektují regionální rozdíly.

Ceny byly zprůměrované přes všechny regiony, vznikla jedna průměrná cena potraviny v ČR za rok.



**Sekundární tabulka (evropská data)**

V tabulce sekundárních dat se u některých evropských států objevují chybějící hodnoty GINI nebo HDP, což omezuje možnost jejich plného porovnání.



### Výzkumné otázky a odpovědi



**Q1:** Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?



**Odpověď:**

Analýza ukázala, že mzdy v České republice mají obecně vzestupný trend. Přesto se v některých odvětvích objevily meziroční poklesy – nejvíce v odvětvích těžba a dobývání (4 případy) a výroba a rozvod elektřiny (3 případy). Naopak odvětví jako zdravotnictví a sociální péče či doprava a skladování vykazovala po celé sledované období pouze růst. Lze tedy konstatovat, že i když převládá růst mezd, neplatí univerzálně pro všechna odvětví.



**Q2:** Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd?



**Odpověď:**

Pro analýzu byla použita průměrná mzda v ČR za všechna odvětví. Výsledky ukazují, že dostupnost základních potravin se mezi prvním a posledním sledovaným obdobím (2006–2018) zlepšila. V roce 2006 si bylo možné za průměrnou mzdu pořídit přibližně 1 065 kg chleba a 1 315 litrů mléka, v roce 2018 to bylo již 1 392 kg chleba a 1 670 litrů mléka.

To znamená, že i když ceny potravin rostly, růst mezd byl rychlejší, a proto se dostupnost chleba a mléka pro průměrného občana v průběhu sledovaného období zvýšila.



**Q3:** Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)?



**Odpověď:**

Analýza ukázala, že některé potravinové kategorie v průběhu sledovaného období (2006–2018) zdražovaly jen velmi pomalu, případně dokonce zlevňovaly. Nejpomaleji zdražoval cukr krystalový, který měl dokonce průměrný meziroční pokles ceny o 0,09 % a rajská jablka červená kulatá, která měla pokles ceny o 0,04 %. U banánů žlutých, přírodní minerální vody sycené a vepřové pečeně s kostí byly zaznamenány pouze minimální meziroční změny, průměrně kolem +0,05 %.



**Q4:** Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?



**Odpověď:**

Analýza neodhalila žádný rok, ve kterém by meziroční růst cen potravin převýšil růst mezd o více než 10 %. Nejblíže této hranici byl rok 2013, kdy ceny potravin vzrostly o 5,1 %, zatímco mzdy klesly o 1,56 %, což představovalo rozdíl +6,66 %. Naopak v roce 2009 mzdy rostly výrazně rychleji než ceny, rozdíl činil −9,48 %. I když se v některých letech ceny a mzdy vyvíjely odlišně, rozdíl nikdy nepřekročil hranici 10 %.



**Q5:** Má výška HDP vliv na změny ve mzdách a cenách potravin? Neboli, pokud HDP vzroste výrazněji v jednom roce, projeví se to na cenách potravin či mzdách ve stejném nebo následujícím roce výraznějším růstem?



**Odpověď:**

HDP vs mzdy (0,922) → velmi silná pozitivní korelace.

HDP vs ceny potravin (0,885) → silná pozitivní korelace.

Analýza ukázala silnou pozitivní korelaci mezi růstem HDP a růstem mezd v ČR. Když HDP roste, mzdy v ČR rostou téměř úměrně. Silná vazba se projevila i mezi HDP a cenami potravin, i když je o něco slabší. To znamená, že růst HDP se odráží zejména v růstu mezd, ale i v růstu cen potravin.



### Shrnutí



Analýza dat z období 2006–2018 ukázala, že mzdy v ČR mají dlouhodobě rostoucí trend, i když některá odvětví zaznamenala opakované poklesy. Dostupnost základních potravin, jako je chléb a mléko, se zlepšila díky rychlejšímu růstu mezd oproti cenám. Některé potraviny (např. cukr) dokonce zlevňovaly, jiné zdražovaly jen minimálně. Růst cen potravin nikdy nepřevýšil růst mezd o více než 10 %, nejblíže tomu byl rok 2013. Byla potvrzena silná pozitivní korelace mezi růstem HDP a růstem mezd (0,922) i cen potravin (0,885), což ukazuje, že ekonomický růst se nejvýrazněji odrazil v růstu mezd, zatímco dopad na ceny potravin byl mírnější.

