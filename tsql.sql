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

/*
3. Cree el/los objetos de base de datos necesarios para corregir la tabla empleado 
en caso que sea necesario. Se sabe que deber�a existir un �nico gerente general 
(deber�a ser el �nico empleado sin jefe). Si detecta que hay m�s de un empleado 
sin jefe deber� elegir entre ellos el gerente general, el cual ser� seleccionado por 
mayor salario. Si hay m�s de uno se seleccionara el de mayor antig�edad en la 
empresa.  Al finalizar la ejecuci�n del objeto la tabla deber� cumplir con la regla 
de un �nico empleado sin jefe (el gerente general) y deber� retornar la cantidad 
de empleados que hab�a sin jefe antes de la ejecuci�n. 
*/

CREATE PROCEDURE ejercicio3 @cantidad int output
AS
BEGIN
	DECLARE @gerente_general numeric(6,0)
	SELECT @cantidad = count(*) from Empleado where empl_jefe is null
	SELECT top 1 @gerente_general = empl_codigo from Empleado where empl_jefe is null order by empl_salario desc, empl_ingreso
	UPDATE Empleado set empl_jefe = @gerente_general where empl_jefe is null and empl_jefe <> @gerente_general
END
GO

-- Ejercicio 4
CREATE PROCEDURE ejercicio4 @empleado_mas_vendio numeric(6,0) output
AS
BEGIN
	DECLARE @empleado numeric(6,0), @monto decimal(12,2), @monto_max decimal(12,2) = -1
	DECLARE c1 CURSOR FOR (select empl_codigo from Empleado)
	OPEN c1
	FETCH NEXT FROM c1 INTO @empleado
	WHILE @@FETCH_STATUS = 0
	BEGIN
		select @monto = sum(isnull(fact_total,0)) from Factura
		where year(fact_fecha) = (select max(year(fact_fecha)) from Factura) and fact_vendedor = @empleado
		group by fact_vendedor

		UPDATE Empleado set empl_comision = @monto where empl_codigo = @empleado
		IF @monto_max = -1 or @monto > @monto_max
		BEGIN
			SET @empleado_mas_vendio = @empleado
			SET @monto_max = @monto
		END
		FETCH NEXT FROM c1 INTO @empleado
	END
	CLOSE c1
	DEALLOCATE c1 
END
GO

-- Ejercicio 10
CREATE TRIGGER ejercicio10 ON Producto AFTER delete
AS
BEGIN
	IF (select count(*) from deleted join STOCK on deleted.prod_codigo = stoc_producto where stoc_cantidad > 0) > 0
	BEGIN
		ROLLBACK
		PRINT 'NO SE PUEDEN ELIMINAR PRODUCTOS CON STOCK!'
	END
END
GO
