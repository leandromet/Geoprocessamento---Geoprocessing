
create table proc_sfb.referencia_imovel_consolidado as

SELECT 
  imovel.idt_imovel 

FROM 
  usr_geocar_aplicacao.imovel, 
  base_referencia.area_consolidada
WHERE 

  imovel.ind_status_imovel in ( 'AT', 'PE') and 
  imovel.flg_ativo is true and
  st_isvalid(geo_area_imovel) and st_isvalid(the_geom) and
  st_intersects(imovel.geo_area_imovel , area_consolidada.the_geom);
  
  CREATE INDEX br_simp2_area_cons_geom_gist
    ON base_referencia.simp2_area_consolidada USING gist
    (geom)
    TABLESPACE sicar1;
    
    create table proc_sfb.imovel_inters_simp2_consol as select gid, gridcode,
    estado, idt_imovel, area_ha, modulo,
    st_makevalid(st_intersection(st_makevalid(st_simplifypreservetopology), st_makevalid(geom)) ) as geom
    from base_referencia.simp2_area_consolidada , geoserver.tema_simp_26_imovel
    where st_intersects(st_makevalid(st_simplifypreservetopology), st_makevalid(geom));
