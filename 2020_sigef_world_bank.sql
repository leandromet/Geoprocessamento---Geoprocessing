create table inma_processamento.simplif_2m_sigef as select id, parcela_co, rt, art, situacao_i, codigo_imo, status, ST_SimplifyPreserveTopology(geom, 0.00002)

from dados_externos.incra_sigef_20200203



select cod_estado, sum (area_ha) from car_publico.tema_simp_26_imovel group by cod_estado order by cod_estado


create table inma_processamento.sigef_int_car_dist as select distinct on (id) id , idt_imovel, area_ha, tipo_imovel, parcela_co, rt, art, situacao_i, codigo_imo, status, simplif_2m_sigef.geom

from inma_processamento.simplif_2m_sigef, car_publico.tema_simp_26_imovel where st_intersects (tema_simp_26_imovel.geom,simplif_2m_sigef.geom )


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



create table inma_processamento.incra_uf as select nm_estado, cd_geocuf, incra_sigef_20200203.id, situacao_i, status, municipio_ as municipio from
dados_externos.ibge_br_uf_250gc_2018, dados_externos.incra_sigef_20200203 where uf_id = cd_geocuf::integer


select nm_estado, count(id), situacao_i, status from
inma_processamento.incra_uf group by nm_estado,situacao_i, status order by nm_estado,situacao_i, status


create table inma_processamento.car_int_sigef_dist_not_touche as select distinct on (idt_imovel)  idt_imovel,id ,
area_ha, tipo_imovel, parcela_co, rt, art, situacao_i, codigo_imo, status
from inma_processamento.simplif_2m_sigef, car_publico.tema_simp_26_imovel where
st_intersects (tema_simp_26_imovel.geom,simplif_2m_sigef.geom ) and
not st_touches (st_buffer(tema_simp_26_imovel.geom,0),st_buffer(simplif_2m_sigef.geom,0) ) 




create table inma_processamento.intersection_sigef_car as select
sigef_int_car_dist.idt_imovel, sigef_int_car_dist.id, sigef_int_car_dist.area_ha,
sigef_int_car_dist.tipo_imovel, cod_estado, ST_intersection(car_int_sigef_dist.geom,sigef_int_car_dist.geom )
from inma_processamento.car_int_sigef_dist, inma_processamento.sigef_int_car_dist, car_publico.tema_simp_26_imovel
where car_int_sigef_dist.idt_imovel = tema_simp_26_imovel.idt_imovel and
st_intersects(car_int_sigef_dist.geom,sigef_int_car_dist.geom ) and 
not st_touches(car_int_sigef_dist.geom,sigef_int_car_dist.geom )


create table inma_processamento.intersection_sigef_car_100k as select
sigef_int_car_dist.idt_imovel, sigef_int_car_dist.id, sigef_int_car_dist.area_ha,
sigef_int_car_dist.tipo_imovel, cod_estado, ST_intersection(car_int_sigef_distg.geom,sigef_int_car_dist.geom ) as geom
from inma_processamento.car_int_sigef_distg, inma_processamento.sigef_int_car_dist, car_publico.tema_simp_26_imovel
where st_isvalid(car_int_sigef_distg.geom) and st_isvalid(sigef_int_car_dist.geom) and car_int_sigef_distg.idt_imovel = tema_simp_26_imovel.idt_imovel and
st_intersects(car_int_sigef_distg.geom,sigef_int_car_dist.geom ) 
