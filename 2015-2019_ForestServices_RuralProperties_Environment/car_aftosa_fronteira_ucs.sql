dados da fronteira:​




create table proc_sfb.mapa_pnefaftosa_front_ir as



SELECT 
  imovel.idt_imovel, 
  imovel.cod_imovel, 
  imovel.ind_tipo_imovel, 
  imovel.idt_municipio, 
  municipio.nom_municipio, 
  municipio.cod_estado, 
  imovel.num_area_imovel, 
  imovel.num_modulo_fiscal, 
  imovel.dat_criacao, 
  tema_simp_26_imovel.st_simplifypreservetopology as geom
FROM 
  usr_geocar_aplicacao.imovel, 
  usr_geocar_aplicacao.municipio, 
  geoserver.tema_simp_26_imovel, 
  proc_sfb.mapa_pnefaftosa_fronteira
WHERE 
ind_status_imovel in ('AT', 'PE') and
  municipio.idt_municipio = imovel.idt_municipio AND
  tema_simp_26_imovel.idt_imovel = imovel.idt_imovel AND
  mapa_pnefaftosa_fronteira.geocodigo::numeric = municipio.idt_municipio;​


Buffer 10km ucs federais



create table proc_sfb.mapa_pnefaftosa_uc_ir as

SELECT 
  tema_simp_26_imovel.idt_rel_tema_imovel, 
  tema_simp_26_imovel.idt_imovel, 
  tema_simp_26_imovel.area_ha, 
  tema_simp_26_imovel.cod_imovel, 
  tema_simp_26_imovel.cod_estado, 
  tema_simp_26_imovel.modulo, 
  tema_simp_26_imovel.data_ref, 
  tema_simp_26_imovel.tipo_imovel, 
  mapa_pnefaftosa_buff_uc.id, 
  mapa_pnefaftosa_buff_uc.idcf, 
  mapa_pnefaftosa_buff_uc.nome, 
  mapa_pnefaftosa_buff_uc.classe, 
  mapa_pnefaftosa_buff_uc.bioma
FROM 
  proc_sfb.mapa_pnefaftosa_buff_uc, 
  geoserver.tema_simp_26_imovel
WHERE 
 st_intersects(  tema_simp_26_imovel.st_simplifypreservetopology , mapa_pnefaftosa_buff_uc.geom);






Desmatamento 2008 - 2011

create table base_referencia.simp_area_ant_apos_2008 as

SELECT 
  area_antropizada_apos_2008.gid, 
  area_antropizada_apos_2008.gridcode, 
  area_antropizada_apos_2008.classificacao, 
  area_antropizada_apos_2008.estado, 
  ST_SimplifyPreserveTopology(the_geom, 0.00002) as geom, 
  area_antropizada_apos_2008.shape
FROM 
  base_referencia.area_antropizada_apos_2008;





 

create table proc_sfb.mapa_pnefaftosa_ant2008_ir as

SELECT 
  tema_simp_26_imovel.idt_rel_tema_imovel, 
  tema_simp_26_imovel.idt_imovel, 
  tema_simp_26_imovel.area_ha, 
  tema_simp_26_imovel.cod_imovel, 
  tema_simp_26_imovel.cod_estado, 
  tema_simp_26_imovel.modulo, 
  tema_simp_26_imovel.data_ref, 
  tema_simp_26_imovel.tipo_imovel, 
  tema_simp_26_imovel.st_simplifypreservetopology, 
  simp_area_ant_apos_2008.gid, 
  simp_area_ant_apos_2008.gridcode
FROM 
  base_referencia.simp_area_ant_apos_2008, 
  geoserver.tema_simp_26_imovel
WHERE 
  st_intersects( tema_simp_26_imovel.st_simplifypreservetopology , simp_area_ant_apos_2008.geom);








SELECT 
  municipio.cod_estado, 
  municipio.idt_municipio, 
  municipio.nom_municipio, 
  mapa_pnefaftosa_ant2008_ir2.tipo_imovel, 
  count(mapa_pnefaftosa_ant2008_ir2.idt_imovel), 
  sum(mapa_pnefaftosa_ant2008_ir2.area_ha)
FROM 
  proc_sfb.mapa_pnefaftosa_ant2008_ir2, 
  usr_geocar_aplicacao.imovel, 
  usr_geocar_aplicacao.municipio
WHERE 
  imovel.idt_imovel = mapa_pnefaftosa_ant2008_ir2.idt_imovel AND
  imovel.idt_municipio = municipio.idt_municipio
  group by  municipio.cod_estado, 
  municipio.idt_municipio, 
  municipio.nom_municipio, 
  mapa_pnefaftosa_ant2008_ir2.tipo_imovel
  order by   municipio.cod_estado,
  municipio.nom_municipio, 
  mapa_pnefaftosa_ant2008_ir2.tipo_imovel;





SELECT 
  municipio.cod_estado, 
  municipio.idt_municipio, 
  municipio.nom_municipio, 
  mapa_pnefaftosa_uc_ir2.tipo_imovel, 
  count(mapa_pnefaftosa_uc_ir2.idt_imovel), 
  sum(mapa_pnefaftosa_uc_ir2.area_ha)
FROM 
  proc_sfb.mapa_pnefaftosa_uc_ir2, 
  usr_geocar_aplicacao.imovel, 
  usr_geocar_aplicacao.municipio
WHERE 
  imovel.idt_imovel = mapa_pnefaftosa_uc_ir2.idt_imovel AND
  municipio.idt_municipio = imovel.idt_municipio
  group by
    municipio.cod_estado, 
  municipio.idt_municipio, 
  municipio.nom_municipio, 
  mapa_pnefaftosa_uc_ir2.tipo_imovel
  order by   municipio.cod_estado, 
  municipio.idt_municipio, 
  municipio.nom_municipio, 
  mapa_pnefaftosa_uc_ir2.tipo_imovel;





SELECT 
  mapa_pnefaftosa_front_ir.cod_estado, 
  mapa_pnefaftosa_front_ir.idt_municipio, 
  mapa_pnefaftosa_front_ir.nom_municipio, 
  mapa_pnefaftosa_front_ir.ind_tipo_imovel, 
  count(mapa_pnefaftosa_front_ir.idt_imovel), 
  sum(mapa_pnefaftosa_front_ir.num_area_imovel)
FROM 
  proc_sfb.mapa_pnefaftosa_front_ir
  group by
  mapa_pnefaftosa_front_ir.cod_estado, 
  mapa_pnefaftosa_front_ir.idt_municipio, 
  mapa_pnefaftosa_front_ir.nom_municipio, 
  mapa_pnefaftosa_front_ir.ind_tipo_imovel
  order by
  mapa_pnefaftosa_front_ir.cod_estado,  
  mapa_pnefaftosa_front_ir.nom_municipio, 
  mapa_pnefaftosa_front_ir.ind_tipo_imovel;

