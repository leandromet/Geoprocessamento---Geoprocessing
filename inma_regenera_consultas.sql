
create table inma_regenera.regen_car_nascentes as select atlas_nascentes.* from car_publico.atlas_nascentes, inma_regenera.regen_geoft_bho_ach_otton_03
where st_intersects(atlas_nascentes.geom, regen_geoft_bho_ach_otton_03.geom)

create table inma_regenera.regen_car_imovel as select tema_simp_26_imovel.* from car_publico.tema_simp_26_imovel, inma_regenera.regen_geoft_bho_ach_otton_03
where st_intersects(tema_simp_26_imovel.geom, regen_geoft_bho_ach_otton_03.geom)

create table inma_regenera.regen_car_rvn as select tema_simp_2_rvn.* from car_publico.tema_simp_2_rvn, inma_regenera.regen_geoft_bho_ach_otton_03
where st_intersects(tema_simp_2_rvn.geom, regen_geoft_bho_ach_otton_03.geom)

create table inma_regenera.regen_car_consolidado as select tema_simp_1_consolidado.* from car_publico.tema_simp_1_consolidado, inma_regenera.regen_geoft_bho_ach_otton_03
where st_intersects(tema_simp_1_consolidado.geom, regen_geoft_bho_ach_otton_03.geom)

create table inma_regenera.regen_car_app as select tema_simp_30_app.* from car_publico.tema_simp_30_app, inma_regenera.regen_geoft_bho_ach_otton_03
where st_intersects(tema_simp_30_app.geom, regen_geoft_bho_ach_otton_03.geom)

create table 
regenera_otto4 as select * from 
geo_admin_published_layers.geoadmin_607_ottobacias 
where gid in (221,227,207,156,482,205,235,152,252,648,484,486,480,485,481,529,504,483)

create table 
regenera.regeneracao as select area_regeneracao.* from regenera_otto4,
base_referencia.area_regeneracao 
where st_intersects(st_transform(regenera_otto4.the_geom,4674), area_regeneracao.the_geom)

