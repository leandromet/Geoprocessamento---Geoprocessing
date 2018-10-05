create table proc_sfb.atlas_26_imovel as
SELECT 
  rel_tema_imovel_poligono.idt_rel_tema_imovel, 
  rel_tema_imovel_poligono.idt_imovel, 
  rel_tema_imovel_poligono.num_area, 
  ST_SimplifyPreserveTopology(the_geom, 0.000025) as geom
FROM 
  usr_geocar_aplicacao.rel_tema_imovel_poligono, 
  usr_geocar_aplicacao.imovel
WHERE 
idt_tema = 26 and
ind_status_imovel in ('AT','PE') AND flg_ativo = TRUE AND
  imovel.idt_imovel = rel_tema_imovel_poligono.idt_imovel;
