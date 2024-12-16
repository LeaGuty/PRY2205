
--INFORME 1:
CREATE OR REPLACE VIEW CLIENTESXREGION AS 
SELECT REG.NOMBRE_REGION,
       SUM(CASE 
               WHEN MONTHS_BETWEEN(SYSDATE, CLI.FECHA_INSCRIPCION) > 240
               THEN 1
               ELSE 0
           END) AS CANTIDAD_CLIENTES_ANTIGUOS,
       COUNT(CLI.NUMRUN) AS TOTAL_CLIENTES
FROM CLIENTE CLI
INNER JOIN REGION REG ON REG.COD_REGION = CLI.COD_REGION
GROUP BY REG.NOMBRE_REGION
ORDER BY CANTIDAD_CLIENTES_ANTIGUOS;



CREATE INDEX IDX_REGION ON CLIENTE (COD_REGION);   

CREATE INDEX IDX_CLI_REGION ON CLIENTE (COD_REGION, NUMRUN);

--INFORME 2:

--Consulta con operador SET
SELECT TO_CHAR(SYSDATE, 'DD-MM-YYYY') AS FECHA
        ,COD_TPTRAN_TARJETA AS CODIGO
        ,UPPER(NOMBRE_TPTRAN_TARJETA) AS DESCRIPCION
        ,ROUND(AVG(MONTO_TRANSACCION)) AS MONTO_PROMEDIO_TRANSACCION
FROM(
    SELECT DISTINCT CTT.NRO_TARJETA
          ,CTT.NRO_TRANSACCION
          --,TTC.FECHA_TRANSACCION
          ,TTC.COD_TPTRAN_TARJETA
          ,TTC.MONTO_TRANSACCION
          ,TTT.NOMBRE_TPTRAN_TARJETA
          ,TRUNC((EXTRACT(MONTH FROM CTT.FECHA_VENC_CUOTA)+1)/7) +1 AS SEMESTRE
         --,SUM(TTC.MONTO_TOTAL_TRANSACCION/CTT.NRO_CUOTA)/COUNT(CTT.NRO_TARJETA)
         
    FROM  CUOTA_TRANSAC_TARJETA_CLIENTE  CTT 
    INNER JOIN TRANSACCION_TARJETA_CLIENTE TTC ON TTC.NRO_TARJETA=CTT.NRO_TARJETA AND TTC.NRO_TRANSACCION = CTT.NRO_TRANSACCION
    INNER JOIN TIPO_TRANSACCION_TARJETA TTT ON TTT.COD_TPTRAN_TARJETA = TTC.COD_TPTRAN_TARJETA
   
    
    MINUS
    
     SELECT DISTINCT CTT.NRO_TARJETA
          ,CTT.NRO_TRANSACCION
          --,TTC.FECHA_TRANSACCION
          ,TTC.COD_TPTRAN_TARJETA
          ,TTC.MONTO_TRANSACCION
          ,TTT.NOMBRE_TPTRAN_TARJETA
          ,TRUNC((EXTRACT(MONTH FROM CTT.FECHA_VENC_CUOTA)+1)/7) +1 AS SEMESTRE
         --,SUM(TTC.MONTO_TOTAL_TRANSACCION/CTT.NRO_CUOTA)/COUNT(CTT.NRO_TARJETA)
         
    FROM  CUOTA_TRANSAC_TARJETA_CLIENTE  CTT 
    INNER JOIN TRANSACCION_TARJETA_CLIENTE TTC ON TTC.NRO_TARJETA=CTT.NRO_TARJETA AND TTC.NRO_TRANSACCION = CTT.NRO_TRANSACCION
    INNER JOIN TIPO_TRANSACCION_TARJETA TTT ON TTT.COD_TPTRAN_TARJETA = TTC.COD_TPTRAN_TARJETA
    WHERE TRUNC((EXTRACT(MONTH FROM CTT.FECHA_VENC_CUOTA)+1)/7) +1 = 1
   )
GROUP BY COD_TPTRAN_TARJETA
        ,NOMBRE_TPTRAN_TARJETA   
    ORDER BY  MONTO_PROMEDIO_TRANSACCION   ;

--Consulta con Subconsulta - Inserción tabla SELECCION_TIPO_TRANSACCION
INSERT INTO SELECCION_TIPO_TRANSACCION
SELECT TO_CHAR(SYSDATE, 'DD-MM-YYYY') AS FECHA
        ,TTT.COD_TPTRAN_TARJETA AS COD_TIPO_TRANSAC
        ,UPPER(TTT.NOMBRE_TPTRAN_TARJETA) AS NOMBRE_TIPO_TRANSAC
        ,ROUND(AVG(TTC.MONTO_TRANSACCION))  AS MONTO_PROMEDIO --INDICÓ EN EL FORO QUE ERA EL MONTO TOTAL, SIN EMBARGO DECIDÍ USAR EL MONTO PORQUE DE ESTE MODO COINCIDEN LOS VALORES CON LA IMÁGEN DEL DOCUMENTO
FROM TRANSACCION_TARJETA_CLIENTE TTC
INNER JOIN (SELECT DISTINCT NRO_TARJETA --JOIN CON UNA SUBCONSULTA
            ,NRO_TRANSACCION
        FROM  CUOTA_TRANSAC_TARJETA_CLIENTE               
        WHERE  EXTRACT(MONTH FROM FECHA_VENC_CUOTA) > 5    ) CTTC ON CTTC.NRO_TARJETA = TTC.NRO_TARJETA AND CTTC.NRO_TRANSACCION = TTC.NRO_TRANSACCION
INNER JOIN TIPO_TRANSACCION_TARJETA TTT ON TTT.COD_TPTRAN_TARJETA = TTC.COD_TPTRAN_TARJETA
GROUP BY TTT.COD_TPTRAN_TARJETA,TTT.NOMBRE_TPTRAN_TARJETA
ORDER BY MONTO_PROMEDIO;

SELECT * FROM SELECCION_TIPO_TRANSACCION;

--Actualización de tabla TIPO_TRANSACCION_TARJETA 
UPDATE TIPO_TRANSACCION_TARJETA TTT SET TTT.TASAINT_TPTRAN_TARJETA = TTT.TASAINT_TPTRAN_TARJETA-0.01
WHERE EXISTS (
    SELECT 1
    FROM SELECCION_TIPO_TRANSACCION TT
    WHERE TT.COD_TIPO_TRANSAC = TTT.COD_TPTRAN_TARJETA
);

/*
1.	¿Cuál es el problema que se debe resolver?
    R:Obtener el monto promedio de las transacciones que presentan alguna cuota con més de vencimiento entre junio a diciembre.

2.	¿Cuál es la información significativa que necesita para resolver el problema?
    R: Las tablas involucradas, las principales son TRANSACCION_TARJETA_CLIENTE y CUOTA_TRANSAC_TARJETA_CLIENTE, también se requiere 
        TIPO_TRANSACCION_TARJETA para obtener la descripción del tipó de transacción.

3.	¿Cuál es el propósito de la solución que se requiere?
    R: Supongo que obtener información sobre los vencimientos de segundo semestre para aplicar la medida de baja de tasa de interés.

4.	Detalle los pasos, en lenguaje natural, necesarios para construir la alternativa que usa SUBCONSULTA.
    La consulta realiza una subconsulta sobre la tabla CUOTA_TRANSAC_TARJETA_CLIENTE, cuyo propósito es obtener, sin repeticiones, 
    las transacciones que tienen cuotas correspondientes a los meses posteriores a mayo. Esta subconsulta filtra las transacciones 
    relevantes y se utiliza en un JOIN con la tabla TRANSACCION_TARJETA_CLIENTE, lo que permite restringir el conjunto de transacciones 
    al criterio especificado (aunque parece que todas las transacciones cumplen con el criterio según los datos disponibles).
    Posteriormente, se realiza otro JOIN con la tabla TIPO_TRANSACCION_TARJETA, lo que permite agregar información descriptiva sobre el 
    tipo de transacción. Finalmente, se seleccionan y formatean los campos solicitados, como la fecha actual (SYSDATE) en formato 'DD-MM-YYYY',
    el código y el nombre del tipo de transacción en mayúsculas, y el promedio redondeado del monto de las transacciones. Los datos se agrupan 
    por tipo de transacción y se ordenan según el monto promedio.


5.	Detalle los pasos, en lenguaje natural, necesarios para construir la alternativa que usa OPERADOR SET.
    R: Esta consulta tiene como principal objetivo generar un listado único de transacciones utilizando la tabla CUOTA_TRANSAC_TARJETA_CLIENTE. 
    Para lograrlo, se agrega un campo calculado que determina si la cuota vence en el primer o segundo semestre del año. Este cálculo se realiza 
    mediante la expresión TRUNC((EXTRACT(MONTH FROM CTT.FECHA_VENC_CUOTA)+1)/7) +1.
    El listado inicial de transacciones puede contener duplicados si una misma transacción tiene cuotas en ambos semestres. Para resolverlo, 
    se utiliza el operador MINUS para restar de este listado las transacciones correspondientes al primer semestre. De esta forma, se obtiene 
    únicamente el conjunto de transacciones con cuotas correspondientes al segundo semestre.
    Finalmente, sobre este conjunto resultante, se calculan los promedios de los montos de las transacciones agrupados por el tipo de transacción, 
    considerando los campos solicitados y aplicando el formato requerido. El resultado es un listado que incluye la fecha actual, el código y la 
    descripción del tipo de transacción (en mayúsculas), y el promedio redondeado del monto de las transacciones, ordenado por este último campo.
    */
