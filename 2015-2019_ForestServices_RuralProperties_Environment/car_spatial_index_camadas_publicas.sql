


---criar chave primária

ALTER TABLE geoserver.tema_simp_26_imovel
    ADD CONSTRAINT pk_tema_simp_26_imovel PRIMARY KEY (idt_rel_tema_imovel)

    USING INDEX TABLESPACE sicar1;
    
    
    ----criar indice da chave primaria
 CREATE UNIQUE INDEX idx_btree_idt_tema_simp_26_imovel
    ON geoserver.tema_simp_26_imovel USING btree
    (idt_rel_tema_imovel ASC NULLS LAST)
    INCLUDE(idt_rel_tema_imovel)
    TABLESPACE sicar1   
;
    --- criar índice espacial
    
CREATE INDEX idx_gist_tema_simp_26_imovel
    ON geoserver.tema_simp_26_imovel USING gist
    (st_simplifypreservetopology)
    TABLESPACE sicar1;
    
    
    
    

    
ALTER TABLE geoserver.tema_simp_1_consolidado
    ADD CONSTRAINT pk_tema_simp_1_consolidado PRIMARY KEY (idt_rel_tema_imovel)

    USING INDEX TABLESPACE sicar1;


 CREATE UNIQUE INDEX idx_btree_idt_tema_simp_1_consolidado
    ON geoserver.tema_simp_1_consolidado USING btree
    (idt_rel_tema_imovel ASC NULLS LAST)
    INCLUDE(idt_rel_tema_imovel)
    TABLESPACE sicar1   
;


    CREATE INDEX idx_gist_tema_simp_1_consolidado
    ON geoserver.tema_simp_1_consolidado USING gist
    (st_simplifypreservetopology)
    TABLESPACE sicar1;
    
    
    
ALTER TABLE geoserver.tema_simp_2_rvn
    ADD CONSTRAINT pk_tema_simp_2_rvn PRIMARY KEY (idt_rel_tema_imovel)

    USING INDEX TABLESPACE sicar1;
    
    
    
 
 CREATE UNIQUE INDEX idx_btree_idt_tema_simp_2_rvn
    ON geoserver.tema_simp_2_rvn USING btree
    (idt_rel_tema_imovel ASC NULLS LAST)
    INCLUDE(idt_rel_tema_imovel)
    TABLESPACE sicar1   
;   
    
    
    
CREATE INDEX idx_gist_tema_simp_2_rvn
    ON geoserver.tema_simp_2_rvn USING gist
    (st_simplifypreservetopology)
    TABLESPACE sicar1;




    
ALTER TABLE geoserver.tema_simp_30_app
    ADD CONSTRAINT pk_tema_simp_30_app PRIMARY KEY (idt_rel_tema_imovel)

    USING INDEX TABLESPACE sicar1;
    
    
     CREATE UNIQUE INDEX idx_btree_idt_tema_simp_30_app
    ON geoserver.tema_simp_30_app USING btree
    (idt_rel_tema_imovel ASC NULLS LAST)
    INCLUDE(idt_rel_tema_imovel)
    TABLESPACE sicar1   
;   
    
    CREATE INDEX idx_gist_tema_simp_30_app
    ON geoserver.tema_simp_30_app USING gist
    (st_simplifypreservetopology gist_geometry_ops_nd)
    TABLESPACE sicar1;
    
ALTER TABLE geoserver.tema_simp_32_rl
    ADD CONSTRAINT pk_tema_simp_32_rl PRIMARY KEY (idt_rel_tema_imovel)

    USING INDEX TABLESPACE sicar1;
    
         CREATE UNIQUE INDEX idx_btree_idt_tema_simp_32_rl
    ON geoserver.tema_simp_32_rl USING btree
    (idt_rel_tema_imovel ASC NULLS LAST)
    INCLUDE(idt_rel_tema_imovel)
    TABLESPACE sicar1   
;   
    
    
    
    
    CREATE INDEX idx_gist_tema_simp_32_rl
    ON geoserver.tema_simp_32_rl USING gist
    (st_simplifypreservetopology gist_geometry_ops_nd)
    TABLESPACE sicar1;
    

ALTER TABLE geoserver.atlas_nascentes
    ADD CONSTRAINT pk_tema_simp_atlas_nascentes PRIMARY KEY (idt_rel_tema_imovel)

    USING INDEX TABLESPACE sicar1;
    
    
    ----criar indice da chave primaria
 CREATE UNIQUE INDEX idx_btree_idt_atlas_nascentes
    ON geoserver.atlas_nascentes USING btree
    (idt_rel_tema_imovel ASC NULLS LAST)
    INCLUDE(idt_rel_tema_imovel)
    TABLESPACE sicar1   
;
    --- criar índice espacial
    
CREATE INDEX idx_gist_atlas_nascentes
    ON geoserver.atlas_nascentes USING gist
    (st_simplifypreservetopology)
    TABLESPACE sicar1;

