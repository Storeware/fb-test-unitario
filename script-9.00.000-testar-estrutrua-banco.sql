
delete from tests;
commit;

set term ^;
execute block  
as  
declare variable nome varchar(128);
begin  
  -- checa tabela de resultado de testes e cria se nao existir;
  if (exists_table('TESTS')=0) then
    execute STATEMENT'CREATE  GLOBAL TEMPORARY TABLE  tests (   titulo varchar(128), sucesso varchar(1), texto varchar(1024)) ON COMMIT PRESERVE ROWS';
  
  
for select distinct rdb$relation_name from RDB$RELATIONS a
where not rdb$relation_name like '%$%' and rdb$view_blr is null and rdb$relation_type=0
   and rdb$relation_name not in ('CADPF','CADSOCIO','FECHACX','CELULACX','CELULAFLU','RESVENDAS')
into :nome do
begin
 if (EXISTS_PRIMARY_KEY(:nome)=0) then
    insert into tests(titulo,sucesso,texto) values('Falta PK para '||trim(:nome),'N','A tabela '||trim(:nome)||' nao possui chave primaria');
 else   
    insert into tests(titulo,sucesso,texto) values('Falta PK para '||trim(:nome),'S','A tabela '||trim(:nome)||' tem chave primaria OK');


end   
   
 
 end^
 set term ;^

SET LIST ON;
SELECT count(*) qtd_tabelas, sum( case when sucesso='S' then 1 else 0 end) PrimaryKey_OK,
sum( case when sucesso='N' then 1 else 0 end) PrimaryKey_Nao_Tem
  FROM TESTS ;


--select titulo from tests where sucesso='N';
