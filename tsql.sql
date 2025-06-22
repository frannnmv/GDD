USE[GD2015C1]
GO
/* 
Ejercicio 1
	Hacer una funci�n que dado un art�culo y un deposito devuelva un string que 
	indique el estado del dep�sito seg�n el art�culo. Si la cantidad almacenada es 
	menor al l�mite retornar �OCUPACION DEL DEPOSITO XX %� siendo XX el 
	% de ocupaci�n. Si la cantidad almacenada es mayor o igual al l�mite retornar 
	�DEPOSITO COMPLETO�.
*/

ALTER FUNCTION ejercicio1 (@articulo char(8), @deposito char(2))
RETURNS varchar(50)
AS
BEGIN
	DECLARE @stock decimal(12,2), @stock_limite decimal(12,2)
	(	
		select @stock = isnull(stoc_cantidad,0), @stock_limite = isnull(stoc_stock_maximo,0) from STOCK
		where stoc_producto = @articulo and stoc_deposito = @deposito
	)
	IF @stock >= @stock_limite or @stock_limite = 0
	BEGIN
		RETURN 'DEPOSITO COMPLETO'
	END
	RETURN 'OCUPACION DEL DEPOSITO '+ @deposito+': ' + str((@stock/@stock_limite)*100)+'%'
END
GO

/*
2. Realizar una funci�n que dado un art�culo y una fecha, retorne el stock que 
exist�a a esa fecha
�*/

CREATE FUNCTION ejercicio2 (@articulo char(8), @fecha smalldatetime)
RETURNS decimal(12,2)
AS
BEGIN
	DECLARE @stock decimal(12,2), @ventas decimal(12,2)
	(
		SELECT @stock = sum(isnull(stoc_cantidad,0)) from STOCK
		where stoc_producto = @articulo
		group by stoc_producto
	)
	(
		SELECT @ventas = sum(item_cantidad) from Item_Factura 
		join Factura on fact_tipo+fact_sucursal+fact_numero = item_tipo+item_sucursal+item_numero
		where fact_fecha = @fecha and item_producto = @articulo
		group by item_producto
	)
	RETURN @stock - @ventas
END
GO