select 'drop table ' || tablename || ' cascade;' from pg_tables 
where schemaname = 'public' and tablename not like 'pg%' and tablename not like 'sql%' and tablename like 'log_imovel%';
