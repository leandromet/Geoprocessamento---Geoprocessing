SELECT 
 replace(replace(substring(ctd_json_imovel from position('"mac' in ctd_json_imovel )+6 for 19), '"', ''), ',codigoProtocolo','null')
FROM 
  usr_geocar_aplicacao.imovel
limit 5

SSELECT 
  imovel.idt_imovel, 
  imovel.cod_imovel, 
   replace(replace(substring(ctd_json_imovel from position('"mac' in ctd_json_imovel )+6 for 19), '"', ''), ',codigoProtocolo','null') as mac_add,
     imovel.ind_tipo_origem, 
  imovel.cod_protocolo, 
  imovel.dat_protocolo, 
  imovel.ind_status_imovel, 
  imovel.ind_tipo_imovel, 
  imovel.cod_cpf_cadastrante, 
  imovel.nom_completo_cadastrante, 
  imovel.nom_imovel, 
  imovel.idt_municipio, 
  imovel.num_area_imovel, 
  imovel.num_modulo_fiscal, 
  imovel.dat_criacao, 
  imovel.dat_atualizacao, 
  ST_AsLatLonText(st_centroid(imovel.geo_area_imovel), 'D.DDDDDDD°C') as centroide,
  flg_ativo,
  flg_migracao,
  cod_cep,
  des_acesso,
idt_condicao_inscricao,
dat_cadastro_estadual,
  historico_imovel.ind_tipo_responsavel, 
  historico_imovel.idt_usuario_responsavel, 
  historico_imovel.des_ip_responsavel, 
  historico_imovel.des_observacoes, 
  historico_imovel.dat_criacao
FROM 
  usr_geocar_aplicacao.imovel,
    usr_geocar_aplicacao.historico_imovel
WHERE 
imovel.idt_municipio = 1400472 and
  historico_imovel.idt_imovel = imovel.idt_imovel
  limit 5;

