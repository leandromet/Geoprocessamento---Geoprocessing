create table geoserver.tema_2_simp as select 

idt_rel_tema_imovel,
idt_imovel,
num_area,
ST_SimplifyPreserveTopology(the_geom, 0.00002)

 from usr_geocar_aplicacao.rel_tema_imovel_poligono where idt_tema = 2;


create table geoserver.tema_simp_2_rvn as select 

idt_rel_tema_imovel,
 rel_tema_imovel_poligono.idt_imovel,
 rel_tema_imovel_poligono.num_area,
ST_SimplifyPreserveTopology( rel_tema_imovel_poligono.the_geom, 0.00002)

 from usr_geocar_aplicacao.rel_tema_imovel_poligono 
,usr_geocar_aplicacao.imovel
where idt_tema = 2 and
imovel.ind_status_imovel in ('AT', 'PE') and flg_ativo is true and
 rel_tema_imovel_poligono.idt_imovel = imovel.idt_imovel;



create table geoserver.tema_simp_2_imovel as select 

idt_rel_tema_imovel,
 rel_tema_imovel_poligono.idt_imovel,
 rel_tema_imovel_poligono.num_area,
ST_SimplifyPreserveTopology( rel_tema_imovel_poligono.the_geom, 0.00002)

 from usr_geocar_aplicacao.rel_tema_imovel_poligono 
,usr_geocar_aplicacao.imovel
where idt_tema = 26 and
imovel.ind_status_imovel in ('AT', 'PE') and flg_ativo is true and
 rel_tema_imovel_poligono.idt_imovel = imovel.idt_imovel;


create table geoserver.tema_simp_32_rl as select 

idt_rel_tema_imovel,
 rel_tema_imovel_poligono.idt_imovel,
 rel_tema_imovel_poligono.num_area,
ST_SimplifyPreserveTopology( rel_tema_imovel_poligono.the_geom, 0.00002)

 from usr_geocar_aplicacao.rel_tema_imovel_poligono 
,usr_geocar_aplicacao.imovel
where idt_tema = 32 and
imovel.ind_status_imovel in ('AT', 'PE') and flg_ativo is true and
 rel_tema_imovel_poligono.idt_imovel = imovel.idt_imovel;
