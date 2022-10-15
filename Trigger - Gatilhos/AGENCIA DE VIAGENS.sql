create database bd_avaliacaoII_bdII

use bd_avaliacaoII_bdII

--Uma agência de viagens possui como principal modelo de negócio a venda de pacotes de 
--viagens. Cada pacote possui um determinado destino (cidade, praia, etc.), o número de dias , 
--um período de validade (composto por uma data inicial e uma data final) e as datas de saída. 
--Os clientes da agência de viagens, quando estão interessados em viajar para determinado 
--destino, preenchem um cadastro e informam quais os destinos de seu interesse. Quando 
--surge um novo pacote, a agência fica responsável por entrar em contato com os clientes 
--para oferecer os pacotes que estão de acordo com o interesse previamente cadastrado
--
--1. Criar uma trigger para preencher automaticamente as datas de saída de um pacote na 
--tabela TB_PACOTE_SAIDA de acordo com as datas inicial e final do pacote. A tabela 
--TB_PACOTE_SAIDA deve ser atualizada todas as vezes que um pacote for incluído ou 
--modificado (mudança no número de dias e/ou datas). Após a inclusão ou alteração de 
--um pacote, as saídas devem ser cadastradas ou atualizadas de acordo com o seguinte 
--procedimento:
--a)     As  datas  de  saída  devem  estar  compreendidas  entre  a  data  inicial  e  a  data  final  do 
--pacote.
--b) Deve existir um intervalo de 2 dias entre a chegada de um grupo e a saída de outro. 
--A data de chegada de um grupo é determinada pela data de saída e número de dias 
--do pacote. Exemplo: Se um pacote de 5 dias tem uma data de saída como 
--01/07/2022, a próxima data de saída deve ser 08/07/2022, desde que essa data esteja 
--dentro do intervalo do pacote.
--
--2. Criar uma trigger para registrar na tabela TB_OFERECE_PACOTE_CLIENTE as 
--ofertas que devem ser feitas aos clientes. Para os clientes que possuem interesse 
--cadastrado, deve ser criada apenas uma linha para cada pacote desde que a seguinte 
--condição seja satisfeita: O Pacote é para um destino cadastrado como interesse do 
--cliente; Serão oferecidos todos os pacotes aos clientes que não possuem interesse 
--cadastrado

DROP TABLE IF EXISTS TB_OFERECE_PACOTE_CLIENTE
DROP TABLE IF EXISTS TB_PACOTE_SAIDA
DROP TABLE IF EXISTS TB_PACOTE
DROP TABLE IF EXISTS TB_INTERESSE_CLIENTE
DROP TABLE IF EXISTS TB_DESTINO
DROP TABLE IF EXISTS TB_CLIENTE


CREATE TABLE TB_DESTINO (
   COD_DESTINO		INT NOT NULL PRIMARY KEY,
   DESCRICAO		VARCHAR(100) NOT NULL,
   ESTADO			CHAR(2) NOT NULL
)

INSERT INTO TB_DESTINO (COD_DESTINO, DESCRICAO, ESTADO)
VALUES (1, 'BARRA DE SÃO MIGUEL', 'AL')

INSERT INTO TB_DESTINO (COD_DESTINO, DESCRICAO, ESTADO)
VALUES (2, 'PORTO DE GALINHAS','PE')

INSERT INTO TB_DESTINO (COD_DESTINO, DESCRICAO, ESTADO)
VALUES (3, 'PORTO SEGURO','BA')

INSERT INTO TB_DESTINO (COD_DESTINO, DESCRICAO, ESTADO)
VALUES (4, 'SALVADOR','BA')

CREATE TABLE TB_CLIENTE (
   COD_CLIENTE		INT NOT NULL PRIMARY KEY,
   NM_CLIENTE		VARCHAR(50) NOT NULL,
   CPF				VARCHAR(13) NOT NULL,
   TELEFONE_CELULAR VARCHAR(20) NOT NULL,
   EMAIL			VARCHAR(100) NOT NULL
)

INSERT INTO TB_CLIENTE
VALUES(1, 'JOAO', '1111111111111','8804-1771','joao@gmail.com')

INSERT INTO TB_CLIENTE
VALUES(2, 'CARLOS', '2222222222222','8804-1772','carlos@gmail.com')

INSERT INTO TB_CLIENTE
VALUES(3, 'ROBERTA', '4444444444444','8804-1773','roberta@gmail.com')

INSERT INTO TB_CLIENTE
VALUES(4, 'PATRICIA', '5555555555555','8804-1774','patricia@gmail.com')

CREATE TABLE TB_INTERESSE_CLIENTE (
   ID_INTERESSE_CLIENTE INT NOT NULL PRIMARY KEY IDENTITY(1,1),
   COD_DESTINO			INT NOT NULL REFERENCES TB_DESTINO,
   COD_CLIENTE			INT NOT NULL REFERENCES TB_CLIENTE,
   UNIQUE (COD_DESTINO, COD_CLIENTE)
)


INSERT INTO TB_INTERESSE_CLIENTE
VALUES(1,1)

INSERT INTO TB_INTERESSE_CLIENTE
VALUES(2,2)

INSERT INTO TB_INTERESSE_CLIENTE
VALUES(3,2)

CREATE TABLE TB_PACOTE (
    COD_PACOTE		INT NOT NULL PRIMARY KEY IDENTITY(1,1),
    DESCRICAO		VARCHAR(200) NOT NULL,
    COD_DESTINO		INT NOT NULL REFERENCES TB_DESTINO,
    NR_DIAS		    INT NOT NULL CHECK (NR_DIAS > 1),
    DATA_INICIAL    DATETIME NOT NULL,
    DATA_FINAL      DATETIME NOT NULL
)     

CREATE TABLE TB_PACOTE_SAIDA (
    ID_PACOTE_SAIDA INT NOT NULL PRIMARY KEY IDENTITY(1,1),
    COD_PACOTE		INT NOT NULL REFERENCES TB_PACOTE,
    DATA_SAIDA		DATETIME NOT NULL,
    UNIQUE (COD_PACOTE, DATA_SAIDA)
)    
    
CREATE TABLE TB_OFERECE_PACOTE_CLIENTE (
    ID_OFERECE	INT NOT NULL PRIMARY KEY IDENTITY(1,1),
    COD_CLIENTE INT NOT NULL REFERENCES TB_CLIENTE,
    COD_PACOTE	INT NOT NULL REFERENCES TB_PACOTE,
    OFERECIDO	CHAR(3) DEFAULT('NAO') CHECK (OFERECIDO IN ('SIM','NAO')),
	UNIQUE (COD_CLIENTE, COD_PACOTE)
)

--1 QUESTÃO OK
CREATE OR ALTER TRIGGER TG_PACOTE_SAIDA_INSERT
ON TB_PACOTE
AFTER INSERT, UPDATE
AS
BEGIN
	DECLARE @DATA_I DATETIME, @COD_PAC INT,
			@DATA_F DATETIME, @NR_DIAS INT

	--INSERIR NA TABELA DE SAIDA
	DECLARE C_PACOTE CURSOR FOR SELECT COD_PACOTE, NR_DIAS, DATA_INICIAL, DATA_FINAL FROM INSERTED
	
	OPEN C_PACOTE
	FETCH C_PACOTE INTO @COD_PAC, @NR_DIAS, @DATA_I, @DATA_F

	WHILE(@@FETCH_STATUS = 0)
	BEGIN
		--APAGA TODAS AS SAÍDAS CASO SEJA UM UPDATE
		--LEMBRANDO QUE EU OPTEI EM JUNTAR AS DUAS TRIGGER 
		--QUE FIZ PARA A PRIMEIRA QUESTÃO
		DELETE TB_PACOTE_SAIDA WHERE COD_PACOTE = @COD_PAC
		
		WHILE(@DATA_I <= @DATA_F)
		BEGIN
			INSERT INTO TB_PACOTE_SAIDA VALUES(@COD_PAC, @DATA_I)
			SET @DATA_I = DATEADD(DD, @NR_DIAS+2, @DATA_I)
		END
		FETCH C_PACOTE INTO @COD_PAC, @NR_DIAS, @DATA_I, @DATA_F
	END
	CLOSE C_PACOTE
	DEALLOCATE C_PACOTE
END
------------------------------------------------------------------------------------------------
--2 QUESTÃO OK
CREATE OR ALTER TRIGGER TG_OFERECER_PACOTE
ON TB_PACOTE
AFTER INSERT--, UPDATE
AS
	--CASO SEJA NECESSÁRIO APAGAR OS REGISTROS DA TABELA "TB_OFERECER_CLIENTE" ANTES DE INSERIR
	--DELETE TB_OFERECE_PACOTE_CLIENTE WHERE COD_PACOTE IN (SELECT COD_PACOTE FROM INSERTED)
	INSERT INTO TB_OFERECE_PACOTE_CLIENTE (COD_CLIENTE, COD_PACOTE)
	SELECT IC.COD_CLIENTE, P.COD_PACOTE
	FROM TB_INTERESSE_CLIENTE IC JOIN INSERTED P
	ON (IC.COD_DESTINO = P.COD_DESTINO)

	UNION ALL

	SELECT C.COD_CLIENTE, P.COD_PACOTE
	FROM INSERTED P, TB_CLIENTE C
	WHERE C.COD_CLIENTE NOT IN (SELECT COD_CLIENTE FROM TB_INTERESSE_CLIENTE)
------------------------------------------------------------------------------------------------
SELECT * FROM TB_PACOTE_SAIDA
SELECT * FROM TB_INTERESSE_CLIENTE
SELECT * FROM TB_OFERECE_PACOTE_CLIENTE
SELECT * FROM TB_PACOTE

UPDATE TB_PACOTE
SET DATA_FINAL = '20220720'
WHERE COD_PACOTE = 1

-- Testes (Lembrar que poderia ser um único insert)

INSERT INTO TB_PACOTE
VALUES('PACOTE BARRA DE SAO MIGUEL',1,4,'20220704', '20220730')

INSERT INTO TB_PACOTE
VALUES('PACOTE PORTO DE GALINHAS',2,5,'20220704', '20220715')

INSERT INTO TB_PACOTE
VALUES('PACOTE SALVADOR',4,5,'20221104', '20221115')

-- Resultado após inclusão dos Pacotes

SELECT * FROM TB_PACOTE
SELECT * FROM TB_PACOTE_SAIDA
SELECT * FROM TB_OFERECE_PACOTE_CLIENTE

/*
COD_PACOTE  DESCRICAO								COD_DESTINO NR_DIAS     DATA_INICIAL            DATA_FINAL
----------- --------------------------------------	----------- ----------- ----------------------- -----------------------
1           PACOTE BARRA DE SAO MIGUEL				1           4           2022-07-04 00:00:00.000 2022-07-30 00:00:00.000
2           PACOTE PORTO DE GALINHAS				2           5           2022-07-04 00:00:00.000 2022-07-15 00:00:00.000
3           PACOTE SALVADOR							4           5           2022-11-04 00:00:00.000 2022-11-15 00:00:00.000

(3 rows affected)

ID_PACOTE_SAIDA COD_PACOTE  DATA_SAIDA
--------------- ----------- -----------------------
1               1           2022-07-04 00:00:00.000
2               1           2022-07-10 00:00:00.000
3               1           2022-07-16 00:00:00.000
4               1           2022-07-22 00:00:00.000
5               1           2022-07-28 00:00:00.000
6               2           2022-07-04 00:00:00.000
7               2           2022-07-11 00:00:00.000
8               3           2022-11-04 00:00:00.000
9               3           2022-11-11 00:00:00.000

(9 rows affected)

ID_OFERECE  COD_CLIENTE COD_PACOTE  OFERECIDO
----------- ----------- ----------- ---------
1           1           1           NAO
2           3           1           NAO
3           4           1           NAO
4           2           2           NAO
5           3           2           NAO
6           4           2           NAO
7           3           3           NAO
8           4           3           NAO

(8 rows affected)

-- Teste de Atualização

UPDATE TB_PACOTE
SET DATA_FINAL = '20220720'
WHERE COD_PACOTE = 1

-- Resultado após atualização

SELECT * FROM TB_PACOTE
SELECT * FROM TB_PACOTE_SAIDA
SELECT * FROM TB_OFERECE_PACOTE_CLIENTE

COD_PACOTE  DESCRICAO                                                                                                                                                                                                COD_DESTINO NR_DIAS     DATA_INICIAL            DATA_FINAL
----------- -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- ----------- ----------- ----------------------- -----------------------
1           PACOTE BARRA DE SAO MIGUEL                                                                                                                                                                               1           4           2022-07-04 00:00:00.000 2022-07-20 00:00:00.000
2           PACOTE PORTO DE GALINHAS                                                                                                                                                                                 2           5           2022-07-04 00:00:00.000 2022-07-15 00:00:00.000
3           PACOTE SALVADOR                                                                                                                                                                                          4           5           2022-11-04 00:00:00.000 2022-11-15 00:00:00.000

(3 rows affected)

ID_PACOTE_SAIDA COD_PACOTE  DATA_SAIDA
--------------- ----------- -----------------------
10              1           2022-07-04 00:00:00.000
11              1           2022-07-10 00:00:00.000
12              1           2022-07-16 00:00:00.000
6               2           2022-07-04 00:00:00.000
7               2           2022-07-11 00:00:00.000
8               3           2022-11-04 00:00:00.000
9               3           2022-11-11 00:00:00.000

(7 rows affected)

ID_OFERECE  COD_CLIENTE COD_PACOTE  OFERECIDO
----------- ----------- ----------- ---------
1           1           1           NAO
2           3           1           NAO
3           4           1           NAO
4           2           2           NAO
5           3           2           NAO
6           4           2           NAO
7           3           3           NAO
8           4           3           NAO

(8 rows affected)



*/