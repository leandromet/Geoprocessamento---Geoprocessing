---anexo dados da tabela do RVN/PCT dissolvido, área albers na RVN e área do sistema no imóvel.

----O shape e etc esta'no image3/boletim arquivo zip.

---Em qua, 9 de jan de 2019 às 08:13, Leandro e Arthur Biondo <leandromet@gmail.com> escreveu:
----o problema é tentar contar imóvei e somar as pessoas com temporalidade na mesma consulta, está ficando grande demais para os dois bancos... deste jeito funcionou mas trouxe o mesmo valor para imóveis e pessoas, sendo que ambos são na verdade a quantidade de pessoas. Anexo o consolidado desta e da próxima consulta no xlsx

SELECT cod_estado, ind_tipo_imovel, count(i.idt_imovel) as numero_imovel, count(p.cod_cpf_cnpj) AS assentados, sum(num_area_imovel) as area_ha,              
  CASE    WHEN num_modulo_fiscal < 4 THEN '0 a 4 MF'                   
     WHEN num_modulo_fiscal >= 4  AND num_modulo_fiscal < 15 THEN '4 e 15 MF'                 
            WHEN num_modulo_fiscal >= 15 THEN 'superior a 15MF'             END AS mf   

                FROM    usr_geocar_aplicacao.imovel i ,  
                        usr_geocar_aplicacao.municipio m   ,
                                usr_geocar_aplicacao.imovel_pessoa p
                    
                              WHERE      flg_ativo = TRUE       AND ind_status_imovel in ('AT','PE')  
                                
                                 and i.idt_municipio = m.idt_municipio   
                                 and p.idt_imovel = i.idt_imovel
 GROUP BY cod_estado, ind_tipo_imovel,   mf ORDER BY cod_estado, ind_tipo_imovel,         mf;




Depois este outro para extrair o número de imóveis e área correta (no anterior a área de cada imóvel ficou multiplicada pela quantidade de pessoas)


SELECT cod_estado, ind_tipo_imovel, count(i.idt_imovel) as numero_imovel, 
 sum(num_area_imovel) as area_ha,              
  CASE    WHEN num_modulo_fiscal < 4 THEN '0 a 4 MF'                   
     WHEN num_modulo_fiscal >= 4  AND num_modulo_fiscal < 15 THEN '4 e 15 MF'                 
            WHEN num_modulo_fiscal >= 15 THEN 'superior a 15MF'             END AS mf   

                FROM    usr_geocar_aplicacao.imovel i ,  
                        usr_geocar_aplicacao.municipio m   
                    
                              WHERE      flg_ativo = TRUE       AND ind_status_imovel in ('AT','PE')  
                                
                                 and i.idt_municipio = m.idt_municipio   
 GROUP BY cod_estado, ind_tipo_imovel,   mf ORDER BY cod_estado, ind_tipo_imovel,         mf;


---Em qua, 9 de jan de 2019 às 00:15, Leandro e Arthur Biondo <leandromet@gmail.com> escreveu:
----deu geometria invalida então estou tentando:

create table proc_sfb.god_rvn_pct_inters_unicos as
SELECT 
  god_rvn_pct_inters.idt_imovel,  
  max(god_rvn_pct_inters.num_area_imovel) as num_area_imovel, 
  max(god_rvn_pct_inters.gid) as gid, 
  max(god_rvn_pct_inters.estado) as estado, 
  st_makevalid(st_union(st_makevalid(god_rvn_pct_inters.st_intersection))), 
  sum(god_rvn_pct_inters.area_ha) as area_rnv
FROM 
  proc_sfb.god_rvn_pct_inters
  group by idt_imovel;


----e para a consulta da rejane com pessoas para classes de MF estou tentando isso mas está demorando mais do que eu esperava, talvez algum erro:

SELECT     max(assentados),    cod_estado, ind_tipo_imovel,     mf,     count(idt_imovel) AS numero_total, sum(num_area_imovel) as area FROM    
(SELECT  assentados, cod_estado, ind_tipo_imovel, i.idt_imovel, num_area_imovel,         
       CASE    WHEN num_modulo_fiscal < 4 THEN '0 a 4 MF'                      WHEN num_modulo_fiscal >= 4  AND num_modulo_fiscal < 15 THEN '4 e 15 MF'  
                             WHEN num_modulo_fiscal >= 15 THEN 'superior a 15MF'             END AS mf      
                              FROM  (select idt_imovel as idt_imovel_p, count(cod_cpf_cnpj) AS assentados from usr_geocar_aplicacao.imovel_pessoa group by idt_imovel)p, 
                               usr_geocar_aplicacao.imovel i       
                                  INNER JOIN              usr_geocar_aplicacao.municipio m               
                                   ON i.idt_municipio = m.idt_municipio  
                                     WHERE idt_imovel_p = i.idt_imovel  and  
                                       (flg_ativo = TRUE       AND ind_status_imovel in ('AT','PE')    AND dat_criacao < to_date('01/01/2019','dd/mm/yyyy')) 
                                         OR (ind_status_imovel in ('CA','RE') AND dat_criacao < to_date('01/01/2019','dd/mm/yyyy') AND 
                                         dat_atualizacao>= to_date('01/01/2019','dd/mm/yyyy')) )a 
 GROUP BY cod_estado, ind_tipo_imovel,   mf ORDER BY cod_estado, ind_tipo_imovel,         mf
;

----Em ter, 8 de jan de 2019 às 23:24, Leandro e Arthur Biondo <leandromet@gmail.com> escreveu:
----como tem vários poligonos de RVN por imóvel, agrupar por idt e usar funções agregadoras... usei max porque é inócuo no caso, mais st_union para agrupar as geometrias e sum na área calculada de rvn


create table proc_sfb.god_rvn_pct_inters_unicos as



SELECT 
  god_rvn_pct_inters.idt_imovel,  
  max(god_rvn_pct_inters.num_area_imovel) as num_area_imovel, 
  max(god_rvn_pct_inters.gid) as gid, 
  max(god_rvn_pct_inters.estado) as estado, 
  st_union(god_rvn_pct_inters.st_intersection), 
  sum(god_rvn_pct_inters.area_ha) as area_rnv
FROM 
  proc_sfb.god_rvn_pct_inters

  group by idt_imovel;


----Em ter, 8 de jan de 2019 às 23:17, Leandro e Arthur Biondo <leandromet@gmail.com> escreveu:
----aparentemente funcionou (a forma que a pamela fez tambem, porque tem uma tabela lá que parece ser a mesma informação)

----agora adicionar ALBERS neste banco e calcular area de cada resultado de geometria




INSERT into spatial_ref_sys (srid, auth_name, auth_srid, proj4text, srtext) values ( 102033, 'ESRI', 102033, '+proj=aea +lat_1=-5 +lat_2=-42 +lat_0=-32 +lon_0=-60 +x_0=0 +y_0=0 +ellps=aust_SA +units=m +no_defs ', 'PROJCS["South_America_Albers_Equal_Area_Conic",GEOGCS["GCS_South_American_1969",DATUM["South_American_Datum_1969",SPHEROID["GRS_1967_Truncated",6378160,298.25]],PRIMEM["Greenwich",0],UNIT["Degree",0.017453292519943295]],PROJECTION["Albers_Conic_Equal_Area"],PARAMETER["False_Easting",0],PARAMETER["False_Northing",0],PARAMETER["longitude_of_center",-60],PARAMETER["Standard_Parallel_1",-5],PARAMETER["Standard_Parallel_2",-42],PARAMETER["latitude_of_center",-32],UNIT["Meter",1],AUTHORITY["EPSG","102033"]]');



UPDATE proc_sfb.god_rvn_pct_inters  SET area_ha = round((ST_AREA(ST_Transform(st_intersection,102033))/10000 )::numeric,4);







----Em ter, 8 de jan de 2019 às 22:29, Leandro e Arthur Biondo <leandromet@gmail.com> escreveu:
----para depois rastrearmos. A idéia: criar uma tabela só com PCT, depois criar indice espacial, criar uma tabela com as geometrias da base de referencia originais de remanescente que intersectam os PCT da tabela criada, depois de ter os dados tentar fazer a intersecção de geometria de fato, talvez simplificar as geometrais de ambos se não for de primeira.






create table proc_sfb.god_pct as
SELECT 
  imovel.idt_imovel, 
  imovel.cod_imovel, 
  imovel.num_area_imovel, 
  imovel.num_modulo_fiscal, 
  imovel.geo_area_imovel as geom
FROM 
  usr_geocar_aplicacao.imovel
  where ind_status_imovel in ('AT', 'PE') and
  ind_tipo_imovel = 'PCT';





create table proc_sfb.god_ast as
SELECT 
  imovel.idt_imovel, 
  imovel.cod_imovel, 
  imovel.num_area_imovel, 
  imovel.num_modulo_fiscal, 
  imovel.geo_area_imovel as geom
FROM 
  usr_geocar_aplicacao.imovel
  where ind_status_imovel in ('AT', 'PE') and
  ind_tipo_imovel = 'AST';





CREATE INDEX sidx_god_pct
  ON proc_sfb.god_pct
  USING gist
  (geom);






create table proc_sfb.god_rvn_pct as

SELECT 
  god_pct.idt_imovel, 
  remanescente_vegetacao_nativa.gid, 
  remanescente_vegetacao_nativa.gridcode, 
  remanescente_vegetacao_nativa.classificacao, 
  remanescente_vegetacao_nativa.estado, 
  remanescente_vegetacao_nativa.the_geom as geom
FROM 
  proc_sfb.god_pct, 
  base_referencia.remanescente_vegetacao_nativa
WHERE 
  st_intersects(remanescente_vegetacao_nativa.the_geom , god_pct.geom);
