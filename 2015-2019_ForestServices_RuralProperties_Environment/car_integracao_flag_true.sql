select cod_estado,  cod_imovel, sum, count,   ind_status_imovel, 
  flg_ativo

from

(SELECT 
  count(imovel.idt_imovel), 
  sum(imovel.num_area_imovel), cod_estado,
  imovel.cod_imovel,
  imovel.ind_status_imovel, 
  imovel.flg_ativo
FROM 
  usr_geocar_aplicacao.imovel, usr_geocar_aplicacao.municipio
  where 
 -- imovel.idt_municipio = 5300108 and 
  flg_ativo = TRUE and
  imovel.idt_municipio=municipio.idt_municipio
  group by
  cod_estado,
  imovel.cod_imovel,
  imovel.ind_status_imovel, 
  imovel.flg_ativo
 -- limit 10
  ) imov
  where count > 1






imoveis AT, PE mais de uma versao


select cod_estado,  cod_imovel, sum, count,   ind_status_imovel, 
  flg_ativo

from

(SELECT 
  count(imovel.idt_imovel), 
  sum(imovel.num_area_imovel), cod_estado,
  imovel.cod_imovel,
  imovel.ind_status_imovel, 
  imovel.flg_ativo
FROM 
  usr_geocar_aplicacao.imovel, usr_geocar_aplicacao.municipio
  where 
 -- imovel.idt_municipio = 5300108 and
  ind_status_imovel in ('AT','PE') and
  --flg_ativo = TRUE and
  imovel.idt_municipio=municipio.idt_municipio
  group by
  cod_estado,
  imovel.cod_imovel,
  imovel.ind_status_imovel, 
  imovel.flg_ativo
 -- limit 10
  ) imov
  where count > 1 ;
