select cod_estado, sum (area_ha) from car_publico.tema_simp_26_imovel group by cod_estado order by cod_estado


select sum (area_ha) from car_publico.tema_simp_26_imovel

select sum (area_ha) from inma_processamento.car_int_sigef_dist



create table inma_processamento.car_int_sigef_dist as select distinct on (idt_imovel)  idt_imovel,id , area_ha, tipo_imovel, parcela_co, rt, art, situacao_i, codigo_imo, status, simplif_2m_sigef.geom

from inma_processamento.simplif_2m_sigef, car_publico.tema_simp_26_imovel where st_intersects (tema_simp_26_imovel.geom,simplif_2m_sigef.geom )


create table inma_processamento.sigef_int_car_dist as select distinct on (id) id , idt_imovel, area_ha, tipo_imovel, parcela_co, rt, art, situacao_i, codigo_imo, status, simplif_2m_sigef.geom

from inma_processamento.simplif_2m_sigef, car_publico.tema_simp_26_imovel where st_intersects (tema_simp_26_imovel.geom,simplif_2m_sigef.geom )


create table inma_processamento.sigef_int_car_dist as select distinct(id), idt_imovel, area_ha, tipo_imovel, parcela_co, rt, art, situacao_i, codigo_imo, status, simplif_2m_sigef.geom

from inma_processamento.simplif_2m_sigef, car_publico.tema_simp_26_imovel where st_intersects (tema_simp_26_imovel.geom,simplif_2m_sigef.geom )




select cod_estado, tipo_imovel, count(idt_imovel) as registros , sum (area_ha) as area from
car_publico.tema_simp_26_imovel group by cod_estado, tipo_imovel order by cod_estado, tipo_imovel

select cod_estado, tema_simp_26_imovel.tipo_imovel, count(tema_simp_26_imovel.idt_imovel) as registros , sum (tema_simp_26_imovel.area_ha) as area 
from inma_processamento.car_int_sigef_dist,car_publico.tema_simp_26_imovel where 
car_int_sigef_dist.idt_imovel = tema_simp_26_imovel.idt_imovel group by cod_estado, tema_simp_26_imovel.tipo_imovel order by cod_estado, tema_simp_26_imovel.tipo_imovel


select cod_estado, tema_simp_26_imovel.tipo_imovel, count(tema_simp_26_imovel.idt_imovel) as registros , sum (tema_simp_26_imovel.area_ha) as area 
from inma_processamento.sigef_int_car_dist,car_publico.tema_simp_26_imovel where 
sigef_int_car_dist.idt_imovel = tema_simp_26_imovel.idt_imovel group by cod_estado, tema_simp_26_imovel.tipo_imovel order by cod_estado, tema_simp_26_imovel.tipo_imovel
