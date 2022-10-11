--Criar uma função SF_DataCompleta para imprimir datas no seguinte formato: 12 de Maio 
--de 2002. A função deve receber como parâmetro uma data e apresentar como retorno uma 
--cadeia de caracteres. Observação: A indicação do idioma pode ser realizada antes da 
--chamada da função.

CREATE OR ALTER FUNCTION SF_DATACOMPLETA(@DATA DATE)
RETURNS VARCHAR(40) AS
BEGIN
	DECLARE @DIA INT, @MES VARCHAR(20), @ANO INT, @TOTAL_DATA VARCHAR(40)
	SET @DIA = DAY(@DATA)
	SET @MES = DATENAME(MONTH, @DATA)
	SET @ANO = YEAR(@DATA)

	SET @TOTAL_DATA = CONCAT(TRIM(STR(@DIA)), ' de ', @MES, ' de ', TRIM(STR(@ANO)))
	
	RETURN @TOTAL_DATA
END

DECLARE @DAT DATE, @RESUL VARCHAR(40)
SET @DAT = '20191012'

EXEC @RESUL = dbo.SF_DATACOMPLETA @DAT

PRINT @RESUL


