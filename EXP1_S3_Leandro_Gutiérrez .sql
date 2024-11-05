--  Caso 1: Gestión de inventario y pedidos
--•	Lista el nombre de cada producto agrupado por categoría. Ordena los resultados por precio de mayor a menor.
SELECT CATEGORIA
        ,NOMBRE
        ,PRECIO
FROM PRODUCTOS
ORDER BY CATEGORIA, PRECIO DESC;

--•	Calcula el promedio de ventas mensuales (en cantidad de productos) 

SELECT ROUND(AVG(TOTAL_VENTAS),1) AS PROMEDIO_VENTAS_MENSUALES 
FROM 
(SELECT EXTRACT(YEAR FROM FECHA) AS ANIO
       ,EXTRACT(MONTH FROM FECHA) AS MES
       ,SUM(CANTIDAD) AS TOTAL_VENTAS
FROM VENTAS
GROUP BY ANIO
       ,MES);
       
-- y muestra el mes y año con mayores ventas.

SELECT   'Mes y año con mayores ventas' AS INFO
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
 
-- •	Encuentra el ID del cliente que ha gastado más dinero en compras durante el último año. Asegúrate de considerar clientes que se registraron hace menos de un año.



SELECT  V.CLIENTE_ID
        , SUM (V.CANTIDAD*P.PRECIO) AS TOTAL_MONTO
        FROM VENTAS  V
JOIN PRODUCTOS P ON P.PRODUCTO_ID = V.PRODUCTO_ID
JOIN CLIENTES C ON C.CLIENTE_ID = V.CLIENTE_ID
WHERE c.fecha_registro + 365 > SYSDATE
GROUP BY V.CLIENTE_ID
ORDER BY TOTAL_MONTO DESC
 FETCH FIRST ROW ONLY;
 
--Caso 2: Gestión de Recursos Humanos
--•	Determina el salario promedio, el salario máximo y el salario mínimo por departamento.

 SELECT DEPARTAMENTO 
        ,AVG(SALARIO) AS SALARIO_PROMEDIO
        ,MAX(SALARIO) AS SALARIO_MAXIMO
        ,MIN(SALARIO) AS SALARIO_MINIMO
FROM EMPLEADOS   
GROUP BY DEPARTAMENTO;

--•	Utilizando funciones de grupo, encuentra el salario más alto en cada departamento.

 SELECT DEPARTAMENTO 
          ,MAX(SALARIO) AS SALARIO_MAS_ALTO
      FROM EMPLEADOS   
GROUP BY DEPARTAMENTO;

--1.	Calcula la antigüedad en años de cada empleado y muestra aquellos con más de 10 años en la empresa.

SELECT  EMPLEADO_ID
        ,NOMBRE
        ,DEPARTAMENTO
        ,FECHA_CONTRATACION
        ,SALARIO
        ,TRUNC(MONTHS_BETWEEN(SYSDATE, FECHA_CONTRATACION) / 12) AS ANTIGUEDAD
FROM EMPLEADOS
WHERE TRUNC(MONTHS_BETWEEN(SYSDATE, FECHA_CONTRATACION) / 12) >10
        

 
   
    
