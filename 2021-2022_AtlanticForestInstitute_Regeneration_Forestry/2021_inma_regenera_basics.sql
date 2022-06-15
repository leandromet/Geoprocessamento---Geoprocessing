update inma_regenera.regen_ibge_br_mi_250gc_2018 set area_ha = st_area(st_transform(geom, 31984))/1000

