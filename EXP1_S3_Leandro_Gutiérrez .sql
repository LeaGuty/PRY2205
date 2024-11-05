--  Caso 1: Gesti�n de inventario y pedidos
--�	Lista el nombre de cada producto agrupado por categor�a. Ordena los resultados por precio de mayor a menor.
SELECT CATEGORIA
        ,NOMBRE
        ,PRECIO
FROM PRODUCTOS
ORDER BY CATEGORIA, PRECIO DESC;

--�	Calcula el promedio de ventas mensuales (en cantidad de productos) 

SELECT ROUND(AVG(TOTAL_VENTAS),1) AS PROMEDIO_VENTAS_MENSUALES 
FROM 
(SELECT EXTRACT(YEAR FROM FECHA) AS ANIO
       ,EXTRACT(MONTH FROM FECHA) AS MES
       ,SUM(CANTIDAD) AS TOTAL_VENTAS
FROM VENTAS
GROUP BY ANIO
       ,MES);
       
-- y muestra el mes y a�o con mayores ventas.

SELECT   'Mes y a�o con mayores ventas' AS INFO
        ,EXTRACT(YEAR FROM FECHA) AS ANIO
        ,EXTRACT(MONTH FROM FECHA) AS MES
        --,SUM(CANTIDAD) AS TOTAL_VENTAS
        , SUM (CANTIDAD*PRECIO) AS TOTAL_MONTO
FROM VENTAS 
JOIN PRODUCTOS ON PRODUCTOS.PRODUCTO_ID = VENTAS.PRODUCTO_ID
GROUP BY EXTRACT(YEAR FROM FECHA)
       ,EXTRACT(MONTH FROM FECHA)
 ORDER BY SUM (CANTIDAD*PRECIO) DESC
 FETCH FIRST ROW ONLY;
 
-- �	Encuentra el ID del cliente que ha gastado m�s dinero en compras durante el �ltimo a�o. Aseg�rate de considerar clientes que se registraron hace menos de un a�o.



SELECT  V.CLIENTE_ID
        , SUM (V.CANTIDAD*P.PRECIO) AS TOTAL_MONTO
        FROM VENTAS  V
JOIN PRODUCTOS P ON P.PRODUCTO_ID = V.PRODUCTO_ID
JOIN CLIENTES C ON C.CLIENTE_ID = V.CLIENTE_ID
WHERE c.fecha_registro + 365 > SYSDATE
GROUP BY V.CLIENTE_ID
ORDER BY TOTAL_MONTO DESC
 FETCH FIRST ROW ONLY;
 
--Caso 2: Gesti�n de Recursos Humanos
--�	Determina el salario promedio, el salario m�ximo y el salario m�nimo por departamento.

 SELECT DEPARTAMENTO 
        ,AVG(SALARIO) AS SALARIO_PROMEDIO
        ,MAX(SALARIO) AS SALARIO_MAXIMO
        ,MIN(SALARIO) AS SALARIO_MINIMO
FROM EMPLEADOS   
GROUP BY DEPARTAMENTO;

--�	Utilizando funciones de grupo, encuentra el salario m�s alto en cada departamento.

 SELECT DEPARTAMENTO 
          ,MAX(SALARIO) AS SALARIO_MAS_ALTO
      FROM EMPLEADOS   
GROUP BY DEPARTAMENTO;

--1.	Calcula la antig�edad en a�os de cada empleado y muestra aquellos con m�s de 10 a�os en la empresa.

SELECT  EMPLEADO_ID
        ,NOMBRE
        ,DEPARTAMENTO
        ,FECHA_CONTRATACION
        ,SALARIO
        ,TRUNC(MONTHS_BETWEEN(SYSDATE, FECHA_CONTRATACION) / 12) AS ANTIGUEDAD
FROM EMPLEADOS
WHERE TRUNC(MONTHS_BETWEEN(SYSDATE, FECHA_CONTRATACION) / 12) >10
        

 
   
    
