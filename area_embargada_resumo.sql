create table proc_sfb.embargos_dados as

SELECT 
  imovel.idt_imovel, 
  imovel.cod_imovel, 
  imovel.ind_status_imovel, 
  imovel.ind_tipo_imovel, 
  imovel.num_area_imovel, 
  imovel.num_modulo_fiscal, 
  imovel.dat_criacao, 
  imovel.dat_atualizacao, 
  imovel.geo_area_imovel as geom, 
  quadro_area.num_area_reserva_legal_proposta, 
  quadro_area.num_area_reserva_legal_averbada, 
  quadro_area.num_area_reserva_legal_aprovada_nao_averbada, 
  quadro_area.num_area_reserva_legal_minima_lei, 
  quadro_area.num_area_vegetacao_nativa, 
  quadro_area.num_area_reserva_legal, 
  quadro_area.num_area_preservacao_permanente, 
  quadro_area.num_area_embargada, 
  imovel.flg_ativo, 
  imovel.flg_migracao, 
  imovel.des_condicao, 
  imovel.idt_condicao_inscricao, 
  municipio.idt_municipio, 
  municipio.nom_municipio, 
  municipio.cod_estado
FROM 
  usr_geocar_aplicacao.imovel, 
  relatorio.quadro_area, 
  usr_geocar_aplicacao.municipio
WHERE 
num_area_embargada > 0 and
  quadro_area.idt_imovel = imovel.idt_imovel AND
  municipio.idt_municipio = imovel.idt_municipio;
