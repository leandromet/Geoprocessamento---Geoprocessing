-- cnfp.orig_fedti
-- cnfp.orig_feduc

--Cria  tabela com categorias

CREATE TABLE cnfp.feduc_union as
SELECT ST_Multi(ST_Union(cnfp.orig_feduc.shape)), cnfp.orig_feduc.tipo_uc as tipo_uc FROM cnfp.orig_feduc WHERE tipo_uc<>'APA' GROUP BY tipo_uc;




--Cria view para rodar intersection



CREATE OR REPLACE VIEW t1 AS SELECT shape, id_uc FROM cnfp.orig_feduc WHERE 
tipo_uc <>'Área de Proteção Ambiental' AND 
tipo_uc <>'Área de Relevante Interesse Ecológico' AND 
tipo_uc <>'Monumento Natural' AND 
tipo_uc <>'Refúgio de Vida Silvestre'
AND situacao_cnfp =  'Ativo';


CREATE OR REPLACE VIEW t2 AS SELECT shape, id_uc FROM t1;




CREATE OR REPLACE VIEW p_intersections AS    -- Create a view with the 
SELECT t1.shape as t1_geom,               -- intersecting geoms. Each pair
       t2.shape as t2_geom               -- appears once (t2.id<t2.id)
    FROM t1, t2
         WHERE t1.id_uc<t2.id_uc AND t1.shape && t2.shape 
                           AND ST_Intersects (t1.shape, t2.shape);




--DROP TABLE cnfp.feduc_result;

CREATE TABLE cnfp.feduc_result as

SELECT ST_Intersection(ST_MakeValid(t1_geom), ST_MakeValid(t2_geom)) 
    AS geom 
    FROM p_intersections

UNION 

--A\AB:
SELECT ST_Difference(ST_MakeValid(t1_geom), ST_MakeValid(t2_geom)) 
    AS geom 
    FROM p_intersections

UNION

--B\AB:
SELECT ST_Difference(ST_MakeValid(t2_geom), ST_MakeValid(t1_geom)) 
    AS geom 
    FROM p_intersections

UNION

SELECT t1.shape as geom              -- intersecting geoms. Each pair -- appears once (t2.id<t2.id)
    FROM t1, t2
         WHERE t1.id_uc<t2.id_uc AND NOT ST_Intersects (t1.shape, t2.shape);







DROP SEQUENCE result_serial;
CREATE SEQUENCE result_serial;
DROP TABLE cnfp.feduc_final;


alter table  cnfp.feduc_result add column id integer not null default nextval('result_serial');


CREATE OR REPLACE VIEW t3 AS SELECT id, geom from cnfp.feduc_result;


--delete FROM  cnfp.feduc_result
--where id IN (
-- select cnfp.feduc_result.id
-- from cnfp.feduc_result, t3
-- where st_equals(cnfp.feduc_result.geom , t3.geom)
-- and cnfp.feduc_result.id < t3.id
-- );



-- Table: cnfp.feduc_final





CREATE TABLE cnfp.feduc_final
(
  geom geometry,
  id integer NOT NULL DEFAULT nextval('final_serial'::regclass)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE cnfp.feduc_final
  OWNER TO postgres;
GRANT ALL ON TABLE cnfp.feduc_final TO public;
GRANT ALL ON TABLE cnfp.feduc_final TO postgres;










CREATE OR REPLACE FUNCTION cnfp.copia_unico(tolera float, OUT removidos integer) AS $$

DECLARE reg_uc cnfp.feduc_result%rowtype;
DECLARE reg_t3 t3%rowtype;

BEGIN


removidos:=0;
FOR reg_uc IN SELECT * FROM cnfp.feduc_result
LOOP
IF ST_Area(reg_uc.geom)=0
THEN
removidos:=removidos+100000;
ELSE
 
IF NOT ST_Intersects(reg_uc.geom, cnfp.feduc_final.shape) FROM cnfp.feduc_final
THEN
removidos := removidos+1;
INSERT INTO cnfp.feduc_final(shape) VALUES (reg_uc.geom);
 
END IF;
 
END IF;
END LOOP;

END;
$$LANGUAGE plpgsql;

--SELECT * from cnfp.copia_unico(0.0);



CREATE OR REPLACE FUNCTION cnfp.remove_area(tolera float, OUT removidos integer) AS $$

DECLARE reg_uc cnfp.feduc_result%rowtype;
DECLARE reg_t3 t3%rowtype;

BEGIN
removidos:=0;
FOR reg_uc IN SELECT * FROM cnfp.feduc_result WHERE ST_GeometryType(cnfp.feduc_result.geom) ILIKE '%polygon%' 
LOOP
IF ST_Area(reg_uc.geom)=0
THEN
removidos:=removidos+100000;
DELETE FROM cnfp.feduc_result WHERE cnfp.feduc_result.id = reg_uc.id;
ELSE

FOR reg_t3 IN SELECT * FROM t3 WHERE ST_GeometryType(t3.geom) ILIKE '%polygon%' 
LOOP
IF ST_Area(reg_t3.geom)=0
THEN
removidos:=removidos+1000;
ELSE
IF reg_t3.id<reg_uc.id AND ST_Intersects(reg_uc.geom, reg_t3.geom)
THEN
IF ($1 > ((ST_Area(reg_uc.geom)-ST_Area(reg_t3.geom))/ST_Area(reg_uc.geom)))
THEN
removidos := removidos+1;
DELETE FROM cnfp.feduc_result WHERE cnfp.feduc_result.id=reg_uc.id;
END IF;
END IF;
END IF;
END LOOP;
END IF;
END LOOP;

END;
$$LANGUAGE plpgsql;

---SELECT * from cnfp.remove_area(0.01);
