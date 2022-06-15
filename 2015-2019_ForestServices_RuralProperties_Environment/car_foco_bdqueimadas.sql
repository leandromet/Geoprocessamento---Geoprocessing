create table proc_sfb.focos_car as select focos_2019_0722a0823.id,bioma,
idt_imovel, area_ha, municipio_ibge, cod_estado, mod_fiscal, 
tipo_imovel,  focos_2019_0722a0823.geom from
geoserver.tema_simp_26_imovel, proc_sfb.focos_2019_0722a0823
where st_intersects (tema_simp_26_imovel.geom, focos_2019_0722a0823.geom)
