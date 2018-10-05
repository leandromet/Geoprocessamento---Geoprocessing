create table sfb_result.filtro_mt_1pp_r3 as
SELECT 
  qua.idt_imovel, 
  qua.ind_tipo_origem, 
  qua.ind_status_imovel, 
  qua.ind_tipo_imovel, 
  qua.num_area_imovel, 
  qua.num_area_reserva_legal_excedente_passivo, 
  qua.num_area_sobreposicao_ir, 
  qua.num_area_app_recompor, 
  qua.num_area_uc, 
  qua.num_area_ti, 
  qua.num_area_assentamento,
  num_area_embargada,
  round((qua.num_area_reserva_legal_excedente_passivo/qua.num_area_imovel)::numeric,3)*100 as prop_rl_exc_pass,
  round((qua.num_area_sobreposicao_ir/qua.num_area_imovel)::numeric,3)*100 as prop_sobreposicao,
  round((qua.num_area_uc/qua.num_area_imovel)::numeric,3)*100 as prop_uc,
  round((qua.num_area_ti/qua.num_area_imovel)::numeric,3)*100 as prop_ti,
  round((qua.num_area_assentamento/qua.num_area_imovel)::numeric,3)*100 as prop_assentamento,
  round((qua.num_area_embargada/qua.num_area_imovel)::numeric,3)*100 as prop_embargo
  
FROM 
  sfb_dados.quadro_mt qua;

ALTER TABLE sfb_result.filtro_mt_1pp_r3
  ADD CONSTRAINT idt_imovel_pk3 PRIMARY KEY(idt_imovel);
CREATE INDEX idt_imovel_idx3 ON sfb_result.filtro_mt_1pp_r3 USING BTREE (idt_imovel);​
