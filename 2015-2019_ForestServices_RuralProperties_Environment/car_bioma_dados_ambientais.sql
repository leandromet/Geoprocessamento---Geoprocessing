

create table proc_sfb.mtat_imoveis_atpe as

SELECT 
distinct(imovel.idt_imovel), 
  mtat_bioma_completo.id, 
  mtat_bioma_completo."OBJECTID", 
  mtat_bioma_completo.lei, 
  mtat_bioma_completo.gid, 
  mtat_bioma_completo.idt_tipo_bioma, 
  imovel.cod_imovel, 
  imovel.ind_status_imovel, 
  imovel.ind_tipo_imovel, 
  imovel.nom_imovel, 
  imovel.num_fracao_ideal, 
  imovel.idt_municipio, 
  municipio.cod_estado, 
  municipio.nom_municipio, 
  imovel.num_area_imovel, 
  imovel.num_modulo_fiscal, 
  imovel.dat_criacao, 
  imovel.dat_atualizacao, 
  imovel.geo_area_imovel, 
  imovel.flg_ativo, 
  imovel.cod_cep, 
  imovel.ind_zona_localizacao, 
  imovel.des_condicao, 
  imovel.idt_condicao_inscricao
FROM 
  proc_sfb.mtat_bioma_completo, 
  usr_geocar_aplicacao.imovel, 
  usr_geocar_aplicacao.municipio
WHERE 
ind_status_imovel in ( 'AT', 'PE') and
  st_intersects(mtat_bioma_completo.the_geom , imovel.geo_area_imovel) AND
  municipio.idt_municipio = imovel.idt_municipio;







create table proc_sfb.mtat_tema_imv_plg as
SELECT 
  rel_tema_imovel_poligono.idt_rel_tema_imovel, 
  rel_tema_imovel_poligono.idt_tema, 
  rel_tema_imovel_poligono.idt_imovel, 
  rel_tema_imovel_poligono.num_area, 
  ST_SimplifyPreserveTopology(rel_tema_imovel_poligono.the_geom, 0.00001) as geom
FROM 
  proc_sfb.mtat_imoveis_atpeb, 
  usr_geocar_aplicacao.rel_tema_imovel_poligono
WHERE 
idt_tema in (1,2,3,30,32) and
  rel_tema_imovel_poligono.idt_imovel = mtat_imoveis_atpeb.idt_imovel;

