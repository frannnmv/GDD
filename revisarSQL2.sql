USE[GD2015C1]
GO

-- Ejercicio 1
select clie_codigo, clie_razon_social
from Cliente
where clie_limite_credito >= 1000
order by clie_codigo

-- Ejercicio 2 
select prod_codigo, prod_detalle
from Producto
join Item_Factura on prod_codigo = item_producto
join Factura on fact_tipo+fact_sucursal+fact_numero = item_tipo+item_sucursal+item_numero
where year(fact_fecha) = 2012
group by prod_codigo, prod_detalle
order by sum(item_cantidad) desc

-- Ejercicio 3
select prod_codigo, prod_detalle, sum(stoc_producto)
from Producto
left join STOCK on prod_codigo = stoc_producto
group by prod_codigo, prod_detalle
order by prod_detalle

-- Ejercicio 4
select prod_codigo, prod_detalle, count(*)
from Producto
join Composicion on prod_codigo = comp_producto
group by prod_codigo, prod_detalle
having prod_codigo in (select stoc_producto from STOCK where stoc_producto = prod_codigo group by stoc_producto having avg(stoc_cantidad) > 100)

-- Ejecicio 5
select prod_codigo, prod_detalle, sum(isnull(item_cantidad,0))
from Producto
join Item_Factura on prod_codigo = item_producto
join Factura on fact_tipo+fact_sucursal+fact_numero = item_tipo+item_sucursal+item_numero
where year(fact_fecha) = 2012
group by prod_codigo, prod_detalle
having sum(item_cantidad) > (select sum(item_cantidad) from Item_Factura 
                             join Factura on fact_tipo+fact_sucursal+fact_numero = item_tipo+item_sucursal+item_numero
                             where year(fact_fecha) = 2011 and prod_codigo = item_producto
                             group by item_producto)

-- Ejercicio 6
select rubr_id, rubr_detalle, count(distinct prod_codigo), sum(isnull(stoc_cantidad,0))
from Rubro
left join Producto on rubr_id = prod_rubro and prod_codigo in (select stoc_producto from STOCK
                                                               group by stoc_producto 
                                                               having sum(isnull(stoc_cantidad,0)) > (select stoc_cantidad from STOCK where stoc_producto = '00000000' and stoc_deposito = '00'))
left join STOCK on prod_codigo = stoc_producto
group by rubr_id, rubr_detalle
order by rubr_id

-- Ejercicio 7
select prod_codigo, prod_detalle, max(item_precio) as precio_maximo, min(item_precio) as precio_minimo, ((max(item_precio) - min(item_precio))/min(item_precio)*100) as diferencia
from Producto
join Item_Factura on prod_codigo = item_producto
where prod_codigo in (select stoc_producto from STOCK group by stoc_producto having sum(isnull(stoc_cantidad,0)) > 0)
group by prod_codigo, prod_detalle

-- Ejercicio 8
select prod_detalle, max(stoc_cantidad)
from Producto
join STOCK on prod_codigo = stoc_producto
group by prod_detalle
having count(*) = (select count(*) from DEPOSITO)

-- Ejercicio 9
select empl_jefe, empl_codigo, RTRIM(empl_apellido)+', '+RTRIM(empl_nombre) as nombre, count(*)
from Empleado
join DEPOSITO on empl_codigo = depo_encargado or empl_jefe = depo_encargado
group by empl_jefe, empl_codigo, RTRIM(empl_apellido)+', '+RTRIM(empl_nombre)

-- Ejercicio 10
select prod_codigo, (select top 1 fact_cliente from Item_Factura 
                       join Factura on fact_tipo+fact_sucursal+fact_numero=item_tipo+item_sucursal+item_numero
                       where item_producto = prod_codigo
                       group by fact_cliente
                       order by sum(isnull(item_cantidad,0)))
from Producto
where prod_codigo in ((select top 10 item_producto from Item_Factura group by item_producto order by sum(isnull(item_cantidad,0)))) or
      prod_codigo in (select top 10 item_producto from Item_Factura group by item_producto order by sum(isnull(item_cantidad,0)) desc)
group by prod_codigo

-- Ejercicio 11
select fami_detalle, count(distinct prod_codigo) as productos_diferentes, sum(item_precio * item_cantidad)
from Familia
join Producto on prod_familia = fami_id
join Item_Factura on prod_codigo = item_producto
where fami_id in (select prod_familia from Producto 
                       join Item_Factura on prod_codigo = item_producto
                       join Factura on fact_tipo+fact_sucursal+fact_numero=item_tipo+item_sucursal+item_numero
                       where year(fact_fecha) = 2012
                       group by prod_familia
                       having sum(item_precio * item_cantidad) > 20000)
group by fami_detalle
order by productos_diferentes desc

-- Ejercicio 12
select prod_detalle, count(distinct fact_cliente) as clientes_distintos, avg(item_precio) as importe_promedio,
       (select count(*) from STOCK where prod_codigo = stoc_producto and stoc_deposito > 0 group by stoc_producto) as cantidad_depositos,
       (select sum(isnull(stoc_cantidad,0)) from STOCK where prod_codigo = stoc_producto group by stoc_producto) as stock_total
from Producto
join Item_Factura on prod_codigo = item_producto
join Factura on fact_tipo+fact_sucursal+fact_numero=item_tipo+item_sucursal+item_numero and year(fact_fecha) = 2012
group by prod_codigo, prod_detalle
order by sum(item_precio) desc

-- Ejercicio 13
select p.prod_detalle, p.prod_precio, sum(pc.prod_precio * comp_cantidad)
from Producto p
join Composicion on prod_codigo = comp_producto
join Producto pc on comp_componente = pc.prod_codigo
group by p.prod_detalle, p.prod_precio
having sum(comp_cantidad) >= 2
order by sum(comp_cantidad) desc

-- Ejercicio 14
select clie_codigo,
       count(fact_numero+fact_sucursal+fact_tipo) as cantidad_compras,
       avg(isnull(fact_total,0)),
       (select count(distinct item_producto) from Item_Factura join Factura ff on ff.fact_numero+ff.fact_sucursal+ff.fact_tipo=item_numero+item_sucursal+item_tipo 
            where clie_codigo = ff.fact_cliente and year(fact_fecha) = (select max(year(fact_fecha)) from Factura)),
       max(isnull(fact_total,0)) as mayor_compra
from Cliente 
left join Factura fc on fc.fact_cliente = clie_codigo and year(fc.fact_fecha) = (select max(year(fact_fecha)) from Factura)
group by clie_codigo, fc.fact_cliente
order by cantidad_compras desc

-- Ejercicio 15
select p1.prod_codigo, p1.prod_detalle, p2.prod_codigo, p2.prod_detalle
from Producto p1
join Item_Factura if1 on p1.prod_codigo = if1.item_producto
join Item_Factura if2 on if1.item_tipo+if1.item_sucursal+if1.item_numero = if2.item_tipo+if2.item_sucursal+if2.item_numero
join Producto p2 on if2.item_producto = p2.prod_codigo
where if1.item_cantidad + if2.item_cantidad > 500 and p1.prod_codigo < p2.prod_codigo
order by if1.item_cantidad + if2.item_cantidad desc 

-- Ejercicio 16
select clie_razon_social, 
       sum(item_cantidad),
       (
        select top 1 item_producto
        from Item_Factura 
        join Factura on fact_tipo+fact_sucursal+fact_numero = item_tipo+item_sucursal+item_numero
        where year(fact_fecha) = 2012 and clie_codigo = fact_cliente
        group by item_producto
        order by sum(item_cantidad) desc, item_producto asc
        )
from Cliente
join Factura on clie_codigo = fact_cliente
join Item_Factura on fact_tipo+fact_sucursal+fact_numero = item_tipo+item_sucursal+item_numero
where year(fact_fecha) = 2012
group by clie_codigo, clie_razon_social
having sum(item_cantidad) < (select top 1 avg(item_cantidad) / 3
                          from Item_Factura
                          join Factura on fact_tipo+fact_sucursal+fact_numero = item_tipo+item_sucursal+item_numero and year(fact_fecha) = 2012
                          where clie_codigo = fact_cliente
                          group by item_producto
                          order by sum(item_cantidad) desc)

-- Ejercicio 17
select ISNULL(FORMAT(f.fact_fecha, 'yyyyMM'),0),
       prod_codigo,
       prod_detalle,
       sum(isnull(item_cantidad,0)) as cantidad_vendida,
       ISNULL((
        select sum(isnull(item_cantidad,0)) from Item_Factura join Factura f2 on f2.fact_tipo+f2.fact_sucursal+f2.fact_numero = item_tipo+item_sucursal+item_numero
        where month(f2.fact_fecha) = month(f.fact_fecha) and year(f2.fact_fecha) = year(f.fact_fecha) - 1 and item_producto = prod_codigo
        group by item_producto
       ),0) as ventas_año_anterior,
       count(distinct fact_tipo+fact_numero+fact_sucursal) as cantidad_facturas
from Producto
join Item_Factura on prod_codigo = item_producto
join Factura f on f.fact_tipo+f.fact_sucursal+f.fact_numero = item_tipo+item_sucursal+item_numero
group by FORMAT(f.fact_fecha, 'yyyyMM'), year(f.fact_fecha), month(f.fact_fecha), prod_codigo, prod_detalle
order by FORMAT(f.fact_fecha, 'yyyyMM'), prod_codigo

-- Ejercicio 18
select rubr_detalle,
       sum(isnull(item_precio * item_cantidad,0)) as ventas,
       ISNULL((
        select top 1 item_producto from Producto join Item_Factura on prod_codigo = item_producto
        where prod_rubro = rubr_id
        group by item_producto
        order by sum(item_cantidad) desc
       ),0) as producto_mas_vendido,
       ISNULL((
        select top 1 item_producto from Producto join Item_Factura on prod_codigo = item_producto
        where prod_rubro = rubr_id and prod_codigo not in (select top 1 item_producto from Producto join Item_Factura on prod_codigo = item_producto
                                                           where prod_rubro = rubr_id
                                                           group by item_producto
                                                           order by sum(item_cantidad) desc)
        group by item_producto
        order by sum(item_cantidad) desc
       ),0) as segundo_producto_mas_vendido,
       ISNULL((
        select top 1 fact_cliente from Factura
        join Item_Factura on fact_tipo+fact_sucursal+fact_numero=item_tipo+item_sucursal+item_numero join Producto on prod_codigo = item_producto
        where prod_rubro = rubr_id and fact_fecha >= DATEADD(DAY,-30,GETDATE())
        group by fact_cliente
        order by sum(item_cantidad) desc        
       ),0)
from Rubro
left join Producto on prod_rubro = rubr_id
left join Item_Factura on prod_codigo = item_producto
group by rubr_id, rubr_detalle
order by count(distinct item_producto) desc

-- Ejercicio 21
select year(fact_fecha), count(distinct fact_cliente), count(distinct fact_tipo+fact_sucursal+fact_numero)
from Factura
where ABS((fact_total-fact_total_impuestos) - (select sum(item_precio * item_cantidad) from Item_Factura where fact_tipo+fact_sucursal+fact_numero = item_tipo+item_sucursal+item_numero)) > 1
group by year(fact_fecha)
having count(distinct fact_tipo+fact_sucursal+fact_numero) > 0

-- Ejercicio 25
select
    year(f.fact_fecha) AS ANIO,
    (
        select top 1 prod_familia from Producto 
        join Item_Factura on item_producto = prod_codigo
        join Factura f_fami on f_fami.fact_tipo+f_fami.fact_sucursal+f_fami.fact_numero = item_tipo+item_sucursal+item_numero
            and year(f_fami.fact_fecha) = year(f.fact_fecha) 
        group by prod_familia
        order by sum(item_cantidad) desc, prod_familia asc
    ) AS FAMILIA_MAS_VENDIO,
    (
        select count(distinct prod_rubro) from Producto
        where prod_familia in (select top 1 prod_familia from Producto 
                                             join Item_Factura on item_producto = prod_codigo
                                             join Factura f_fami on f_fami.fact_tipo+f_fami.fact_sucursal+f_fami.fact_numero = item_tipo+item_sucursal+item_numero
                                             and year(f_fami.fact_fecha) = year(f.fact_fecha) 
                                             group by prod_familia
                                             order by sum(item_cantidad) desc, prod_familia asc) 
    ) AS CANTIDAD_RUBROS,
    (
        select count(*) from Composicion 
        where comp_producto in (select top 1 prod_codigo from Producto
                                join Item_Factura on item_producto = prod_codigo
                                where prod_familia = (select top 1 prod_familia from Producto 
                                                      join Item_Factura on item_producto = prod_codigo
                                                      join Factura f_fami on f_fami.fact_tipo+f_fami.fact_sucursal+f_fami.fact_numero = item_tipo+item_sucursal+item_numero
                                                      and year(f_fami.fact_fecha) = year(f.fact_fecha) 
                                                      group by prod_familia
                                                      order by sum(item_cantidad) desc, prod_familia asc)
                                group by prod_codigo
                                order by sum(item_cantidad) desc) 
    ) AS CANTIDAD_COMPONENTES,
    count(distinct fact_tipo+fact_sucursal+fact_numero) AS DISTINTAS_FACTURAS,
    (
        select top 1 fact_cliente from Factura
        join Item_Factura on fact_tipo+fact_sucursal+fact_numero = item_tipo+item_sucursal+item_numero
        join Producto on prod_codigo = item_producto and prod_familia in (select top 1 prod_familia from Producto 
                                                                          join Item_Factura on item_producto = prod_codigo
                                                                          join Factura f_fami on f_fami.fact_tipo+f_fami.fact_sucursal+f_fami.fact_numero = item_tipo+item_sucursal+item_numero
                                                                          and year(f_fami.fact_fecha) = year(f.fact_fecha) 
                                                                          group by prod_familia
                                                                          order by sum(item_cantidad) desc, prod_familia asc)
        where year(fact_fecha) = year(f.fact_fecha)
        group by fact_cliente
        order by sum(item_cantidad) desc
    ) AS CLIENTE_QUE_MAS_COMPRO,
    (   
        select sum(item_cantidad * item_precio) from Factura
        join Item_Factura on fact_tipo+fact_sucursal+fact_numero = item_tipo+item_sucursal+item_numero
        join Producto on prod_codigo = item_producto and prod_familia in (select top 1 prod_familia from Producto 
                                                                          join Item_Factura on item_producto = prod_codigo
                                                                          join Factura f_fami on f_fami.fact_tipo+f_fami.fact_sucursal+f_fami.fact_numero = item_tipo+item_sucursal+item_numero
                                                                          and year(f_fami.fact_fecha) = year(f.fact_fecha)                                                                           
                                                                          group by prod_familia
                                                                          order by sum(item_cantidad) desc, prod_familia asc)
        where year(fact_fecha) = year(f.fact_fecha)
    )/sum(fact_total)*100 AS PORCENTAJE
from Factura f
join Item_Factura on f.fact_tipo+f.fact_sucursal+f.fact_numero = item_tipo+item_sucursal+item_numero
join Producto on prod_codigo = item_producto
where prod_familia in (select top 1 prod_familia from Producto 
                                             join Item_Factura on item_producto = prod_codigo
                                             join Factura f_fami on f_fami.fact_tipo+f_fami.fact_sucursal+f_fami.fact_numero = item_tipo+item_sucursal+item_numero
                                             and year(f_fami.fact_fecha) = year(f.fact_fecha) 
                                             group by prod_familia
                                             order by sum(item_cantidad) desc, prod_familia asc) 
group by year(f.fact_fecha)

-- Ejercicio 26

select
    f.fact_vendedor as EMPLEADO,
    (select count(*) from DEPOSITO where depo_encargado = f.fact_vendedor) AS CANTIDAD_DEPOSITOS,
    sum(fact_total) AS MONTO_TOTAL_FACTURADO_EN_EL_ANIO_CORRIENTE,
    (
        select top 1 fact_cliente from Factura
        where fact_vendedor = f.fact_vendedor
        group by fact_cliente
        order by sum(fact_total) desc
    ) AS CLIENTE_QUE_MAS_VENDIO,
    (
        select top 1 item_producto from Factura
        join Item_Factura on item_tipo+item_sucursal+item_numero = fact_tipo+fact_sucursal+fact_numero
        where fact_vendedor = f.fact_vendedor and year(fact_fecha) = (select max(year(fact_fecha)) from Factura)
        group by item_producto
        order by sum(item_cantidad) desc
    ) AS PRODUCTO_QUE_MAS_VENDIO,
    (
        sum(fact_total) / (select sum(fact_total) from Factura where year(fact_fecha) = (select max(year(fact_fecha)) from Factura)) * 100
    ) AS PORCENTAJE
from Factura f
join Empleado on empl_codigo = f.fact_vendedor
where year(f.fact_fecha) = (select max(year(fact_fecha)) from Factura)
group by f.fact_vendedor
order by MONTO_TOTAL_FACTURADO_EN_EL_ANIO_CORRIENTE desc

-- Ejercicio 28
select 
    year(f.fact_fecha) AS ANIO,
    f.fact_vendedor AS CODIGO_VENDEDOR,
    rtrim(empl_nombre)+', '+rtrim(empl_apellido) AS DETALLE_VENDEDOR,
    count(distinct f.fact_tipo+f.fact_sucursal+f.fact_numero) AS CANTIDAD_FACTURAS,
    count(distinct f.fact_cliente) AS CANTIDAD_CLIENTES,
    (
         select count(distinct item_producto) from Factura
         join Item_Factura on item_tipo+item_sucursal+item_numero = fact_tipo+fact_sucursal+fact_numero
         and year(fact_fecha) = year(f.fact_fecha) and fact_vendedor = f.fact_vendedor
         where item_producto in (select distinct comp_producto from Composicion)
    ) AS PRODUCTOS_CON_COMPOSICION,
    (
         select count(distinct item_producto) from Factura
         join Item_Factura on item_tipo+item_sucursal+item_numero = fact_tipo+fact_sucursal+fact_numero
         and year(fact_fecha) = year(f.fact_fecha) and fact_vendedor = f.fact_vendedor
         where item_producto not in (select distinct comp_producto from Composicion)    
    ) AS PRODUCTOS_SIN_COMPOSICION,
    sum(item_precio * item_cantidad) AS MONTO_TOTAL
from Factura f
join Empleado on empl_codigo = f.fact_vendedor
join Item_Factura on f.fact_tipo+f.fact_sucursal+f.fact_numero = item_tipo+item_sucursal+item_numero
group by year(f.fact_fecha), f.fact_vendedor, rtrim(empl_nombre)+', '+rtrim(empl_apellido)
order by year(f.fact_fecha), MONTO_TOTAL desc

-- Ejercicio 29
select 
    p.prod_codigo AS CODIGO,
    p.prod_detalle AS DETALLE,
    sum(item_cantidad) AS CANTIDAD_VENDIDA,
    count(distinct fact_tipo+fact_sucursal+fact_numero) AS CANTIDAD_FACTURAS,
    sum(item_precio * item_cantidad) AS MONTO_TOTAL
from Producto p
join Item_Factura on item_producto = p.prod_codigo
join Factura on fact_tipo+fact_sucursal+fact_numero = item_tipo+item_sucursal+item_numero
where year(fact_fecha) = 2011 and p.prod_familia in (select prod_familia from Producto 
                                                     group by prod_familia
                                                     having count(*) > 20 )
group by p.prod_codigo, p.prod_detalle
order by CANTIDAD_VENDIDA desc

-- Ejercicio 30
select
    rtrim(jefe.empl_apellido)+', '+rtrim(jefe.empl_nombre) AS NOMBRE_JEFE,
    count(distinct subordinado.empl_codigo) AS CANTIDAD_EMPLEADOS,
    sum(fact_total) AS MONTO_TOTAL,
    count(fact_tipo+fact_sucursal+fact_numero) AS CANTIDAD_FACTURAS,
    (
        select top 1 empl_codigo from Empleado
        join Factura on empl_codigo = fact_vendedor and year(fact_fecha) = 2012
        where empl_jefe = jefe.empl_codigo
        group by empl_codigo
        order by sum(fact_total) desc
    ) AS EMPLEADO_CON_MEJOR_VENTAS
from Empleado jefe
join Empleado subordinado on subordinado.empl_jefe = jefe.empl_codigo
join Factura on fact_vendedor = subordinado.empl_codigo
where year(fact_fecha) = 2012
group by jefe.empl_codigo, rtrim(jefe.empl_apellido)+', '+rtrim(jefe.empl_nombre)
having count(fact_tipo+fact_sucursal+fact_numero) > 10
order by MONTO_TOTAL desc