DO
$do$
DECLARE
   _tbl text;
BEGIN

FOR _tbl  IN
    SELECT c.oid::regclass::text  -- escape identifier and schema-qualify!
    FROM   pg_catalog.pg_class c
    JOIN   pg_catalog.pg_namespace n ON n.oid = c.relnamespace
    WHERE  n.nspname NOT LIKE 'pg_%'      -- exclude system schemas
    AND    c.relname LIKE 'desmat' || '%' -- your table name prefix
    AND    c.relkind = 'r'                -- only tables
LOOP
 RAISE NOTICE '%',
 --EXECUTE
  'DROP TABLE ' || _tbl || ' CASCADE';
END LOOP;
END
$do$;
