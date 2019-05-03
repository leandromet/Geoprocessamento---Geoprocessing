
create table geoserver.imovel_rural as
SELECT 
  imovel.idt_imovel, 
  imovel.cod_imovel,
  imovel.ind_status_imovel, 
  imovel.ind_tipo_imovel, 
  imovel.num_area_imovel, 
  imovel.num_modulo_fiscal, 
  municipio.idt_municipio as geocod_mun, 
  municipio.cod_estado, 
  municipio.nom_municipio, 
  imovel.dat_criacao, 
  imovel.flg_ativo, 
  imovel.geo_area_imovel as geom
FROM 
  usr_geocar_aplicacao.imovel, 
  usr_geocar_aplicacao.municipio
WHERE 
num_area_imovel > 0.04 and
ind_status_imovel in ( 'AT', 'PE') and flg_ativo is true and
  municipio.idt_municipio = imovel.idt_municipio;
