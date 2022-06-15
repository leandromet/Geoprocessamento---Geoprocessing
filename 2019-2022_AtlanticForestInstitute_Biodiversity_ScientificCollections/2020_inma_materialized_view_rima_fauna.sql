
-- View: rima_geoserver.pontos_fauna_niveis

-- DROP MATERIALIZED VIEW rima_geoserver.pontos_fauna_niveis;

CREATE MATERIALIZED VIEW rima_geoserver.pontos_fauna_niveis
TABLESPACE pg_default
AS
 SELECT pontos_fauna.phylum,
    pontos_fauna.class,
    pontos_fauna.ordem,
    pontos_fauna.family,
    pontos_fauna.genus,
    pontos_fauna.species,
    count(*) AS num_gen
   FROM rima_geoserver.pontos_fauna
  GROUP BY pontos_fauna.genus, pontos_fauna.phylum, pontos_fauna.ordem, pontos_fauna.class, pontos_fauna.family, pontos_fauna.species
  ORDER BY pontos_fauna.phylum, pontos_fauna.class, pontos_fauna.ordem, pontos_fauna.family
WITH DATA;

ALTER TABLE rima_geoserver.pontos_fauna_niveis
    OWNER TO postgres;







-- View: rima_geoserver.postos_fauna_niveis

-- DROP MATERIALIZED VIEW rima_geoserver.pontos_fauna_niveis;

CREATE MATERIALIZED VIEW rima_geoserver.pontos_fauna_niveis
TABLESPACE pg_default
AS
 SELECT DISTINCT table5.phylum,
    table5.class,
    table5.ordem,
    table5.family,
    table5.genus,
    table5.species,
    table5.num_gen
   FROM ( SELECT DISTINCT table4.class,
            table4.ordem,
            table4.family,
            table4.phylum,
            table4.genus,
            table4.species,
            table4.num_gen
           FROM ( SELECT DISTINCT tale3.ordem,
                    tale3.phylum,
                    tale3.family,
                    tale3.class,
                    tale3.genus,
                    tale3.species,
                    tale3.num_gen
                   FROM ( SELECT DISTINCT table2.family,
                            table2.phylum,
                            table2.ordem,
                            table2.class,
                            table2.genus,
                            table2.species,
                            table2.num_gen
                           FROM ( SELECT DISTINCT tabela.genus,
                                    tabela.phylum,
                                    tabela.family,
                                    tabela.ordem,
                                    tabela.class,
                                    tabela.species,
                                    tabela.num_gen
                                   FROM ( SELECT DISTINCT pontos_fauna.species,
    pontos_fauna.genus,
    pontos_fauna.phylum,
    pontos_fauna.ordem,
    pontos_fauna.class,
    pontos_fauna.family,
    count(*) AS num_gen
   FROM rima_geoserver.pontos_fauna
  GROUP BY pontos_fauna.genus, pontos_fauna.phylum, pontos_fauna.ordem, pontos_fauna.class, pontos_fauna.family, pontos_fauna.species) tabela) table2) tale3) table4) table5
  ORDER BY table5.phylum, table5.class, table5.ordem, table5.family
WITH DATA;

ALTER TABLE rima_geoserver.pontos_fauna_niveis
    OWNER TO postgres;
