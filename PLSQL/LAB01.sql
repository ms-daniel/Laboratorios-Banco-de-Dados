CREATE TABLE TB_FORNECEDOR(
    CD_FORNECEDOR NUMBER(3) NOT NULL PRIMARY KEY,
    NM_FORNECEDOR VARCHAR2(40) NOT NULL,
    NM_CONTATO VARCHAR2(40) NOT NULL,
    DT_CADASTRO DATE DEFAULT (SYSDATE)
)

CREATE SEQUENCE SQ_FORNECEDAOR
START WITH 1
INCREMENT BY 1

INSERT INTO TB_FORNECEDOR(CD_FORNECEDOR, NM_FORNECEDOR, NM_CONTATO)
       VALUES(SQ_FORNECEDAOR.NEXTVAL, 'Jo�o Caros', '9454555')