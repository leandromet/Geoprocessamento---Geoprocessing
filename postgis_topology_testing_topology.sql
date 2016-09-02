-- GPL Leandro Biondo 2016
-- Various tests on a newly created topogeometry table and its elements

--count distinct registries on topogeometry table
SELECT count(distinct idt_imovel) FROM sfb_topo.mt_topo3;
--106337

--count disinct registries on source postgis geoemtry table
SELECT count(distinct idt_imovel) FROM sfb_dados.geom_mt;
--108290

-- see what topo column is made of
SELECT * FROM sfb_topo.mt_topo3 limit 1;
--1980;1417948;"(4,1,1981,3)"

-- select all that is in one registry from the source geometry table
SELECT id, geom, idt_imovel FROM sfb_dados.geom_mt limit 1;
--100899;"01060000204212000001000000010300000001000000DA0000008533C528FC054CC0DB67E3E4016F2AC06EAA64B12D064CC0AC90C327936D2AC0E4DAFA63F20A4CC075B45E4DF3762AC0AA8744A7810B4CC04D0326EB0C782AC0A606F86D7E0B4CC04AFC66391E782AC02191EF307D0B4CC01A08D06524782AC0039BFE227C0B (...)";2762049

-- calculate area on topogeometry
SELECT ST_Area(topo) FROM sfb_topo.mt_topo3 where idt_imovel = 1417948;
--0.00029206950898525

-- calculate area on geometry, same registry
SELECT ST_Area(geom) FROM sfb_dados.geom_mt where idt_imovel = 1417948;
--0.000292069510311885

--original table calculate the area of all geometries
SELECT sum(ST_Area(geom)) FROM sfb_dados.geom_mt;
--Result 59.9794519423682
--time 183ms


--topology table calculate the area of geometries that were correctly inserted on topology table
SELECT sum(ST_Area(topo)) FROM sfb_topo.mt_topo3;
-- Result 55.7808649152464
-- time 5:17 min

--original table calculate the area of geometries that were correctly inserted on topology table
SELECT sum(ST_Area(geom)) FROM sfb_dados.geom_mt, sfb_topo.mt_topo3 where geom_mt.idt_imovel = mt_topo3.idt_imovel;
--55.7808275474501
--time < 200ms


--original table calculate the area of geometries NOT inserted on topology table
SELECT sum(ST_Area(geom)) FROM sfb_dados.geom_mt where geom_mt.idt_imovel not in ( select geom_mt.idt_imovel from sfb_dados.geom_mt, sfb_topo.mt_topo3 where geom_mt.idt_imovel = mt_topo3.idt_imovel);
--4.19862439491804

-- Select the geometries that were not inserted
create table sfb_result.geom_mt_not_topo as SELECT id,idt_imovel,geom  FROM sfb_dados.geom_mt where geom_mt.idt_imovel not in ( select geom_mt.idt_imovel from sfb_dados.geom_mt, sfb_topo.mt_topo3 where geom_mt.idt_imovel = mt_topo3.idt_imovel);

-- Find Intersections, both did not finish
SELECT count(ST_Intersects(mt1.geom, mt2.geom)) FROM sfb_dados.geom_mt mt1, sfb_dados.geom_mt mt2 where mt1.id < mt2.id;


SELECT count(ST_Intersects(mt1.topo, mt2.topo)) FROM sfb_topo.mt_topo3 mt1, sfb_topo.mt_topo3 mt2 where mt1.gid < mt2.gid;

--Self intersecting multiple count

SELECT count(ST_Intersects(mt1.geom, mt2.geom)) FROM sfb_dados.geom_mt mt1, sfb_dados.geom_mt mt2 , sfb_topo.mt_topo3 where mt1.id < mt2.id and mt2.id<5000 and mt1.idt_imovel = mt_topo3.idt_imovel;
--12490340
--10sec

SELECT count(ST_Intersects(mt1.topo, mt2.topo)) FROM sfb_topo.mt_topo3 mt1, sfb_topo.mt_topo3 mt2 where mt1.gid < mt2.gid and mt2.gid<5000 and geom_mt.idt_imovel = mt_topo3.idt_imovel;
--498501
--43min


--touches itself
SELECT count(ST_Touches(mt1.geom, mt2.geom)) FROM sfb_dados.geom_mt mt1, sfb_dados.geom_mt mt2 , sfb_topo.mt_topo3 where mt1.id < mt2.id and mt2.id<5000 and mt1.idt_imovel = mt_topo3.idt_imovel;
--12490340

-- Intersects corrected

SELECT count(CASE WHEN ST_Intersects(mt1.geom, mt2.geom) THEN 1 END) FROM sfb_dados.geom_mt mt1, sfb_dados.geom_mt mt2 where mt1.id < mt2.id and mt2.id<2000;
--60
--3.8sec

SELECT count(CASE WHEN ST_Intersects(mt1.topo, mt2.topo) THEN 1 END) FROM sfb_topo.mt_topo3 mt1, sfb_topo.mt_topo3 mt2, sfb_dados.geom_mt where mt1.gid < mt2.gid and mt2.gid<2000 and geom_mt.idt_imovel = mt1.idt_imovel and mt2.id<2000;


-- Intersects topology corrected

SELECT count(CASE WHEN ST_Intersects(mt1.topo, mt2.topo) THEN 1 END) FROM sfb_topo.mt_topo3 mt1, sfb_topo.mt_topo3 mt2 where mt1.gid < mt2.gid and mt2.gid<2000;
7


-- Some data on the created topogeoemtry table

total nodes
426146

start_node = end_node
10062

total faces
323975

relation
453480

start_node
Count:733910
Unique values:426143
Minimum value:1468.000000
Maximum value:784513.000000
Range:783045.000000
Sum:407569991754.000000
Mean value:555340.561859
Median value:557526.000000
Standard deviation:132930.427356
Coefficient of Variation:0.239367

edge_data
Count:733910
Unique values:426138
Minimum value:1468.000000
Maximum value:784513.000000
Range:783045.000000
Sum:407548130504.000000
Mean value:555310.774487
Median value:557467.500000
Standard deviation:132902.344536
Coefficient of Variation:0.239330




right_face

Count:733910
Unique values:205284
Minimum value:0.000000
Maximum value:589069.000000
Range:589069.000000
Sum:261446862410.000000
Mean value:356238.315883
Median value:392059.000000
Standard deviation:185979.769782
Coefficient of Variation:0.522066

right_face>0
615647

total edges
733910


left_edge=right_edge
10883

