
--GPL Leandro Biondo 2016
-- Creating topology and topogeometry table in postgis

--create topology with Sirgas 2000 EPSG
select topology.CreateTopology('topo_car', 4674);

-- create table with 2 fields
create table sfb_topo.mt_iru(gid serial primary key, idt_imovel numeric(16));

-- add topogeometry column using the created topology

SELECT topology.AddTopoGeometryColumn('topo_car', 'sfb_topo', 'mt_iru', 'topo', 'MULTIPOLYGON') As layer_mt_iru;
