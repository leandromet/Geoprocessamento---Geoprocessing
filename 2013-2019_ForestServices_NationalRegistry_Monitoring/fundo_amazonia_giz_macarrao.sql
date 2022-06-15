create table proc_sfb.fa_giz_macarra_30_app as

SELECT 
  imovel.idt_imovel, 
  imovel.cod_imovel, 
  imovel.ind_status_imovel, 
  imovel.ind_tipo_imovel, 
  imovel.nom_imovel, 
  imovel.idt_municipio, 
  imovel.num_area_imovel, 
  imovel.num_modulo_fiscal, 
  imovel.dat_criacao, 
  imovel.dat_atualizacao, 
  imovel.flg_ativo, 
  tema_simp_30_app.cod_estado, 
  tema_simp_30_app.st_simplifypreservetopology as geom, 
  left(fa_giz_macarra_munic."Projeto",20)
FROM 
  geoserver.tema_simp_30_app, 
  usr_geocar_aplicacao.imovel, 
  proc_sfb.fa_giz_macarra_munic
WHERE 
ind_status_imovel in ( 'AT', 'PE') AND flg_ativo is true and
  imovel.idt_imovel = tema_simp_30_app.idt_imovel AND
  fa_giz_macarra_munic."CD_GEOCMU" = imovel.idt_municipio;
  
  
 create table proc_sfb.fa_giz_macarra_30_app as

SELECT 
  imovel.idt_imovel, 
  imovel.cod_imovel, 
  imovel.ind_status_imovel, 
  imovel.ind_tipo_imovel, 
  imovel.nom_imovel, 
  imovel.idt_municipio, 
  imovel.num_area_imovel, 
  imovel.num_modulo_fiscal, 
  imovel.dat_criacao, 
  imovel.dat_atualizacao, 
  imovel.flg_ativo, 
  tema_simp_30_app.cod_estado, 
  tema_simp_30_app.st_simplifypreservetopology as geom, 
  left(fa_giz_macarra_munic."Projeto",20)
FROM 
  geoserver.tema_simp_30_app, 
  usr_geocar_aplicacao.imovel, 
  proc_sfb.fa_giz_macarra_munic
WHERE 
ind_status_imovel in ( 'AT', 'PE') AND flg_ativo is true and
  imovel.idt_imovel = tema_simp_30_app.idt_imovel AND
  fa_giz_macarra_munic."CD_GEOCMU" = imovel.idt_municipio;
  
  
  
  create table proc_sfb.fa_giz_macarra_1_consol as

SELECT 
  imovel.idt_imovel, 
  imovel.cod_imovel, 
  imovel.ind_status_imovel, 
  imovel.ind_tipo_imovel, 
  imovel.nom_imovel, 
  imovel.idt_municipio, 
  imovel.num_area_imovel, 
  imovel.num_modulo_fiscal, 
  imovel.dat_criacao, 
  imovel.dat_atualizacao, 
  imovel.flg_ativo, 
  tema_simp_1_consolidado.cod_estado, 
  tema_simp_1_consolidado.st_simplifypreservetopology as geom, 
  left(fa_giz_macarra_munic."Projeto",20)
FROM 
  geoserver.tema_simp_1_consolidado, 
  usr_geocar_aplicacao.imovel, 
  proc_sfb.fa_giz_macarra_munic
WHERE 
ind_status_imovel in ( 'AT', 'PE') AND flg_ativo is true and
  imovel.idt_imovel = tema_simp_1_consolidado.idt_imovel AND
  fa_giz_macarra_munic."CD_GEOCMU" = imovel.idt_municipio;
  
  
  
  
  create table proc_sfb.fa_giz_macarra_2_rvn as

SELECT 
  imovel.idt_imovel, 
  imovel.cod_imovel, 
  imovel.ind_status_imovel, 
  imovel.ind_tipo_imovel, 
  imovel.nom_imovel, 
  imovel.idt_municipio, 
  imovel.num_area_imovel, 
  imovel.num_modulo_fiscal, 
  imovel.dat_criacao, 
  imovel.dat_atualizacao, 
  imovel.flg_ativo, 
  tema_simp_2_rvn.cod_estado, 
  tema_simp_2_rvn.st_simplifypreservetopology as geom, 
  left(fa_giz_macarra_munic."Projeto",20)
FROM 
  geoserver.tema_simp_2_rvn, 
  usr_geocar_aplicacao.imovel, 
  proc_sfb.fa_giz_macarra_munic
WHERE 
ind_status_imovel in ( 'AT', 'PE') AND flg_ativo is true and
  imovel.idt_imovel = tema_simp_2_rvn.idt_imovel AND
  fa_giz_macarra_munic."CD_GEOCMU" = imovel.idt_municipio;
  
  
  
  
