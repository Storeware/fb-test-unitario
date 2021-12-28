commit work;
set term ^;


create or alter procedure get_primary_key( name varchar(128))
 returns (field_name varchar(128) )
as
begin
  for select sg.rdb$field_name from rdb$indices ix
        left join rdb$index_segments sg on ix.rdb$index_name = sg.rdb$index_name
        left join rdb$relation_constraints rc on rc.rdb$index_name = ix.rdb$index_name
        where rc.rdb$constraint_type = 'PRIMARY KEY' AND ix.RDB$RELATION_NAME = upper(:name) 
  into :field_name do
  begin
     Suspend;
  
  end     
end^


CREATE or ALTER PROCEDURE get_updatable_fields( name varchar(128))
  returns (field_name varchar(128))
as
begin
        for SELECT R.RDB$FIELD_NAME 
        FROM rdb$relation_fields r join RDB$FIELDS f on (r.RDB$FIELD_SOURCE = f.RDB$FIELD_NAME)
        where r.rdb$relation_name = upper(:name) AND F.RDB$COMPUTED_SOURCE IS NULL 
        into :field_name do
          suspend;
end^

CREATE or ALTER PROCEDURE get_all_fields( table_name varchar(128))
  returns (field_name varchar(128))
as
begin
        for SELECT R.RDB$FIELD_NAME 
        FROM rdb$relation_fields r join RDB$FIELDS f on (r.RDB$FIELD_SOURCE = f.RDB$FIELD_NAME)
        where r.rdb$relation_name = upper(:table_name)  
        into :field_name do
          suspend;
end^


create or alter function exists_column( table_name varchar(128), name varchar(128))
   returns integer
as
declare variable  conta integer;
begin
    
    SELECT count(*)  FROM rdb$relation_fields  
        where rdb$relation_name = upper(:table_name) and RDB$FIELD_NAME = upper(:name)  
    into :conta;
    if (conta>0) then return 1; else return 0;
end^


create or alter function exists_primary_key( name varchar(128))
  returns integer
as
declare variable  conta integer;
begin
    select count(*) from rdb$indices ix
        left join rdb$index_segments sg on ix.rdb$index_name = sg.rdb$index_name
        left join rdb$relation_constraints rc on rc.rdb$index_name = ix.rdb$index_name
        where rc.rdb$constraint_type = 'PRIMARY KEY' AND ix.RDB$RELATION_NAME = upper(:name) 
    into :conta;
    if (conta>0) then return 1; else return 0;
end^
   

--drop function exists_table;
create or alter function exists_table( name varchar(128))
  returns integer
as
declare variable  conta integer;
begin
    select count(*) from RDB$RELATIONS where rdb$relation_name = upper(:name) AND RDB$VIEW_BLR IS NULL 
    into :conta;
    if (conta>0) then return 1; else return 0;
end^

create or alter function exists_procedure( name varchar(128))
  returns integer
as
declare variable  conta integer;
begin
    select count(*) from RDB$PROCEDURES where rdb$procedure_name = upper(:name) 
    into :conta;
    if (conta>0) then return 1; else return 0;
end^


create or alter function exists_view( name varchar(128))
  returns integer
as
declare variable  conta integer;
begin
    select count(*) from RDB$RELATIONS where rdb$relation_name = upper(:name) AND RDB$VIEW_BLR IS not NULL 
    into :conta;
    if (conta>0) then return 1; else return 0;
end^

create or alter function exists_trigger( name varchar(128))
  returns integer
as
declare variable  conta integer;
begin
    select count(*) from RDB$TRIGGERS where rdb$trigger_name = upper(:name) 
    into :conta;
    if (conta>0) then return 1; else return 0;
end^

create or alter function exists_indice( name varchar(128))
  returns integer
as
declare variable  conta integer;
begin
    select count(*) from RDB$INDICES where rdb$index_name = upper(:name) 
    into :conta;
    if (conta>0) then return 1; else return 0;
end^



create or alter function exists_role( name varchar(128))
  returns integer
as
declare variable  conta integer;
begin
    select count(*) from RDB$ROLES where rdb$ROLE_name = upper(:name) 
    into :conta;
    if (conta>0) then return 1; else return 0;
end^

create or alter function exists_function( name varchar(128))
  returns integer
as
declare variable  conta integer;
begin
    select count(*) from RDB$FUNCTIONS where rdb$function_name = upper(:name) 
    into :conta;
    if (conta>0) then return 1; else return 0;
end^



create or alter function fields_count( table_name varchar(128))
  returns integer
as
declare variable  conta integer;
begin
    select count(*) from RDB$RELATION_FIELDS where rdb$relation_name = upper(:table_name) 
    into :conta;
    return conta;
end^

create or alter function SN( value_ integer )
  returns varchar(1)
as
BEGIN
    if (value_ =0 ) then return 'N'; else return 'S';
end^  


execute block
as
begin
   -- checa tabela de resultado de testes e cria se n�o existir;
   if (exists_table('TESTS')=0) then
     execute STATEMENT
      'CREATE  GLOBAL TEMPORARY TABLE  tests (   titulo varchar(128), sucesso varchar(1), texto varchar(1024)) ON COMMIT PRESERVE ROWS;';
end^

set term ;^

commit;
