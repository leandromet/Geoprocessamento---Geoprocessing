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





--FUNCAO PARA VALIDACAO E INCLUSAO DE PATIOS PRINCIPAIS NA UMF RETORNA "0" SE VALIDADO E SÃO COPIADOS OS REGISTROS PARA TABELA scc.scc_patio_PRINCIPAL, RETORNA NÚMERO DE PÁTIOS FORA DA UMF SE NÃO VÁLIDO. SE VÁLIDO E HOUVER PÁTIOS REPETIDOS, RETONA O TOTAL.

CREATE OR REPLACE FUNCTION scc.scc_val_patio_principal(id_umf integer, OUT fora_umf numeric, OUT repetidos numeric) AS $$

DECLARE org scc.temp_patio_principal%rowtype;
DECLARE geom_umf geometry;
BEGIN
	geom_umf := ST_Union(ARRAY(SELECT shape FROM sde.umfs WHERE sde.umfs.id_umf = $1));
	fora_umf := (SELECT count(temp_patio_principal.gid) FROM temp_patio_principal
WHERE NOT ST_Intersects(geom_umf, temp_patio_principal.shape) AND ST_Distance(geom_umf, temp_patio_principal.shape) > 0);
	IF fora_umf = 0
		THEN
				repetidos:=(SELECT count(scc.scc_patio_principal.objectid) FROM scc.temp_patio_principal, scc.scc_patio_principal
				    WHERE temp_patio_principal.num_upa=scc_patio_principal.num_upa AND temp_patio_principal.area_ha=scc_patio_principal.area_ha
				);

				INSERT INTO scc.scc_patio_principal(num_upa, area_ha, shape) 
	              		(SELECT scc.temp_patio_principal.num_upa, scc.temp_patio_principal.area_ha, scc.temp_patio_principal.shape
				 FROM temp_patio_principal
				  WHERE NOT EXISTS 
				  (SELECT scc.scc_patio_principal.num_upa, scc.scc_patio_principal.area_ha FROM scc.temp_patio_principal, scc.scc_patio_principal
				    WHERE temp_patio_principal.num_upa=scc_patio_principal.num_upa AND temp_patio_principal.area_ha=scc_patio_principal.area_ha
				  )
				);

	END IF;

END;
$$LANGUAGE plpgsql;


--SELECT * FROM scc.scc_val_patio_principal(1);





--FUNCAO PARA VALIDACAO E INCLUSAO DE NASCENTES NA UMF RETORNA "0" SE VALIDADO E SÃO COPIADOS OS REGISTROS PARA TABELA scc.scc_nascentes, RETORNA NÚMERO DE NASCENTES FORA DA UMF SE NÃO VÁLIDO. SE VÁLIDO E HOUVER PÁTIOS REPETIDOS, RETONA O TOTAL.

CREATE OR REPLACE FUNCTION scc.scc_val_nascentes(id_umf integer, OUT fora_umf numeric, OUT repetidos numeric) AS $$

DECLARE org scc.temp_nascentes%rowtype;
DECLARE geom_umf geometry;
BEGIN
	geom_umf := ST_Union(ARRAY(SELECT shape FROM sde.umfs WHERE sde.umfs.id_umf = $1));
	fora_umf := (SELECT count(temp_nascentes.gid) FROM temp_nascentes
WHERE NOT ST_Intersects(geom_umf, temp_nascentes.shape) AND ST_Distance(geom_umf, temp_nascentes.shape) > 0);
	IF fora_umf = 0
		THEN
				repetidos:=(SELECT count(scc.scc_nascentes.objectid) FROM scc.temp_nascentes, scc.scc_nascentes
				    WHERE temp_nascentes.num_upa=scc_nascentes.num_upa AND temp_nascentes.shape=scc_nascentes.shape
				);

				INSERT INTO scc.scc_nascentes(num_upa, area_ha, shape) 
	              		(SELECT scc.temp_nascentes.num_upa, scc.temp_nascentes.shape
				 FROM temp_nascentes
				  WHERE NOT EXISTS 
				  (SELECT scc.scc_nascentes.num_upa, scc.scc_nascentes.shape FROM scc.temp_nascentes, scc.scc_nascentes
				    WHERE temp_nascentes.num_upa=scc_nascentes.num_upa AND temp_nascentes.shape=scc_nascentes.shape
				  )
				);

	END IF;

END;
$$LANGUAGE plpgsql;


--SELECT * FROM scc.scc_val_nascentes(1);





--FUNCAO PARA VALIDACAO E INCLUSAO DE TRILHAS DE ARRASTE NA UMF RETORNA "0" SE VALIDADO E SÃO COPIADOS OS REGISTROS PARA TABELA scc.scc_trilhas_arraste, RETORNA NÚMERO DE TRILHAS FORA DA UMF SE NÃO VÁLIDO. SE VÁLIDO E HOUVER TRILHAS REPETIDAS, RETONA O TOTAL.

CREATE OR REPLACE FUNCTION scc.scc_val_trilhas_arraste(id_umf integer, OUT est_val numeric, OUT est_rep numeric) AS $$

DECLARE org scc.temp_trilhas_arraste%rowtype;
DECLARE geom_umf geometry;

BEGIN
		geom_umf := ST_Union(ARRAY(SELECT shape FROM sde.umfs WHERE sde.umfs.id_umf = $1));
	est_rep := 0;
	est_val := (SELECT count(temp_trilhas_arraste.gid) FROM temp_trilhas_arraste WHERE NOT ST_Intersects(geom_umf, temp_trilhas_arraste.shape) AND ST_Distance(geom_umf, temp_trilhas_arraste.shape) > 0);
	IF est_val = 0
		THEN
				est_val = 1;
				est_rep := est_rep+(SELECT count(temp_trilhas_arraste.gid) FROM scc.scc_trilhas_arraste, scc.temp_trilhas_arraste 
				  WHERE scc.scc_trilhas_arraste.comp_m=scc.temp_trilhas_arraste.comp_m
					AND scc.scc_trilhas_arraste.shape=scc.temp_trilhas_arraste.shape);
				INSERT INTO scc.scc_trilhas_arraste(num_upa, comp_m, shape) 
	              		(SELECT temp_trilhas_arraste.num_upa, temp_trilhas_arraste.comp_m, temp_trilhas_arraste.shape
				  FROM temp_trilhas_arraste
				  WHERE NOT EXISTS (SELECT scc.scc_trilhas_arraste.num_upa, scc.scc_trilhas_arraste.comp_m, scc.scc_trilhas_arraste.shape FROM scc.scc_trilhas_arraste, scc.temp_trilhas_arraste 
				  WHERE scc.scc_trilhas_arraste.comp_m=scc.temp_trilhas_arraste.comp_m
					AND scc.scc_trilhas_arraste.shape=scc.temp_trilhas_arraste.shape)
				);
				
	END IF;
END;
$$LANGUAGE plpgsql;


SELECT * FROM scc.scc_val_trilhas_arraste(1);





--FUNCAO PARA VALIDACAO E INCLUSAO DE APP NA UMF RETORNA "0" SE VALIDADO E SÃO COPIADOS OS REGISTROS PARA TABELA scc.scc_app, RETORNA NÚMERO APP FORA DA UMF SE NÃO VÁLIDO. SE VÁLIDO E HOUVER APP REPETIDAS, RETONA O TOTAL.

CREATE OR REPLACE FUNCTION scc.scc_val_app(id_umf integer, OUT fora_umf numeric, OUT repetidos numeric) AS $$

DECLARE org scc.temp_app%rowtype;
DECLARE geom_umf geometry;
BEGIN
	geom_umf := ST_Union(ARRAY(SELECT shape FROM sde.umfs WHERE sde.umfs.id_umf = $1));
	fora_umf := (SELECT count(temp_app.gid) FROM temp_app
WHERE NOT ST_Intersects(geom_umf, temp_app.shape) AND ST_Distance(geom_umf, temp_app.shape) > 0);
	IF fora_umf = 0
		THEN
				repetidos:=(SELECT count(scc.scc_app.objectid) FROM scc.temp_app, scc.scc_app
				    WHERE temp_app.num_upa=scc_app.num_upa AND temp_app.area_ha=scc_app.area_ha
				);

				INSERT INTO scc.scc_app(num_upa, area_ha, shape) 
	              		(SELECT scc.temp_app.num_upa, scc.temp_app.area_ha, scc.temp_app.shape
				 FROM temp_app
				  WHERE NOT EXISTS 
				  (SELECT scc.scc_app.num_upa, scc.scc_app.area_ha FROM scc.temp_app, scc.scc_app
				    WHERE temp_app.num_upa=scc_app.num_upa AND temp_app.area_ha=scc_app.area_ha
				  )
				);

	END IF;

END;
$$LANGUAGE plpgsql;


--SELECT * FROM scc.scc_val_app(1);






--FUNCAO PARA VALIDACAO E INCLUSAO DE ESPELHOS D'ÁGUA NA UMF RETORNA "0" SE VALIDADO E SÃO COPIADOS OS REGISTROS PARA TABELA scc.scc_espelho_dagua, RETORNA NÚMERO DE ESPELHOS FORA DA UMF SE NÃO VÁLIDO. SE VÁLIDO E HOUVER ESPELHOS REPETIDOS, RETONA O TOTAL.

CREATE OR REPLACE FUNCTION scc.scc_val_espelho_dagua(id_umf integer, OUT fora_umf numeric, OUT repetidos numeric) AS $$

DECLARE org scc.temp_espelho_dagua%rowtype;
DECLARE geom_umf geometry;
BEGIN
	geom_umf := ST_Union(ARRAY(SELECT shape FROM sde.umfs WHERE sde.umfs.id_umf = $1));
	fora_umf := (SELECT count(temp_espelho_dagua.gid) FROM temp_espelho_dagua
WHERE NOT ST_Intersects(geom_umf, temp_espelho_dagua.shape) AND ST_Distance(geom_umf, temp_espelho_dagua.shape) > 0);
	IF fora_umf = 0
		THEN
				repetidos:=(SELECT count(scc.scc_espelho_dagua.objectid) FROM scc.temp_espelho_dagua, scc.scc_espelho_dagua
				    WHERE temp_espelho_dagua.num_upa=scc_espelho_dagua.num_upa AND temp_espelho_dagua.area_ha=scc_espelho_dagua.area_ha
				);

				INSERT INTO scc.scc_espelho_dagua(num_upa, area_ha, shape) 
	              		(SELECT scc.temp_espelho_dagua.num_upa, scc.temp_espelho_dagua.area_ha, scc.temp_espelho_dagua.shape
				 FROM temp_espelho_dagua
				  WHERE NOT EXISTS 
				  (SELECT scc.scc_espelho_dagua.num_upa, scc.scc_espelho_dagua.area_ha FROM scc.temp_espelho_dagua, scc.scc_espelho_dagua
				    WHERE temp_espelho_dagua.num_upa=scc_espelho_dagua.num_upa AND temp_espelho_dagua.area_ha=scc_espelho_dagua.area_ha
				  )
				);

	END IF;

END;
$$LANGUAGE plpgsql;


--SELECT * FROM scc.scc_val_espelho_dagua(1);




--FUNCAO PARA VALIDACAO E INCLUSAO DE UNIDADES DE TRABALHO NA UMF RETORNA "0" SE VALIDADO E SÃO COPIADOS OS REGISTROS PARA TABELA scc.scc_unidade_trabalho, RETORNA NÚMERO DE UTS FORA DA UMF SE NÃO VÁLIDO. SE VÁLIDO E HOUVER UTS REPETIDOS, RETONA O TOTAL.

CREATE OR REPLACE FUNCTION scc.scc_val_unidade_trabalho(id_umf integer, OUT fora_umf numeric, OUT repetidos numeric) AS $$

DECLARE org scc.temp_unidade_trabalho%rowtype;
DECLARE geom_umf geometry;
BEGIN
	geom_umf := ST_Union(ARRAY(SELECT shape FROM sde.umfs WHERE sde.umfs.id_umf = $1));
	fora_umf := (SELECT count(temp_unidade_trabalho.gid) FROM temp_unidade_trabalho
WHERE NOT ST_Intersects(geom_umf, temp_unidade_trabalho.shape) AND ST_Distance(geom_umf, temp_unidade_trabalho.shape) > 0);
	IF fora_umf = 0
		THEN
				repetidos:=(SELECT count(scc.scc_unidade_trabalho.objectid) FROM scc.temp_unidade_trabalho, scc.scc_unidade_trabalho
				    WHERE temp_unidade_trabalho.num_upa=scc_unidade_trabalho.num_upa AND temp_unidade_trabalho.area_ha=scc_unidade_trabalho.area_ha
				);

				INSERT INTO scc.scc_unidade_trabalho(num_upa, area_ha, cod_ut, shape) 
	              		(SELECT scc.temp_unidade_trabalho.num_upa, scc.temp_unidade_trabalho.area_ha, scc.temp_unidade_trabalho.cod_ut, scc.temp_unidade_trabalho.shape
				 FROM temp_unidade_trabalho
				  WHERE NOT EXISTS 
				  (SELECT scc.scc_unidade_trabalho.num_upa, scc.scc_unidade_trabalho.cod_ut FROM scc.temp_unidade_trabalho, scc.scc_unidade_trabalho
				    WHERE temp_unidade_trabalho.num_upa=scc_unidade_trabalho.num_upa AND temp_unidade_trabalho.cod_ut=scc_unidade_trabalho.cod_ut
				  )
				);

	END IF;

END;
$$LANGUAGE plpgsql;


--SELECT * FROM scc.scc_val_unidade_trabalho(1);





--FUNCAO PARA VALIDACAO E INCLUSAO DE HIDROGRAFIA NA UMF RETORNA "0" SE VALIDADO E SÃO COPIADOS OS REGISTROS PARA TABELA scc.scc_hidrografia, RETORNA NÚMERO DE HIDROGRAFIA FORA DA UMF SE NÃO VÁLIDO. SE VÁLIDO E HOUVER HIDROGRAFIA REPETIDAS, RETONA O TOTAL.

CREATE OR REPLACE FUNCTION scc.scc_val_hidrografia(id_umf integer, OUT est_val numeric, OUT est_rep numeric) AS $$

DECLARE org scc.temp_hidrografia%rowtype;
DECLARE geom_umf geometry;

BEGIN
		geom_umf := ST_Union(ARRAY(SELECT shape FROM sde.umfs WHERE sde.umfs.id_umf = $1));
	est_rep := 0;
	est_val := (SELECT count(temp_hidrografia.gid) FROM temp_hidrografia WHERE NOT ST_Intersects(geom_umf, temp_hidrografia.shape) AND ST_Distance(geom_umf, temp_hidrografia.shape) > 0);
	IF est_val = 0
		THEN
				est_val = 1;
				est_rep := est_rep+(SELECT count(temp_hidrografia.gid) FROM scc.scc_hidrografia, scc.temp_hidrografia 
				  WHERE scc.scc_hidrografia.comp_m=scc.temp_hidrografia.comp_m
					AND scc.scc_hidrografia.shape=scc.temp_hidrografia.shape);
				INSERT INTO scc.scc_hidrografia(num_upa, comp_m, shape) 
	              		(SELECT temp_hidrografia.num_upa, temp_hidrografia.comp_m, temp_hidrografia.shape
				  FROM temp_hidrografia
				  WHERE NOT EXISTS (SELECT scc.scc_hidrografia.num_upa, scc.scc_hidrografia.comp_m, scc.scc_hidrografia.shape FROM scc.scc_hidrografia, scc.temp_hidrografia 
				  WHERE scc.scc_hidrografia.comp_m=scc.temp_hidrografia.comp_m
					AND scc.scc_hidrografia.shape=scc.temp_hidrografia.shape)
				);
				
	END IF;
END;
$$LANGUAGE plpgsql;


--SELECT * FROM scc.scc_val_hidrografia(1);
