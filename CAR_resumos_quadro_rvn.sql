select cod_uf, sum (num_area_vegetacao_nativa) from relatorio.quadro_area 
where ind_status_imovel in ('AT', 'PE') and cod_uf in ('AC','AM','AP','MA', 'MT', 'PA', 'RO','RR', 'TO' )
group by cod_uf



create table proc_sfb.amz_rvn_imovel as
select  
gid,gridcode,estado,cod_estado, idt_imovel, st_intersection(geom, geo_area_imovel) from
geoserver.reman_veg_nativa , usr_geocar_aplicacao.imovel, usr_geocar_aplicacao.municipio

where ind_status_imovel in ('AT', 'PE') and cod_estado in ('AC','AM','AP','MA', 'MT', 'PA', 'RO','RR', 'TO' ) and imovel.idt_municipio=municipio.idt_municipio and
st_intersects(geom, geo_area_imovel)



create table proc_sfb.amz_rvn_imovel as
select  
gid,gridcode,estado,cod_estado, idt_imovel, st_intersection(geom, st_simplifypreservetopology) from
geoserver.reman_veg_nativa ,  geoserver.tema_simp_26_imovel

where  cod_estado in ('AC','AM','AP','MA', 'MT', 'PA', 'RO','RR', 'TO' ) and
st_intersects(geom, st_simplifypreservetopology)
