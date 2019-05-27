create table proc_sfb.mpf_quilombo_dados as

SELECT 
  mpf_quilombo_imoveis.idt_imovel, 
  mpf_quilombo_imoveis.cod_imovel, 
  mpf_quilombo_imoveis.ind_status_imovel, 
  mpf_quilombo_imoveis.ind_tipo_imovel, 
  mpf_quilombo_imoveis.idt_municipio, 
  mpf_quilombo_imoveis.nom_municipio, 
  mpf_quilombo_imoveis.cod_estado, 
  mpf_quilombo_imoveis.num_area_imovel, 
  mpf_quilombo_imoveis.num_modulo_fiscal, 
  mpf_quilombo_imoveis.dat_criacao, 
  mpf_quilombo_imoveis.dat_atualizacao, 
  mpf_quilombo_imoveis.des_condicao, 
  mpf_quilombo_imoveis.idt_condicao_inscricao, 
  mpf_quilombo_imoveis.nom_condicao_inscricao, 
  mpf_quilombo_imoveis.idt_instituicao_cancelamento, 
  mpf_quilombo_imoveis.motivo_cancelamento, 
  mpf_quilombo_imoveis.id, 
  mpf_quilombo_imoveis.nm_territ, 
  mpf_quilombo_imoveis.nm_municip, 
  mpf_quilombo_imoveis.org_expedi, 
  mpf_quilombo_imoveis.situacao, 
  imovel.cod_cpf_cadastrante, 
  imovel.nom_completo_cadastrante, 
  p1.id_pessoa, 
  p1.nm_pessoa, 
  p1.fl_tipo, 
  p1.tx_cpf_cnpj, 
  p1.tx_email, 
  p1.tx_telefone, 
  p1.tx_celular, 
  p1.id_endereco, 
  e1.tx_logradouro, 
  e1.tx_numero, 
  e1.tx_complemento, 
  e1.tx_bairro, 
  e1.tx_cep, 
  e1.id_municipio, 
  imovel.nom_imovel, 
  imovel.cod_cep, 
  imovel.des_acesso, 
  imovel.ind_zona_localizacao, 
  i2.idt_imovel_pessoa, 
  i2.ind_tipo_pessoa, 
  i2.cod_cpf_cnpj, 
  i2.nom_completo, 
  i2.dat_nascimento, 
  i2.nom_mae, 
  i2.cod_cpf_conjuge, 
  i2.nom_completo_conjuge, 
  i2.nom_fantasia, 
  p2.tx_cpf_cnpj as p2_tx_cpf_cnpj, 
  p2.tx_email as p2_tx_email, 
  p2.tx_telefone as p2_tx_telefone, 
  p2.tx_celular as p2_tx_celular, 
  p2.id_endereco as p2_id_endereco, 
  e2.tx_logradouro as p2_tx_logradouro, 
  e2.tx_numero as p2_tx_numero, 
  e2.tx_complemento as p2_tx_complemento, 
  e2.tx_bairro as p2_tx_bairro, 
  e2.tx_cep as p2_tx_cep, 
  e2.id_municipio as p2_id_municipio
FROM 
  geoserver.mpf_quilombo_imoveis, 
  usr_geocar_aplicacao.imovel_pessoa i2 left join
     portal_seguranca.pessoa p2  on
     REPLACE(REPLACE(REPLACE(p2.tx_cpf_cnpj,'.',''), '-',''),'/','')  = i2.cod_cpf_cnpj, 
  portal_seguranca.endereco e2, 
  portal_seguranca.endereco e1,
usr_geocar_aplicacao.imovel left join 
portal_seguranca.pessoa p1 on
 REPLACE(REPLACE(REPLACE(p1.tx_cpf_cnpj,'.',''), '-',''),'/','')  = imovel.cod_cpf_cadastrante 
  
WHERE 
  imovel.idt_imovel = mpf_quilombo_imoveis.idt_imovel AND
  i2.idt_imovel = imovel.idt_imovel AND
  p2.id_pessoa = u2.id_pessoa AND
  e2.id_endereco = p2.id_endereco AND
  u1.id_pessoa = p1.id_pessoa AND
  e1.id_endereco = p1.id_endereco;
