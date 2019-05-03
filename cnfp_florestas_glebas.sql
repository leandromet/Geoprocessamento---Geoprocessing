create table cnfp_2018.d_glebas2018_floresta2006 as 

SELECT 
  a_orig_florestas2006.id, 
  c_glebas_consolidado2018.idtz, 
  c_glebas_consolidado2018.origem, 
  c_glebas_consolidado2018.nome, 
  c_glebas_consolidado2018.id, 
  c_glebas_consolidado2018.parcela_co, 
  c_glebas_consolidado2018.codigo_imo, 
  c_glebas_consolidado2018.data_submi, 
  c_glebas_consolidado2018.data_aprov, 
  c_glebas_consolidado2018.status, 
  c_glebas_consolidado2018.governo, 
  c_glebas_consolidado2018.natureza, 
  c_glebas_consolidado2018.situacao_i, 
  a_orig_florestas2006.tb_tipolog,
  case when ST_CoveredBy(ac_glebas_consolidado2018.geom, _orig_florestas2006.geom )
  then ac_glebas_consolidado2018.geom 
  else
ST_Multi(
      ST_Intersection(ac_glebas_consolidado2018.geom, _orig_florestas2006.geom)
      ) END AS geom
  
FROM 
  cnfp_2018.a_orig_florestas2006 inner join
  cnfp_2018.c_glebas_consolidado2018
on
  (ST_Intersects(c_glebas_consolidado2018.geom, a_orig_florestas2006.geom) 
and not ST_Touches(c_glebas_consolidado2018.geom, a_orig_florestas2006.geom) );
