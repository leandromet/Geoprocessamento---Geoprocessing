Consulta de imóveis que aderiram PRA
Pâmella Brenda <pamella.brenda@hotmail.com>
Gustavo Henrique de Oliveira;
Rejane Marques Mendes;Leandro Meneguelli Biondo;kimberly.castro@giz.de;
Create table proc_sfb.boletim_pra as 

SELECT 
cod_estado,
idt_resposta_pergunta,
  count(imovel.idt_imovel)

FROM 
  usr_geocar_aplicacao.imovel, 
  usr_geocar_aplicacao.municipio, 
  usr_geocar_aplicacao.resposta_imovel
WHERE 
  resposta_imovel.idt_resposta_pergunta IN (1,2) AND flg_ativo = TRUE
AND ind_status_imovel in ('AT','PE') AND 
  imovel.idt_municipio = municipio.idt_municipio AND
  imovel.idt_imovel = resposta_imovel.idt_imovel
group by cod_estado,
idt_resposta_pergunta
;
