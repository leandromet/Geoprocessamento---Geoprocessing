
SELECT 



idt_resposta_pergunta,
municipio.cod_estado,
count(imovel.idt_imovel) as imoveis ,
sum(imovel.num_area_imovel) as area_imovel,
sum(quadro_area.num_area_liquida_imovel) as area_liquida,
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
sum(quadro_area.num_area_reserva_legal_recompor) as a_rl_recompor ,
sum(quadro_area.num_area_uso_restrito_recompor) as a_restrito_recompor ,
sum(quadro_area.num_area_preservacao_permanente) as a_app ,
sum(quadro_area.num_area_uso_restrito) as a_restrito ,
sum(quadro_area.num_area_hidrografia) as a_hidrografia ,
sum(quadro_area.num_area_reserva_legal) as a_rl ,
sum(quadro_area.num_area_reserva_legal_declarada) as a_rl_declarada ,
sum(quadro_area.num_area_app_nascente) as a_nascente

FROM
usr_geocar_aplicacao.imovel,
relatorio.quadro_area,
usr_geocar_aplicacao.municipio,
 usr_geocar_aplicacao.resposta_imovel
WHERE
(num_area_app_recompor > 0 or num_area_reserva_legal_recompor > 0 or num_area_reserva_legal_recompor_area_consolidada > 0 
 or num_area_reserva_legal_recompor_area_antropizada > 0 or
num_area_uso_restrito_recompor > 0 ) and
imovel.ind_status_imovel in ('AT','PE') AND imovel.flg_ativo = TRUE and resposta_imovel.idt_resposta_pergunta IN (1,2) and
  imovel.idt_imovel = resposta_imovel.idt_imovel and
quadro_area.idt_imovel = imovel.idt_imovel AND
municipio.idt_municipio = imovel.idt_municipio
group by municipio.cod_estado, idt_resposta_pergunta
order by municipio.cod_estado, idt_resposta_pergunta;
