create table proc_sfb.mapa_pnefaftosa as

SELECT 
  imovel.idt_imovel, 
  imovel.cod_imovel, 
  imovel.ind_tipo_imovel, 
  imovel.nom_imovel, 
  imovel.idt_municipio, 
  imovel.num_area_imovel, 
  imovel.num_modulo_fiscal, 
  imovel.dat_criacao, 
  municipio.nom_municipio, 
  municipio.cod_estado, 
  imovel.geo_area_imovel as geom
FROM 
  usr_geocar_aplicacao.imovel, 
  usr_geocar_aplicacao.municipio
WHERE imovel.idt_municipio in (5000906,5000609,5001243,5002100,5002803,5003157,5003207,5003702,5003751,5004304,5004601,5004809,5005004,5005251,5005681,5006358,5006606,5006903,5007703,5007950) and
ind_status_imovel in ('AT', 'PE') and flg_ativo is true and

  municipio.idt_municipio = imovel.idt_municipio;
