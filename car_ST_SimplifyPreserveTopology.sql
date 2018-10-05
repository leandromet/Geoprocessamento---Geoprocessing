create table geoserver.tema_2_simp as select 

idt_rel_tema_imovel,
idt_imovel,
num_area,
ST_SimplifyPreserveTopology(the_geom, 0.00002)

 from usr_geocar_aplicacao.rel_tema_imovel_poligono where idt_tema = 2;
