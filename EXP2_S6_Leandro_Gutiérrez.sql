
--CASO 1
create table RECAUDACION_BONOS_MEDICOS  as 
SELECT  TO_CHAR(SUBSTR(LPAD(med.rut_med, 8, '0'), 1, 2)) || '.' ||
        TO_CHAR(SUBSTR(LPAD(med.rut_med, 8, '0'), 3, 3)) || '.' ||
        TO_CHAR(SUBSTR(LPAD(med.rut_med, 8, '0'), 6, 3)) || '-' ||
        med.dv_run AS RUT_MÉDICO
        ,UPPER(med.pnombre || ' ' || med.apaterno || ' ' || med.amaterno) as NOMBRE_MÉDICO
        ,LPAD('$' || TO_CHAR(SUM(bc.costo), 'FM999G999G999'),11,' ') AS TOTAL_RECAUDADO
        ,INITCAP(uc.nombre) as UNIDAD_MÉDICA
FROM MEDICO med
join unidad_consulta uc on uc.uni_id = med.uni_id
join bono_consulta bc on bc.rut_med = med.rut_med
where med.car_id != 100 and med.car_id != 500  and med.car_id != 600  and EXTRACT(YEAR FROM bc.fecha_bono)=EXTRACT(YEAR FROM SYSDATE)
GROUP BY RUT_MÉDICO
            ,NOMBRE_MÉDICO
            ,UNIDAD_MÉDICA
ORDER BY SUM(bc.costo)   ; 


--CASO 2
select upper(nombre) as especialidad_medica
        ,count(id_bono) as cantidad_bonos
        ,LPAD('$' || TO_CHAR(SUM(costo), 'FM999G999G999'),11,' ') AS monto_perdida
        ,min(fecha_bono) as fecha_bono
        ,estado_de_cobro
        from 
(select esp.nombre
        ,bc.id_bono
        ,bc.costo
        ,bc.fecha_bono
        ,case 
            when EXTRACT(YEAR FROM bc.fecha_bono)> EXTRACT(YEAR FROM SYSDATE)-2
                then 'COBRABLE'
            ELSE
                 'INCOBRABLE'    
            END  AS estado_de_cobro
        
from bono_consulta bc
join especialidad_medica esp on esp.esp_id = bc.esp_id

minus

select esp.nombre
        ,bc.id_bono
        ,bc.costo
        ,bc.fecha_bono
        ,case 
            when EXTRACT(YEAR FROM bc.fecha_bono)> EXTRACT(YEAR FROM SYSDATE)-2
                then 'COBRABLE'
            ELSE
                 'INCOBRABLE'    
            END  AS estado_de_cobro
        
from bono_consulta bc
join especialidad_medica esp on esp.esp_id = bc.esp_id
join pagos p on p.id_bono = bc.id_bono)
group by nombre, estado_de_cobro
ORDER BY  cantidad_bonos, SUM(costo) desc;


-- CASO  3
insert into cant_bonos_pacientes_annio
select EXTRACT(YEAR FROM SYSDATE) as annio_calculo
        ,p.pac_run
        ,p.dv_run
        --,p.fecha_nacimiento
        ,TRUNC(MONTHS_BETWEEN(SYSDATE, p.fecha_nacimiento) / 12) AS edad
        ,count(bc.id_bono) as cantidad_bonos
        ,sum(case when bc.costo is null  then 0 else bc.costo end) as monto_total_bonos
        ,upper(ss.descripcion) as sistema_salud
from paciente p
left join bono_consulta bc on EXTRACT(YEAR FROM bc.fecha_bono)= EXTRACT(YEAR FROM SYSDATE) and bc.pac_run = p.pac_run 
join salud s on s.sal_id = p.sal_id
join sistema_salud ss on ss.tipo_sal_id = s.tipo_sal_id
--where EXTRACT(YEAR FROM bc.fecha_bono)= EXTRACT(YEAR FROM SYSDATE)
having count(bc.id_bono) <= (select round(avg(cantidad_bono),0) from
(select bc.pac_run
    , count(bc.id_bono) as cantidad_bono
from bono_consulta bc 
where EXTRACT(YEAR FROM bc.fecha_bono)= EXTRACT(YEAR FROM SYSDATE)-1
group by bc.pac_run))
group by p.pac_run
        ,p.dv_run
       -- ,p.fecha_nacimiento
        ,edad
        ,ss.descripcion
order by cantidad_bonos, edad desc;


