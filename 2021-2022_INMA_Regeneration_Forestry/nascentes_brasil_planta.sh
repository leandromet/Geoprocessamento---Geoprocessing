#!/bin/sh



ogr2ogr -f "ESRI Shapefile" -update -append  es.shp PG:"host=10.20.20.144 user=sfb dbname=car_nacional"  -sql "SELECT   * FROM   usr_geocar_aplicacao.rel_tema_imovel_ponto,   plantador_de_rio.classificacao_nascente WHERE    classificacao_nascente.id_nascente = rel_tema_imovel_ponto.idt_rel_tema_imovel  " -nln imoveis -nlt POINT



