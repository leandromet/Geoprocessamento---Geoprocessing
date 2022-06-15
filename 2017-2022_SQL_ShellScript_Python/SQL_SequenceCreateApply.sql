CREATE SEQUENCE scc_seq_app
  INCREMENT 1
  MINVALUE 1
  MAXVALUE 2147483647
  START 1
  CACHE 1;
ALTER TABLE scc_seq_app OWNER TO geo_administrador;

CREATE SEQUENCE scc_seq_arvores
  INCREMENT 1
  MINVALUE 1
  MAXVALUE 2147483647
  START 1
  CACHE 1;
ALTER TABLE scc_seq_arvores OWNER TO geo_administrador;

CREATE SEQUENCE scc_seq_estradas
  INCREMENT 1
  MINVALUE 1
  MAXVALUE 2147483647
  START 1
  CACHE 1;
ALTER TABLE scc_seq_estradas OWNER TO geo_administrador;




CREATE SEQUENCE scc_seq_patio_principal
  INCREMENT 1
  MINVALUE 1
  MAXVALUE 2147483647
  START 1
  CACHE 1;
ALTER TABLE scc_seq_patio_principal OWNER TO geo_administrador;
CREATE SEQUENCE scc_seq_patio_estocagem
  INCREMENT 1
  MINVALUE 1
  MAXVALUE 2147483647
  START 1
  CACHE 1;
ALTER TABLE scc_seq_patio_estocagem
  OWNER TO geo_administrador;
CREATE SEQUENCE scc_seq_trilhas_arraste
  INCREMENT 1
  MINVALUE 1
  MAXVALUE 2147483647
  START 1
  CACHE 1;
ALTER TABLE scc_seq_trilhas_arraste  OWNER TO geo_administrador;
CREATE SEQUENCE scc_seq_upa
  INCREMENT 1
  MINVALUE 1
  MAXVALUE 2147483647
  START 1
  CACHE 1;
ALTER TABLE scc_seq_upa  OWNER TO geo_administrador;
CREATE SEQUENCE scc_seq_unidade_trabalho
  INCREMENT 1
  MINVALUE 1
  MAXVALUE 2147483647
  START 1
  CACHE 1;
ALTER TABLE scc_seq_unidade_trabalho
  OWNER TO geo_administrador;
CREATE SEQUENCE scc_seq_umf  INCREMENT 1
  MINVALUE 1
  MAXVALUE 2147483647
  START 1
  CACHE 1;
ALTER TABLE scc_seq_umf
  OWNER TO geo_administrador;
CREATE SEQUENCE scc_seq_espelho_dagua
  INCREMENT 1
  MINVALUE 1
  MAXVALUE 2147483647
  START 1
  CACHE 1;
ALTER TABLE scc_seq_espelho_dagua
  OWNER TO geo_administrador;
CREATE SEQUENCE scc_seq_parcelas_permanentes  INCREMENT 1
  MINVALUE 1
  MAXVALUE 2147483647
  START 1
  CACHE 1;
ALTER TABLE scc_seq_parcelas_permanentes
  OWNER TO geo_administrador;
CREATE SEQUENCE scc_seq_nascentes  INCREMENT 1
  MINVALUE 1
  MAXVALUE 2147483647
  START 1
  CACHE 1;
ALTER TABLE scc_seq_nascentes   OWNER TO geo_administrador;

ALTER TABLE scc.scc_patio_principal ALTER COLUMN objectid SET DEFAULT nextval('scc.scc_seq_patio_principal'::regclass);

ALTER TABLE scc.scc_patios_estocagem ALTER COLUMN objectid SET DEFAULT nextval('eq_patio_estocagem'::regclass);

ALTER TABLE scc.scc_seq_trilhas_arraste ALTER COLUMN objectid SET DEFAULT nextval('scc.scc_seq_seq_trilhas_arraste'::regclass);
ALTER TABLE scc.scc_unidade_trabalho ALTER COLUMN objectid SET DEFAULT nextval('scc.scc_seq_unidade_trabalho'::regclass);

ALTER TABLE scc.scc_upa ALTER COLUMN objectid SET DEFAULT nextval('scc.scc_seq_upa'::regclass);

ALTER TABLE scc.scc_estradas ALTER COLUMN objectid SET DEFAULT nextval('scc.scc_seq_estradas'::regclass);

ALTER TABLE scc.scc_hidrografia ALTER COLUMN objectid SET DEFAULT nextval('scc.scc_seq_hidrografia'::regclass);

ALTER TABLE scc.scc_umf ALTER COLUMN objectid SET DEFAULT nextval('scc.scc_seq_umf'::regclass);

ALTER TABLE scc.scc_arvores ALTER COLUMN objectid SET DEFAULT nextval('scc.scc_seq_arvores'::regclass);

ALTER TABLE scc.scc_parcelas_permanentes ALTER COLUMN objectid SET DEFAULT nextval('scc.scc_seq_parcelas_permanentes'::regclass);

ALTER TABLE scc.scc_nascentes ALTER COLUMN objectid SET DEFAULT nextval('scc.scc_seq_nascentes'::regclass);

ALTER TABLE scc.scc_espelho_dagua ALTER COLUMN objectid SET DEFAULT nextval('scc.scc_seq_espelho_dagua'::regclass);
