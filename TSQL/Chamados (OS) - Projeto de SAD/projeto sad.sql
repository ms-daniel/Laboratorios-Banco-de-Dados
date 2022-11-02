CREATE DATABASE PROJETO_SAD

USE PROJETO_SAD

CREATE TABLE TB_STATUS(
	ID_STATUS INT PRIMARY KEY NOT NULL,
	STATUS VARCHAR(30) CHECK (STATUS = 'Em Aberto' OR STATUS= 'Resolvido') NOT NULL
)

CREATE TABLE TB_CATEGORIA(
	ID_CATEGORIA INT PRIMARY KEY NOT NULL,
	CATEGORIA VARCHAR(30) NOT NULL
)

CREATE TABLE TB_ENDERECO(
	ID_ENDERECO INT PRIMARY KEY NOT NULL,
	UF VARCHAR(2) NOT NULL,
	CIDADE VARCHAR(30) NOT NULL,
	BAIRRO VARCHAR(30) NOT NULL,
	RUA VARCHAR(30) NOT NULL,
	NUMERO INT
)

CREATE TABLE TB_CAMPUS(
	ID_CAMPUS INT PRIMARY KEY NOT NULL,
	CNPJ VARCHAR(14) NOT NULL,
	NOME VARCHAR(60) NOT NULL,
	TELEFONE VARCHAR(20) NOT NULL,
	ID_ENDERECO INT FOREIGN KEY REFERENCES TB_ENDERECO(ID_ENDERECO),
	ID_DIRETOR INT FOREIGN KEY REFERENCES TB_FUNCIONARIO(ID_FUNCIONARIO)
)

CREATE TABLE TB_FUNCIONARIO(
	ID_FUNCIONARIO INT PRIMARY KEY NOT NULL,
	MATRICULA INT NOT NULL,
	NOME VARCHAR(80) NOT NULL,
	EMAIL VARCHAR(50),
	TELEFONE VARCHAR(20),
	DATA_INICIO_CONTRATO DATETIME DEFAULT GETDATE() NOT NULL ,
	DATA_FIM_CONTRATO DATETIME,
	ID_DEPARTAMENTO INT FOREIGN KEY REFERENCES TB_DEPARTAMENTO(ID_DEPARTAMENTO) NOT NULL,
	ID_ORGAO_RESPONSAVEL INT FOREIGN KEY REFERENCES TB_ORGAO_RESPONSAVEL(ID_ORGAO_RESPONSAVEL)
)

CREATE TABLE TB_DEPARTAMENTO(
	ID_DEPARTAMENTO INT PRIMARY KEY NOT NULL,
	COD_DEPARTAMENTO INT NOT NULL,
	NOME VARCHAR(40) NOT NULL,
	SIGLA VARCHAR(6) NOT NULL,
	DESCRICAO VARCHAR(45),
	ID_DIRETOR INT FOREIGN KEY REFERENCES TB_FUNCIONARIO(ID_FUNCIONARIO),
	ID_CAMPUS INT FOREIGN KEY REFERENCES TB_CAMPUS(ID_CAMPUS)
)