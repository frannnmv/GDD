select
	prod_detalle,
	CASE
		WHEN (select count(distinct item_tipo+item_sucursal+item_numero) from Item_Factura 
			  join Factura on item_tipo+item_sucursal+item_numero = fact_tipo+fact_sucursal+fact_numero
			  where year(fact_fecha) = 2012 and item_producto = prod_codigo) > 100
		THEN 'POPULAR' 
		ELSE 'SIN INTERES' 
	END AS LEYENDA,
	count(distinct fact_tipo+fact_sucursal+fact_numero) AS CANTIDAD_FACTURAS_2012,
	(
		select top 1 fact_cliente from Factura
		join Item_Factura on item_tipo+item_sucursal+item_numero = fact_tipo+fact_sucursal+fact_numero
		where year(fact_fecha) = 2012 and item_producto = prod_codigo
		group by fact_cliente
		order by sum(item_cantidad) desc, fact_cliente asc
	) AS CLIENTE_MAS_COMPRO
from Producto
join Item_Factura on item_producto = prod_codigo
join Factura on item_tipo+item_sucursal+item_numero = fact_tipo+fact_sucursal+fact_numero
where year(fact_fecha) = 2012
group by prod_detalle, prod_codigo
having sum(item_precio*item_cantidad) > (( (select sum(item_precio * item_cantidad) from Item_Factura 
									     join Factura on item_tipo+item_sucursal+item_numero = fact_tipo+fact_sucursal+fact_numero
										 where year(fact_fecha) = 2010 and item_producto = prod_codigo
										 group by item_producto)
										 +
										 (select sum(item_precio * item_cantidad) from Item_Factura 
									     join Factura on item_tipo+item_sucursal+item_numero = fact_tipo+fact_sucursal+fact_numero
										 where year(fact_fecha) = 2011 and item_producto = prod_codigo
										 group by item_producto)
										 )/2)* 0.15
