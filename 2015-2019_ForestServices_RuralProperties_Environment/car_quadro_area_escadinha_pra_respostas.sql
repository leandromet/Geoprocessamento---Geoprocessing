
SELECT 



idt_resposta_pergunta,
municipio.cod_estado,
count(imovel.idt_imovel) as imoveis ,
sum(imovel.num_area_imovel) as area_imovel,
sum(quadro_area.num_area_liquida_imovel) as area_liquida,
sum(quadro_area.num_area_reserva_legal_proposta) as rl_prop,
sum(quadro_area.num_area_reserva_legal_averbada) as rl_averb,
sum(quadro_area.num_area_reserva_legal_aprovada_nao_averbada) as rl_ap_naverb,
sum(quadro_area.num_area_reserva_legal_minima_lei) as rl_minlei,
sum(quadro_area.num_area_reserva_legal_excedente_passivo) as esc_pass,
sum(quadro_area.num_area_app_area_consolidada) as a_app_consolidada,
sum(quadro_area.num_area_app_area_antropizada) as a_app_antropizada,
sum(quadro_area.num_area_app_recompor) as a_app_recompor ,
sum(quadro_area.num_area_app_vegetacao_nativa) as a_app_rvn ,
sum(quadro_area.num_area_reserva_legal_recompor_area_consolidada) as a_rl_rec_cons ,
sum(quadro_area.num_area_reserva_legal_recompor_area_antropizada) as a_rl_rec_antrop ,
sum(quadro_area.num_area_reserva_legal_app) as a_rl_app ,
sum(quadro_area.num_area_reserva_legal_vegetacao_nativa) as a_rl_rvn ,
sum(quadro_area.num_area_uso_restrito_area_consolidada) as a_restrito_cons ,
sum(quadro_area.num_area_uso_restrito_area_antropizada) as a_restrito_antrop ,
sum(quadro_area.num_area_uso_restrito_vegetacao_nativa) as a_restrito_rvn ,
sum(quadro_area.num_area_vegetacao_nativa) as a_rvn ,
sum(quadro_area.num_area_consolidada) as a_consolidada ,
sum(quadro_area.num_area_antropizada) as a_antropizada ,
sum(quadro_area.num_area_pousio) as a_pousio ,
sum(quadro_area.num_area_sobreposicao_ir) as a_sobrep_ir ,
sum(quadro_area.num_area_uc) as a_uc ,
sum(quadro_area.num_area_ti) as a_ti ,
sum(quadro_area.num_area_assentamento) as a_assent ,
sum(quadro_area.num_area_servidao_administrativa) as a_servidao ,
sum(quadro_area.num_area_rl_compensada_terceiro_ir) as a_rl_compens_terc_ir ,
sum(quadro_area.num_area_rl_compensada_ir_terceiro) as a_rl_compens_terc ,
sum(quadro_area.num_area_reserva_legal_recompor) as a_rl_recompor ,
sum(quadro_area.num_area_uso_restrito_recompor) as a_restrito_recompor ,
sum(quadro_area.num_area_preservacao_permanente) as a_app ,
sum(quadro_area.num_area_uso_restrito) as a_restrito ,
sum(quadro_area.num_area_hidrografia) as a_hidrografia ,
sum(quadro_area.num_area_reserva_legal) as a_rl ,
sum(quadro_area.num_area_reserva_legal_declarada) as a_rl_declarada ,
sum(quadro_area.num_area_app_banhado) as a_banhado ,
sum(quadro_area.num_area_app_lago_lagoa_natural) as a_lagoa ,
sum(quadro_area.num_area_app_nascente) as a_nascente ,
sum(num_area_app_escadinha_vereda) as a_appesc_vereda ,
sum(num_area_app_manguezal) as a_app_mangue,
sum(num_area_app_restinga) as a_app_restinga,
sum(num_area_declarada) as a_declarada,
sum(num_area_embargada) as a_embargada,
sum(num_area_uso_restrito_declividade) as a_rest_decliv,
sum(num_area_uso_restrito_pantaneira) as a_rest_pantaneira,
sum(num_area_ur_recompor_declividade) as a_ur_recomp_decliv,
sum(num_area_ur_recompor_pantaneira) as a_ur_recompor_pantan,
sum(num_area_sa_entorno_reservatorio) as a_sa_ent_reservatorio,
sum(num_area_sa_reservatorio) as a_sa_reservat,
sum(num_area_sa_infraestrutura_publica) as a_sa_infra_pub,
sum(num_area_sa_utilidade_publica) as a_sa_util_pub
sum(num_area_app_escadinha_lago_lagoa_natural) as esc_app_lago ,
sum(num_area_app_escadinha_nascente) as esc_app_nasc ,
sum(num_area_app_escadinha_rio_ate_10)  as esc_app_rio10,
sum(num_area_app_escadinha_rio_10_a_50)  as esc_app_rio50,
sum(num_area_app_escadinha_rio_50_a_200)  as esc_app_rio200,
sum(num_area_app_escadinha_rio_200_a_600)  as esc_app_rio600,
sum(num_area_app_escadinha_rio_acima_600)  as esc_app_rio_acima600,
sum(num_area_app_escadinha_vereda) as esc_app_vereda



FROM
usr_geocar_aplicacao.imovel,
relatorio.quadro_area,
usr_geocar_aplicacao.municipio,
 usr_geocar_aplicacao.resposta_imovel
WHERE
imovel.ind_status_imovel in ('AT','PE') AND imovel.flg_ativo = TRUE and resposta_imovel.idt_resposta_pergunta IN (1,2) and
  imovel.idt_imovel = resposta_imovel.idt_imovel and
quadro_area.idt_imovel = imovel.idt_imovel AND
municipio.idt_municipio = imovel.idt_municipio
group by municipio.cod_estado, idt_resposta_pergunta
order by municipio.cod_estado, idt_resposta_pergunta;
