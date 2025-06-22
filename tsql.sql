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

CREATE FUNCTION ejercicio1 (@articulo char(8), @deposito char(2))
RETURNS varchar(50)
AS
BEGIN
	DECLARE @stock decimal(12,2), @stock_limite decimal(12,2)
	(	
		select @stock = isnull(stoc_cantidad,0), @stock_limite = isnull(stoc_stock_maximo,0) from STOCK
		where stoc_producto = @articulo and stoc_deposito = @deposito
	)
	IF @stock >= @stock_limite or @stock_limite = 0
		RETURN PRINT('DEPOSITO COMPLETO')
	RETURN PRINT('OCUPACION DEL DEPOSITO '+ @deposito+': ' + (@stock/@stock_limite)*100+'%')
END
GO

select *, dbo.ejercicio1(stoc_producto, stoc_deposito)
from stock