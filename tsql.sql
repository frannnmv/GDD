USE[GD2015C1]
GO
/* 
Ejercicio 1
	Hacer una función que dado un artículo y un deposito devuelva un string que 
	indique el estado del depósito según el artículo. Si la cantidad almacenada es 
	menor al límite retornar “OCUPACION DEL DEPOSITO XX %” siendo XX el 
	% de ocupación. Si la cantidad almacenada es mayor o igual al límite retornar 
	“DEPOSITO COMPLETO”.
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
2. Realizar una función que dado un artículo y una fecha, retorne el stock que 
existía a esa fecha
´*/

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
en caso que sea necesario. Se sabe que debería existir un único gerente general 
(debería ser el único empleado sin jefe). Si detecta que hay más de un empleado 
sin jefe deberá elegir entre ellos el gerente general, el cual será seleccionado por 
mayor salario. Si hay más de uno se seleccionara el de mayor antigüedad en la 
empresa.  Al finalizar la ejecución del objeto la tabla deberá cumplir con la regla 
de un único empleado sin jefe (el gerente general) y deberá retornar la cantidad 
de empleados que había sin jefe antes de la ejecución. 
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
