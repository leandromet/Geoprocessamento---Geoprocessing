update geoserver.reman_veg_nativa set  area = st_area(geom::geography)/10000

select estado, sum (area) from geoserver.reman_veg_nativa group by estado



update geoserver.area_consolidada set area = st_area(geom::geography)/10000
