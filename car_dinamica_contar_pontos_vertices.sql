SELECT sum(ST_NPoints(geo_area_imovel)) FROM usr_geocar_aplicacao.imovel;

SELECT sum(ST_NPoints(the_geom)) FROM usr_geocar_aplicacao.rel_tema_imovel_poligono;

SELECT 
  imovel.ind_status_imovel, 
  count(imovel.idt_imovel)
FROM 
  usr_geocar_aplicacao.imovel
  group by ind_status_imovel
  order by ind_status_imovel;





