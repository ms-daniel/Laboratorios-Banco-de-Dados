USE PROJETO_SAD

CREATE OR ALTER PROCEDURE SP_CHAMADOS(@DATA_INICIAL DATETIME, @DATA_FINAL DATETIME,@ID_CAMPUS INT, @QUANTIDADE_DEPARTAMENTOS INT, @MAXIMO_CHAMADOS_SEMANAIS INT) AS
BEGIN
	DECLARE @PROXIMO_DEPARTAMENTO INT, @QT_CHAMADOS INT, @DIAS_CORRIDOS INT

	SET @PROXIMO_DEPARTAMENTO = 1

	--FAR� AT� QUE AS DATAS INICIAIS E FINAIS COINCIDAM
	WHILE (@DATA_INICIAL <= @DATA_FINAL)
	BEGIN
		--ESSE WHILE GARANTE QUE TODOS OS DEPARTAMENTOS SER�O USADOS PARA CRIAR OS CHAMADOS
		WHILE(@PROXIMO_DEPARTAMENTO <= @QUANTIDADE_DEPARTAMENTOS)
		BEGIN
			SET @QT_CHAMADOS = (SELECT (ABS(CHECKSUM(NEWID())) % 60) + 1 AS INT_ALEATORIO_MEGA)
			
			PRINT @PROXIMO_DEPARTAMENTO

			SET @PROXIMO_DEPARTAMENTO = @PROXIMO_DEPARTAMENTO + 1 
		END

		SET @DATA_INICIAL = DATEADD(DD,1,@DATA_INICIAL)
	END
		
END

EXEC SP_CHAMADOS '01-02-2010 23:00', '15-03-2010 23:00', 1, 5, 10