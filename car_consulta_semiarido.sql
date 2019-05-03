create table proc_sfb.semi_arido_imoveis_dist as

 

SELECT distinct (imovel.idt_imovel) as idt_imovel,

  semi_arido_municipios.cd_geocmu::integer as idt_municipio, 

  semi_arido_municipios.nm_municip as nom_municipio, 

  semi_arido_municipios.uf as cod_estado, 

  imovel.cod_imovel, 

  imovel.ind_status_imovel, 

  imovel.ind_tipo_imovel, 

  imovel.nom_imovel, 

  imovel.num_area_imovel, 

  imovel.num_modulo_fiscal, 

  imovel.dat_criacao, 

  imovel.dat_atualizacao, 

  imovel.geo_area_imovel, 

  quadro_area.num_nascente, 

  quadro_area.num_area_reserva_legal, 

  quadro_area.num_proprietario_possuidor, 

  quadro_area.num_area_reserva_legal_declarada, 

  quadro_area.num_area_reserva_legal_recompor, 

  quadro_area.num_area_preservacao_permanente, 

  quadro_area.num_area_app_recompor, 

  quadro_area.num_area_app_vegetacao_nativa, 

  quadro_area.num_area_vegetacao_nativa, 

  quadro_area.num_area_consolidada, 

  quadro_area.num_area_antropizada, 

  quadro_area.num_area_sobreposicao_ir, 

  quadro_area.num_area_assentamento, 

  quadro_area.num_area_declarada, 

  quadro_area.num_area_embargada

FROM 

  proc_sfb.semi_arido_municipios, 

  usr_geocar_aplicacao.imovel, 

  relatorio.quadro_area

WHERE 

  imovel.ind_status_imovel in ('AT', 'PE') and

  semi_arido_municipios.cd_geocmu::integer = imovel.idt_municipio AND

  quadro_area.idt_imovel = imovel.idt_imovel;

 

 

create table proc_sfb.semi_arido_resumo_municipio as

SELECT 

  semi_arido_imoveis_dist.cod_estado, 

  semi_arido_imoveis_dist.idt_municipio, 

  semi_arido_imoveis_dist.nom_municipio,

  semi_arido_imoveis_dist.ind_tipo_imovel, 

  resposta_imovel.idt_resposta_pergunta, 

  count(semi_arido_imoveis_dist.idt_imovel) as imoveis, 

  sum(semi_arido_imoveis_dist.num_area_imovel) as area_ir, 

  sum(semi_arido_imoveis_dist.num_nascente) as nacesentes, 

  sum(semi_arido_imoveis_dist.num_area_reserva_legal) as area_rl, 

  sum(semi_arido_imoveis_dist.num_proprietario_possuidor) as proprietarios, 

  sum(semi_arido_imoveis_dist.num_area_reserva_legal_declarada) as rl_declarada, 

  sum(semi_arido_imoveis_dist.num_area_reserva_legal_recompor) as rl_recompor, 

  sum(semi_arido_imoveis_dist.num_area_preservacao_permanente) as area_app, 

  sum(semi_arido_imoveis_dist.num_area_app_recompor) as app_recompor, 

  sum(semi_arido_imoveis_dist.num_area_app_vegetacao_nativa) as app_rvn, 

  sum(semi_arido_imoveis_dist.num_area_vegetacao_nativa) as area_rvn, 

  sum(semi_arido_imoveis_dist.num_area_consolidada) as area_consol, 

  sum(semi_arido_imoveis_dist.num_area_antropizada) as area_antrop, 

  sum(semi_arido_imoveis_dist.num_area_sobreposicao_ir) as sobre_ir, 

  sum(semi_arido_imoveis_dist.num_area_assentamento) as sobre_ast, 

  sum(semi_arido_imoveis_dist.num_area_declarada) as area_declara, 

  sum(semi_arido_imoveis_dist.num_area_embargada) as area_embargo

FROM 

  proc_sfb.semi_arido_imoveis_dist left join 

  usr_geocar_aplicacao.resposta_imovel

  on resposta_imovel.idt_imovel = semi_arido_imoveis_dist.idt_imovel

and

idt_resposta_pergunta<3

  

  group by

    semi_arido_imoveis_dist.cod_estado, 

  semi_arido_imoveis_dist.idt_municipio, 

  semi_arido_imoveis_dist.nom_municipio, 

  semi_arido_imoveis_dist.ind_tipo_imovel,

  resposta_imovel.idt_resposta_pergunta

  order by

    semi_arido_imoveis_dist.cod_estado, 

  semi_arido_imoveis_dist.idt_municipio, 

  semi_arido_imoveis_dist.nom_municipio, 

  semi_arido_imoveis_dist.ind_tipo_imovel,

  resposta_imovel.idt_resposta_pergunta;

 
