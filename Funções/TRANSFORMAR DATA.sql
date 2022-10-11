--Criar  uma  função  SF_TO_CHAR  para  transformar  uma  data  em  uma  cadeia 
--de  caracteres. 
--A função  deve  receber  como parâmetros  uma data  e uma máscara.

CREATE OR ALTER FUNCTION SF_TO_CHAR(@DATA DATETIME, @MASK VARCHAR(20))
RETURNS VARCHAR(20)
BEGIN
	SET @MASK = REPLACE(@MASK,'DD',DAY(@DATA))
	SET @MASK = REPLACE(@MASK,'MM',MONTH(@DATA))
	SET @MASK = REPLACE(@MASK,'YYYY',YEAR(@DATA))
	SET @MASK = REPLACE(@MASK,'HH', DATEPART(HH, @DATA))
	SET @MASK = REPLACE(@MASK,'MI', DATEPART(MI, @DATA))
	SET @MASK = REPLACE(@MASK,'SS', DATEPART(SS, @DATA))
	SET @MASK = REPLACE(@MASK,'Month',DATENAME(MONTH, @DATA))

	RETURN @MASK
END


select dbo.sf_TO_CHAR(GETDATE(),'DD de Month, YYYY.')
