create table proc_sfb.resumo_amazonia as

SELECT 
cod_estado,
count(idt_imovel) as imoveis ,
sum(num_area_imovel) as area_imovel, 
sum(num_area_reserva_legal_proposta) as rl_prop, 
sum(num_area_reserva_legal_averbada) as rl_averb, 
sum(num_area_reserva_legal_aprovada_nao_averbada) as rl_ap_naverb, 
sum(num_area_app_recompor) as a_app_recompor ,
sum(num_area_app_vegetacao_nativa) as a_app_rvn ,
sum(num_area_reserva_legal_vegetacao_nativa) as a_rl_rvn ,
sum(num_area_vegetacao_nativa) as a_rvn ,
sum(num_area_consolidada) as a_consolidada ,
sum(num_area_antropizada) as a_antropizada ,
sum(num_area_pousio) as a_pousio ,
sum(num_area_preservacao_permanente) as a_app ,
sum(num_area_reserva_legal) as a_rl,
sum(num_area_reserva_legal_minima_lei) as rl_minlei, 
sum(num_area_reserva_legal_excedente_passivo) as esc_pass, 
sum(num_area_reserva_legal_recompor_area_consolidada) as a_rl_rec_cons ,
sum(num_area_reserva_legal_recompor_area_antropizada) as a_rl_rec_antrop


FROM (
select distinct on (idt_imovel) imovel.idt_imovel,
cod_estado,
imovel.num_area_imovel, 
num_area_reserva_legal_proposta,
num_area_reserva_legal_averbada, 
num_area_reserva_legal_aprovada_nao_averbada,
num_area_app_recompor,
num_area_app_vegetacao_nativa,
num_area_reserva_legal_vegetacao_nativa,
num_area_vegetacao_nativa,
num_area_consolidada,
num_area_antropizada,
num_area_pousio,
num_area_preservacao_permanente,
num_area_reserva_legal,
num_area_reserva_legal_minima_lei,
num_area_reserva_legal_excedente_passivo,
num_area_reserva_legal_recompor_area_consolidada,
num_area_reserva_legal_recompor_area_antropizada

FROM
usr_geocar_aplicacao.municipio,
usr_geocar_aplicacao.imovel, 
relatorio.quadro_area,
geo_admin_published_layers.geoadmin_5505_bioma

WHERE 
geoadmin_5505_bioma.idt_tipo_bioma = 5 and
st_intersects(imovel.geo_area_imovel, geoadmin_5505_bioma.the_geom) and
imovel.ind_status_imovel in ('AT','PE') AND
imovel.idt_municipio = municipio.idt_municipio and
quadro_area.idt_imovel = imovel.idt_imovel ) tabela
group by cod_estado
