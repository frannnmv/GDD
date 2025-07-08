select
	prod_codigo,
	prod_detalle,
	depo_domicilio,
	(
		select count(stoc_deposito) from STOCK
		where stoc_producto = prod_codigo and stoc_cantidad > stoc_punto_reposicion
	)
from Producto
join STOCK on stoc_producto = prod_codigo
join DEPOSITO on depo_codigo = stoc_deposito
where (stoc_cantidad = 0 or stoc_cantidad is null) and prod_codigo in (select distinct stoc_producto from STOCK
																	   where stoc_deposito <> depo_codigo and stoc_cantidad > stoc_punto_reposicion)
order by prod_codigo
GO


CREATE TRIGGER parcial ON Item_Factura FOR insert
AS
BEGIN

	DECLARE @tipo char, @sucursal char(4), @numero char(8), @fecha smalldatetime
	DECLARE @producto char(8), @precio decimal(12,2)
	DECLARE c_facturas CURSOR FOR ( select fact_tipo, fact_sucursal, fact_numero from inserted i
									join Factura on fact_tipo+fact_sucursal+fact_numero = i.item_tipo+i.item_sucursal+i.item_numero)
	DECLARE c_items CURSOR FOR (select i.item_producto, i.item_precio, fact_fecha from inserted i
								join Factura on fact_tipo+fact_sucursal+fact_numero = i.item_tipo+i.item_sucursal+i.item_numero
								where i.item_tipo+i.item_sucursal+i.item_numero = @tipo+@sucursal+@numero)
	
	OPEN c_facturas
	FETCH NEXT FROM c_facturas INTO @tipo,@sucursal,@numero
	WHILE @@FETCH_STATUS = 0
		BEGIN
	
			OPEN c_items
			FETCH NEXT FROM c_items INTO @producto, @precio, @fecha
			WHILE @@FETCH_STATUS = 0
				BEGIN
					IF @precio > ( ( select item_precio from Factura
									join Item_Factura on fact_tipo+fact_sucursal+fact_numero = item_tipo+item_sucursal+item_numero
									where item_producto = @producto and DATEDIFF(MONTH, @fecha, fact_fecha) = 1
									) * 0.95) 
					   or @precio > ( ( select item_precio from Factura
										join Item_Factura on fact_tipo+fact_sucursal+fact_numero = item_tipo+item_sucursal+item_numero
										where item_producto = @producto and DATEDIFF(YEAR, @fecha, fact_fecha) = 1) * 1.5) 
							   BEGIN
									DELETE Item_Factura
									WHERE item_tipo = @tipo and item_sucursal = @sucursal and item_numero = @numero

									DELETE Factura
									WHERE fact_tipo = @tipo and fact_sucursal = @sucursal and fact_numero = @numero

									BREAK
							   END
					FETCH NEXT FROM c_items INTO @producto, @precio,  @fecha
				END
		CLOSE c_items
		DEALLOCATE c_items
		FETCH NEXT FROM c_facturas INTO @tipo,@sucursal,@numero
	END
	CLOSE c_facturas
	DEALLOCATE c_facturas
END
GO