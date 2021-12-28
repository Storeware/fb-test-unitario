delete from tests;

commit work;



set term ^;

execute block as
declare variable hoje Timestamp;
declare variable conta integer;
begin
 
 
   hoje = cast('now' as TIMESTAMP); 
   
   
   insert into tests values ('checa se table de eventos existe',SN(exists_table('eventos_item')),'Não criou a tabela de eventos');


   -- teste eventos
   if (exists_table('eventos_item')=1) then begin
   delete from eventos_item where tabela='SIG02' AND DATA >= 'TODAY' and dcto between '990' and '999';
     insert into sig02 (dcto,prtserie,ordem,banco,data,filial,codigo,valor) values ('999','TESTE',1,'00',:hoje,1,'010',.01);
     if (not exists (select * from EVENTOS_ITEM where data >='TODAY' and dcto='999') ) then
       insert into tests values('teste evento 010',  'N', 'nao gerou o evento - checar se existe a trigger');
   
     insert into sig02 (dcto,prtserie,ordem,banco,data,filial,codigo,valor) values ('998','TESTE',1,'00',:hoje,1,'112',.01);
     if (not exists (select * from EVENTOS_ITEM where data >= 'TODAY' and dcto='998') ) then
       INSERT into TESTS VALUES ('testa event 112','N','falhou evento SIG02 112, nao gerou evento de alteracao - checar se falta a trigger');
   end
   insert into tests values('checa se criou SIG02 notificacoes',SN(exists_trigger('TR_SIG02_NOTIFICACOES')),'falta criar notificacoes');


   -- checa se tem alguma coluna de PK que aceita NULL (alexandre)
   Select count(*)
    from
        (select tc.rdb$relation_name Nome_tabela, idx.RDB$FIELD_NAME Nome_coluna  
                from  RDB$RELATION_CONSTRAINTS tc  
                      join RDB$INDEX_SEGMENTS idx on (idx.RDB$INDEX_NAME = tc.RDB$INDEX_NAME)  
                where  tc.RDB$CONSTRAINT_TYPE = 'PRIMARY KEY') a  
   join (select rdb$relation_name nome_tabela, rdb$field_name nome_coluna, coalesce(rdb$null_flag,0) ehnulo 
                from RDB$RELATION_FIELDS 
                where rdb$system_flag = 0) b on (a.nome_tabela = b.nome_tabela and a.nome_coluna = b.nome_coluna)           
   where b.ehnulo = 0  
   into :conta;
   insert into tests values ('checa se alguma tabela tem coluna NULL para chave primaria',SN(case when :conta=0 then 1 else 0 end),'Achei coluna de chave primaria que aceita NULL, corrigir');


   -- checa compatibilidade com FB4
   select count(*)
      from rdb$relation_fields a   
               join   rdb$fields b on (a.rdb$field_source = b.rdb$field_name)   
      where a.rdb$field_name =  'LOCAL'  
   into :conta;   
   insert into tests values ('checa se alguma tabela tem coluna LOCAL (FB4)',SN(case when :conta=0 then 1 else 0 end),'Tabelas com coluna LOCAL não rodam no FB4, preparar conversao para nova versao do FB');


  -- checa se foi retirado o ID da sigcaut1
   
   if ((SELECT COUNT(*)  FROM get_primary_key('SIGCAUT1') WHERE FIELD_NAME = 'ID')>0) then
     insert into tests values('checa primary key sigcaut1','N','nao removeu o ID da chave primaria SIGCAU1 - ID NAO PODE SER USADO PARA EXLUIR INSERIR E EXCLUIR ITEM EM SEGUIDA');      

   -- checa se foi criado a view 
   insert into tests values('testa se existe view WEB_CLIENTES',SN(exists_view( 'WEB_CLIENTES')),'Falta criar a view');

   insert into tests values('checa se existe web_produtos',SN(exists_view('WEB_PRODUTOS')),'falta criar a view');  

   insert into tests values('checa se existe procure PROC_INFO_CAST',SN(exists_procedure('PROC_INFO_CAST')),'falta criar a procedure PROC_INFO_CAST');

   insert into tests values('checa role PUBLICWEB',SN(exists_role('PUBLICWEB')),'Role nao foi criada');

   insert into tests values('checa se criou PDVLOGIN notificacoes',SN(exists_trigger('TR_PDVLOGIN_NOTIFICACOES')),'falta criar notificacoes');
   insert into tests values('checa se criou SIGCAD notificacoes',SN(exists_trigger('TR_SIGCAD_NOTIFICACOES')),'falta criar notificacoes');
 
   insert into tests values('chace se carregou funcioes padroes',SN(exists_function('sright')),'Nao foi carregar a lista de funcoes nativas do firebird');
 
   insert into tests values('checa se existe indices FK_agenda_gid',SN(exists_indice('fk_pet_agenda_gid')),'Nao foi criado o FK_AGENDA_GID para a tabela AGENDA');
 
   insert into tests values('checa se criou columna nome_upper na sigcad',SN(exists_column('sigcad','nome_upper')), 'nao criou columna requerida para otimizacao de busca');
 
   insert into tests values('checa se tem  ctgrupo',SN(exists_table('ctgrupo')),'Nao encontrei a ctgrupo');

   insert into tests values('checa se tem primary key na ctgrupo',SN(exists_primary_key('ctgrupo')),'Nao encontrei primary key na ctgrupo');
   insert into tests values('checar procedure de atualização de cliente',SN(exists_procedure('WEB_ATUALIZAR_CLIENTE_BYCELULAR')),'Não achei a procedure WEB_ATUALIZAR_CLIENTE_BYCELULAR'); 
   insert into tests values('checar procedure usada no checkou',SN(exists_procedure('WEB_ATUALIZAR_VISUALIZADO')),'Não achei a procedure WEB_ATUALIZAR_VISUALIZADO'); 
 
end^
set term ;^

COMMIT;


set heading off;
SELECT (case when sucesso='N' then '(Falha)' else '(  OK  )' end) sts  ,titulo || ' -> ' || texto FROM TESTS where sucesso='N';


