--acesso:

psql -h 172.16.32.23 geosfb scc

--funções:

SELECT * FROM scc.scc_val_upa(1);
SELECT * FROM scc.scc_val_arvore(1);
SELECT * FROM scc.scc_val_estradas(1);
SELECT * FROM scc.scc_val_parcelas(1);
SELECT * FROM scc.scc_val_patio_principal(1);
SELECT * FROM scc.scc_val_nascentes(1);
SELECT * FROM scc.scc_val_trilhas_arraste(1);
SELECT * FROM scc.scc_val_app(1);
SELECT * FROM scc.scc_val_espelho_dagua(1);
SELECT * FROM scc.scc_val_unidade_trabalho(1);
SELECT * FROM scc.scc_val_hidrografia(1);



--scc.scc_val_upa(0) => recebe "0" (ZERO) por padrão, devolve V se validado ou F se não validado, retorna total de indivíduos fora da umf, se não houver grava no banco, se existirem parte dos indivíduos em registros, devolve total de repetidos
--scc.scc_val_arvores(0) => recebe "0" (ZERO) por padrão, retorna total de indivíduos fora da umf, se não houver grava no banco, se existirem parte dos indivíduos em registros, devolve total de repetidos
--scc.scc_val_estradas(0) => recebe "0" (ZERO) por padrão, retorna total de indivíduos fora da umf, se não houver grava no banco, se existirem parte dos indivíduos em registros, devolve total de repetidos
--scc.scc_val_patios_estocagem(0) => recebe "0" (ZERO) por padrão, retorna total de indivíduos fora da umf, se não houver grava no banco, se existirem parte dos indivíduos em registros, devolve total de repetidos
--scc.scc_val_parcelas(0) => recebe "0" (ZERO) por padrão, retorna total de indivíduos fora da umf, se não houver grava no banco, se existirem parte dos indivíduos em registros, devolve total de repetidos














-- lista tabelas
SELECT table_name
  FROM information_schema.tables
 WHERE table_schema='sde'
   AND table_type='BASE TABLE';



--Cria tabelas temporárias



#!/bin/sh
export PGPASSWORD="dbscc"
/usr/bin/shp2pgsql -d -W LATIN1 -s 4674 -g shape $1 scc.temp_upa | /usr/bin/psql -h pgsqldv01.florestal.gov.br -U dbscc -d geoscc
unset PGPASSWORD
exit 0










shp2pgsql -d -W LATIN1 -s 4674 -g shape umf.shp scc.umf | psql -h 172.16.32.23 -U scc -d geosfb


shp2pgsql -d -W LATIN1 -s 4674 -g shape limite_upa5.shp scc.temp_upa | psql -h 172.16.32.23 -U scc -d geosfb
shp2pgsql -d -W LATIN1 -s 4674 -g shape arvore_upa5.shp scc.temp_arvores | psql -h 172.16.32.23 -U scc -d geosfb
shp2pgsql -d -W LATIN1 -s 4674 -g shape parcelas_permanetes_upa5.shp scc.temp_parcelas | psql -h 172.16.32.23 -U scc -d geosfb
shp2pgsql -d -W LATIN1 -s 4674 -g shape estradas_upa5.shp scc.temp_estradas | psql -h 172.16.32.23 -U scc -d geosfb
shp2pgsql -d -W LATIN1 -s 4674 -g shape patios_planejados_upa5.shp scc.temp_patios | psql -h 172.16.32.23 -U scc -d geosfb

shp2pgsql -d -W LATIN1 -s 4674 -g shape app_upa5.shp scc.temp_app | psql -h 172.16.32.23 -U scc -d geosfb
shp2pgsql -d -W LATIN1 -s 4674 -g shape espelho_dagua_upa5.shp scc.temp_espelho_dagua | psql -h 172.16.32.23 -U scc -d geosfb
shp2pgsql -d -W LATIN1 -s 4674 -g shape hidrografia_upa5.shp scc.temp_hidrografia | psql -h 172.16.32.23 -U scc -d geosfb
shp2pgsql -d -W LATIN1 -s 4674 -g shape nascente_upa5.shp scc.temp_nascentes | psql -h 172.16.32.23 -U scc -d geosfb
shp2pgsql -d -W LATIN1 -s 4674 -g shape patio_principal.shp scc.temp_patio_principal | psql -h 172.16.32.23 -U scc -d geosfb
shp2pgsql -d -W LATIN1 -s 4674 -g shape trilhas_arraste_upa5.shp scc.temp_trilhas_arraste | psql -h 172.16.32.23 -U scc -d geosfb
shp2pgsql -d -W LATIN1 -s 4674 -g shape unidades_trabalho_upa5.shp scc.temp_unidade_trabalho | psql -h 172.16.32.23 -U scc -d geosfb


shp2pgsql -d -W LATIN1 -s 4674 -g shape umf.shp scc.umf | psql -h 172.16.32.23 -U scc -d geosfb




shp2pgsql -d -W LATIN1 -s 4674 -g shape Limite_UPA11.shp scc.temp_upa | psql -h pgsqldv01.florestal.gov.br -U dbscc -d geoscc



shp2pgsql -d -W LATIN1 -s 4674 -g shape arvore_upa5.shp scc.temp_arvores | psql -h 172.16.32.23 -U scc -d geosfb
shp2pgsql -d -W LATIN1 -s 4674 -g shape parcelas_permanetes_upa5.shp scc.temp_parcelas | psql -h 172.16.32.23 -U scc -d geosfb
shp2pgsql -d -W LATIN1 -s 4674 -g shape estradas_upa5.shp scc.temp_estradas | psql -h 172.16.32.23 -U scc -d geosfb
shp2pgsql -d -W LATIN1 -s 4674 -g shape patios_planejados_upa5.shp scc.temp_patios | psql -h 172.16.32.23 -U scc -d geosfb

shp2pgsql -d -W LATIN1 -s 4674 -g shape app_upa5.shp scc.temp_app | psql -h 172.16.32.23 -U scc -d geosfb
shp2pgsql -d -W LATIN1 -s 4674 -g shape espelho_dagua_upa5.shp scc.temp_espelho_dagua | psql -h 172.16.32.23 -U scc -d geosfb
shp2pgsql -d -W LATIN1 -s 4674 -g shape hidrografia_upa5.shp scc.temp_hidrografia | psql -h 172.16.32.23 -U scc -d geosfb
shp2pgsql -d -W LATIN1 -s 4674 -g shape nascente_upa5.shp scc.temp_nascentes | psql -h 172.16.32.23 -U scc -d geosfb
shp2pgsql -d -W LATIN1 -s 4674 -g shape patio_principal.shp scc.temp_patio_principal | psql -h 172.16.32.23 -U scc -d geosfb
shp2pgsql -d -W LATIN1 -s 4674 -g shape trilhas_arraste_upa5.shp scc.temp_trilhas_arraste | psql -h 172.16.32.23 -U scc -d geosfb
shp2pgsql -d -W LATIN1 -s 4674 -g shape unidades_trabalho_upa5.shp scc.temp_unidade_trabalho | psql -h 172.16.32.23 -U scc -d geosfb





 app_upa5.shp
 arvore_upa5.shp
 espelho_dagua_upa5.shp
 estradas_upa5.shp
 hidrografia_upa5.shp
 limite_upa5.shp
 nascente_upa5.shp
 parcelas_permanetes_upa5.shp
 patios_planejados_upa5.shp
 patio_principal.shp
 trilhas_arraste_upa5.shp
 unidades_trabalho_upa5.shp



 CREATE OR REPLACE FUNCTION scc.centro(IN _tbl regclass, IN registro integer, OUT centroide char) AS $$

 BEGIN
 EXECUTE format('SELECT ST_AsText(ST_Centroid(shape)) FROM %s WHERE objectid=%s',_tbl, registro)
 INTO centroide;
 END;
 $$LANGUAGE plpgsql;





SELECT * FROM scc.centro('scc.scc_upa', 314);




 CREATE OR REPLACE FUNCTION scc.scc_centro_upa(IN umf integer, IN upa integer, OUT centroide char) AS $$

 BEGIN
 EXECUTE format('SELECT ST_AsText(ST_Centroid(shape)) FROM scc.scc_upa WHERE num_umf=%s AND num_upa=%s', umf, upa )
 INTO centroide;
 END;
 $$LANGUAGE plpgsql;





SELECT * FROM scc.centro(6, 7);




--Data - 20150623
 --FUNCAO PARA VALIDACAO E INCLUSAO DE UPA NA UMF, RETORNA TRUE SE VALIDADO (COPIA REGISTROS PARA TABELA scc.scc_upa)
 -- E FALSE SE NÃO VALIDADO. DEVOLVE O PORCENTUAL DE ÁREA FORA DA UMF E QUANTAS UPA EXISTENTES ELE SE SOBREPÕE SE FOR O CASO
-- NA INCLUSÃO VERIFICA SE JÁ EXISTE OUTRO REGISTRO COM MESMO UMF E UPA QUE ESTÃO MARCADOS COMO INATIVOS (ATIVO = 0) 
-- CASO EXISTAM, ADICIONA UMA CENTENA NO NÚMERO DA UPA PARA CADA REGISTRO IGUAL EXISTENTE

 CREATE OR REPLACE FUNCTION scc.scc_val_upa(id_umf integer, OUT pn boolean, OUT v_umf float, OUT v_upa integer) AS $$
--Data - 20150623
 DECLARE valida float;
 DECLARE valida2 float;
 DECLARE valida3 integer;
 DECLARE addicupa integer;
 DECLARE org RECORD;
 DECLARE geom_umf geometry;
 DECLARE geom_upa geometry;
 DECLARE orgupa scc.scc_upa%rowtype;
 BEGIN

	geom_umf := ST_Union(ARRAY(SELECT shape FROM sde.umfs WHERE
 sde.umfs.id_umf = $1));
	geom_upa := ST_Union(ARRAY(SELECT temp_upa.shape FROM scc.temp_upa));
	valida := 0;
	org := (SELECT (num_upa , area_ha , geom_upa) 
			FROM scc.temp_upa
		);

					INSERT INTO scc.scc_upa (num_upa, area_ha, shape, num_umf, ativo) 
					VALUES(org.f1+addicupa, org.f2, org.f3, $1, TRUE);
	
	v_umf := 0;
	v_upa := 0;
	pn := TRUE;

 END;
 $$LANGUAGE plpgsql;


 -- Código para chamar função:
 --SELECT * FROM scc.scc_val_upa(1);



--Data - 20150623
-- FUNCAO PARA VALIDACAO E INCLUSAO DE DAS ÁRVORES NA UPA SE RETORNA "0", VALIDADO E COPIADOS
--OS REGISTROS PARA TABELA scc.scc_arvores, RETORNA NÚMERO DE ÁRVORES FORA DA TOLERâNCIA SE
--NÃO VÁLIDO. RETORNA TOTAL DE ÁRVORES REPETIDAS CASO HAJA REGISTROS IGUAIS AOS QUE SE ESTÁ
--TENTANDO INSERIR. NÃO ATUALIZA OS EXISTENTES, APENAS INCLUI OS NÃO EXISTENTES.
CREATE OR REPLACE FUNCTION scc.scc_val_arvore(id_umf integer,OUT valido boolean,
       	OUT fora_tolerancia integer, OUT repetido integer) AS $$
--Data - 20150623
DECLARE org scc.temp_arvores%rowtype;
BEGIN
	valido := TRUE;
	fora_tolerancia := 0;
	repetido:=0;

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
		    FROM scc.scc_arvores, scc.temp_arvores
		    WHERE scc.scc_arvores.num_upa=scc.temp_arvores.num_upa
		    AND scc.scc_arvores.num_ut=scc.temp_arvores.num_ut
		    AND scc.scc_arvores.num_arvore=scc.temp_arvores.num_arvore
		    AND scc.scc_arvores.num_umf=id_umf
		  )
		 );
  END;
$$LANGUAGE plpgsql;



-- Código para chamar função:
SELECT * FROM scc.scc_val_arvore(1);





--Data - 20150623
--FUNCAO PARA VALIDACAO E INCLUSAO DE ESTRADAS NA UMF SE RETORNA "0" (est_val) SE VALIDADO E SÃO COPIADOS OS REGISTROS PARA TABELA scc.scc_estradas, RETORNA NÚMERO DE ESTRADAS FORA DA UMF SE NÃO VÁLIDO. CASO AS ESTRADAS VALIDADAS JÁ EXISTAM, DEVOLVE O NÚMERO DE ESTRADAS REPETIDAS (est_rep).

CREATE OR REPLACE FUNCTION scc.scc_val_estradas(id_umf integer, OUT est_val integer, OUT est_rep integer) AS $$
--Data - 20150623
DECLARE org scc.temp_estradas%rowtype;
DECLARE geom_umf geometry;

BEGIN
		geom_umf := ST_Union(ARRAY(SELECT shape FROM sde.umfs WHERE sde.umfs.id_umf = $1));
	est_rep := 0;
	est_val := 0;

				INSERT INTO scc.scc_estradas(num_upa, comp_m, tipo, shape) 
	              		(SELECT temp_estradas.num_upa, temp_estradas.comp_m, temp_estradas.tipo, temp_estradas.shape
				  FROM scc.temp_estradas
				  WHERE NOT EXISTS (SELECT scc.scc_estradas.num_upa, scc.scc_estradas.comp_m, scc.scc_estradas.shape FROM scc.scc_estradas, scc.temp_estradas 
				  WHERE scc.scc_estradas.comp_m=scc.temp_estradas.comp_m
					AND scc.scc_estradas.tipo=scc.temp_estradas.tipo));

END;
$$LANGUAGE plpgsql;


--SELECT * FROM scc.scc_val_estradas(1);




--Data - 20150623
--FUNCAO PARA VALIDACAO E INCLUSAO DE PATIOS DE ESTOCAGEM NA UMF SE RETORNA "0" SE VALIDADO E SÃO COPIADOS OS REGISTROS PARA TABELA scc.scc_patios_estocagem, RETORNA NÚMERO DE PÁTIOS FORA DA UMF SE NÃO VÁLIDO. SE VÁLIDO E HOUVER PÁTIOS REPETIDOS, RETONA O TOTAL.

CREATE OR REPLACE FUNCTION scc.scc_val_patios_estocagem(id_umf integer, OUT fora_umf integer, OUT repetidos integer) AS $$
--Data - 20150623
DECLARE org scc.temp_patios%rowtype;
DECLARE geom_umf geometry;
BEGIN
	geom_umf := ST_Union(ARRAY(SELECT shape FROM sde.umfs WHERE sde.umfs.id_umf = $1));
	fora_umf := 0;
	repetidos:=0;
				INSERT INTO scc.scc_patios_estocagem(num_upa, cod_pat, shape, num_umf) 
	              		(SELECT scc.temp_patios.num_upa, (scc.temp_patios.cod_pat::varchar), scc.temp_patios.shape, $1
				 FROM scc.temp_patios
				  WHERE NOT EXISTS 
				  (SELECT scc.scc_patios_estocagem.num_upa, scc.scc_patios_estocagem.cod_pat FROM scc.temp_patios, scc.scc_patios_estocagem
				    WHERE temp_patios.num_upa=scc_patios_estocagem.num_upa AND (temp_patios.cod_pat::varchar)=scc_patios_estocagem.cod_pat AND scc.scc_patios_estocagem.num_umf=$1
				  )
				);


END;
$$LANGUAGE plpgsql;


SELECT * FROM scc.scc_val_patios_estocagem(1);



--Data - 20150623
--FUNCAO PARA VALIDACAO E INCLUSAO DE PARCELAS PERMANENTES NA UMF SE RETORNA "0" SE VALIDADO E SÃO COPIADOS OS REGISTROS PARA TABELA scc.scc_parcelas, RETORNA NÚMERO DE PARCELAS FORA DA UMF SE NÃO VÁLIDO. SE VÁLIDO E HOUVER PARCELAS REPETIDAS, RETORNA O TOTAL.

CREATE OR REPLACE FUNCTION scc.scc_val_parcelas(id_umf integer, OUT fora_umf integer, OUT repetidos integer)  AS $$
--Data - 20150623

DECLARE org scc.temp_parcelas%rowtype;
DECLARE geom_umf geometry;
BEGIN
	geom_umf := ST_Union(ARRAY(SELECT shape FROM sde.umfs WHERE sde.umfs.id_umf = $1));
	fora_umf := 0;
	repetidos:=0;
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


END;
$$LANGUAGE plpgsql;


--SELECT * FROM scc.scc_val_parcelas(1);



--Data - 20150623
--FUNCAO PARA VALIDACAO E INCLUSAO DE PATIOS PRINCIPAIS NA UMF RETORNA "0" SE VALIDADO E SÃO COPIADOS OS REGISTROS PARA TABELA scc.scc_patio_PRINCIPAL, RETORNA NÚMERO DE PÁTIOS FORA DA UMF SE NÃO VÁLIDO. SE VÁLIDO E HOUVER PÁTIOS REPETIDOS, RETONA O TOTAL.


CREATE OR REPLACE FUNCTION scc.scc_val_patio_principal(id_umf integer, OUT fora_umf integer, OUT repetidos integer) AS $$
--Data - 20150623
DECLARE org scc.temp_patio_principal%rowtype;
DECLARE geom_umf geometry;
BEGIN
	geom_umf := ST_Union(ARRAY(SELECT shape FROM sde.umfs WHERE sde.umfs.id_umf = $1));
	fora_umf := 0;
	repetidos:=0;

				INSERT INTO scc.scc_patio_principal( num_umf, shape) 
	              		(SELECT $1, scc.temp_patio_principal.shape
				 FROM scc.temp_patio_principal
				  WHERE NOT EXISTS 
				  (SELECT  scc.scc_patio_principal.shape FROM scc.temp_patio_principal, scc.scc_patio_principal
				    WHERE temp_patio_principal.shape=scc_patio_principal.shape AND $1=scc_patio_principal.num_umf
				  )
				);
END;
$$LANGUAGE plpgsql;


--SELECT * FROM scc.scc_val_patio_principal(1);




--Data - 20150623
--FUNCAO PARA VALIDACAO E INCLUSAO DE NASCENTES NA UMF RETORNA "0" SE VALIDADO E SÃO COPIADOS OS REGISTROS PARA TABELA scc.scc_nascentes, RETORNA NÚMERO DE NASCENTES FORA DA UMF SE NÃO VÁLIDO. SE VÁLIDO E HOUVER PÁTIOS REPETIDOS, RETONA O TOTAL.

CREATE OR REPLACE FUNCTION scc.scc_val_nascentes(id_umf integer, OUT fora_umf integer, OUT repetidos integer) AS $$
--Data - 20150623
DECLARE org scc.temp_nascentes%rowtype;
DECLARE geom_umf geometry;
BEGIN
	geom_umf := ST_Union(ARRAY(SELECT shape FROM sde.umfs WHERE sde.umfs.id_umf = $1));
	fora_umf := 0;
	repetidos:=0;
				INSERT INTO scc.scc_nascentes(num_upa, shape) 
	              		(SELECT scc.temp_nascentes.num_upa, scc.temp_nascentes.shape
				 FROM scc.temp_nascentes
				  WHERE NOT EXISTS 
				  (SELECT scc.scc_nascentes.num_upa, scc.scc_nascentes.shape FROM scc.temp_nascentes, scc.scc_nascentes
				    WHERE temp_nascentes.num_upa=scc_nascentes.num_upa AND temp_nascentes.shape=scc_nascentes.shape
				  )
				);
END;
$$LANGUAGE plpgsql;



--SELECT * FROM scc.scc_val_nascentes(1);




--Data - 20150623
--FUNCAO PARA VALIDACAO E INCLUSAO DE TRILHAS DE ARRASTE NA UMF RETORNA "0" SE VALIDADO E SÃO COPIADOS OS REGISTROS PARA TABELA scc.scc_trilhas_arraste, RETORNA NÚMERO DE TRILHAS FORA DA UMF SE NÃO VÁLIDO. SE VÁLIDO E HOUVER TRILHAS REPETIDAS, RETONA O TOTAL.

CREATE OR REPLACE FUNCTION scc.scc_val_trilhas_arraste(id_umf integer, OUT est_val integer, OUT est_rep integer) AS $$
--Data - 20150623
DECLARE org scc.temp_trilhas_arraste%rowtype;
DECLARE geom_umf geometry;

BEGIN
		geom_umf := ST_Union(ARRAY(SELECT shape FROM sde.umfs WHERE sde.umfs.id_umf = $1));
	est_rep := 0;
	est_val :=0;
	est_rep :=0;
				INSERT INTO scc.scc_trilhas_arraste(num_umf, num_upa, comp_m, shape) 
	              		(SELECT $1, scc.temp_trilhas_arraste.num_upa, scc.temp_trilhas_arraste.comp_m, scc.temp_trilhas_arraste.shape
				  FROM scc.temp_trilhas_arraste
				  WHERE NOT EXISTS (SELECT scc.scc_trilhas_arraste.num_upa, scc.scc_trilhas_arraste.comp_m, scc.scc_trilhas_arraste.shape FROM scc.scc_trilhas_arraste, scc.temp_trilhas_arraste 
				  WHERE scc.scc_trilhas_arraste.comp_m=scc.temp_trilhas_arraste.comp_m
					AND scc.scc_trilhas_arraste.shape=scc.temp_trilhas_arraste.shape)
				);
END;
$$LANGUAGE plpgsql;


--SELECT * FROM scc.scc_val_trilhas_arraste(1);




--Data - 20150623
--FUNCAO PARA VALIDACAO E INCLUSAO DE APP NA UMF RETORNA "0" SE VALIDADO E SÃO COPIADOS OS REGISTROS PARA TABELA scc.scc_app, RETORNA NÚMERO APP FORA DA UMF SE NÃO VÁLIDO. SE VÁLIDO E HOUVER APP REPETIDAS, RETONA O TOTAL.

CREATE OR REPLACE FUNCTION scc.scc_val_app(id_umf integer, OUT fora_umf integer, OUT repetidos integer) AS $$
--Data - 20150623
DECLARE org scc.temp_app%rowtype;
DECLARE geom_umf geometry;
BEGIN
	geom_umf := ST_Union(ARRAY(SELECT shape FROM sde.umfs WHERE sde.umfs.id_umf = $1));
	fora_umf := 0;
	repetidos:=0;
				INSERT INTO scc.scc_app(num_upa, area_ha, shape) 
	              		(SELECT scc.temp_app.num_upa, scc.temp_app.area_ha, scc.temp_app.shape
				 FROM scc.temp_app
				  WHERE NOT EXISTS 
				  (SELECT scc.scc_app.num_upa, scc.scc_app.area_ha FROM scc.temp_app, scc.scc_app
				    WHERE temp_app.num_upa=scc_app.num_upa AND temp_app.area_ha=scc_app.area_ha
				  )
				);
END;
$$LANGUAGE plpgsql;


--SELECT * FROM scc.scc_val_app(1);





--Data - 20150623
--FUNCAO PARA VALIDACAO E INCLUSAO DE ESPELHOS D'ÁGUA NA UMF RETORNA "0" SE VALIDADO E SÃO COPIADOS OS REGISTROS PARA TABELA scc.scc_espelho_dagua, RETORNA NÚMERO DE ESPELHOS FORA DA UMF SE NÃO VÁLIDO. SE VÁLIDO E HOUVER ESPELHOS REPETIDOS, RETONA O TOTAL.

CREATE OR REPLACE FUNCTION scc.scc_val_espelho_dagua(id_umf integer, OUT fora_umf integer, OUT repetidos integer) AS $$
--Data - 20150623
DECLARE org scc.temp_espelho_dagua%rowtype;
DECLARE geom_umf geometry;
BEGIN
	geom_umf := ST_Union(ARRAY(SELECT shape FROM sde.umfs WHERE sde.umfs.id_umf = $1));
	fora_umf := 0;
	repetidos:=0;

				INSERT INTO scc.scc_espelho_dagua(num_upa, area_ha, shape) 
	              		(SELECT scc.temp_espelho_dagua.num_upa, scc.temp_espelho_dagua.area_ha, scc.temp_espelho_dagua.shape
				 FROM scc.temp_espelho_dagua
				  WHERE NOT EXISTS 
				  (SELECT scc.scc_espelho_dagua.num_upa, scc.scc_espelho_dagua.area_ha FROM scc.temp_espelho_dagua, scc.scc_espelho_dagua
				    WHERE temp_espelho_dagua.num_upa=scc_espelho_dagua.num_upa AND temp_espelho_dagua.area_ha=scc_espelho_dagua.area_ha
				  )
				);
END;
$$LANGUAGE plpgsql;


--SELECT * FROM scc.scc_val_espelho_dagua(1);



--Data - 20150623
--FUNCAO PARA VALIDACAO E INCLUSAO DE UNIDADES DE TRABALHO NA UMF RETORNA "0" SE VALIDADO E SÃO COPIADOS OS REGISTROS PARA TABELA scc.scc_unidade_trabalho, RETORNA NÚMERO DE UTS FORA DA UMF SE NÃO VÁLIDO. SE VÁLIDO E HOUVER UTS REPETIDOS, RETONA O TOTAL.

CREATE OR REPLACE FUNCTION scc.scc_val_unidade_trabalho(id_umf integer, OUT fora_umf integer, OUT repetidos integer) AS $$
--Data - 20150623
DECLARE org scc.temp_unidade_trabalho%rowtype;
DECLARE geom_umf geometry;
BEGIN
	geom_umf := ST_Union(ARRAY(SELECT shape FROM sde.umfs WHERE sde.umfs.id_umf = $1));
	fora_umf := 0;
	repetidos:=0;

				INSERT INTO scc.scc_unidade_trabalho(num_upa, area_ha, cod_ut, shape) 
	              		(SELECT scc.temp_unidade_trabalho.num_upa, scc.temp_unidade_trabalho.area_ha, (temp_unidade_trabalho.cod_ut::integer), scc.temp_unidade_trabalho.shape
				 FROM scc.temp_unidade_trabalho
				  WHERE NOT EXISTS 
				  (SELECT scc.scc_unidade_trabalho.num_upa, scc.scc_unidade_trabalho.cod_ut FROM scc.temp_unidade_trabalho, scc.scc_unidade_trabalho
				    WHERE temp_unidade_trabalho.num_upa=scc_unidade_trabalho.num_upa AND (temp_unidade_trabalho.cod_ut::integer)=(scc_unidade_trabalho.cod_ut::integer)
				  )
				);
END;
$$LANGUAGE plpgsql;


SELECT * FROM scc.scc_val_unidade_trabalho(1);





--Data - 20150623
--FUNCAO PARA VALIDACAO E INCLUSAO DE HIDROGRAFIA NA UMF RETORNA "0" SE VALIDADO E SÃO COPIADOS OS REGISTROS PARA TABELA scc.scc_hidrografia, RETORNA NÚMERO DE HIDROGRAFIA FORA DA UMF SE NÃO VÁLIDO. SE VÁLIDO E HOUVER HIDROGRAFIA REPETIDAS, RETONA O TOTAL.

CREATE OR REPLACE FUNCTION scc.scc_val_hidrografia(id_umf integer, OUT est_val integer, OUT est_rep integer) AS $$
--Data - 20150623
DECLARE org scc.temp_hidrografia%rowtype;
DECLARE geom_umf geometry;

BEGIN
		geom_umf := ST_Union(ARRAY(SELECT shape FROM sde.umfs WHERE sde.umfs.id_umf = $1));
	est_rep := 0;
	est_val := 0;
	est_rep := 0;
				INSERT INTO scc.scc_hidrografia(num_upa, comp_m, shape) 
	              		(SELECT temp_hidrografia.num_upa, temp_hidrografia.comp_m, temp_hidrografia.shape
				  FROM scc.temp_hidrografia
				  WHERE NOT EXISTS (SELECT scc.scc_hidrografia.num_upa, scc.scc_hidrografia.comp_m, scc.scc_hidrografia.shape FROM scc.scc_hidrografia, scc.temp_hidrografia 
				  WHERE  scc.scc_hidrografia.shape=scc.temp_hidrografia.shape)
				);
END;
$$LANGUAGE plpgsql;


--SELECT * FROM scc.scc_val_hidrografia(1);


