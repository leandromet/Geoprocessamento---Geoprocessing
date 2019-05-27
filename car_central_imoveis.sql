Re: consulta pessoas central
Pâmella Brenda <pamella.brenda@hotmail.com>
Leandro Meneguelli Biondo;
Create table proc_sfb.imoveis_central as 
SELECT 
  municipio.cod_estado, 
  municipio.idt_municipio, 
  imovel.idt_imovel, 
  imovel.cod_imovel, 
  imovel.ind_status_imovel, 
  imovel.ind_tipo_imovel, 
  imovel.num_area_imovel, 
  imovel.num_modulo_fiscal, 
  imovel.geo_area_imovel as geom, 
  COUNT(imovel_pessoa.idt_imovel_pessoa) as pessoas
FROM 
  portal_seguranca.pessoa, 
  usr_geocar_aplicacao.imovel, 
  usr_geocar_aplicacao.municipio, 
  usr_geocar_aplicacao.imovel_pessoa
WHERE 
  imovel.idt_municipio = municipio.idt_municipio AND
  imovel_pessoa.idt_imovel = imovel.idt_imovel AND
imovel_pessoa.cod_cpf_cnpj = REPLACE(REPLACE(REPLACE(pessoa.tx_cpf_cnpj,'.',''), '-',''),'/','') 
Group by municipio.cod_estado, 
  municipio.idt_municipio, 
  imovel.idt_imovel
ORDER BY municipio.cod_estado, 
  municipio.idt_municipio, 
  imovel.idt_imovel
