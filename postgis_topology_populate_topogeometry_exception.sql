-- GPL Leandro Biondo 2016
-- Insert topogeometries from a postgis geoemtry table with a 10meter tolerance on a EPSG:4674 topology


DO $$DECLARE r record;
BEGIN
  FOR r IN SELECT * FROM sfb_dados.geom_mt LOOP
   IF (r.id<10000 ) then
    BEGIN
      INSERT INTO sfb_topo.mt_topo(idt_imovel, topo)
      SELECT mt.idt_imovel, topology.toTopoGeom(mt.geom, 'topo_sfb_car', 1, 0.0001)
      FROM sfb_dados.geom_mt mt,   usr_geocar_aplicacao.imovel i
      WHERE mt.id = r.id 
	and i.idt_imovel = mt.idt_imovel
  	and i.ind_status_imovel in ('PE','AT')
	and i.ind_tipo_imovel='IRU';
    EXCEPTION
      WHEN OTHERS THEN
        RAISE WARNING 'Loading of record % failed: %', r.id, SQLERRM;
    END;
   END IF;
  END LOOP;
END$$;
