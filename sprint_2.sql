/*SPRINT 2
NIVELL 1
EXERCICI 2
Utilitzant JOIN realitzaràs les següents consultes:
•	Llistat dels països que estan fent compres.*/

SELECT company.country
FROM company
JOIN transaction ON company.id=transaction.company_id
GROUP BY company.country
ORDER BY company.country ASC;

/*
•	Des de quants països es realitzen les compres.*/
SELECT COUNT(DISTINCT(company.country)) AS Numero_Paises
FROM company
JOIN transaction ON company.id=transaction.company_id;

/*
•	Identifica la companyia amb la mitjana més gran de vendes.*/

SELECT  transaction.company_id, company.company_name, avg(transaction.amount)
FROM transaction
JOIN company
ON company.id=transaction.company_id
WHERE declined = 0
GROUP BY company_id
ORDER BY avg(amount) DESC
LIMIT 1;

/* AQUESTA SOLUCIÓ FUNCIONA PERÒ NO ÉS ÓPTIMA - PARLAT AMB ALANA.
SELECT  transaction.company_id,  aux.avgsales
FROM 	(SELECT company_id, AVG(amount) AS avgsales 
		FROM transaction
        WHERE NOT declined=1
        GROUP BY company_id) AS aux
JOIN transaction
ON aux.company_id = transaction.company_id
ORDER BY aux.avgsales DESC
LIMIT 1;
*/

/*- AQUESTA SOLUCIÓ FUNCIONA PERÒ NO ÉS ÓPTIMA - PARLAT AMB ALANA.
SELECT aux1.company_id, aux1.avgsales
FROM	(SELECT company_id, AVG(amount) AS avgsales
		FROM transaction
		WHERE NOT declined = 1 
		GROUP BY company_id
		) AS aux1
WHERE avgsales = 	(SELECT MAX(	avgsales)
					FROM	(SELECT company_id, AVG(amount) AS avgsales
							FROM transaction
							WHERE NOT declined = 1 
							GROUP BY company_id) AS aux2);
*/

/*EXERCICI 3
Utilitzant només subconsultes (sense utilitzar JOIN):
•	Mostra totes les transaccions realitzades per empreses d'Alemanya.*/

SELECT *
FROM transaction
WHERE company_id IN (
					SELECT id
					FROM company
                    WHERE country LIKE 'Germany')
	AND declined = 0
ORDER BY transaction.company_id ASC;

/*
•	Llista les empreses que han realitzat transaccions per un amount superior a la mitjana de totes les transaccions.*/

SELECT DISTINCT(company_id)
FROM transaction
WHERE amount > (SELECT AVG(amount) AS avgSale
				FROM transaction
                WHERE declined = 0)
ORDER BY company_id ASC;

/*
•	Eliminaran del sistema les empreses que no tenen transaccions registrades, entrega el llistat d'aquestes empreses.*/

SELECT company.id
FROM company
WHERE NOT EXISTS ( SELECT transaction.company_id
						FROM transaction);

/* AIXÒ ÉS SI HO FAS AMB JOIN - No és el que demana l'enunciat
	SELECT *
	FROM company
	LEFT JOIN transaction
	ON company.id = transaction.company_id
	WHERE transaction.id IS NULL;
*/

/* 
NIVELL 2
EXERCICI 1
Identifica els cinc dies que es va generar la quantitat més gran d'ingressos a l'empresa per vendes. Mostra la data de cada transacció juntament amb el total de les vendes.
*/

SELECT DATE(timestamp) AS dia , SUM(amount) AS ingressos
FROM transaction
WHERE declined = 0
GROUP BY dia
ORDER BY ingressos DESC
LIMIT 5;

/*NIVELL 2
EXERCICI 2
Quina és la mitjana de vendes per país? Presenta els resultats ordenats de major a menor mitjà.
*/

SELECT company.country AS pais, AVG(transaction.amount) AS mitjana_vendes
FROM company
JOIN transaction
ON company.id = transaction.company_id
WHERE transaction.declined = 0
GROUP BY pais
ORDER BY mitjana_vendes DESC;

/*NIVELL 2
EXERCICI 3
En la teva empresa, es planteja un nou projecte per a llançar algunes campanyes publicitàries per a fer competència a la companyia "Non Institute". Per a això, et demanen la llista de totes les transaccions realitzades per empreses que estan situades en el mateix país que aquesta companyia.
*/

/*
    Mostra el llistat aplicant JOIN i subconsultes.
*/

SELECT transaction.id, company.company_name, company.country
FROM transaction
LEFT JOIN company
ON transaction.company_id = company.id
WHERE company.country = (SELECT country
						FROM company
                        WHERE company_name = "Non Institute")
    AND company_name NOT IN ("Non Institute")
    AND transaction.declined = 0
ORDER BY company.company_name ASC ;
    
/*
    Mostra el llistat aplicant solament subconsultes.
*/
    
SELECT id, company_id
FROM  transaction
WHERE company_id IN (	SELECT	id
						FROM	company
						WHERE   country = (	SELECT	country
											FROM	company
											WHERE	company_name = 'Non Institute')
													AND company_name <> 'Non Institute')
	AND declined = 0
    ORDER BY company_id ASC;

/*NIVELL 3
EXERCICI 1
Presenta el nom, telèfon, país, data i amount, d'aquelles empreses que van realitzar transaccions amb un valor comprès entre 100 i 200 euros i en alguna d'aquestes dates: 29 d'abril del 2021, 20 de juliol del 2021 i 13 de març del 2022. Ordena els resultats de major a menor quantitat.
*/

SELECT c.company_name, c.phone, c.country, DATE(t.timestamp), t.amount
FROM company AS c
JOIN transaction AS t
ON c.id = t.company_id
WHERE DATE(t.timestamp) IN ('2021-04-29', '2021-07-20', '2022-03-13')
	AND t.amount BETWEEN 100 AND 200
    AND t.declined = 0
ORDER BY t.amount DESC;

/*NIVELL 3
EXERCICI 2
Necessitem optimitzar l'assignació dels recursos i dependrà de la capacitat operativa que es requereixi, per la qual cosa et demanen la informació sobre la quantitat de transaccions que realitzen les empreses, però el departament de recursos humans és exigent i vol un llistat de les empreses on especifiquis si tenen més de 4 transaccions o menys.
*/

SELECT 
    CASE
        WHEN COUNT(t.id) > 4 THEN 'MÉS de 4 transaccions'
        WHEN COUNT(t.id) = 4 THEN 'JUSTES 4 transaccions'
        ELSE 'MENYS de 4 transaccions'
    END AS Classif_Emp_X_Num_Transac,
    t.company_id, c.company_name
FROM
    transaction AS t
JOIN company AS c
ON c.id = t.company_id
GROUP BY t.company_id
ORDER BY Classif_Emp_X_Num_Transac DESC, t.company_id ASC;
