-- GPL Leandro Biondo 2016
-- One way of finding the relation in topogeometry schema using the topo column from the topogeometry table

--- Separate the element_id from topo column

select a[3] from (select regexp_split_to_array(replace(replace(topo::text, '(',''), ')',''),',') as t from sfb_topo.mt_iru where gid=8000) as dt(a);



--- find the element_id in the topogeoemtry schema

select topogeo_id from topo_car.relation 
	where exists (select id 
	from (select regexp_split_to_array(replace(replace(topo::text, '(',''), ')',''),',') as t, element_id as id
		from sfb_topo.mt_iru where gid<20000) as dt(a), topo_car.relation where a[3]::int=element_id);
