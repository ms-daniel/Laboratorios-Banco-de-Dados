-- Scripts para povoar o ambiente operacional

/*
   sp_povar_vendas

   A ideia desse procedimento é gerar vendas
   entre duas datas de maneira aleatória.

   A ideia geral é fazer um loop inicial entre a data inicial
   e data final passadas como parâmetro.

   Dentro desse loop, vamos fazer um outro loop com uma quantidade 
   de vendas aleatória para cada dia e incluir também vendas
   como valores aleatórios para tipo de pagamento, codigo da loja,
   codigo do produto, etc.

   Como o objetivo de deixar a coisa um pouco mais real, foram
   criados dois loops: Um para combustível e outro para lubrificantes uma
   vez que o volume vendido de combustível é bem diferente do volume
   vendido de lubrificante.

   Para conseguir gerar os números aleatórios,
   podemos utilizar as seguinte expressões em T-SQL:

   Para números decimais:
   SELECT RAND()*(b-a)+a;
   Onde b é o maior número
   e a é o menor número

   Para números inteiros:
   SELECT FLOOR(RAND()*(b-a+1))+a;
   Onde b é o maior número
   e a é o menor número

    Exemplos: 

	Gerar um valor decimal aleatório entre 10.0 e 100.0
	SELECT RAND()*(100-10)+10;

	Gerar um valor inteiro aleatório entre 1 e 7
	SELECT FLOOR(RAND()*(7-1+1))+1;

*/

use bd_rede_postos


create or alter function dbo.fn_aleatorio(@rand float, @maior_valor int, @menor_valor int =1)
returns int 
as
begin
    return (SELECT FLOOR(@rand*(@maior_valor-@menor_valor+1))+@menor_valor);
end


create or alter procedure sp_insert_venda_produto(@data datetime,
                                                  @categoria varchar(100))
as
begin
    set nocount on
    declare @cod_loja int,
	        @cod_funcionario int,
	        @cod_produto int,
			@cod_tipo_pagamento int,
			@volume numeric(10,2),
			@valor numeric(10,2),

			@MAX_LOJA int,
			@MAX_FUNCIONARIO int,
			@MAX_PRODUTO int,
			@MAX_TIPO_PAGAMENTO int,
			@MAX_VOLUME int
     
	 create table #tb_volume_max (categoria varchar(100), volume int)
	 insert into #tb_volume_max values('COMBUSTÍVEL',50)
	 insert into #tb_volume_max values ('LUBRIFICANTE', 5)

	 -- Gerar codigos para as lojas

	 create table #tb_loja (id int identity(1,1), cod_loja int)
	 insert into #tb_loja select cod_loja from tb_loja
	 set @MAX_LOJA = (select count(*) from #tb_loja)


	 set @cod_loja = (select cod_loja 
	                 from #tb_loja
					 where id = (select dbo.fn_aleatorio(rand(), @MAX_LOJA,1))
					 )
	 
	 -- Gerar codigos de funcionarios de acordo com a loja
	 create table #tb_funcionario (id int identity(1,1), cod_funcionario int)
	 insert into #tb_funcionario select cod_funcionario 
	                             from tb_loja_funcionario    
								 where cod_loja = @cod_loja

     set @MAX_FUNCIONARIO = (select count(*) from #tb_funcionario)

	 set @cod_funcionario = (select cod_funcionario
	                         from #tb_funcionario
					         where id = (select dbo.fn_aleatorio(rand(), @MAX_FUNCIONARIO,1))
					        )
	 
	 -- Gerar codigos para os produtos 
	 create table #tb_produto (id int identity(1,1), cod_produto int)
	 insert into #tb_produto select p.cod_produto from tb_produto p
	                         inner join tb_subcategoria s 
							 on (p.cod_subcategoria = s.cod_subcategoria)
							 inner join tb_categoria c
							 on (s.cod_categoria = c.cod_categoria)
							 where c.categoria = @categoria
     
	 set @MAX_PRODUTO = (select count(*) from #tb_produto)

	 set @cod_produto = (select cod_produto
	                     from #tb_produto
					     where id = (select dbo.fn_aleatorio(rand(), @MAX_PRODUTO,1))
					    )

	 -- Gerar códigos para o tipo de pagamento

	 create table #tb_tipo_pagamento (id int identity(1,1), cod_tipo_pagamento int)
	 insert into #tb_tipo_pagamento select cod_tipo_pagamento from tb_tipo_pagamento
	 set @MAX_TIPO_PAGAMENTO = (select count(*) from #tb_tipo_pagamento)


	 set @cod_tipo_pagamento = (select cod_tipo_pagamento 
	                 from #tb_tipo_pagamento
					 where id = (select dbo.fn_aleatorio(rand(), @MAX_TIPO_PAGAMENTO,1))
					 )
	 
	 -- Gerar o volume de acordo com o volume máximo de cada categoria.

	 set @MAX_VOLUME = (select volume from #tb_volume_max 
	                    where categoria = @categoria)


	 set @volume = (select dbo.fn_aleatorio(rand(), @MAX_VOLUME,1))


	 set @valor = @volume * (select valor from tb_produto 
	                         where cod_produto = @cod_produto)
	 insert into tb_venda
	 values(@cod_loja, @cod_funcionario, @cod_produto, @cod_tipo_pagamento,
	        @data, @volume, @valor)
end

create or alter procedure sp_povoar_vendas (@dt_inicial datetime, @dt_final datetime)
as
begin
    set nocount on
    declare @max_vendas_combustivel int = 3000, 
	        @min_vendas_combustivel int = 2000,
	        @max_vendas_lubrificante int = 200,
			@min_vendas_lubrificante int = 60,
			@total_vendas_dia_combustivel int,
			@total_vendas_dia_lubrificantes int,
			@contador_vendas int = 0,
			@semente float
			
    select @semente = rand(10)
	while (@dt_inicial < @dt_final)
	begin
	   
	   set @total_vendas_dia_combustivel = 
	               (select dbo.fn_aleatorio(rand(), @max_vendas_combustivel,@min_vendas_combustivel))
	   set @contador_vendas = 0
	   print 'total venda combustivel:' + str(@total_vendas_dia_combustivel)
	   while (@contador_vendas < @total_vendas_dia_combustivel)
	      begin
		     exec sp_insert_venda_produto @dt_inicial, 'COMBUSTÍVEL'
		     set @contador_vendas = @contador_vendas + 1
		  end


	   set @total_vendas_dia_lubrificantes = 
	                      (select dbo.fn_aleatorio(rand(), @max_vendas_lubrificante,@min_vendas_lubrificante))
	   set @contador_vendas = 0
	   print 'total venda lubrificante:' + str(@total_vendas_dia_lubrificantes)
	   while (@contador_vendas < @total_vendas_dia_lubrificantes)
	      begin
		     exec sp_insert_venda_produto @dt_inicial, 'LUBRIFICANTE'
		     set @contador_vendas = @contador_vendas + 1
		  end
	   
	   set @dt_inicial = @dt_inicial + 1
	end 
end


exec sp_povoar_vendas '20210101', '20210103'


select count(*) from tb_venda

truncate table tb_venda


