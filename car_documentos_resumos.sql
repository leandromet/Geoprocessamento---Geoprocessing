create table documentos_codigos as

SELECT 
count (*) as contagem,
  imovel.cod_imovel,  
  tipo_documento.cod_tipo_documento, 
  municipio.cod_estado
FROM 
  usr_geocar_aplicacao.documento_imovel, 
  usr_geocar_aplicacao.imovel, 
  usr_geocar_aplicacao.tipo_documento, 
  usr_geocar_aplicacao.municipio
WHERE 
ind_status_imovel in ('AT', 'PE') and
  imovel.idt_imovel = documento_imovel.idt_imovel AND
  tipo_documento.idt_tipo_documento = documento_imovel.idt_tipo_documento AND
  municipio.idt_municipio = imovel.idt_municipio

group by

  imovel.cod_imovel,  
  tipo_documento.cod_tipo_documento, 
  municipio.cod_estado;



----agrupamento e colunas de tipos

create table documentos_somas_tipos as 

select 
cod_estado,
cod_imovel,
sum (case when cod_tipo_documento = 'PROPRIEDADE' then contagem else 0 end) as propriedade,
sum (case when cod_tipo_documento = 'POSSE' then contagem else 0 end) as posse,
sum (case when cod_tipo_documento = 'CONCESSAO' then contagem else 0 end) as concessao,
sum (case when cod_tipo_documento = 'IDENTIFICACAO' then contagem else 0 end) as identificacao,
sum (case when cod_tipo_documento = 'ATFA' then contagem else 0 end) as atfa,
sum (case when cod_tipo_documento = 'OUTRO' then contagem else 0 end) as outro

from documentos_codigos
group by cod_estado,
cod_imovel;













----totais de documentos


SELECT 
  documento.nom_documento, 
  imovel.ind_tipo_imovel, 
  imovel.ind_status_imovel, 
  count(imovel.idt_imovel)
FROM 
  usr_geocar_aplicacao.imovel, 
  usr_geocar_aplicacao.rel_documento_imovel_documento, 
  usr_geocar_aplicacao.documento_imovel, 
  usr_geocar_aplicacao.documento
WHERE 
  imovel.idt_imovel = documento_imovel.idt_imovel AND
  rel_documento_imovel_documento.idt_documento_imovel = documento_imovel.idt_documento_imovel AND
  documento.idt_documento = rel_documento_imovel_documento.idt_documento

group by   documento.nom_documento, 
  imovel.ind_tipo_imovel, 
  imovel.ind_status_imovel;





----totais por quantidades
select nom_documento, idts, count (cod_imovel)

from (

SELECT 
imovel.cod_imovel,
  documento.nom_documento, 
  count(imovel.idt_imovel) as idts
FROM 
  usr_geocar_aplicacao.imovel, 
  usr_geocar_aplicacao.rel_documento_imovel_documento, 
  usr_geocar_aplicacao.documento_imovel, 
  usr_geocar_aplicacao.documento
WHERE 
ind_status_imovel in ('AT', 'PE') and
  imovel.idt_imovel = documento_imovel.idt_imovel AND
  rel_documento_imovel_documento.idt_documento_imovel = documento_imovel.idt_documento_imovel AND
  documento.idt_documento = rel_documento_imovel_documento.idt_documento

group by  imovel.cod_imovel, documento.nom_documento) grupo
group by nom_documento, idts;
