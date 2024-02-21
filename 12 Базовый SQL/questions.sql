/*
1.
Отобразите все записи из таблицы company по компаниям, которые закрылись.
*/
SELECT *
FROM company
WHERE status = 'closed';

/*
2.
Отобразите количество привлечённых средств для новостных компаний США. Используйте данные из таблицы company. 
Отсортируйте таблицу по убыванию значений в поле funding_total .
*/
SELECT funding_total
FROM company
WHERE category_code = 'news' AND country_code = 'USA'
ORDER BY funding_total DESC;

/*
3.
Найдите общую сумму сделок по покупке одних компаний другими в долларах. Отберите сделки, 
которые осуществлялись только за наличные с 2011 по 2013 год включительно.
*/
SELECT SUM(price_amount)
FROM acquisition
WHERE term_code = 'cash' 
AND acquired_at::date BETWEEN  '2011-01-01' AND '2013-12-31';

/*
4.

Отобразите имя, фамилию и названия аккаунтов людей в поле network_username, у которых названия аккаунтов начинаются на 'Silver'.
*/
SELECT  first_name,
        last_name,
        network_username
FROM people
WHERE network_username LIKE 'Silver%';

/*
5.
Выведите на экран всю информацию о людях, у которых названия аккаунтов в поле network_username содержат подстроку 'money', а фамилия начинается на 'K'.
*/
SELECT *
FROM people
WHERE network_username LIKE '%money%' AND last_name LIKE 'K%';

/*
6.
Для каждой страны отобразите общую сумму привлечённых инвестиций, которые получили компании, зарегистрированные в этой стране. Страну, в которой зарегистрирована компания, можно определить по коду страны. Отсортируйте данные по убыванию суммы.
*/
SELECT country_code,
SUM(funding_total)
FROM company
GROUP BY country_code
ORDER BY sum DESC;

/*
7.
Составьте таблицу, в которую войдёт дата проведения раунда, а также минимальное и максимальное значения суммы инвестиций, привлечённых в эту дату.
Оставьте в итоговой таблице только те записи, в которых минимальное значение суммы инвестиций не равно нулю и не равно максимальному значению.
*/
SELECT funded_at,
    MIN(raised_amount),
    MAX(raised_amount)
FROM funding_round
GROUP BY funded_at
HAVING MIN(raised_amount) != 0 
AND MIN(raised_amount) != MAX(raised_amount);

/*
8.
Создайте поле с категориями:
    - Для фондов, которые инвестируют в 100 и более компаний, назначьте категорию high_activity.
    - Для фондов, которые инвестируют в 20 и более компаний до 100, назначьте категорию middle_activity.
    - Если количество инвестируемых компаний фонда не достигает 20, назначьте категорию low_activity.
Отобразите все поля таблицы fund и новое поле с категориями.
*/
SELECT *,
    CASE
    WHEN invested_companies >= 100 THEN 'high_activity'
    WHEN invested_companies < 20 THEN 'low_activity'
    ELSE 'middle_activity'
    END
FROM fund;

/*
9.
Для каждой из категорий, назначенных в предыдущем задании, посчитайте округлённое до ближайшего целого 
числа среднее количество инвестиционных раундов, в которых фонд принимал участие. Выведите на экран 
категории и среднее число инвестиционных раундов. Отсортируйте таблицу по возрастанию среднего.
*/
WITH act AS (SELECT *,
       CASE
           WHEN invested_companies>=100 THEN 'high_activity'
           WHEN invested_companies>=20 THEN 'middle_activity'
           ELSE 'low_activity'
       END AS activity
FROM fund)
SELECT activity,
ROUND(AVG(investment_rounds))
FROM act
GROUP BY activity
ORDER BY round;

/*
10.
Проанализируйте, в каких странах находятся фонды, которые чаще всего инвестируют в стартапы. 
Для каждой страны посчитайте минимальное, максимальное и среднее число компаний, в которые инвестировали фонды 
этой страны, основанные с 2010 по 2012 год включительно. Исключите страны с фондами, у которых минимальное 
число компаний, получивших инвестиции, равно нулю. 
Выгрузите десять самых активных стран-инвесторов: отсортируйте таблицу по среднему количеству компаний 
от большего к меньшему. Затем добавьте сортировку по коду страны в лексикографическом порядке.
*/
SELECT country_code,
	MIN(invested_companies),
	MAX(invested_companies),
	AVG(invested_companies)
FROM fund
WHERE founded_at BETWEEN '2010-01-01' AND '2012-12-31'
GROUP BY country_code
HAVING MIN(invested_companies) != 0
ORDER BY avg DESC, country_code
LIMIT 10;

/*
11.
Отобразите имя и фамилию всех сотрудников стартапов. Добавьте поле с названием 
учебного заведения, которое окончил сотрудник, если эта информация известна.
*/
SELECT  p.first_name,
	p.last_name,
	ed.instituition
FROM people AS p
LEFT JOIN education AS ed ON p.id=ed.person_id;

/*
12.
Для каждой компании найдите количество учебных заведений, которые окончили её сотрудники. 
Выведите название компании и число уникальных названий учебных заведений. 
Составьте топ-5 компаний по количеству университетов.
*/
SELECT c.name,
COUNT(DISTINCT ed.instituition)

FROM company AS c
JOIN people AS p ON c.id=p.company_id
JOIN education AS ed ON p.id=ed.person_id
GROUP BY c.name
ORDER BY count DESC
LIMIT 5;

/*
13.
Составьте список с уникальными названиями закрытых компаний, для которых первый раунд финансирования оказался последним.
*/
SELECT DISTINCT c.name
FROM company AS c
JOIN funding_round AS fr ON c.id=fr.company_id
WHERE c.status = 'closed' AND
fr.is_first_round=1 AND
fr.is_last_round=1;

/*
14.
Составьте список уникальных номеров сотрудников, которые работают в компаниях, отобранных в предыдущем задании.
*/
WITH xxx AS (SELECT c.id
FROM company AS c
JOIN funding_round AS fr ON c.id=fr.company_id
WHERE c.status = 'closed' AND
fr.is_first_round=1 AND
fr.is_last_round=1)
SELECT DISTINCT p.id
FROM people AS p JOIN xxx ON p.company_id = xxx.id;

/*
15.
Составьте таблицу, куда войдут уникальные пары с номерами сотрудников из предыдущей задачи 
и учебным заведением, которое окончил сотрудник.
*/
WITH xxx AS (
    SELECT c.id
    FROM company AS c
    JOIN funding_round AS fr ON c.id=fr.company_id
    WHERE c.status = 'closed' AND
    fr.is_first_round=1 AND
    fr.is_last_round=1
)
SELECT DISTINCT p.id,
ed.instituition;

/*
16.
Посчитайте количество учебных заведений для каждого сотрудника из предыдущего задания. 
При подсчёте учитывайте, что некоторые сотрудники могли окончить одно и то же заведение дважды.
*/
SELECT DISTINCT
    p.id ,
    COUNT(DISTINCT ed.id)
FROM company AS c
JOIN funding_round AS fr ON fr.company_id = c.id
JOIN people AS p ON p.company_id = c.id
JOIN education AS ed ON ed.person_id = p.id
WHERE 
    c.status = 'closed' AND
    fr.is_first_round = 1 AND
    fr.is_last_round  = 1
GROUP BY p.id;

/*
17.
Дополните предыдущий запрос и выведите среднее число учебных заведений (всех, не только уникальных), 
которые окончили сотрудники разных компаний. Нужно вывести только одну запись, группировка здесь не понадобится.
*/
SELECT AVG(xxx.count) FROM (
SELECT DISTINCT
    p.id ,
    COUNT(DISTINCT ed.id)
FROM company AS c
JOIN funding_round AS fr ON fr.company_id = c.id
JOIN people AS p ON p.company_id = c.id
JOIN education AS ed ON ed.person_id = p.id
WHERE 
    c.status = 'closed' AND
    fr.is_first_round = 1 AND
    fr.is_last_round  = 1
GROUP BY p.id
) AS xxx;

/*
18.
Напишите похожий запрос: выведите среднее число учебных заведений (всех, не только уникальных), которые окончили сотрудники Facebook*.
*(сервис, запрещённый на территории РФ)
*/
SELECT AVG(xxx.count) FROM (
SELECT DISTINCT
    p.id ,
    COUNT(DISTINCT ed.id)
FROM company AS c
JOIN funding_round AS fr ON fr.company_id = c.id
JOIN people AS p ON p.company_id = c.id
JOIN education AS ed ON ed.person_id = p.id
WHERE 
    c.name = 'Socialnet'
GROUP BY p.id
) AS xxx;

/*
19.
Составьте таблицу из полей:
    - name_of_fund — название фонда;
    - name_of_company — название компании;
    - amount — сумма инвестиций, которую привлекла компания в раунде.
В таблицу войдут данные о компаниях, в истории которых было больше шести важных этапов, 
а раунды финансирования проходили с 2012 по 2013 год включительно.
*/
SELECT f.name AS name_of_fund,
	c.name AS name_of_company,
	fr.raised_amount as amount
FROM fund AS f
JOIN investment AS i ON i.fund_id = f.id
JOIN funding_round AS fr ON fr.id = i.funding_round_id
JOIN company as c ON c.id = i.company_id
WHERE 
    c.milestones > 6 AND fr.funded_at BETWEEN '2012-01-01' AND '2013-12-31';

/*
20.
Выгрузите таблицу, в которой будут такие поля:
    - название компании-покупателя;
    - сумма сделки;
    - название компании, которую купили;
    - сумма инвестиций, вложенных в купленную компанию;
    - доля, которая отображает, во сколько раз сумма покупки превысила сумму вложенных 
      в компанию инвестиций, округлённая до ближайшего целого числа.
Не учитывайте те сделки, в которых сумма покупки равна нулю. Если сумма инвестиций 
в компанию равна нулю, исключите такую компанию из таблицы. 
Отсортируйте таблицу по сумме сделки от большей к меньшей, а затем по названию купленной компании 
в лексикографическом порядке. Ограничьте таблицу первыми десятью записями.
*/
WITH idb AS(
SELECT c_b.name as acquiring,
a_b.price_amount,
a_b.id
FROM acquisition AS a_b 
JOIN company AS c_b ON a_b.acquiring_company_id=c_b.id
WHERE a_b.price_amount != 0),

ids AS (
    SELECT c_s.name as acquired,
        c_s.funding_total,
    a_s.id
FROM acquisition AS a_s 
JOIN company AS c_s ON a_s.acquired_company_id=c_s.id
WHERE c_s.funding_total != 0)

SELECT acquiring,
price_amount,
acquired,
funding_total,
ROUND(price_amount/funding_total)
FROM idb AS b
JOIN ids AS s ON b.id = s.id
ORDER BY price_amount DESC, acquired
LIMIT 10;

/*
21.
Выгрузите таблицу, в которую войдут названия компаний из категории social, получившие финансирование 
с 2010 по 2013 год включительно. Проверьте, что сумма инвестиций не равна нулю. 
Выведите также номер месяца, в котором проходил раунд финансирования.
*/
WITH xxx AS (SELECT company_id,
EXTRACT(MONTH FROM funded_at)
FROM funding_round
WHERE funded_at BETWEEN '2010-01-01' AND '2013-12-31' AND raised_amount != 0)

SELECT c.name,
xxx.extract
FROM company AS c JOIN xxx ON c.id = xxx.company_id
WHERE c.category_code = 'social';

/*
22.
Отберите данные по месяцам с 2010 по 2013 год, когда проходили инвестиционные раунды. 
Сгруппируйте данные по номеру месяца и получите таблицу, в которой будут поля:
    - номер месяца, в котором проходили раунды;
    - количество уникальных названий фондов из США, которые инвестировали в этом месяце;
    - количество компаний, купленных за этот месяц;
    - общая сумма сделок по покупкам в этом месяце.
*/
WITH 
xxx AS (
    SELECT 
        EXTRACT(MONTH FROM CAST(fr.funded_at AS DATE)) AS months,
        COUNT(DISTINCT f.id) AS count_name
    FROM 
        fund AS f
        LEFT JOIN investment AS i ON  i.fund_id = f.id
        LEFT JOIN funding_round AS fr ON i.funding_round_id = fr.id
    WHERE 
        f.country_code = 'USA'
        AND EXTRACT(YEAR FROM CAST(fr.funded_at AS DATE)) BETWEEN 2010 AND 2013
    GROUP BY 
        months
),
acquisitions AS (
    SELECT 
        EXTRACT(MONTH FROM CAST(acquired_at AS DATE)) AS months,
        COUNT(acquired_company_id) AS seller,
        SUM(price_amount) AS sum_total
    FROM 
        acquisition
    WHERE 
        EXTRACT(YEAR FROM CAST(acquired_at AS DATE)) BETWEEN 2010 AND 2013
    GROUP BY 
        months
)
    
SELECT 
    f.months, 
    f.count_name, 
    a.seller AS seller, 
    a.sum_total AS sum_total
FROM 
    xxx f
    LEFT JOIN acquisitions a ON f.months = a.months;;

/*
23.
Составьте сводную таблицу и выведите среднюю сумму инвестиций для стран, в которых есть стартапы, 
зарегистрированные в 2011, 2012 и 2013 годах. Данные за каждый год должны быть в отдельном поле. 
Отсортируйте таблицу по среднему значению инвестиций за 2011 год от большего к меньшему.
*/
WITH
mean_funding_total_2011 AS (
	SELECT
	    country_code,
	    AVG(funding_total) AS mean_2011
	FROM company
	WHERE EXTRACT(YEAR FROM founded_at) = 2011
	GROUP BY country_code
),
mean_funding_total_2012 AS (
	SELECT
	    country_code,
	    AVG(funding_total) AS mean_2012
	FROM company
	WHERE EXTRACT(YEAR FROM founded_at) = 2012
	GROUP BY country_code
	),
mean_funding_total_2013 AS (
	SELECT
	    country_code,
	    AVG(funding_total) AS mean_2013
	FROM company
	WHERE EXTRACT(YEAR FROM founded_at) = 2013
	GROUP BY country_code
)

SELECT
    s_2011.country_code,
    mean_2011,
    mean_2012,
    mean_2013
FROM mean_funding_total_2011 AS s_2011
JOIN mean_funding_total_2012 AS s_2012 ON s_2012.country_code = s_2011.country_code
JOIN mean_funding_total_2013 AS s_2013 ON s_2013.country_code = s_2011.country_code
ORDER BY mean_2011 DESC;