-FUNCAO PARA VALIDACAO E INCLUSAO DE TI NO cnfp, RETORNA TRUE SE VALIDADO (COPIA REGISTROS PARA TABELA scc.scc_upa)
 -- E FALSE SE NÃO VALIDADO. DEVOLVE O PORCENTUAL DE ÁREA FORA DA UMF E QUANTAS UPA EXISTENTES ELE SE SOBREPÕE

 CREATE OR REPLACE FUNCTION cnfp.f_adic_ti
(IN anoCNFP integer, IN dataAtual date, OUT pn boolean, OUT Territorio float, OUT Verificado integer, OUT Nov_Geom integer, OUT Nov_Atrib integer, OUT Nov_Dado integer ) AS $$
 DECLARE valida float;
 DECLARE valida3 integer;
 DECLARE org RECORD;
 DECLARE geom_Brasil geometry;
 DECLARE orgitem cnfp.orig_fedti%rowtype;
 DECLARE orgitem2 cnfp.adic_ti%rowtype;
 BEGIN

Nov_Geom := 0;
Nov_Atrib := 0;
Nov_Dado := 0;

geom_Brasil := ST_Union(ARRAY(SELECT shape FROM cnfp.base_uf_s2000));
valida := (SELECT count(adic_ti.gid) FROM cnfp.adic_ti
WHERE NOT ST_Intersects(geom_Brasil, cnfp.adic_ti.shape) );
IF valida = 0

THEN 
 
valida3 := 0;
valida3:=valida3+(SELECT count(cnfp.orig_fedti.id_ti)
   FROM cnfp.orig_fedti, cnfp.adic_ti
   WHERE cnfp.orig_fedti.etapa=cnfp.adic_ti.fase_ti
   AND cnfp.orig_fedti.nome_ti=substring(cnfp.adic_ti.terrai_nom for 40)
   AND (SELECT cnfp.orig_fedti.shape~=cnfp.adic_ti.shape)=TRUE
 );
raise notice 'Valida3 = %', valida3;
IF valida3 = 0
THEN
INSERT INTO cnfp.orig_fedti(uf, nome_ti, etapa, shape, ano_inc_cnfp, documento, data_atual) 
(SELECT cnfp.adic_ti.uf_sigla , substring(cnfp.adic_ti.terrai_nom for 40), cnfp.adic_ti.fase_ti , cnfp.adic_ti.shape , $1,'Decreto', $2
FROM cnfp.adic_ti);
raise notice 'INSERE';
ELSE
     FOR orgitem IN SELECT * FROM cnfp.orig_fedti WHERE data_inativo is null 
     LOOP
raise notice 'orgitem = %', orgitem.nome_ti;
FOR orgitem2 IN SELECT * FROM cnfp.adic_ti
      LOOP
 IF ((SELECT orgitem.shape~=orgitem2.shape)=TRUE) 
THEN
Nov_Atrib := Nov_Atrib+1;
UPDATE cnfp.orig_fedti
SET (uf, nome_ti, etapa, documento, data_atual) = 
(orgitem2.uf_sigla, substring(orgitem2.terrai_nom for 40), orgitem2.fase_ti,'Decreto', $2)
WHERE cnfp.orig_fedti.id_ti=orgitem.id_ti
;
    ELSE
IF (orgitem2.terrai_nom=orgitem.nome_ti AND orgitem2.fase_ti=orgitem.etapa)
THEN
raise notice 'orgitem2 = %', orgitem2.terrai_nom;
Nov_Geom := Nov_Geom+1;
UPDATE cnfp.orig_fedti
SET (data_inativo) = 
($2)
FROM cnfp.adic_ti
WHERE cnfp.orig_fedti.id_ti=orgitem.id_ti;

INSERT INTO cnfp.orig_fedti(uf, nome_ti, etapa, shape, ano_inc_cnfp, documento, data_atual) 
VALUES (orgitem2.uf_sigla , substring(orgitem2.terrai_nom for 40), orgitem2.fase_ti , orgitem2.shape , $1,'Decreto', $2);
ELSIF ((select exists(SELECT 1 FROM cnfp.orig_fedti WHERE cnfp.orig_fedti.nome_ti=substring(orgitem2.terrai_nom for 40)))=FALSE)
THEN
Nov_Dado := Nov_Dado+1;
INSERT INTO cnfp.orig_fedti(uf, nome_ti, etapa, shape, ano_inc_cnfp, documento, data_atual) 
VALUES (orgitem2.uf_sigla , substring(orgitem2.terrai_nom for 40), orgitem2.fase_ti , orgitem2.shape , $1,'Decreto', $2);

END IF;
 
  END IF;
END LOOP;
      END LOOP;
END IF;
END IF;
Territorio := valida;
Verificado := valida3;
IF valida < (0.05) AND valida3 = 0
THEN 
pn := TRUE;
ELSE
pn := FALSE;
END IF;
 END;
 $$LANGUAGE plpgsql;

 -- Código para chamar função:
 --SELECT * FROM cnfp.f_adic_ti();
