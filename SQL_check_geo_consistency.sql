SQL





--FUNCAO PARA VALIDACAO E INCLUSAO DE UPA NA UMF, RETORNA TRUE SE VALIDADO (COPIA REGISTROS PARA TABELA scc.scc_upa) E FALSE SE NÃO VALIDADO. DEVOLVE O PORCENTUAL DE ÁREA FORA DA UMF E QUANTAS UPA EXISTENTES ELE SE SOBREPÕE

CREATE OR REPLACE FUNCTION scc.scc_val_upa(id_umf integer, OUT pn boolean, OUT v_umf float, OUT v_upa integer) AS $$
DECLARE valida numeric;
DECLARE valida2 numeric;
DECLARE valida3 numeric;
DECLARE org RECORD;
DECLARE geom_umf geometry;
DECLARE orgupa scc.scc_upa%rowtype;
BEGIN

	geom_umf := ST_Union(ARRAY(SELECT shape FROM sde.umfs WHERE
sde.umfs.id_umf = $1));
	valida := (SELECT (1 - ST_Area(ST_Intersection((select temp_upa.shape
from scc.temp_upa), geom_umf)) / ST_Area((select temp_upa.shape from scc.temp_upa)))
			FROM scc.temp_upa 
			WHERE ST_Intersects(temp_upa.shape, geom_umf)
		   );
	org := (SELECT (num_upa , area_ha , shape) 
			FROM scc.temp_upa
		);
	IF valida < (0.05)
		THEN 
			valida3 := 0;
			FOR orgupa IN SELECT * FROM scc.scc_upa
				LOOP
					valida2 := (SELECT (ST_Area(ST_Intersection(temp_upa.shape, orgupa.shape)) / ST_Area(temp_upa.shape))
						     FROM temp_upa 
						     WHERE ST_Intersects(temp_upa.shape, orgupa.shape)
						   );
					IF valida2 > (0.05)
						THEN
							valida3 := valida3+1;
					END IF;
				END LOOP;
			IF valida3 = 0
				THEN
					INSERT INTO scc.scc_upa (num_upa, area_ha, shape, num_umf) 
					VALUES(org.f1, org.f2, org.f3, $1);
			END IF;
	END IF;
	v_umf := valida;
	v_upa := valida3;
	IF valida < (0.05) AND valida3 = 0
		THEN 
			pn := TRUE;
	ELSE
		pn := FALSE;
	END IF;
END;
$$LANGUAGE plpgsql;




SELECT * FROM scc.scc_val_upa(1);




-- FUNCAO PARA VALIDACAO E INCLUSAO DE DAS ÁRVORES NA UPA SE RETORNA "0", VALIDADO E COPIADOS OS REGISTROS PARA TABELA scc.scc_arvores, RETORNA NÚMERO DE ÁRVORES FORA DA TOLERâNCIA SE NÃO VÁLIDO. RETORNA TOTAL DE ÁRVORES REPETIDAS CASO HAJA REGISTROS IGUAIS AOS QUE SE ESTÁ TENTANDO INSERIR. NÃO ATUALIZA OS EXISTENTES, APENAS INCLUI OS NÃO EXISTENTES.

CREATE OR REPLACE FUNCTION scc.scc_val_arvore(id_umf integer, OUT fora_tolerancia numeric, OUT repetido numeric) AS $$

DECLARE org scc.temp_arvores%rowtype;

BEGIN
	fora_tolerancia := (SELECT count(temp_arvores.gid) FROM temp_arvores, temp_upa WHERE NOT ST_Intersects(temp_upa.shape, temp_arvores.shape) AND ST_Distance(temp_upa.shape, temp_arvores.shape) > (0.00018));
	IF fora_tolerancia = 0
		THEN
				
				repetido:=(SELECT count(scc.scc_arvores.objectid)
				    FROM scc.scc_arvores, temp_arvores
				    WHERE scc.scc_arvores.num_upa=scc.temp_arvores.num_upa
				    AND scc.scc_arvores.num_ut=scc.temp_arvores.num_ut
				    AND scc.scc_arvores.num_arvore=scc.temp_arvores.num_arvore
				    AND scc.scc_arvores.x=scc.temp_arvores.x
				    AND scc.scc_arvores.y=scc.temp_arvores.y
				    AND scc.scc_arvores.num_umf=id_umf
				  );
				INSERT INTO scc.scc_arvores (num_upa,
nom_cient, nom_com, dap_cm, altura_m, volume_m3, categoria, x, y, num_ut, num_arvore, shape, num_umf) 
	              		(SELECT scc.temp_arvores.num_upa,
scc.temp_arvores.nom_cient, scc.temp_arvores.nom_com, scc.temp_arvores.dap_cm,
scc.temp_arvores.altura_m, scc.temp_arvores.volume_m3,
scc.temp_arvores.categoria, scc.temp_arvores.x, scc.temp_arvores.y,
scc.temp_arvores.num_ut, scc.temp_arvores.num_arvore,
scc.temp_arvores.shape,id_umf
				  FROM scc.temp_arvores
				  WHERE NOT EXISTS 
				  (SELECT scc.scc_arvores.num_upa,scc.scc_arvores.num_arvore,scc.scc_arvores.num_umf
				    FROM scc.scc_arvores, temp_arvores
				    WHERE scc.scc_arvores.num_upa=scc.temp_arvores.num_upa
				    AND scc.scc_arvores.num_ut=scc.temp_arvores.num_ut
				    AND scc.scc_arvores.num_arvore=scc.temp_arvores.num_arvore
				    AND scc.scc_arvores.x=scc.temp_arvores.x
				    AND scc.scc_arvores.y=scc.temp_arvores.y
				    AND scc.scc_arvores.num_umf=id_umf
				  )
				 );
			
	END IF;
END;
$$LANGUAGE plpgsql;




SELECT * FROM scc.scc_val_arvore(1);






--FUNCAO PARA VALIDACAO E INCLUSAO DE ESTRADAS NA UMF SE RETORNA "1" (est_val) SE VALIDADO E SÃO COPIADOS OS REGISTROS PARA TABELA scc.scc_estradas, RETORNA NÚMERO DE ESTRADAS FORA DA UMF SE NÃO VÁLIDO. CASO AS ESTRADAS VALIDADAS JÁ EXISTAM, DEVOLVE O NÚMERO DE ESTRADAS REPETIDAS (est_rep).

CREATE OR REPLACE FUNCTION scc.scc_val_estradas(id_umf integer, OUT est_val numeric, OUT est_rep numeric) AS $$

DECLARE org scc.temp_estradas%rowtype;
DECLARE geom_umf geometry;

BEGIN
		geom_umf := ST_Union(ARRAY(SELECT shape FROM sde.umfs WHERE sde.umfs.id_umf = $1));
	est_rep := 0;
	est_val := (SELECT count(temp_estradas.gid) FROM temp_estradas WHERE NOT ST_Intersects(geom_umf, temp_estradas.shape) AND ST_Distance(geom_umf, temp_estradas.shape) > 0);
	IF est_val = 0
		THEN
				est_val = 1;
				est_rep := est_rep+(SELECT count(temp_estradas.gid) FROM scc.scc_estradas, scc.temp_estradas 
				  WHERE scc.scc_estradas.comp_m=scc.temp_estradas.comp_m
					AND scc.scc_estradas.tipo=scc.temp_estradas.tipo);
				INSERT INTO scc.scc_estradas(num_upa, comp_m, tipo, shape) 
	              		(SELECT temp_estradas.num_upa, temp_estradas.comp_m, temp_estradas.tipo, temp_estradas.shape
				  FROM temp_estradas
				  WHERE NOT EXISTS (SELECT scc.scc_estradas.num_upa, scc.scc_estradas.comp_m, scc.scc_estradas.shape FROM scc.scc_estradas, scc.temp_estradas 
				  WHERE scc.scc_estradas.comp_m=scc.temp_estradas.comp_m
					AND scc.scc_estradas.tipo=scc.temp_estradas.tipo)
				);
				
	END IF;
END;
$$LANGUAGE plpgsql;


SELECT * FROM scc.scc_val_estradas(1);




--FUNCAO PARA VALIDACAO E INCLUSAO DE PATIOS DE ESTOCAGEM NA UMF SE RETORNA "0" SE VALIDADO E SÃO COPIADOS OS REGISTROS PARA TABELA scc.scc_patios_estocagem, RETORNA NÚMERO DE PÁTIOS FORA DA UMF SE NÃO VÁLIDO. SE VÁLIDO E HOUVER PÁTIOS REPETIDOS, RETONA O TOTAL.

CREATE OR REPLACE FUNCTION scc.scc_val_patios_estocagem(id_umf integer, OUT fora_umf numeric, OUT repetidos numeric) AS $$

DECLARE org scc.temp_patios%rowtype;
DECLARE geom_umf geometry;
BEGIN
	geom_umf := ST_Union(ARRAY(SELECT shape FROM sde.umfs WHERE sde.umfs.id_umf = $1));
	fora_umf := (SELECT count(temp_patios.gid) FROM temp_patios
WHERE NOT ST_Intersects(geom_umf, temp_patios.shape) AND ST_Distance(geom_umf, temp_patios.shape) > 0);
	IF fora_umf = 0
		THEN
				repetidos:=(SELECT count(scc.scc_patios_estocagem.objectid) FROM scc.temp_patios, scc.scc_patios_estocagem
				    WHERE temp_patios.num_upa=scc_patios_estocagem.num_upa AND temp_patios.cod_pat=scc_patios_estocagem.cod_pat
				);

				INSERT INTO scc.scc_patios_estocagem(num_upa, cod_pat, shape) 
	              		(SELECT scc.temp_patios.num_upa, scc.temp_patios.cod_pat, scc.temp_patios.shape
				 FROM temp_patios
				  WHERE NOT EXISTS 
				  (SELECT scc.scc_patios_estocagem.num_upa, scc.scc_patios_estocagem.cod_pat FROM scc.temp_patios, scc.scc_patios_estocagem
				    WHERE temp_patios.num_upa=scc_patios_estocagem.num_upa AND temp_patios.cod_pat=scc_patios_estocagem.cod_pat
				  )
				);

	END IF;

END;
$$LANGUAGE plpgsql;


SELECT * FROM scc.scc_val_patios_estocagem(1);




--FUNCAO PARA VALIDACAO E INCLUSAO DE PARCELAS PERMANENTES NA UMF SE RETORNA "0" SE VALIDADO E SÃO COPIADOS OS REGISTROS PARA TABELA scc.scc_parcelas, RETORNA NÚMERO DE PARCELAS FORA DA UMF SE NÃO VÁLIDO. SE VÁLIDO E HOUVER PARCELAS REPETIDAS, RETORNA O TOTAL.

CREATE OR REPLACE FUNCTION scc.scc_val_parcelas(id_umf integer, OUT fora_umf numeric, OUT repetidos numeric)  AS $$


DECLARE org scc.temp_parcelas%rowtype;
DECLARE geom_umf geometry;
BEGIN
	geom_umf := ST_Union(ARRAY(SELECT shape FROM sde.umfs WHERE sde.umfs.id_umf = $1));
	fora_umf := (SELECT count(scc.temp_parcelas.gid) FROM scc.temp_parcelas
WHERE NOT ST_Intersects(geom_umf, scc.temp_parcelas.shape) AND
ST_Distance(geom_umf, scc.temp_parcelas.shape) > 0);
	IF fora_umf = 0
		THEN
				repetidos:=(SELECT
count(scc.scc_parcelas_permanentes.objectid) FROM scc.temp_parcelas, scc.scc_parcelas_permanentes
				    WHERE
$1=scc_parcelas_permanentes.num_umf AND
temp_parcelas.num_upa=scc_parcelas_permanentes.num_upa AND
temp_parcelas.cod_par=scc_parcelas_permanentes.cod_par
				);
				INSERT INTO
scc.scc_parcelas_permanentes(num_umf, num_upa, cod_par, shape) 
	              		(SELECT $1, scc.temp_parcelas.num_upa,
scc.temp_parcelas.cod_par, scc.temp_parcelas.shape
				   FROM scc.temp_parcelas
				  WHERE NOT EXISTS
				   (SELECT scc.temp_parcelas.shape,
scc.scc_parcelas_permanentes.shape FROM scc.temp_parcelas, scc.scc_parcelas_permanentes
				    WHERE ST_Equals(scc.temp_parcelas.shape, scc.scc_parcelas_permanentes.shape))
				);
			
	END IF;

END;
$$LANGUAGE plpgsql;


SELECT * FROM scc.scc_val_parcelas(1);




