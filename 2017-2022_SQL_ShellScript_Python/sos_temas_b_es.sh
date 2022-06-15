#!/bin/sh


while read line 
	do 

	echo $line

ogr2ogr -f "SQLite" -update -append  es.sqlite PG:"host=10.20.20.144 user=sfb dbname=car_nacional"  -sql "SELECT    rel_tema_imovel_poligono.idt_imovel,    rel_tema_imovel_poligono.idt_rel_tema_imovel,    rel_tema_imovel_poligono.num_area,    rel_tema_imovel_poligono.idt_tema,    rel_tema_imovel_poligono.the_geom,  municipio.idt_municipio,  municipio.cod_estado FROM    usr_geocar_aplicacao.rel_tema_imovel_poligono,    usr_geocar_aplicacao.imovel,    usr_geocar_aplicacao.municipio WHERE municipio.idt_municipio = $line and  idt_tema = 1 and imovel.ind_status_imovel in ('AT','PE') AND rel_tema_imovel_poligono.idt_imovel = imovel.idt_imovel AND   municipio.idt_municipio = imovel.idt_municipio    " -nln imoveis -nlt MULTIPOLYGON

ogr2ogr -f "SQLite" -update -append   es.sqlite PG:"host=10.20.20.144 user=sfb dbname=car_nacional"  -sql "SELECT    rel_tema_imovel_poligono.idt_imovel,    rel_tema_imovel_poligono.idt_rel_tema_imovel,    rel_tema_imovel_poligono.num_area,    rel_tema_imovel_poligono.idt_tema,    rel_tema_imovel_poligono.the_geom,  municipio.idt_municipio,  municipio.cod_estado FROM    usr_geocar_aplicacao.rel_tema_imovel_poligono,    usr_geocar_aplicacao.imovel,    usr_geocar_aplicacao.municipio WHERE municipio.idt_municipio = $line and  idt_tema = 1 and imovel.ind_status_imovel in ('AT','PE') AND rel_tema_imovel_poligono.idt_imovel = imovel.idt_imovel AND   municipio.idt_municipio = imovel.idt_municipio    " -nln consolidado -nlt MULTIPOLYGON

ogr2ogr -f "SQLite" -update -append   es.sqlite PG:"host=10.20.20.144 user=sfb dbname=car_nacional"  -sql "SELECT    rel_tema_imovel_poligono.idt_imovel,    rel_tema_imovel_poligono.idt_rel_tema_imovel,    rel_tema_imovel_poligono.num_area,    rel_tema_imovel_poligono.idt_tema,    rel_tema_imovel_poligono.the_geom,  municipio.idt_municipio,  municipio.cod_estado FROM    usr_geocar_aplicacao.rel_tema_imovel_poligono,    usr_geocar_aplicacao.imovel,    usr_geocar_aplicacao.municipio WHERE municipio.idt_municipio = $line and  idt_tema = 2 and imovel.ind_status_imovel in ('AT','PE') AND rel_tema_imovel_poligono.idt_imovel = imovel.idt_imovel AND   municipio.idt_municipio = imovel.idt_municipio    " -nln remanescente -nlt MULTIPOLYGON

ogr2ogr -f "SQLite" -update -append   es.sqlite PG:"host=10.20.20.144 user=sfb dbname=car_nacional"  -sql "SELECT    rel_tema_imovel_poligono.idt_imovel,    rel_tema_imovel_poligono.idt_rel_tema_imovel,    rel_tema_imovel_poligono.num_area,    rel_tema_imovel_poligono.idt_tema,    rel_tema_imovel_poligono.the_geom,  municipio.idt_municipio,  municipio.cod_estado FROM    usr_geocar_aplicacao.rel_tema_imovel_poligono,    usr_geocar_aplicacao.imovel,    usr_geocar_aplicacao.municipio WHERE municipio.idt_municipio = $line and  idt_tema = 3 and imovel.ind_status_imovel in ('AT','PE') AND rel_tema_imovel_poligono.idt_imovel = imovel.idt_imovel AND   municipio.idt_municipio = imovel.idt_municipio    " -nln pousio -nlt MULTIPOLYGON


done < /rede/image03/extracoes/mata_atl/municipios_es.txt


