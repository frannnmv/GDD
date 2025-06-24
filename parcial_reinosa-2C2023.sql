select 
	clie_razon_social,
	count(distinct item_producto) AS CANTIDAD_PRODUCTOS_DISTINTOS_COMPRADOS,
	(
		select sum(item_cantidad) from Factura 
		join Item_Factura on item_tipo+item_sucursal+item_numero = fact_tipo+fact_sucursal+fact_numero
		where fact_cliente = clie_codigo and year(fact_fecha) = 2012 and (month(fact_fecha) >= 1 and month(fact_fecha) <= 6)
	) AS CANTIDAD_PRODUCTOS_COMPRADOS_PRIMER_SEMESTRE_2012
from Cliente
join Factura on clie_codigo = fact_cliente
join Item_Factura on item_tipo+item_sucursal+item_numero = fact_tipo+fact_sucursal+fact_numero
where year(fact_fecha) = 2012 and clie_codigo in (select top 10 fact_cliente from Factura
												  where year(fact_fecha) = 2012
												  group by fact_cliente
												  having count(distinct fact_vendedor) > 3
												  order by count(fact_tipo+fact_sucursal+fact_numero) desc)
group by clie_codigo, clie_razon_social
order by count(fact_tipo+fact_sucursal+fact_numero) desc, clie_codigo
go

/*
REALIZAR UN STORED PROCEDURE QUE RECIBA UN CÓDIGO DE PRODUCTO Y UNA FECHA Y DEVUELVA LA MAYOR CATNIDAD DE DIAS CONSECUTIVOS
A PARTIR DE ESA FECHAQUE EL PRODUCTO TUVO AL MENOS LA VENTA DE UNA UNIDAD EN EL DIA, EL SISTEMA DE VENTAS ON LINE ESTA
HABILITADO 24/7
*/
CREATE PROCEDURE parcial @producto char(8), @fecha smalldatetime, @max_dias_consecutivos INT OUTPUT
AS
BEGIN
	DECLARE @dias_consecutivos INT = 0
	DECLARE @fecha_anterior smalldatetime
	DECLARE @fecha_actual smalldatetime
	DECLARE c_facturas CURSOR FOR (select fact_fecha from Factura 
								   join Item_Factura on fact_tipo+fact_sucursal+fact_numero = item_tipo+item_sucursal+item_numero
								   where fact_fecha >= @fecha and item_producto = @producto
								   group by fact_fecha
								   order by fact_fecha)
	SET @max_dias_consecutivos = 0
	OPEN c_facturas
	FETCH NEXT FROM c_facturas INTO @fecha_actual
	WHILE @@FETCH_STATUS = 0
		BEGIN
			IF @fecha_anterior IS NULL
				SET @dias_consecutivos = 1
			ELSE IF DATEDIFF(DAY,@fecha_anterior, @fecha_actual) = 1
				BEGIN
					SET @dias_consecutivos = @dias_consecutivos + 1
				END
			ELSE
				SET @dias_consecutivos = 1

			IF @dias_consecutivos > @max_dias_consecutivos
					SET @max_dias_consecutivos = @dias_consecutivos

			SET @fecha_anterior = @fecha_actual
			SET @fecha_actual = DATEADD(DAY,1,@fecha_actual)
			FETCH NEXT FROM c_facturas INTO @fecha_actual
		END
	CLOSE c_facturas
	DEALLOCATE c_facturas
END
GO