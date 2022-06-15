create table proc_sfb.caat_municipios as

 

SELECT 

  municipio.idt_municipio, 

  municipio.nom_municipio, 

  municipio.cod_estado, 

  municipio.geo_localizacao, 

  municipio.num_hectares_modulo_fiscal, 

  municipio.num_area, 

  geoadmin_5505_bioma.nome, 

  geoadmin_5505_bioma.idt_tipo_bioma

FROM 

  usr_geocar_aplicacao.municipio, 

  geo_admin_published_layers.geoadmin_5505_bioma

WHERE 

idt_tipo_bioma = 1 and

  st_intersects(geoadmin_5505_bioma.the_geom , municipio.geo_localizacao);

 

 

 

 

 

create table proc_sfb.caat_imoveis as

 

SELECT 

  caat_municipios.idt_municipio, 

  caat_municipios.nom_municipio, 

  caat_municipios.cod_estado, 

  imovel.idt_imovel, 

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

  proc_sfb.caat_municipios, 

  usr_geocar_aplicacao.imovel, 

  relatorio.quadro_area

WHERE 

  imovel.ind_status_imovel in ('AT', 'PE') and

  caat_municipios.idt_municipio = imovel.idt_municipio AND

  quadro_area.idt_imovel = imovel.idt_imovel;​

 

 

 

 

create table proc_sfb.caat_resumo_municipio as

SELECT 

  caat_imoveis_dist.cod_estado, 

  caat_imoveis_dist.idt_municipio, 

  caat_imoveis_dist.nom_municipio,

  caat_imoveis_dist.ind_tipo_imovel, 

  resposta_imovel.idt_resposta_pergunta, 

  count(caat_imoveis_dist.idt_imovel) as imoveis, 

  sum(caat_imoveis_dist.num_area_imovel) as area_ir, 

  sum(caat_imoveis_dist.num_nascente) as nacesentes, 

  sum(caat_imoveis_dist.num_area_reserva_legal) as area_rl, 

  sum(caat_imoveis_dist.num_proprietario_possuidor) as proprietarios, 

  sum(caat_imoveis_dist.num_area_reserva_legal_declarada) as rl_declarada, 

  sum(caat_imoveis_dist.num_area_reserva_legal_recompor) as rl_recompor, 

  sum(caat_imoveis_dist.num_area_preservacao_permanente) as area_app, 

  sum(caat_imoveis_dist.num_area_app_recompor) as app_recompor, 

  sum(caat_imoveis_dist.num_area_app_vegetacao_nativa) as app_rvn, 

  sum(caat_imoveis_dist.num_area_vegetacao_nativa) as area_rvn, 

  sum(caat_imoveis_dist.num_area_consolidada) as area_consol, 

  sum(caat_imoveis_dist.num_area_antropizada) as area_antrop, 

  sum(caat_imoveis_dist.num_area_sobreposicao_ir) as sobre_ir, 

  sum(caat_imoveis_dist.num_area_assentamento) as sobre_ast, 

  sum(caat_imoveis_dist.num_area_declarada) as area_declara, 

  sum(caat_imoveis_dist.num_area_embargada) as area_embargo

FROM 

  proc_sfb.caat_imoveis_dist left join 

  usr_geocar_aplicacao.resposta_imovel

  on resposta_imovel.idt_imovel = caat_imoveis_dist.idt_imovel

and

idt_resposta_pergunta<3

  

  group by

    caat_imoveis_dist.cod_estado, 

  caat_imoveis_dist.idt_municipio, 

  caat_imoveis_dist.nom_municipio, 

  caat_imoveis_dist.ind_tipo_imovel,

  resposta_imovel.idt_resposta_pergunta

  order by

    caat_imoveis_dist.cod_estado, 

  caat_imoveis_dist.idt_municipio, 

  caat_imoveis_dist.nom_municipio, 

  caat_imoveis_dist.ind_tipo_imovel,

  resposta_imovel.idt_resposta_pergunta;

 

 
