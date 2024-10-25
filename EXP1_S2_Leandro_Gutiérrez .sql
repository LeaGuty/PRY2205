--Desafío 1: Obtener la lista de clientes registrados en el �ltimo mes, mostrando su nombre completo y fecha de registro. Ordenar la lista por fecha de registro en orden descendente.

SELECT   nombre || ' ' || apellido AS nombre_completo
        , fecha_registro
FROM CUSTOMERS
WHERE EXTRACT(MONTH FROM fecha_registro) = EXTRACT(MONTH FROM SYSDATE)
ORDER BY fecha_registro DESC;

--Desafío 2: Calcular el incremento del 15% del precio de todos los productos cuyo nombre termine en A y que tengan m�s de 10 unidades en stock. Considera el resultado del incremento con 1 decimal. Ordenar el listado por el incremento de forma ascendente.

SELECT  product_id
        ,nombre_producto
        ,categoria
        ,stock
        ,precio
        , precio*1.15 AS aumentoprecio
FROM PRODUCTS
WHERE UPPER(nombre_producto) LIKE '%A'   AND stock > 10
ORDER BY aumentoprecio ASC;

--Desafío 3:
SELECT nombre || ' ' || apellido AS nombre_completo
        , email
        , SUBSTR(nombre, 1, 4) || LENGTH(email) || SUBSTR(apellido, -3) AS pass
FROM sales_staff
ORDER BY apellido DESC, nombre ASC ;






