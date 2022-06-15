
#!/bin/sh

#Simple shell script for loading geometries into topogeometry table in 1000 registries steps
#GPL Leandro Biondo 2016


dbname="car_nacional082016"
username="admincar"
line=0

for i in {0..3300}
 do 
  line=$((i*1000))
  next=$(($line+1000))
  echo $line
  echo $next

  psql -h 172.16.32.116 $dbname $username -c "DO \$\$DECLARE r record;  BEGIN    FOR r IN SELECT * FROM usr_geocar_aplicacao.imovel where num_area_imovel>500 LOOP     IF (r.idt_imovel>$line and r.idt_imovel<=$next ) then      BEGIN        INSERT INTO sfb_topo.brasil_iru(idt_imovel, topo)        SELECT i.idt_imovel, topology.toTopoGeom(geo_area_imovel, 'topo_brasil', 1, 0.001)        FROM  usr_geocar_aplicacao.imovel i        WHERE i.idt_imovel = r.idt_imovel    and i.ind_status_imovel in ('PE','AT')   and i.ind_tipo_imovel='IRU' and i.num_area_imovel>500;      EXCEPTION        WHEN OTHERS THEN   RAISE WARNING 'Loading of record % failed: %', r.idt_imovel, SQLERRM;      END;     END IF;    END LOOP;  END\$\$;"


 done
