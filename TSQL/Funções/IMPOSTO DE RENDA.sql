--Criar uma função para calcular o IMPOSTO DE RENDA a ser pago em função de uma 
--determinada Renda. A função deve apresentar como parâmetro de entrada a Renda. O 
--retorno da função deve ser o imposto a ser pago. Considere as seguintes informações para 
--cálculo do imposto:
--Base  de  cálculo  mensal  em  R$ 	| Alícota %	| Parcela  a  deduzir  do  imposto  em  R$
--				Até  1.372,81				|		-		|						-
--		De  1.372,82  até  2.743,25		|	  15,0		|					205,92
--			Acima  de  2.743,25			|	  27,5		|					548,82

CREATE FUNCTION SP_CALC_IMPOS(@IMPOSTO NUMERIC(10,2))
RETURNS NUMERIC(10,2) AS
BEGIN
	DECLARE @TOTAL NUMERIC(10,2)
	SET @TOTAL = @IMPOSTO

	IF(@IMPOSTO >= 1372.82 AND @IMPOSTO <= 2743.25)
	BEGIN
		SET @TOTAL = @IMPOSTO*0.15 - 205.92
	END
	ELSE
	BEGIN
		IF(@IMPOSTO >= 2743.26)
		BEGIN
			SET @TOTAL = @IMPOSTO*0.275 - 548.82
		END
	END
	RETURN @TOTAL
END

DECLARE @NUM NUMERIC(10,2)
SET @NUM = 1500

EXEC @NUM = dbo.SP_CALC_IMPOS @NUM

PRINT @NUM