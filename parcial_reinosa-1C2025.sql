select 
	rtrim(empl_apellido)+', '+rtrim(empl_nombre) AS NOMBRE_VENDEDOR,
	sum(item_cantidad) AS UNIDADES_VENDIDAS,
	sum(item_precio * item_cantidad)/count(distinct fact_tipo+fact_sucursal+fact_numero) AS MONTO_PROMEDIO_POR_FACTURA,
	sum(item_precio * item_cantidad) AS MONTO_TOTAL_VENTAS
from Empleado
join Factura on fact_vendedor = empl_codigo
join Item_Factura on fact_tipo+fact_sucursal+fact_numero = item_tipo+item_sucursal+item_numero
where empl_codigo in (select top 5 fact_vendedor from Factura
					  where year(fact_fecha) = (select max(year(fact_fecha)) from Factura)
					  group by fact_vendedor
					  order by count(fact_cliente), (select sum(item_precio * item_cantidad)
													 from Factura f
													 join Item_Factura on f.fact_tipo+f.fact_sucursal+f.fact_numero = item_tipo+item_sucursal+item_numero
													 where year(f.fact_fecha) = (select max(year(fact_fecha)) from Factura)
														and f.fact_vendedor = fact_vendedor
														and fact_tipo+fact_sucursal+fact_numero in (select item_tipo+item_sucursal+item_numero 
																								    from Item_Factura
																									group by item_tipo, item_sucursal, item_numero
																									having count(*) > 2)) desc )
and year(fact_fecha) = (select max(year(fact_fecha)) from Factura)
and fact_tipo+fact_sucursal+fact_numero in (select item_tipo+item_sucursal+item_numero
										    from Item_Factura
											group by item_tipo, item_sucursal, item_numero
											having count(*) > 2)
group by rtrim(empl_apellido)+', '+rtrim(empl_nombre), empl_codigo
order by count(distinct fact_tipo+fact_sucursal+fact_numero) desc, empl_codigo