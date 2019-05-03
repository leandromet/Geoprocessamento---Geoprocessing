create table sao_francisco_union as
SELECT 
  imovel.idt_municipio,
  sao_francisco_tema.idt_tema, 
  ST_MakeValid(ST_union(ST_Buffer(ST_MakeValid(sao_francisco_tema.the_geom),0.0000001))) as geom, 
  count(sao_francisco_tema.idt_rel_tema_imovel) as feicoes, 
  sum(sao_francisco_tema.num_area) as area_tema, 
  count(imovel.idt_imovel) as imoveis
FROM 
  public.sao_francisco_tema,
  usr_geocar_aplicacao.rel_tema_imovel_poligono,
  usr_geocar_aplicacao.imovel
WHERE 
  imovel.ind_status_imovel = 'AT' AND
  sao_francisco_tema.idt_tema in (2,26) AND
  sao_francisco_tema.idt_rel_tema_imovel = rel_tema_imovel_poligono.idt_rel_tema_imovel AND
  imovel.idt_imovel = rel_tema_imovel_poligono.idt_imovel
  group by
  imovel.idt_municipio,
  sao_francisco_tema.idt_tema
  order by
  imovel.idt_municipio,
  sao_francisco_tema.idt_tema
 ;
