
select count (*), bioma from proc_sfb.focos_car_unicos group by bioma


select count (id), pais, bioma from proc_sfb.focos_2019_0722a0823
group by pais, bioma order by pais, bioma



create table focos_2019_amz_unicos as 

select distinct on (focos_2019_amz.id)  * from proc_sfb.focos_2019_amz 



create table proc_sfb.focos_2019_amz_car_unicos_dat as

select distinct on (focos_2019_amz_car.id)  focos_2019_0722a0823.id, datahora, focos_2019_0722a0823.geom,idt_imovel from proc_sfb.focos_2019_amz_car , proc_sfb.focos_2019_0722a0823
where focos_2019_amz_car.id = focos_2019_0722a0823.id




create table proc_sfb.focos_2019_amz_car as select focos_2019_amz.id,bioma,
idt_imovel, area_ha, municipio_ibge, cod_estado, mod_fiscal, 
tipo_imovel,  focos_2019_amz.geom from
geoserver.tema_simp_26_imovel, proc_sfb.focos_2019_amz
where st_intersects (tema_simp_26_imovel.geom, focos_2019_amz.geom)


create table proc_sfb.focos_car as select focos_2019_0722a0823.id,bioma,
idt_imovel, area_ha, municipio_ibge, cod_estado, mod_fiscal, 
tipo_imovel,  focos_2019_0722a0823.geom from
geoserver.tema_simp_26_imovel, proc_sfb.focos_2019_0722a0823
where st_intersects (tema_simp_26_imovel.geom, focos_2019_0722a0823.geom)





SELECT "focos_2019_car"."bioma",Count(*) 
FROM "focos_2019_car"
GROUP BY "focos_2019_car"."bioma"




create table proc_sfb.focos_class_consol as select distinct(focos_2019_0722a0823.id), gid, bioma,
datahora,  focos_2019_0722a0823.geom from
base_referencia.area_consolidada , proc_sfb.focos_2019_0722a0823
where  st_intersects(area_consolidada.the_geom, focos_2019_0722a0823.geom)



create table proc_sfb.focos_class_antrop as select distinct(focos_2019_0722a0823.id), gid, bioma,
datahora,  focos_2019_0722a0823.geom from
base_referencia.area_antropizada_apos_2008 , proc_sfb.focos_2019_0722a0823
where  st_intersects(area_antropizada_apos_2008.the_geom, focos_2019_0722a0823.geom)




create table proc_sfb.focos_class_regen_car as select distinct(id), gid, bioma,idt_imovel,
datahora,  focos_class_regen.geom from
proc_sfb.focos_class_regen , geoserver.tema_simp_26_imovel
where  st_intersects(focos_class_regen.geom, tema_simp_26_imovel.geom)




create table proc_sfb.focos_class_rvn_car as select distinct(id), gid, bioma,idt_imovel,
datahora,  focos_class_rvn.geom from
proc_sfb.focos_class_rvn , geoserver.tema_simp_26_imovel
where  st_intersects(focos_class_rvn.geom, tema_simp_26_imovel.geom)




create table proc_sfb.focos_class_antrop_car as select distinct(id), gid, bioma,idt_imovel,
datahora,  focos_class_antrop.geom from
proc_sfb.focos_class_antrop , geoserver.tema_simp_26_imovel
where  st_intersects(focos_class_antrop.geom, tema_simp_26_imovel.geom)




create table proc_sfb.focos_class_consol_car as select distinct(id), gid, bioma,idt_imovel,
datahora,  focos_class_consol.geom from
proc_sfb.focos_class_consol , geoserver.tema_simp_26_imovel
where  st_intersects(focos_class_consol.geom, tema_simp_26_imovel.geom)


create table proc_sfb.focos_class_consol_car_rl as select distinct(id), gid, bioma,focos_class_consol_car.idt_imovel,
datahora,  focos_class_consol_car.geom from
proc_sfb.focos_class_consol_car , geoserver.tema_simp_32_rl
where  st_intersects(focos_class_consol_car.geom, tema_simp_32_rl.geom)
