-- GPL Leandro Biondo 2016
-- Insert geometries that are topologicaly consistent (no exceptions)


INSERT INTO sfb_topo.mt_topo3(idt_imovel, topo)
SELECT mt.idt_imovel, topology.toTopoGeom(mt.geom, 'topo_sfb_car', 1, 0.0001)
FROM sfb_dados.geom_mt mt,   usr_geocar_aplicacao.imovel i
where  imovel.idt_imovel = mt_topo3.idt_imovel
  and imovel.ind_status_imovel in ('RE','CA');
