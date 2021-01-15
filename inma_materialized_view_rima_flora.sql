-- View: rima_geoserver.pontos_flora_niveis

-- DROP MATERIALIZED VIEW rima_geoserver.pontos_flora_niveis;

CREATE MATERIALIZED VIEW rima_geoserver.pontos_flora_niveis
TABLESPACE pg_default
AS
 SELECT DISTINCT table4.phylum,
    table4.class,
    table4.ordem,
    table4.family,
    table4.genus,
    table4.num_gen
   FROM ( SELECT DISTINCT tale3.class,
            tale3.ordem,
            tale3.family,
            tale3.phylum,
            tale3.genus,
            tale3.num_gen
           FROM ( SELECT DISTINCT table2.ordem,
                    table2.phylum,
                    table2.family,
                    table2.class,
                    table2.genus,
                    table2.num_gen
                   FROM ( SELECT DISTINCT tabela.family,
                            tabela.phylum,
                            tabela.ordem,
                            tabela.class,
                            tabela.genus,
                            tabela.num_gen
                           FROM ( SELECT DISTINCT pontos_flora.genus,
                                    pontos_flora.phylum,
                                    pontos_flora.ordem,
                                    pontos_flora.class,
                                    pontos_flora.family,
                                    count(*) AS num_gen
                                   FROM rima_geoserver.pontos_flora
                                  GROUP BY pontos_flora.genus, pontos_flora.phylum, pontos_flora.ordem, pontos_flora.class, pontos_flora.family) tabela) table2) tale3) table4
  ORDER BY table4.phylum, table4.class, table4.ordem, table4.family
WITH DATA;

ALTER TABLE rima_geoserver.pontos_flora_niveis
    OWNER TO postgres;
