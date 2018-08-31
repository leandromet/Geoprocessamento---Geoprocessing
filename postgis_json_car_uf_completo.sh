#!/bin/sh


for estado in AC AL AP AM CE DF ES GO MA MS MG PA PB PR PE PI RJ RN RS RR SC SP SE TO RO MT BA
do
print $estado

ogr2ogr -f "GeoJSON"  pessoal_br_nomes_20180414_$estado.json PG:"host=172.16.32.248 user=postgres dbname=car_nacional201804"  -sql "SELECT  municipio.cod_estado,  imovel_pessoa.idt_imovel,  imovel_pessoa.ind_tipo_pessoa,  imovel_pessoa.cod_cpf_cnpj,  imovel_pessoa.nom_completo,  imovel.ind_status_imovel,  imovel.ind_tipo_imovel,  documento_imovel.idt_documento_imovel,  tipo_documento.cod_tipo_documento FROM  usr_geocar_aplicacao.imovel,  usr_geocar_aplicacao.municipio,  usr_geocar_aplicacao.imovel_pessoa,  usr_geocar_aplicacao.tipo_documento,  usr_geocar_aplicacao.documento_imovel, ST_centroid(imovel.geo_area_imovel) as geom WHERE cod_estado = '$estado' and municipio.idt_municipio = imovel.idt_municipio AND imovel_pessoa.idt_imovel = imovel.idt_imovel AND tipo_documento.idt_tipo_documento = documento_imovel.ind_tipo_documento AND documento_imovel.idt_imovel = imovel.idt_imovel  order by municipio.cod_estado, cod_tipo_documento" -nln nomes -nlt point

ogr2ogr -f "GeoJSON" -update -append  publico_br_imoveis_20180414_$estado.json PG:"host=172.16.32.248 user=postgres dbname=car_nacional201804"  -sql "SELECT    imovel.idt_imovel, imovel.cod_imovel, imovel.cod_protocolo, imovel.dat_protocolo, imovel.ind_status_imovel, imovel.ind_tipo_imovel, imovel.dat_criacao, imovel.dat_atualizacao,  imovel.num_area_imovel as area_imovel,   imovel.num_modulo_fiscal as num_mf, municipio.idt_municipio as geocodigo,    municipio.cod_estado,    rel_tema_imovel_poligono.the_geom as geom FROM    usr_geocar_aplicacao.imovel,    usr_geocar_aplicacao.municipio,    usr_geocar_aplicacao.rel_tema_imovel_poligono,    usr_geocar_aplicacao.tema WHERE  cod_estado = '$estado' and  tema.idt_tema = 26 AND   municipio.idt_municipio = imovel.idt_municipio AND   rel_tema_imovel_poligono.idt_imovel = imovel.idt_imovel AND   tema.idt_tema = rel_tema_imovel_poligono.idt_tema order by municipio.cod_estado" -nln imoveis -nlt MULTIPOLYGON

for contar in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40
do
print 'Tema: ' $contar


ogr2ogr -f "GeoJSON" -update -append  pub_br_usosolo_20180414_$estado$contar.json PG:"host=172.16.32.248 user=postgres dbname=car_nacional201804"  -sql "SELECT     municipio.cod_estado,municipio.idt_municipio, imovel.idt_imovel,   rel_tema_imovel_poligono.idt_tema,    tema.nom_tema,  imovel.num_area_imovel as area_imovel, rel_tema_imovel_poligono.num_area as area_tema,   municipio.idt_municipio,   rel_tema_imovel_poligono.the_geom FROM    usr_geocar_aplicacao.imovel,    usr_geocar_aplicacao.municipio,    usr_geocar_aplicacao.rel_tema_imovel_poligono,    usr_geocar_aplicacao.tema WHERE  cod_estado = '$estado' and  imovel.ind_status_imovel IN ('AT','PE') AND tema.idt_tema = $contar AND   municipio.idt_municipio = imovel.idt_municipio AND   rel_tema_imovel_poligono.idt_imovel = imovel.idt_imovel AND   tema.idt_tema = rel_tema_imovel_poligono.idt_tema AND GeometryType(the_geom)='MULTIPOLYGON';" -nln tema_$contar

done

for contar in 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 80 81 82 83 84
do
print 'Tema: ' $contar


ogr2ogr -f "GeoJSON" -update -append  pub_br_usosolo_20180414_$estado$contar.json PG:"host=172.16.32.248 user=postgres dbname=car_nacional201804"  -sql "SELECT     municipio.cod_estado,municipio.idt_municipio, imovel.idt_imovel,   rel_tema_imovel_poligono.idt_tema,    tema.nom_tema,  imovel.num_area_imovel as area_imovel, rel_tema_imovel_poligono.num_area as area_tema,   municipio.idt_municipio,   rel_tema_imovel_poligono.the_geom FROM    usr_geocar_aplicacao.imovel,    usr_geocar_aplicacao.municipio,    usr_geocar_aplicacao.rel_tema_imovel_poligono,    usr_geocar_aplicacao.tema WHERE  cod_estado = '$estado' and  imovel.ind_status_imovel IN ('AT','PE') AND tema.idt_tema = $contar AND   municipio.idt_municipio = imovel.idt_municipio AND   rel_tema_imovel_poligono.idt_imovel = imovel.idt_imovel AND   tema.idt_tema = rel_tema_imovel_poligono.idt_tema AND GeometryType(the_geom)='MULTIPOLYGON';" -nln tema_$contar

done
done

print 'final'
