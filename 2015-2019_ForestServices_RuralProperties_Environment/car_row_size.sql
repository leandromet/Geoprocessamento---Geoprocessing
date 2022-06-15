WITH x AS (
   SELECT count(*)               AS ct
        , sum(length(t::text))   AS txt_len  -- length in characters
        , 'usr_geocar_aplicacao.imovel'::regclass AS tbl  -- provide (qualified) table name here
   FROM   usr_geocar_aplicacao.imovel t  -- ... and here
   )
, y AS (
   SELECT ARRAY [pg_relation_size(tbl)
               , pg_relation_size(tbl, 'vm')
               , pg_relation_size(tbl, 'fsm')
               , pg_table_size(tbl)
               , pg_indexes_size(tbl)
               , pg_total_relation_size(tbl)
               , txt_len
             ] AS val
        , ARRAY ['core_relation_size'
               , 'visibility_map'
               , 'free_space_map'
               , 'table_size_incl_toast'
               , 'indexes_size'
               , 'total_size_incl_toast_and_indexes'
               , 'live_rows_in_text_representation'
             ] AS name
   FROM   x
   )
SELECT unnest(name)                AS what
     , unnest(val)                 AS "bytes/ct"
     , pg_size_pretty(unnest(val)) AS bytes_pretty
     , unnest(val) / ct            AS bytes_per_row
FROM   x, y

UNION ALL SELECT '------------------------------', NULL, NULL, NULL
UNION ALL SELECT 'row_count', ct, NULL, NULL FROM x
UNION ALL SELECT 'live_tuples', pg_stat_get_live_tuples(tbl), NULL, NULL FROM x
UNION ALL SELECT 'dead_tuples', pg_stat_get_dead_tuples(tbl), NULL, NULL FROM x;
