-- Function: analise.area_vetorizada_reser_legal_tecnico_por_tema_analise(integer, integer)

-- DROP FUNCTION analise.area_vetorizada_reser_legal_tecnico_por_tema_analise(integer, integer);

CREATE OR REPLACE FUNCTION analise.area_vetorizada_reser_legal_tecnico_por_tema_analise(
    v_id_analise integer,
    v_id_tema integer)
  RETURNS SETOF record AS
$BODY$
BEGIN
    RETURN QUERY SELECT COALESCE ((ST_Difference (ST_Union(t.the_geom), ST_Union(c.the_geom))) , ST_Union(t.the_geom) ) AS the_geom, 
      ST_Area(ST_Transform( COALESCE ((ST_Difference (ST_Union(t.the_geom), ST_Union(c.the_geom))), ST_Union(t.the_geom)) , usr_geocar_aplicacao.utmzone(ST_Centroid(ST_Union(t.the_geom))))) / 10000 AS nu_area
     FROM analise.imovel_geometria_tecnico t
      LEFT OUTER JOIN analise.imovel_geometria c  
      ON (t.id_analise = c.id_analise) AND c.id_tema IN (23,24,25) AND c.id_analise = v_id_analise    
     WHERE  t.id_tema = v_id_tema AND t.id_analise = v_id_analise;
    RETURN;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100
  ROWS 1000;
ALTER FUNCTION analise.area_vetorizada_reser_legal_tecnico_por_tema_analise(integer, integer)
  OWNER TO postgres;
COMMENT ON FUNCTION analise.area_vetorizada_reser_legal_tecnico_por_tema_analise(integer, integer) IS 'Calcula a área vetorizada da reserva legal pelo técnico utilizando como parametro a analise e o tema.';



-- Function: analise.cancela_processo_de_ir_duplicado(text, text)

-- DROP FUNCTION analise.cancela_processo_de_ir_duplicado(text, text);

CREATE OR REPLACE FUNCTION analise.cancela_processo_de_ir_duplicado(
    p_codigo_imovel text,
    p_cpf_responsavel text)
  RETURNS integer AS
$BODY$
DECLARE
	v_id_processo integer;
	v_id_analise integer;
	v_cpf_sem_mascara text;
	v_id_instituicao integer;
	v_id_imovel integer;
BEGIN

	select idt_imovel
	into v_id_imovel
	from usr_geocar_aplicacao.imovel
	where cod_imovel = p_codigo_imovel
		and flg_ativo = true;

	-- Consultar o processo associado ao imóvel

	select id_processo 
	into v_id_processo
	from analise.processo 
	where cod_imovel = p_codigo_imovel;

	if (v_id_processo is null) then
		return 0;
	end if;

	-- Desvincular a equipe do processo

	update	analise.membro_equipe 
	set	fl_ativo = false 
	where	fl_ativo = true 
		and id_processo = v_id_processo;

	-- Inserir o registro do cancelamento do processo

	insert into analise.cancelamento_processo (id_motivo_cancelamento, id_processo, tx_justificativa, dt_cadastro)
	values (2, v_id_processo, 'Imóvel cancelado por duplicidade', now());


	-- Verificar se há alguma análise ativa para o imóvel

	select id_analise 
	into v_id_analise
	from analise.analise
	where id_processo = v_id_processo
		and fl_ativo = true;

	if (v_id_analise is not null) then

		-- Mudar o status da notificação na análise de pendente para cancelada
		update analise.analise 
		set tp_status_notificacao = 3
		where id_analise = v_id_analise
			and tp_status_notificacao = 1;

		-- Desativar as solicitações da análise na Central de Comunicação
		update central_comunicacao.analise
		set ativo = false
		where id_analise = v_id_analise
			and ativo = true
			and codigo_imovel = p_codigo_imovel;
	end if;

	-- Desativar as solicitações do sicar na Central de Comunicação

	update central_comunicacao.sicar
	set ativo = false
	where codigo_imovel = p_codigo_imovel
		and ativo = true;

	--Tramitar o processo para cancelado

	update	tramitacao.objeto_tramitavel 
	set	id_condicao = 14, 
		id_etapa = 4,
		id_usuario = null 
	WHERE	id_objeto_tramitavel = (
			SELECT	id_objeto_tramitavel 
			FROM	analise.processo 
			WHERE	id_processo = v_id_processo);

	-- Inserir registro no histórico da tramitação, informando o cancelamento manual do processo

	INSERT INTO tramitacao.historico_objeto_tramitavel 
		(id_objeto_tramitavel, dt_cadastro, tx_observacao, id_acao, 
		tx_acao, id_condicao_inicial, tx_condicao_inicial, 
		id_etapa_inicial, tx_etapa_inicial, id_condicao_final, 
		tx_condicao_final, id_etapa_final, tx_etapa_final)

	SELECT	p.id_objeto_tramitavel,
		NOW(), 
		'Imóvel cancelado por duplicidade', 
		23, 
		'Cancelar por Decisão Administrativa', 
		c.id_condicao, 
		c.nm_condicao,
		e.id_etapa,
		e.tx_etapa,
		14,
		'Cancelado', 
		4, 
		'Cancelamento'
	FROM analise.processo p 
		INNER JOIN
		tramitacao.objeto_tramitavel ot
		ON p.id_objeto_tramitavel = ot.id_objeto_tramitavel
		INNER JOIN
		tramitacao.condicao c
		ON c.id_condicao = ot.id_condicao
		INNER JOIN
		tramitacao.etapa e
		ON e.id_etapa = ot.id_etapa
	WHERE	p.id_processo = v_id_processo;

	-- Cancelar o imóvel no receptor

	select i.id_instituicao
	into v_id_instituicao
	from portal_seguranca.instituicao i
	    join portal_seguranca.usuario_instituicao ui using (id_instituicao)
	    join portal_seguranca.usuario u using (id_usuario)
	    join usr_geocar_aplicacao.municipio m on m.cod_estado = i.id_estado
	    join usr_geocar_aplicacao.imovel im using (idt_municipio)
	WHERE u.tx_login = p_cpf_responsavel
	    and im.cod_imovel = p_codigo_imovel
	limit 1;

	update usr_geocar_aplicacao.imovel 
	set ind_status_imovel = 'CA',
		flg_ativo = false,
		cpf_responsavel = replace(replace(p_cpf_responsavel, '.', ''), '-', ''),
		motivo_mudanca = 'ANA_DECADM',
		retificavel = false,
		des_condicao = 'CANCELADO_POR_DECISAO_ADMINISTRATIVA',
		idt_condicao_inscricao = 17,
		motivo_cancelamento = 'Cancelado por duplicidade',
		dat_atualizacao = now(),
		idt_instituicao_cancelamento = v_id_instituicao
	where cod_imovel = p_codigo_imovel
		and flg_ativo = true
		and ind_status_imovel <> 'CA';

	-- Criar tarefa agendada de Feições do SIG para remover as geometrias do imóvel

	insert into usr_geocar_aplicacao.tarefa_agendada_imovel(
		idt_imovel, 
		cod_imovel, 
		ind_tipo_tarefa_agendada, 
		dat_cadastro, 
		prioridade_processamento, 
		ind_status_processamento)
	values (v_id_imovel, p_codigo_imovel, 'FEICOES_SIG', now(), 0, 'PENDENTE');

	-- Recalcula as sobreposições dos imóveis que estão sobrepostos com este imóvel cancelado

	perform usr_geocar_aplicacao.imovel_sobreposicao(p_codigo_imovel);

	RETURN 1;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION analise.cancela_processo_de_ir_duplicado(text, text)
  OWNER TO suporte_maykel;


-- Function: analise.conjuntos_sobreposicao(integer, double precision)

-- DROP FUNCTION analise.conjuntos_sobreposicao(integer, double precision);

CREATE OR REPLACE FUNCTION analise.conjuntos_sobreposicao(
    v_id_analise integer,
    v_area_corte double precision)
  RETURNS integer AS
$BODY$
DECLARE

	v_idt_arl_proposta INTEGER;
	v_idt_arl_averbada INTEGER;
	v_idt_arl_aprovada_nao_averbada INTEGER;

BEGIN

	SELECT	idt_tema
	INTO	v_idt_arl_proposta
	FROM 	usr_geocar_aplicacao.tema
	WHERE	cod_tema = 'ARL_PROPOSTA';

	SELECT	idt_tema
	INTO	v_idt_arl_averbada
	FROM 	usr_geocar_aplicacao.tema
	WHERE	cod_tema = 'ARL_AVERBADA';

	SELECT	idt_tema
	INTO	v_idt_arl_aprovada_nao_averbada
	FROM 	usr_geocar_aplicacao.tema
	WHERE	cod_tema = 'ARL_APROVADA_NAO_AVERBADA';

	WITH sobreposicao AS (

	SELECT	id_analise,
		id_subconjunto_sobreposicao,
		cod_conjunto_sobreposicao,
		nu_area_conflito_conjunto_sobreposicao,
		(nu_area_conflito_conjunto_sobreposicao / nu_area_reserva_legal) * 100 AS nu_percentual_sobreposicao,
		des_subconjunto_sobreposicao,
		nu_centroide_x,
		nu_centroide_y,
		nu_area_conflito_subconjunto_sobreposicao,
		array_imovel_geometria
		
	FROM	(SELECT	t3.id_analise,
			nextval('analise.subconjunto_sobreposicao_id_subconjunto_sobreposicao_seq') AS id_subconjunto_sobreposicao,
			COALESCE(t1.cod_geometria, 1) AS cod_conjunto_sobreposicao,
			SUM(ST_Area(ST_Transform(t1.the_geom, usr_geocar_aplicacao.utmzone(ST_Centroid(t1.the_geom)))) / 10000) OVER (PARTITION BY t1.cod_geometria) AS nu_area_conflito_conjunto_sobreposicao,
			ST_Area(ST_Transform(t4.the_geom, usr_geocar_aplicacao.utmzone(ST_Centroid(t4.the_geom)))) / 10000 AS nu_area_reserva_legal,
			String_Agg('Polígono ' || t3.cod_geometria::TEXT || ' (' || t.nom_tema || ')', ', ') AS des_subconjunto_sobreposicao,
			X(Centroid(t1.the_geom)) AS nu_centroide_x,
			Y(Centroid(t1.the_geom)) AS nu_centroide_y,	
			ST_Area(ST_Transform(t1.the_geom, usr_geocar_aplicacao.utmzone(ST_Centroid(t1.the_geom)))) / 10000 AS nu_area_conflito_subconjunto_sobreposicao,
			Array_Agg(t3.id_imovel_geometria) AS array_imovel_geometria

		FROM	analise.imovel_geometria t3
		
			INNER JOIN

				(SELECT	(the_geom).geom AS the_geom,
					row_number() over () AS cod_geometria,
					id_analise
				FROM	
					(SELECT	the_geom,
						id_analise
					FROM	(SELECT	ST_Dump(ST_Union(ST_Intersection(t1.the_geom, t2.the_geom))) AS the_geom,
							t1.id_analise						
						FROM	analise.imovel_geometria t1
							INNER JOIN
							analise.imovel_geometria t2
							ON t1.id_analise = t2.id_analise
							AND t1.id_imovel_geometria < t2.id_imovel_geometria						
						WHERE	t1.id_analise = v_id_analise
							AND t2.id_analise = v_id_analise
							AND t1.id_tema IN (v_idt_arl_proposta, v_idt_arl_averbada, v_idt_arl_aprovada_nao_averbada)
							AND t2.id_tema IN (v_idt_arl_proposta, v_idt_arl_averbada, v_idt_arl_aprovada_nao_averbada)
							AND ST_Intersects(t1.the_geom, t2.the_geom)						
						GROUP BY t1.id_analise) a
					WHERE	(ST_Area(ST_Transform((the_geom).geom, usr_geocar_aplicacao.utmzone(ST_Centroid((the_geom).geom)))) / 10000) >= v_area_corte) t1
				) t1
			ON t3.id_analise = t1.id_analise
			AND ST_Intersects(t1.the_geom, t3.the_geom)
			
			INNER JOIN
				(SELECT	(ST_Dump(ST_Union(t1.the_geom))).geom AS the_geom,
					t1.id_analise
				FROM	analise.imovel_geometria t1
				WHERE	t1.id_analise = v_id_analise
					AND t1.id_tema IN (v_idt_arl_proposta, v_idt_arl_averbada, v_idt_arl_aprovada_nao_averbada)
				GROUP BY t1.id_analise) t4
			ON t4.id_analise = t1.id_analise
			AND ST_Intersects(t1.the_geom, t4.the_geom)
			
			INNER JOIN
			usr_geocar_aplicacao.tema t
			ON t.idt_tema = t3.id_tema
			
		WHERE	t3.id_analise = v_id_analise 
			AND t3.id_tema IN (v_idt_arl_proposta, v_idt_arl_averbada, v_idt_arl_aprovada_nao_averbada)
						
		GROUP BY t3.id_analise,
			t1.the_geom,
			t4.the_geom,
			t1.cod_geometria) a
	),

	--Inserção na tabela analise.conjunto_sobreposicao
	cs AS (
	INSERT INTO analise.conjunto_sobreposicao(nu_area_conflito, nu_percentual_sobreposicao, cod_conjunto_sobreposicao, id_analise)
	SELECT 	DISTINCT nu_area_conflito_conjunto_sobreposicao, 
		nu_percentual_sobreposicao, 
		cod_conjunto_sobreposicao, 
		id_analise
	FROM sobreposicao
	RETURNING *
	),

	--Inserção na tabela analise.subconjunto_sobreposicao
	ss AS (
	INSERT INTO analise.subconjunto_sobreposicao(id_subconjunto_sobreposicao, nu_area_conflito, nu_centroide_x, nu_centroide_y, id_conjunto_sobreposicao, des_subconjunto_sobreposicao)
	SELECT 	sobreposicao.id_subconjunto_sobreposicao,
		sobreposicao.nu_area_conflito_subconjunto_sobreposicao, 
		sobreposicao.nu_centroide_x, 
		sobreposicao.nu_centroide_y,
		cs.id_conjunto_sobreposicao,
		sobreposicao.des_subconjunto_sobreposicao
	FROM 	sobreposicao
		INNER JOIN
		cs
		ON sobreposicao.cod_conjunto_sobreposicao = cs.cod_conjunto_sobreposicao
	RETURNING *
	)

	--Inserção na tabela analise.subconjunto_sobreposicao_imovel_geometria
	INSERT INTO analise.subconjunto_sobreposicao_imovel_geometria(id_subconjunto_sobreposicao, id_imovel_geometria)
	SELECT	sobreposicao.id_subconjunto_sobreposicao,
		unnest(sobreposicao.array_imovel_geometria)
	FROM	sobreposicao;

	RETURN 1;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION analise.conjuntos_sobreposicao(integer, double precision)
  OWNER TO postgres;



-- Function: analise.imovel_geometria(integer)

-- DROP FUNCTION analise.imovel_geometria(integer);

CREATE OR REPLACE FUNCTION analise.imovel_geometria(v_id_analise integer)
  RETURNS integer AS
$BODY$
DECLARE

	v_srid INTEGER;
	v_idt_area_imovel INTEGER;
	v_imovel_buffer GEOMETRY;

BEGIN
	SELECT	idt_tema
	INTO	v_idt_area_imovel
	FROM 	usr_geocar_aplicacao.tema
	WHERE	cod_tema = 'AREA_IMOVEL';

	SELECT	usr_geocar_aplicacao.utmzone(ST_Centroid(the_geom)) 
	INTO 	v_srid
	FROM	analise.analise a
		INNER JOIN
		usr_geocar_aplicacao.rel_tema_imovel_poligono rtip
		ON a.id_imovel = rtip.idt_imovel
	WHERE	a.id_analise = v_id_analise
		AND rtip.idt_tema = v_idt_area_imovel; 

	SELECT	ST_Transform(ST_Buffer(ST_Transform(the_geom, v_srid), 600), 4674) imovel_buffer
	INTO	v_imovel_buffer
	FROM	analise.analise a
		INNER JOIN
		usr_geocar_aplicacao.rel_tema_imovel_poligono rtip
		ON a.id_imovel = rtip.idt_imovel
	WHERE	a.id_analise = v_id_analise
		AND rtip.idt_tema = v_idt_area_imovel; 

	INSERT INTO analise.imovel_geometria(id_analise, id_tema, tp_geometria, nu_area, cod_geometria, the_geom)

	SELECT	id_analise,
		idt_tema, 
		0, --tipo geometria: poligono
		ST_Area(ST_Transform(the_geom, v_srid)) / 10000, --area em hectares
		1,
		the_geom
	FROM	(SELECT	a.id_analise,
			rtip.idt_tema, 
			(ST_Dump(the_geom)).geom AS the_geom
		FROM	analise.analise a
			INNER JOIN
			usr_geocar_aplicacao.rel_tema_imovel_poligono rtip
			ON a.id_imovel = rtip.idt_imovel
		WHERE	a.id_analise = v_id_analise) a
	WHERE	ST_Intersects_Error(the_geom, v_imovel_buffer);

	INSERT INTO analise.imovel_geometria(id_analise, id_tema, tp_geometria, nu_area, cod_geometria, the_geom)

	SELECT	id_analise,
		idt_tema, 
		1, --tipo geometria: ponto
		0, --área de ponto sempre será 0
		1,
		the_geom
	FROM	(SELECT	a.id_analise,
			rtip.idt_tema, 
			(ST_Dump(the_geom)).geom AS the_geom
		FROM	analise.analise a
			INNER JOIN
			usr_geocar_aplicacao.rel_tema_imovel_ponto rtip
			ON a.id_imovel = rtip.idt_imovel
		WHERE	a.id_analise = v_id_analise) a
	WHERE	ST_Intersects_Error(the_geom, v_imovel_buffer);

	INSERT INTO analise.imovel_geometria(id_analise, id_tema, tp_geometria, nu_area, cod_geometria, the_geom)

	SELECT	id_analise,
		idt_tema, 
		2, --tipo geometria: linha
		0, --área de linha sempre será 0
		1,
		the_geom
	FROM	(SELECT	a.id_analise,
			rtip.idt_tema, 
			(ST_Dump(the_geom)).geom AS the_geom
		FROM	analise.analise a
			INNER JOIN
			usr_geocar_aplicacao.rel_tema_imovel_linha rtip
			ON a.id_imovel = rtip.idt_imovel
		WHERE	a.id_analise = v_id_analise) a
	WHERE	ST_Intersects_Error(the_geom, v_imovel_buffer);

	UPDATE	analise.imovel_geometria g 
	SET 	cod_geometria = t.cod_geometria                                     
	FROM 	(SELECT id_imovel_geometria,
			ROW_NUMBER() OVER (PARTITION BY id_analise, id_tema) AS cod_geometria
		FROM 	analise.imovel_geometria
		WHERE	id_analise = v_id_analise) AS t
	WHERE	g.id_analise = v_id_analise
		AND g.id_imovel_geometria = t.id_imovel_geometria;

	RETURN 1;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION analise.imovel_geometria(integer)
  OWNER TO postgres;
COMMENT ON FUNCTION analise.imovel_geometria(integer) IS 'Explodir geometrias das tabelas usr_geocar_aplicacao.rel_tema_imovel_poligono e inserir na tabela analise.imovel_geometria';



-- Function: analise.imovel_geometria_area_liquida_analise(integer)

-- DROP FUNCTION analise.imovel_geometria_area_liquida_analise(integer);

CREATE OR REPLACE FUNCTION analise.imovel_geometria_area_liquida_analise(v_id_analise integer)
  RETURNS integer AS
$BODY$
DECLARE

v_srid INTEGER;
v_idt_area_infraestrutura_publica INTEGER;
v_idt_area_utilidade_publica INTEGER;
v_idt_reservatorio_energia INTEGER;
v_idt_area_imovel INTEGER;
v_idt_area_imovel_liquida INTEGER;
v_idt_area_imovel_liquida_analise INTEGER;
v_idt_area_entorno_reservatorio_energia INTEGER;
v_geometria_desconsiderada GEOMETRY;
v_geometria_area_liquida GEOMETRY;

BEGIN

	SELECT	idt_tema
	INTO	v_idt_area_imovel
	FROM 	usr_geocar_aplicacao.tema
	WHERE	cod_tema = 'AREA_IMOVEL';

	SELECT	idt_tema
	INTO	v_idt_area_imovel_liquida
	FROM 	usr_geocar_aplicacao.tema
	WHERE	cod_tema = 'AREA_IMOVEL_LIQUIDA';

	SELECT	idt_tema
	INTO	v_idt_area_infraestrutura_publica
	FROM 	usr_geocar_aplicacao.tema
	WHERE	cod_tema = 'AREA_INFRAESTRUTURA_PUBLICA';

	SELECT	idt_tema
	INTO	v_idt_area_utilidade_publica
	FROM 	usr_geocar_aplicacao.tema
	WHERE	cod_tema = 'AREA_UTILIDADE_PUBLICA';

	SELECT	idt_tema
	INTO	v_idt_reservatorio_energia
	FROM 	usr_geocar_aplicacao.tema
	WHERE	cod_tema = 'RESERVATORIO_ENERGIA';

	SELECT	idt_tema
	INTO	v_idt_area_entorno_reservatorio_energia
	FROM 	usr_geocar_aplicacao.tema
	WHERE	cod_tema = 'AREA_ENTORNO_RESERVATORIO_ENERGIA';

	SELECT	idt_tema
	INTO	v_idt_area_imovel_liquida_analise
	FROM 	usr_geocar_aplicacao.tema
	WHERE	cod_tema = 'AREA_IMOVEL_LIQUIDA_ANALISE';

	SELECT	usr_geocar_aplicacao.utmzone(ST_Centroid(the_geom)) 
	INTO 	v_srid
	FROM	analise.imovel_geometria 
	WHERE	id_analise = v_id_analise
		AND id_tema = v_idt_area_imovel;

	SELECT	ST_Union(ig.the_geom)
	INTO	v_geometria_desconsiderada
	FROM	analise.geometria_desconsiderada_calculo_rl gd,
		analise.imovel_geometria ig
	WHERE	ig.id_imovel_geometria = gd.id_imovel_geometria
		AND ig.id_analise = v_id_analise
		AND ig.id_tema IN (v_idt_area_infraestrutura_publica, v_idt_area_utilidade_publica, v_idt_reservatorio_energia, v_idt_area_entorno_reservatorio_energia); 

	SELECT	ST_Union(the_geom)
	INTO 	v_geometria_area_liquida
	FROM	analise.imovel_geometria 
	WHERE	id_analise = v_id_analise
		AND id_tema = v_idt_area_imovel_liquida;

	DELETE FROM analise.imovel_geometria WHERE id_analise = v_id_analise AND id_tema = v_idt_area_imovel_liquida_analise;

	INSERT INTO analise.imovel_geometria(id_analise, id_tema, tp_geometria, nu_area, cod_geometria, the_geom)

	SELECT	v_id_analise,
		v_idt_area_imovel_liquida_analise,
		0, --tipo geometria: poligono
		ST_Area(ST_Transform(the_geom, v_srid)) / 10000,
		0,
		the_geom
	FROM	(SELECT	(ST_Dump(Coalesce(ST_CollectionExtract(ST_Union(v_geometria_desconsiderada, v_geometria_area_liquida), 3), v_geometria_area_liquida))).geom AS the_geom
		) a;

	UPDATE	analise.imovel_geometria g 
	SET 	cod_geometria = t.cod_geometria                                     
	FROM 	(SELECT id_imovel_geometria, 
			ROW_NUMBER()OVER (PARTITION BY id_analise, id_tema) AS cod_geometria
		FROM 	analise.imovel_geometria
		WHERE	id_analise = v_id_analise) AS t
	WHERE	g.id_imovel_geometria = t.id_imovel_geometria
		AND id_tema = v_idt_area_imovel_liquida_analise
		AND g.id_analise = v_id_analise;

	RETURN 1;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION analise.imovel_geometria_area_liquida_analise(integer)
  OWNER TO postgres;
COMMENT ON FUNCTION analise.imovel_geometria_area_liquida_analise(integer) IS 'Gerar poligonos de área líquida juntamente com as geometrias desconsideradas.';




-- Function: analise.imovel_geometria_areas_class_info_complementar(integer)

-- DROP FUNCTION analise.imovel_geometria_areas_class_info_complementar(integer);

CREATE OR REPLACE FUNCTION analise.imovel_geometria_areas_class_info_complementar(v_id_analise integer)
  RETURNS integer AS
$BODY$
DECLARE

BEGIN
	UPDATE	analise.imovel_geometria ig
	SET	nu_area_sobreposicao_classificacao = a.nu_area_sobreposicao_classificacao
	FROM	(SELECT	ig.id_imovel_geometria,
			SUM(igs.nu_area) AS nu_area_sobreposicao_classificacao
		FROM	analise.imovel_geometria ig
			INNER JOIN
			analise.imovel_geometria_sobreposicao igs
			ON ig.id_imovel_geometria = igs.id_imovel_geometria
		WHERE	ig.id_analise = v_id_analise
			AND igs.tp_origem = 0
		GROUP BY ig.id_imovel_geometria,
			ig.nu_area) a
	WHERE	ig.id_imovel_geometria = a.id_imovel_geometria
		AND ig.id_analise = v_id_analise;

	UPDATE	analise.imovel_geometria ig
	SET	nu_area_sobreposicao_info_complementar = a.nu_area_sobreposicao_info_complementar
	FROM	(SELECT	ig.id_imovel_geometria,
			SUM(igs.nu_area) AS nu_area_sobreposicao_info_complementar
		FROM	analise.imovel_geometria ig
			INNER JOIN
			analise.imovel_geometria_sobreposicao igs
			ON ig.id_imovel_geometria = igs.id_imovel_geometria
		WHERE	ig.id_analise = v_id_analise
			AND igs.tp_origem = 2
		GROUP BY ig.id_imovel_geometria,
			ig.nu_area) a
	WHERE	ig.id_imovel_geometria = a.id_imovel_geometria
		AND ig.id_analise = v_id_analise;

	UPDATE 	analise.imovel_geometria ig
	SET 	nu_area_sobreposicao_tecnico = 0
	WHERE 	ig.id_analise = v_id_analise
		AND NOT EXISTS
		(SELECT id_imovel_geometria
		FROM 	analise.imovel_geometria_sobreposicao igs
		WHERE 	ig.id_imovel_geometria = igs.id_imovel_geometria
			AND tp_origem = 0);

	UPDATE 	analise.imovel_geometria ig
	SET 	nu_area_sobreposicao_tecnico = 0
	WHERE 	ig.id_analise = v_id_analise
		AND NOT EXISTS
		(SELECT id_imovel_geometria
		FROM 	analise.imovel_geometria_sobreposicao igs
		WHERE 	ig.id_imovel_geometria = igs.id_imovel_geometria
			AND tp_origem = 2);

	RETURN 1;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION analise.imovel_geometria_areas_class_info_complementar(integer)
  OWNER TO postgres;
COMMENT ON FUNCTION analise.imovel_geometria_areas_class_info_complementar(integer) IS 'Calcular área divergente de classificacao e informacao complementar';




-- Function: analise.imovel_geometria_areas_tecnico(integer)

-- DROP FUNCTION analise.imovel_geometria_areas_tecnico(integer);

CREATE OR REPLACE FUNCTION analise.imovel_geometria_areas_tecnico(v_id_analise integer)
  RETURNS integer AS
$BODY$
DECLARE

BEGIN
	UPDATE	analise.imovel_geometria ig
	SET	nu_area_sobreposicao_tecnico = a.nu_area_sobreposicao_tecnico
	FROM	(SELECT	ig.id_imovel_geometria,
			SUM(igs.nu_area) AS nu_area_sobreposicao_tecnico
		FROM	analise.imovel_geometria ig
			INNER JOIN
			analise.imovel_geometria_sobreposicao igs
			ON ig.id_imovel_geometria = igs.id_imovel_geometria
		WHERE	ig.id_analise = v_id_analise
			AND igs.tp_origem = 1
		GROUP BY ig.id_imovel_geometria,
			ig.nu_area) a
	WHERE	ig.id_imovel_geometria = a.id_imovel_geometria
		AND ig.id_analise = v_id_analise;

	UPDATE 	analise.imovel_geometria ig
	SET 	nu_area_sobreposicao_tecnico = 0
	WHERE 	ig.id_analise = v_id_analise
		AND NOT EXISTS
		(SELECT id_imovel_geometria
		FROM 	analise.imovel_geometria_sobreposicao igs
		WHERE 	ig.id_imovel_geometria = igs.id_imovel_geometria
			AND tp_origem = 1);

	RETURN 1;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION analise.imovel_geometria_areas_tecnico(integer)
  OWNER TO postgres;
COMMENT ON FUNCTION analise.imovel_geometria_areas_tecnico(integer) IS 'Calcular área divergente de classificacao do técnico';




-- Function: analise.imovel_geometria_corpo_dagua(integer)

-- DROP FUNCTION analise.imovel_geometria_corpo_dagua(integer);

CREATE OR REPLACE FUNCTION analise.imovel_geometria_corpo_dagua(v_id_analise integer)
  RETURNS integer AS
$BODY$
DECLARE

v_srid INTEGER;
v_idt_area_imovel INTEGER;
v_idt_curso_agua INTEGER;
v_idt_rio_ate_10 INTEGER;
v_idt_rio_10_50 INTEGER;
v_idt_rio_50_200 INTEGER;
v_idt_rio_200_600 INTEGER;
v_idt_rio_acima_600 INTEGER;
v_idt_lago_natural INTEGER;
v_idt_reservatorio_artificial_decorrente_barramento INTEGER;
v_idt_nascente INTEGER;

BEGIN
	SELECT	idt_tema
	INTO	v_idt_area_imovel
	FROM 	usr_geocar_aplicacao.tema
	WHERE	cod_tema = 'AREA_IMOVEL';

	SELECT	idt_tema
	INTO	v_idt_curso_agua
	FROM 	usr_geocar_aplicacao.tema
	WHERE	cod_tema = 'CORPO_DAGUA';

	SELECT	idt_tema
	INTO	v_idt_rio_ate_10
	FROM 	usr_geocar_aplicacao.tema
	WHERE	cod_tema = 'RIO_ATE_10';
	
	SELECT	idt_tema
	INTO	v_idt_rio_10_50
	FROM 	usr_geocar_aplicacao.tema
	WHERE	cod_tema = 'RIO_10_A_50';

	SELECT	idt_tema
	INTO	v_idt_rio_50_200
	FROM 	usr_geocar_aplicacao.tema
	WHERE	cod_tema = 'RIO_50_A_200';

	SELECT	idt_tema
	INTO	v_idt_rio_200_600
	FROM 	usr_geocar_aplicacao.tema
	WHERE	cod_tema = 'RIO_200_A_600';

	SELECT	idt_tema
	INTO	v_idt_rio_acima_600
	FROM 	usr_geocar_aplicacao.tema
	WHERE	cod_tema = 'RIO_ACIMA_600';

	SELECT	idt_tema
	INTO	v_idt_lago_natural
	FROM 	usr_geocar_aplicacao.tema
	WHERE	cod_tema = 'LAGO_NATURAL';

	SELECT	idt_tema
	INTO	v_idt_reservatorio_artificial_decorrente_barramento
	FROM 	usr_geocar_aplicacao.tema
	WHERE	cod_tema = 'RESERVATORIO_ARTIFICIAL_DECORRENTE_BARRAMENTO';

	SELECT	idt_tema
	INTO	v_idt_nascente
	FROM 	usr_geocar_aplicacao.tema
	WHERE	cod_tema = 'NASCENTE_OLHO_DAGUA';

	SELECT	usr_geocar_aplicacao.utmzone(ST_Centroid(the_geom)) 
	INTO 	v_srid
	FROM	analise.imovel_geometria 
	WHERE	id_analise = v_id_analise
		AND id_tema = v_idt_area_imovel; 

	INSERT INTO analise.imovel_geometria(id_analise, id_tema, tp_geometria, nu_area, cod_geometria, the_geom)

	SELECT	id_analise,
		v_idt_curso_agua,
		0, --tipo geometria: poligono
		nu_area,
		0, --código inicial da coluna cod_geometria, será atualizado com o update abaixo
		the_geom
	FROM	analise.imovel_geometria 
	WHERE	id_analise = v_id_analise
		AND id_tema IN (v_idt_rio_ate_10, v_idt_rio_10_50, v_idt_rio_50_200, v_idt_rio_200_600, v_idt_rio_acima_600, v_idt_lago_natural, v_idt_reservatorio_artificial_decorrente_barramento);

	INSERT INTO analise.imovel_geometria(id_analise, id_tema, tp_geometria, nu_area, cod_geometria, the_geom)

	SELECT	id_analise,
		v_idt_curso_agua, 
		1, --tipo geometria: ponto
		nu_area, 
		0, --código inicial da coluna cod_geometria, será atualizado com o update abaixo
		the_geom
	FROM	analise.imovel_geometria 
	WHERE	id_analise = v_id_analise
		AND id_tema IN (v_idt_nascente);

	UPDATE	analise.imovel_geometria g 
	SET 	cod_geometria = t.cod_geometria                                     
	FROM 	(SELECT id_imovel_geometria, 
			ROW_NUMBER()OVER (PARTITION BY id_analise, id_tema) AS cod_geometria
		FROM 	analise.imovel_geometria
		WHERE	id_analise = v_id_analise) AS t
	WHERE	g.id_imovel_geometria = t.id_imovel_geometria
		AND g.id_analise = v_id_analise
		AND id_tema = v_idt_curso_agua;

	RETURN 1;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION analise.imovel_geometria_corpo_dagua(integer)
  OWNER TO postgres;
COMMENT ON FUNCTION analise.imovel_geometria_corpo_dagua(integer) IS 'Agrupar polígonos de curso dagua (id_tema de 9 a 16) e inserir na tabela analise.imovel_geometria';








-- Function: analise.imovel_geometria_sobreposicao_cadastrante(integer, double precision)

-- DROP FUNCTION analise.imovel_geometria_sobreposicao_cadastrante(integer, double precision);

CREATE OR REPLACE FUNCTION analise.imovel_geometria_sobreposicao_cadastrante(
    v_id_analise integer,
    v_area_corte double precision)
  RETURNS integer AS
$BODY$DECLARE

BEGIN
	INSERT INTO analise.imovel_geometria_sobreposicao (id_imovel_geometria, cod_geometria, nu_centroide_x, nu_centroide_y, tp_origem, the_geom, tp_geometria, nu_area, id_imovel_geometria_sobreposta)
 
	SELECT	id_imovel_geometria,
		Row_Number() OVER (PARTITION BY id_imovel_geometria) AS cod_geometria,
		ST_X(ST_Centroid(the_geom)) AS nu_centroide_x, 
		ST_Y(ST_Centroid(the_geom)) AS nu_centroide_y,
		3 AS tp_origem,
		the_geom,
		CASE	GeometryType(the_geom)
			WHEN 'POLYGON' THEN 0
			WHEN 'POINT' THEN 1
			WHEN 'LINESTRING' THEN 2
		END AS tp_geometria,
		ST_Area(ST_Transform(the_geom, usr_geocar_aplicacao.utmzone(ST_Centroid(the_geom)))) / 10000 AS nu_area,
		id_imovel_geometria_sobreposta
	FROM	(SELECT	igt1.id_imovel_geometria AS id_imovel_geometria,
			3 AS tp_origem,
			(ST_Dump(ST_Intersection_Error(igt1.the_geom, igt2.the_geom))).geom AS the_geom,
			igt2.id_imovel_geometria  AS id_imovel_geometria_sobreposta
		FROM	analise.imovel_geometria igt1
			INNER JOIN
			analise.tema_correspondente_tema tct
			ON igt1.id_tema = tct.id_tema_principal
			INNER JOIN
			analise.imovel_geometria igt2
			ON igt1.id_analise = igt2.id_analise
			AND igt2.id_tema = tct.id_tema_sobreposicao	
		WHERE	tct.tp_sobreposicao = 1	
			AND igt1.id_analise = v_id_analise
			AND ST_Intersects_Error(igt1.the_geom, igt2.the_geom)) a
	WHERE	ST_Area(ST_Transform(the_geom, usr_geocar_aplicacao.utmzone(ST_Centroid(the_geom)))) / 10000 >= v_area_corte;

	RETURN 1;
	
END;$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION analise.imovel_geometria_sobreposicao_cadastrante(integer, double precision)
  OWNER TO postgres;
COMMENT ON FUNCTION analise.imovel_geometria_sobreposicao_cadastrante(integer, double precision) IS 'Inserir na tabela analise.imovel_geometria_sobreposicao dados referentes a Vetorização cadastrante X Vetorização cadastrante';





-- Function: analise.imovel_geometria_sobreposicao_class_info_complementar(integer, double precision)

-- DROP FUNCTION analise.imovel_geometria_sobreposicao_class_info_complementar(integer, double precision);

CREATE OR REPLACE FUNCTION analise.imovel_geometria_sobreposicao_class_info_complementar(
    v_id_analise integer,
    v_area_corte double precision)
  RETURNS text AS
$BODY$DECLARE

v_idt_area_imovel INTEGER;
v_sql TEXT;
v_srid INTEGER;

BEGIN
	SELECT	idt_tema
	INTO	v_idt_area_imovel
	FROM 	usr_geocar_aplicacao.tema
	WHERE	cod_tema = 'AREA_IMOVEL';

	SELECT	usr_geocar_aplicacao.utmzone(ST_Centroid(the_geom)) 
	INTO 	v_srid
	FROM	analise.imovel_geometria 
	WHERE	id_analise = v_id_analise
		AND id_tema = v_idt_area_imovel; --tema area imovel
		
	IF v_srid IS NOT NULL THEN 

		SELECT 	String_Agg('INSERT INTO analise.imovel_geometria_sobreposicao(id_imovel_geometria, id_tema_analise, cod_geometria, nu_centroide_x, nu_centroide_y, tp_origem, the_geom, tp_geometria, nu_area)
		SELECT 	id_imovel_geometria,
			' || id_tema_analise || ',
			row_number() OVER (),
			ST_X(ST_Centroid(the_geom)),
			ST_Y(ST_Centroid(the_geom)),
			' || CASE WHEN tp_origem = 1 THEN 2
			     ELSE tp_origem
			     END
			|| ',
			the_geom,
			CASE	GeometryType(the_geom)
				WHEN ''POLYGON'' THEN 0
				WHEN ''POINT'' THEN 1
				WHEN ''LINESTRING'' THEN 2
			END,
			ST_Area(ST_Transform(the_geom, '|| v_srid || ')) / 10000
		FROM	(
			SELECT	ig.id_imovel_geometria,				
				(ST_Dump(ST_Intersection_Error(ig.the_geom, ST_Transform(ta.the_geom, 4674)))).geom AS the_geom
			FROM	analise.imovel_geometria ig
				INNER JOIN
				analise.tema_analise_tema tat
				ON ig.id_tema = tat.id_tema
				INNER JOIN
				"' || nm_esquema_camada || '"."' || nm_tabela_camada ||'" ta
				ON ig.the_geom && ST_Transform(ta.the_geom, 4674)
				AND ST_Intersects_Error(ig.the_geom, ST_Transform(ta.the_geom, 4674))
			WHERE	ig.id_analise = ' || v_id_analise || '
				AND tat.id_tema_analise = ' || id_tema_analise || ') a
		WHERE	ST_Area(ST_Transform(the_geom, '|| v_srid || ')) / 10000 >= '|| v_area_corte || ';', '

		')
		INTO	v_sql
		FROM 	analise.tema_analise
		WHERE	nm_esquema_camada IS NOT NULL 
			AND cod_tema NOT LIKE 'IMOVEIS_CERTIFICADOS_INCRA'
			AND id_tema_analise IN (
				SELECT DISTINCT id_tema_analise
				FROM	analise.tema_analise_tema);

		EXECUTE v_sql;

		SELECT 	String_Agg('INSERT INTO analise.imovel_geometria_sobreposicao(id_imovel_geometria, id_tema_analise, cod_geometria, nu_centroide_x, nu_centroide_y, tp_origem, the_geom, tp_geometria, nu_area, cod_imovel_incra)
		SELECT 	id_imovel_geometria,
			' || id_tema_analise || ',
			row_number() OVER (),
			ST_X(ST_Centroid(the_geom)),
			ST_Y(ST_Centroid(the_geom)),
			' || CASE WHEN tp_origem = 1 THEN 2
			     ELSE tp_origem
			     END
			|| ',
			the_geom,
			CASE	GeometryType(the_geom)
				WHEN ''POLYGON'' THEN 0
				WHEN ''POINT'' THEN 1
				WHEN ''LINESTRING'' THEN 2
			END,
			ST_Area(ST_Transform(the_geom, '|| v_srid || ')) / 10000,
			cod_imovel
		FROM	(
			SELECT	ig.id_imovel_geometria,				
				(ST_Dump(ST_Intersection_Error(ig.the_geom, ST_Transform(ta.the_geom, 4674)))).geom AS the_geom,
				ta.cod_imovel
			FROM	analise.imovel_geometria ig
				INNER JOIN
				analise.tema_analise_tema tat
				ON ig.id_tema = tat.id_tema
				INNER JOIN
				"' || nm_esquema_camada || '"."' || nm_tabela_camada ||'" ta
				ON ig.the_geom && ST_Transform(ta.the_geom, 4674)
				AND ST_Intersects_Error(ig.the_geom, ST_Transform(ta.the_geom, 4674))
			WHERE	ig.id_analise = ' || v_id_analise || '
				AND tat.id_tema_analise = ' || id_tema_analise || ') a
		WHERE	ST_Area(ST_Transform(the_geom, '|| v_srid || ')) / 10000 >= '|| v_area_corte || ';', '

		')
		INTO	v_sql
		FROM 	analise.tema_analise
		WHERE	nm_esquema_camada IS NOT NULL
			AND cod_tema LIKE 'IMOVEIS_CERTIFICADOS_INCRA'
			AND id_tema_analise IN (
				SELECT DISTINCT id_tema_analise
				FROM	analise.tema_analise_tema);

		EXECUTE v_sql;

		RETURN v_sql;
	
	END IF;
		
		RETURN 'Não existem dados para o id_analise passado';

END;$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION analise.imovel_geometria_sobreposicao_class_info_complementar(integer, double precision)
  OWNER TO postgres;
COMMENT ON FUNCTION analise.imovel_geometria_sobreposicao_class_info_complementar(integer, double precision) IS 'Inserir na tabela analise.imovel_geometria_sobreposicao dados referentes a Vetorização cadastrante X Classificação do CAR ou Vetorização cadastrante X Informações complementares';






-- Function: analise.imovel_geometria_sobreposicao_cod_geometria(integer)

-- DROP FUNCTION analise.imovel_geometria_sobreposicao_cod_geometria(integer);

CREATE OR REPLACE FUNCTION analise.imovel_geometria_sobreposicao_cod_geometria(v_id_analise integer)
  RETURNS integer AS
$BODY$
DECLARE
BEGIN
	UPDATE	analise.imovel_geometria_sobreposicao igs
	SET	cod_geometria = a.cod_geometria
	FROM	(SELECT ROW_NUMBER() OVER (PARTITION BY i.id_imovel_geometria) AS cod_geometria, id_imovel_geometria_sobreposicao
		FROM analise.imovel_geometria_sobreposicao i,
		analise.imovel_geometria ig
		WHERE tp_origem IN (0, 1, 2)
		AND i.id_imovel_geometria = ig.id_imovel_geometria
		AND ig.id_analise = v_id_analise
		) a,
		analise.imovel_geometria ig
		WHERE  tp_origem IN (0, 1, 2)
		AND igs.id_imovel_geometria_sobreposicao = a.id_imovel_geometria_sobreposicao
		AND ig.id_imovel_geometria = igs.id_imovel_geometria
		AND id_analise = v_id_analise;
	RETURN 1;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION analise.imovel_geometria_sobreposicao_cod_geometria(integer)
  OWNER TO analise_car;
COMMENT ON FUNCTION analise.imovel_geometria_sobreposicao_cod_geometria(integer) IS 'Calcular cod_geometria na tabela analise.imovel_geometria_sobreposicao.';




-- Function: analise.imovel_geometria_sobreposicao_tecnico_cadastrante_insert(integer, integer, double precision)

-- DROP FUNCTION analise.imovel_geometria_sobreposicao_tecnico_cadastrante_insert(integer, integer, double precision);

CREATE OR REPLACE FUNCTION analise.imovel_geometria_sobreposicao_tecnico_cadastrante_insert(
    v_id_analise integer,
    v_id_imovel_geometria_tecnico integer,
    v_area_corte double precision)
  RETURNS integer AS
$BODY$DECLARE

BEGIN
	INSERT INTO analise.imovel_geometria_sobreposicao(
		id_imovel_geometria_tecnico, id_imovel_geometria_sobreposta, cod_geometria, nu_centroide_x, 
		nu_centroide_y, tp_origem, the_geom, tp_geometria, nu_area)

	SELECT	id_imovel_geometria_tecnico,
		id_imovel_geometria_sobreposta,
		Row_Number() OVER (PARTITION BY id_imovel_geometria_tecnico) AS cod_geometria,
		ST_X(ST_Centroid(the_geom)) AS nu_centroide_x, 
		ST_Y(ST_Centroid(the_geom)) AS nu_centroide_y,
		4 AS tp_origem,
		the_geom,
		CASE	GeometryType(the_geom)
			WHEN 'POLYGON' THEN 0
			WHEN 'POINT' THEN 1
			WHEN 'LINESTRING' THEN 2
		END AS tp_geometria,
		ST_Area(ST_Transform(the_geom, usr_geocar_aplicacao.utmzone(ST_Centroid(the_geom)))) / 10000 AS nu_area
	FROM	(SELECT	igt.id_imovel_geometria_tecnico AS id_imovel_geometria_tecnico,
			ig.id_imovel_geometria AS id_imovel_geometria_sobreposta,
			4 AS tp_origem,
			(ST_Dump(ST_Intersection_Error(ig.the_geom, igt.the_geom))).geom AS the_geom
		FROM	analise.imovel_geometria_tecnico igt			
			INNER JOIN
			analise.tema_correspondente_tema tct
			ON igt.id_tema = tct.id_tema_principal
			INNER JOIN
			analise.imovel_geometria ig
			ON igt.id_analise = ig.id_analise
			AND ig.id_tema = tct.id_tema_sobreposicao	
		WHERE	tct.tp_sobreposicao = 2
			AND igt.id_analise = v_id_analise
			AND ST_Intersects(ig.the_geom, igt.the_geom)
			AND igt.id_imovel_geometria_tecnico = v_id_imovel_geometria_tecnico) a
	WHERE	ST_Area(ST_Transform(the_geom, usr_geocar_aplicacao.utmzone(ST_Centroid(the_geom)))) / 10000 >= v_area_corte;

	RETURN 1;
	
END;$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION analise.imovel_geometria_sobreposicao_tecnico_cadastrante_insert(integer, integer, double precision)
  OWNER TO postgres;
COMMENT ON FUNCTION analise.imovel_geometria_sobreposicao_tecnico_cadastrante_insert(integer, integer, double precision) IS 'Insert na tabela analise.imovel_geometria_tecnico: atualização na tabela analise.imovel_geometria_sobreposicao no caso de Vetorização tecnico X Vetorização cadastrante';




-- Function: analise.imovel_geometria_sobreposicao_tecnico_cadastrante_update(integer, integer, double precision)

-- DROP FUNCTION analise.imovel_geometria_sobreposicao_tecnico_cadastrante_update(integer, integer, double precision);

CREATE OR REPLACE FUNCTION analise.imovel_geometria_sobreposicao_tecnico_cadastrante_update(
    v_id_analise integer,
    v_id_imovel_geometria_tecnico integer,
    v_area_corte double precision)
  RETURNS integer AS
$BODY$DECLARE

BEGIN
	DELETE FROM analise.imovel_geometria_sobreposicao WHERE id_imovel_geometria_tecnico = v_id_imovel_geometria_tecnico AND tp_origem = 4;

	PERFORM analise.imovel_geometria_sobreposicao_tecnico_cadastrante_insert(v_id_analise, v_id_imovel_geometria_tecnico, v_area_corte);

	RETURN 1;
	
END;$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION analise.imovel_geometria_sobreposicao_tecnico_cadastrante_update(integer, integer, double precision)
  OWNER TO postgres;
COMMENT ON FUNCTION analise.imovel_geometria_sobreposicao_tecnico_cadastrante_update(integer, integer, double precision) IS 'Update na tabela analise.imovel_geometria_tecnico: atualização na tabela analise.imovel_geometria_sobreposicao no caso de Vetorização tecnico X Vetorização cadastrante';



-- Function: analise.imovel_geometria_sobreposicao_tecnico_insert(integer, integer, double precision)

-- DROP FUNCTION analise.imovel_geometria_sobreposicao_tecnico_insert(integer, integer, double precision);

CREATE OR REPLACE FUNCTION analise.imovel_geometria_sobreposicao_tecnico_insert(
    v_id_analise integer,
    v_id_imovel_geometria_tecnico integer,
    v_area_corte double precision)
  RETURNS integer AS
$BODY$DECLARE

BEGIN
	INSERT INTO analise.imovel_geometria_sobreposicao(
		id_imovel_geometria, cod_geometria, nu_centroide_x, nu_centroide_y, tp_origem, 
		the_geom, tp_geometria, nu_area, id_imovel_geometria_tecnico)

	SELECT	id_imovel_geometria,
		Row_Number() OVER (PARTITION BY id_imovel_geometria) AS cod_geometria,
		ST_X(ST_Centroid(the_geom)) AS nu_centroide_x, 
		ST_Y(ST_Centroid(the_geom)) AS nu_centroide_y,
		1 AS tp_origem,
		the_geom,
		CASE	GeometryType(the_geom)
			WHEN 'POLYGON' THEN 0
			WHEN 'POINT' THEN 1
			WHEN 'LINESTRING' THEN 2
		END AS tp_geometria,
		ST_Area(ST_Transform(the_geom, usr_geocar_aplicacao.utmzone(ST_Centroid(the_geom)))) / 10000 AS nu_area,
		id_imovel_geometria_tecnico
	FROM	(SELECT	ig.id_imovel_geometria AS id_imovel_geometria,
			1 AS tp_origem,
			(ST_Dump(ST_Intersection_Error(ig.the_geom, igt.the_geom))).geom AS the_geom,
			igt.id_imovel_geometria_tecnico
		FROM	analise.imovel_geometria ig
			INNER JOIN
			analise.tema_correspondente_tema tct
			ON ig.id_tema = tct.id_tema_principal
			INNER JOIN
			analise.imovel_geometria_tecnico igt
			ON ig.id_analise = igt.id_analise
			AND igt.id_tema = tct.id_tema_sobreposicao
		WHERE	tct.tp_sobreposicao = 0
			AND ig.id_analise = v_id_analise
			AND ST_Intersects(ig.the_geom, igt.the_geom)
			AND igt.id_imovel_geometria_tecnico = v_id_imovel_geometria_tecnico) a
	WHERE	ST_Area(ST_Transform(the_geom, usr_geocar_aplicacao.utmzone(ST_Centroid(the_geom)))) / 10000 >= v_area_corte;

	RETURN 1;
	
END;$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION analise.imovel_geometria_sobreposicao_tecnico_insert(integer, integer, double precision)
  OWNER TO postgres;
COMMENT ON FUNCTION analise.imovel_geometria_sobreposicao_tecnico_insert(integer, integer, double precision) IS 'Insert na tabela analise.imovel_geometria_tecnico: atualização na tabela analise.imovel_geometria_sobreposicao';






-- Function: analise.imovel_geometria_sobreposicao_tecnico_update(integer, integer, double precision)

-- DROP FUNCTION analise.imovel_geometria_sobreposicao_tecnico_update(integer, integer, double precision);

CREATE OR REPLACE FUNCTION analise.imovel_geometria_sobreposicao_tecnico_update(
    v_id_analise integer,
    v_id_imovel_geometria_tecnico integer,
    v_area_corte double precision)
  RETURNS integer AS
$BODY$DECLARE

BEGIN
	DELETE FROM analise.imovel_geometria_sobreposicao WHERE id_imovel_geometria_tecnico = v_id_imovel_geometria_tecnico AND tp_origem = 1;

	PERFORM analise.imovel_geometria_sobreposicao_tecnico_insert(v_id_analise, v_id_imovel_geometria_tecnico, v_area_corte);

	RETURN 1;
	
END;$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION analise.imovel_geometria_sobreposicao_tecnico_update(integer, integer, double precision)
  OWNER TO postgres;
COMMENT ON FUNCTION analise.imovel_geometria_sobreposicao_tecnico_update(integer, integer, double precision) IS 'Update na tabela analise.imovel_geometria_tecnico: atualização na tabela analise.imovel_geometria_sobreposicao';




-- Function: analise.imovel_restricao(integer)

-- DROP FUNCTION analise.imovel_restricao(integer);

CREATE OR REPLACE FUNCTION analise.imovel_restricao(v_id_analise integer)
  RETURNS integer AS
$BODY$
DECLARE

v_cod_imovel VARCHAR(100);

BEGIN

	SELECT	cod_imovel
	INTO 	v_cod_imovel
	FROM	analise.analise a
		INNER JOIN
		usr_geocar_aplicacao.imovel i
		ON a.id_imovel = i.idt_imovel
	WHERE	a.id_analise = v_id_analise;

	INSERT INTO analise.imovel_restricao(id_restricao, id_origem, tx_descricao, nu_area_conflito, nu_percentual, dt_cadastro, id_analise)

	SELECT 	idt_restricao, idt_origem, des_descricao, num_area_conflito,
		num_percentual, dat_cadastro, v_id_analise
	FROM 	usr_geocar_aplicacao.imovel_restricao
	WHERE	cod_imovel = v_cod_imovel;

	RETURN 1;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION analise.imovel_restricao(integer)
  OWNER TO postgres;





-- Function: analise.imovel_restricao_analise(integer)

-- DROP FUNCTION analise.imovel_restricao_analise(integer);

CREATE OR REPLACE FUNCTION analise.imovel_restricao_analise(v_id_analise integer)
  RETURNS integer AS
$BODY$
DECLARE
	v_sql_uc TEXT;
	v_sql_ti TEXT;
	v_sql_ae TEXT;
	v_sql_as TEXT;
BEGIN
    INSERT INTO analise.historico_imovel_restricao
        (id_restricao, id_origem, tx_descricao, nu_area_conflito, nu_percentual, dt_cadastro, id_analise, dt_modificacao, tp_acao)
    SELECT id_restricao,
        id_origem,
        tx_descricao,
        nu_area_conflito,
        nu_percentual,
        dt_cadastro,
        id_analise,
        now(),
        0
    FROM analise.imovel_restricao
    WHERE	id_analise = v_id_analise;
    DELETE FROM analise.imovel_restricao
	WHERE id_analise = v_id_analise;
    SELECT '
		INSERT INTO analise.imovel_restricao(id_restricao, id_origem, nu_area_conflito, nu_percentual, dt_cadastro, id_analise)
		SELECT	5,
			uc.'|| nm_chave_primaria || ',
			ST_Area(ST_Transform(ST_Intersection_error(i.the_geom, ST_Transform(uc.the_geom, 4674)), usr_geocar_aplicacao.utmzone(ST_Centroid(i.the_geom)))) / 10000,
			(ST_Area(ST_Transform(ST_Intersection_error(i.the_geom, ST_Transform(uc.the_geom, 4674)), usr_geocar_aplicacao.utmzone(ST_Centroid(i.the_geom)))) / 10000) / i.nu_area * 100,
			now(),
			a.id_analise
		FROM	analise.analise a
			INNER JOIN
			analise.imovel_geometria i
			ON a.id_analise = i.id_analise
			INNER JOIN
			' ||nm_esquema || '.' || nm_tabela || ' uc
			ON ST_Intersects(i.the_geom, ST_Transform(uc.the_geom, 4674))
		WHERE	a.id_analise = ' || v_id_analise || '
			AND i.id_tema = 26
		'||COALESCE('AND uc.' || nm_ativo || ' = ''' ||tx_valor_ativo || '''', '') ||' ;'
    FROM usr_geocar_aplicacao.restricao
    INTO	v_sql_uc
	WHERE 	id_restricao = 5;
    EXECUTE v_sql_uc;
    SELECT '
		INSERT INTO analise.imovel_restricao(id_restricao, id_origem, nu_area_conflito, nu_percentual, dt_cadastro, id_analise)
		SELECT	4,
			ti.'|| nm_chave_primaria || ',
			ST_Area(ST_Transform(ST_Intersection_ERROR(i.the_geom, ST_Transform(ti.the_geom, 4674)), usr_geocar_aplicacao.utmzone(ST_Centroid(i.the_geom)))) / 10000,
			(ST_Area(ST_Transform(ST_Intersection_ERROR(i.the_geom, ST_Transform(ti.the_geom, 4674)), usr_geocar_aplicacao.utmzone(ST_Centroid(i.the_geom)))) / 10000) / i.nu_area * 100,
			now(),
			a.id_analise
		FROM	analise.analise a
			INNER JOIN
			analise.imovel_geometria i
			ON a.id_analise = i.id_analise
			INNER JOIN
			' ||nm_esquema || '.' || nm_tabela || ' ti
			ON ST_Intersects_ERROR(i.the_geom, ST_Transform(ti.the_geom, 4674))
		WHERE	a.id_analise = ' || v_id_analise || '
			AND i.id_tema = 26
		'||COALESCE('AND ti.' || nm_ativo || ' = ''' ||tx_valor_ativo || '''', '') ||' ;'
    FROM usr_geocar_aplicacao.restricao
    INTO	v_sql_ti
	WHERE 	id_restricao = 4;
    EXECUTE v_sql_ti;
    SELECT '
		INSERT INTO analise.imovel_restricao(id_restricao, id_origem, nu_area_conflito, nu_percentual, dt_cadastro, id_analise)
		SELECT	6,
			ae.'|| nm_chave_primaria || ',
			ST_Area(ST_Transform(ST_Intersection_error(i.the_geom, ST_Transform(ae.the_geom, 4674)), usr_geocar_aplicacao.utmzone(ST_Centroid(i.the_geom)))) / 10000,
			(ST_Area(ST_Transform(ST_Intersection_error(i.the_geom, ST_Transform(ae.the_geom, 4674)), usr_geocar_aplicacao.utmzone(ST_Centroid(i.the_geom)))) / 10000) / i.nu_area * 100,
			now(),
			a.id_analise
		FROM	analise.analise a
			INNER JOIN
			analise.imovel_geometria i
			ON a.id_analise = i.id_analise
			INNER JOIN
			' ||nm_esquema || '.' || nm_tabela || ' ae
			ON ST_Intersects(i.the_geom, ST_Transform(ae.the_geom, 4674))
		WHERE	a.id_analise = ' || v_id_analise || '
			AND i.id_tema = 26
		'||COALESCE('AND ae.' || nm_ativo || ' = ''' ||tx_valor_ativo || '''', '') ||' ;'
    FROM usr_geocar_aplicacao.restricao
    INTO	v_sql_ae
	WHERE 	id_restricao = 6;
    EXECUTE v_sql_ae;
    SELECT '
		INSERT INTO analise.imovel_restricao(id_restricao, id_origem, dt_cadastro, id_analise)
		SELECT	DISTINCT 13,
			ae.'|| nm_chave_primaria || ',
			now(),
			a.id_analise
		FROM	analise.analise a
			INNER JOIN
			analise.imovel_geometria i
			ON a.id_analise = i.id_analise
			INNER JOIN
			usr_geocar_aplicacao.imovel_pessoa ip
			ON a.id_imovel = ip.idt_imovel
			INNER JOIN
			usr_geocar_aplicacao.municipio m
			ON ST_Intersects(i.the_geom, m.geo_localizacao)
			INNER JOIN
			' ||nm_esquema || '.' || nm_tabela || ' ae
			ON ip.cod_cpf_cnpj = ae.cpf_cnpj_infrator
			INNER JOIN
			usr_geocar_aplicacao.municipio mae
			ON ST_Intersects(mae.geo_localizacao, ST_Transform(ae.the_geom, 4674))
			AND m.idt_municipio = mae.idt_municipio
			AND NOT ST_Intersects(i.the_geom, ST_Transform(ae.the_geom, 4674))
		WHERE	a.id_analise = ' || v_id_analise || '
			AND i.id_tema = 26
		'||COALESCE('AND ae.' || nm_ativo || ' = ''' ||tx_valor_ativo || '''', '') ||' ;'
    FROM usr_geocar_aplicacao.restricao
    INTO	v_sql_ae
	WHERE 	id_restricao = 13;
    EXECUTE v_sql_ae;
    SELECT '
		INSERT INTO analise.imovel_restricao(id_restricao, id_origem, dt_cadastro, id_analise)
		SELECT	DISTINCT 13,
			ae.'|| nm_chave_primaria || ',
			now(),
			a.id_analise
		FROM	analise.analise a
			INNER JOIN
			usr_geocar_aplicacao.imovel im
			ON a.id_imovel = im.idt_imovel
			INNER JOIN
			analise.imovel_geometria i
			ON a.id_analise = i.id_analise
			INNER JOIN
			usr_geocar_aplicacao.imovel_pessoa ip
			ON a.id_imovel = ip.idt_imovel
			INNER JOIN
			' ||nm_esquema || '.' || nm_tabela || ' ae
			ON im.idt_municipio = ae.cod_municipio::INTEGER
			AND ip.cod_cpf_cnpj = cpf_cnpj_infrator
		WHERE	a.id_analise = ' || v_id_analise || '
			AND i.id_tema = 26
			AND ae.the_geom IS NULL;'
    FROM usr_geocar_aplicacao.restricao
    INTO	v_sql_ae
	WHERE 	id_restricao = 13;
    EXECUTE v_sql_ae;
    SELECT '
		INSERT INTO analise.imovel_restricao(id_restricao, id_origem, nu_area_conflito, nu_percentual, dt_cadastro, id_analise)
		SELECT	12,
			ae.'|| nm_chave_primaria || ',
			ST_Area(ST_Transform(ST_Intersection_error(i.the_geom, ST_Transform(ae.the_geom, 4674)), usr_geocar_aplicacao.utmzone(ST_Centroid(i.the_geom)))) / 10000,
			(ST_Area(ST_Transform(ST_Intersection_error(i.the_geom, ST_Transform(ae.the_geom, 4674)), usr_geocar_aplicacao.utmzone(ST_Centroid(i.the_geom)))) / 10000) / i.nu_area * 100,
			now(),
			a.id_analise
		FROM	analise.analise a
			INNER JOIN
			analise.imovel_geometria i
			ON a.id_analise = i.id_analise
			INNER JOIN
			' ||nm_esquema || '.' || nm_tabela || ' ae
			ON ST_Intersects(i.the_geom, ST_Transform(ae.the_geom, 4674))
		WHERE	a.id_analise = ' || v_id_analise || '
			AND i.id_tema = 26
		'||COALESCE('AND ae.' || nm_ativo || ' = ''' ||tx_valor_ativo || '''', '') ||' ;'
    FROM usr_geocar_aplicacao.restricao
    INTO	v_sql_as
	WHERE 	id_restricao = 12;
    EXECUTE v_sql_as;
    RETURN 1;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION analise.imovel_restricao_analise(integer)
  OWNER TO postgres;




-- Function: analise.imovel_sobreposicao(integer)

-- DROP FUNCTION analise.imovel_sobreposicao(integer);

CREATE OR REPLACE FUNCTION analise.imovel_sobreposicao(v_id_analise integer)
  RETURNS integer AS
$BODY$
DECLARE

v_cod_imovel VARCHAR(100);

BEGIN

	SELECT	cod_imovel
	INTO 	v_cod_imovel
	FROM	analise.analise a
		INNER JOIN
		usr_geocar_aplicacao.imovel i
		ON a.id_imovel = i.idt_imovel
	WHERE	a.id_analise = v_id_analise;

	INSERT INTO analise.imovel_sobreposicao(id_analise, arr_imoveis_areas, nu_area_sobreposicao, nu_percentual_sobreposicao, nu_area_imovel, nu_modulo_fiscal)

	SELECT 	v_id_analise, arr_imoveis_areas, num_area_sobreposicao, num_percentual_sobreposicao, num_area_imovel, num_modulo_fiscal
	FROM 	usr_geocar_aplicacao.imovel_sobreposicao
	WHERE	cod_imovel = v_cod_imovel;

	RETURN 1;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION analise.imovel_sobreposicao(integer)
  OWNER TO postgres;




-- Function: analise.imovel_sobreposicao_analise(integer)

-- DROP FUNCTION analise.imovel_sobreposicao_analise(integer);

CREATE OR REPLACE FUNCTION analise.imovel_sobreposicao_analise(v_id_analise integer)
  RETURNS integer AS
$BODY$

DECLARE

	v_arr_imoveis_areas character varying[][];
	v_num_area_sobreposicao numeric (13,4);
	v_num_percentual_sobreposicao numeric(7,4);
	v_num_area_imovel numeric(13,4);
	v_num_modulo_fiscal numeric(13,4);
	v_id_analise_sobreposicao integer;

BEGIN

	--Verificar se o campo nu_area_imovel_edicao e nu_modulos_fiscais_edicao da tabela analise não é nulo, caso for nulo pegar da tabela de imóvel
  SELECT 
  INTO v_num_area_imovel,
       v_num_modulo_fiscal
  CASE WHEN i1.num_area_imovel IS NULL 
       THEN i2.num_area_imovel
       ELSE i1.num_area_imovel
  END AS num_area_imovel,
  CASE WHEN i1.num_modulo_fiscal IS NULL 
       THEN i2.num_modulo_fiscal
       ELSE i1.num_modulo_fiscal
  END AS num_mod_fiscal 
  FROM    analise.analise a1
  INNER JOIN
  usr_geocar_aplicacao.imovel i2
  ON i2.idt_imovel=a1.id_imovel
  Inner join
  usr_geocar_aplicacao.imovel i1
  on a1.id_imovel = i1.idt_imovel
  WHERE a1.id_analise = v_id_analise
  AND i2.ind_status_imovel <> 'CA'
  AND i2.flg_ativo = TRUE;


    SELECT analise.array_agg_custom(string_to_array(i2.cod_imovel || ',' ||
		(st_area(st_transform(ST_Intersection(ig1.the_geom, i2.geo_area_imovel), usr_geocar_aplicacao.utmzone(st_centroid(ig1.the_geom)))) / 10000) || ',' ||
		(((st_area(st_transform(ST_Intersection(ig1.the_geom, i2.geo_area_imovel), usr_geocar_aplicacao.utmzone(st_centroid(ig1.the_geom)))) / 10000) / v_num_area_imovel) * 100), ','))
    ::character varying[][],
		ST_Area
    (ST_Transform
    (ST_Intersection
    (ig1.the_geom, ST_Union
    (i2.geo_area_imovel)), usr_geocar_aplicacao.utmzone
    (ST_Centroid
    (ig1.the_geom)))) / 10000  AS num_area_sobreposicao,
    ((ST_Area
    (ST_Transform
    (ST_Intersection
    (ig1.the_geom, ST_Union
    (i2.geo_area_imovel)), usr_geocar_aplicacao.utmzone
    (ST_Centroid
    (ig1.the_geom)))) / 10000) / ig1.nu_area) * 100  AS num_percentual_sobreposicao
	INTO	v_arr_imoveis_areas,
		v_num_area_sobreposicao,
		v_num_percentual_sobreposicao
	FROM    analise.analise a1
		INNER JOIN
		analise.imovel_geometria ig1
		ON a1.id_analise = ig1.id_analise
		Inner join
		usr_geocar_aplicacao.imovel i1
		on a1.id_imovel = i1.idt_imovel
		INNER JOIN
		usr_geocar_aplicacao.imovel i2
		ON st_intersects
    (ig1.the_geom, i2.geo_area_imovel)
		AND a1.id_imovel <> i2.idt_imovel
	        AND i2.ind_status_imovel <> 'CA'
	WHERE	a1.id_analise = v_id_analise
		AND ig1.id_tema = 26
		AND i2.flg_ativo = TRUE
	GROUP BY ig1.the_geom,
		ig1.nu_area,
		i1.num_modulo_fiscal;

SELECT id_analise
INTO	v_id_analise_sobreposicao
FROM analise.imovel_sobreposicao i1
WHERE	i1.id_analise = v_id_analise;

IF v_arr_imoveis_areas IS NULL THEN

IF v_id_analise_sobreposicao IS NOT NULL THEN

INSERT INTO analise.historico_imovel_sobreposicao
    (id_analise, arr_imoveis_areas, nu_area_sobreposicao, nu_percentual_sobreposicao, nu_area_imovel, nu_modulo_fiscal, dt_cadastro, dt_modificacao, tp_acao)
SELECT id_analise,
    arr_imoveis_areas,
    nu_area_sobreposicao,
    nu_percentual_sobreposicao,
    nu_area_imovel,
    nu_modulo_fiscal,
    dt_cadastro,
    NOW(),
    0
FROM analise.imovel_sobreposicao
WHERE	id_analise = v_id_analise;

DELETE FROM analise.imovel_sobreposicao
			WHERE id_analise = v_id_analise;

RETURN 1;

END
IF;

	--Se tiver sobreposicao
	ELSE
		--Se tiver na tabela usr_geocar_aplicacao.imovel_sobreposicao:
		IF v_id_analise_sobreposicao IS NOT NULL THEN

INSERT INTO analise.historico_imovel_sobreposicao
    (id_analise, arr_imoveis_areas, nu_area_sobreposicao, nu_percentual_sobreposicao, nu_area_imovel, nu_modulo_fiscal, dt_cadastro, dt_modificacao, tp_acao)
SELECT id_analise,
    arr_imoveis_areas,
    nu_area_sobreposicao,
    nu_percentual_sobreposicao,
    nu_area_imovel,
    nu_modulo_fiscal,
    dt_cadastro,
    NOW(),
    0
FROM analise.imovel_sobreposicao
WHERE	id_analise = v_id_analise;

DELETE FROM analise.imovel_sobreposicao
			WHERE id_analise = v_id_analise;

INSERT INTO analise.imovel_sobreposicao
    (id_analise, arr_imoveis_areas, nu_area_sobreposicao, nu_percentual_sobreposicao, nu_area_imovel, nu_modulo_fiscal, dt_cadastro)
VALUES
    (v_id_analise, v_arr_imoveis_areas, v_num_area_sobreposicao, v_num_percentual_sobreposicao, v_num_area_imovel, v_num_modulo_fiscal, now());

RETURN 1;

ELSE
INSERT INTO analise.imovel_sobreposicao
    (id_analise, arr_imoveis_areas, nu_area_sobreposicao, nu_percentual_sobreposicao, nu_area_imovel, nu_modulo_fiscal, dt_cadastro)
VALUES
    (v_id_analise, v_arr_imoveis_areas, v_num_area_sobreposicao, v_num_percentual_sobreposicao, v_num_area_imovel, v_num_modulo_fiscal, now());

RETURN 1;

END     
IF;

	END
IF;

	RETURN 1;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION analise.imovel_sobreposicao_analise(integer)
  OWNER TO postgres;




-- Function: analise.imovel_sobreposicao_tema(integer)

-- DROP FUNCTION analise.imovel_sobreposicao_tema(integer);

CREATE OR REPLACE FUNCTION analise.imovel_sobreposicao_tema(v_id_analise integer)
  RETURNS integer AS
$BODY$DECLARE

	v_idt_area_imovel INTEGER;
	v_idt_area_antropizada INTEGER;
	v_idt_area_consolidada INTEGER;
	v_idt_vegetacao_nativa INTEGER;
	v_idt_area_uso_restrito_declividade_25_a_45 INTEGER;
	v_idt_area_uso_restrito_pantaneira INTEGER;
	v_idt_app_total INTEGER;
	v_idt_area_servidao_administrativa_total INTEGER;
	v_idt_arl_total INTEGER;
	v_idt_corpo_dagua INTEGER;
	v_sql TEXT;
	v_srid INTEGER;

BEGIN


	SELECT  idt_tema
	INTO  v_idt_area_imovel
	FROM  usr_geocar_aplicacao.tema
	WHERE cod_tema = 'AREA_IMOVEL';

	SELECT  idt_tema
	INTO  v_idt_area_antropizada
	FROM  usr_geocar_aplicacao.tema
	WHERE cod_tema = 'AREA_NAO_CLASSIFICADA';

	SELECT  idt_tema
	INTO  v_idt_area_consolidada
	FROM  usr_geocar_aplicacao.tema
	WHERE cod_tema = 'AREA_CONSOLIDADA';

	SELECT  idt_tema
	INTO  v_idt_vegetacao_nativa
	FROM  usr_geocar_aplicacao.tema
	WHERE cod_tema = 'VEGETACAO_NATIVA';

	SELECT  idt_tema
	INTO  v_idt_area_uso_restrito_declividade_25_a_45
	FROM  usr_geocar_aplicacao.tema
	WHERE cod_tema = 'AREA_USO_RESTRITO_DECLIVIDADE_25_A_45';

	SELECT  idt_tema
	INTO  v_idt_area_uso_restrito_pantaneira
	FROM  usr_geocar_aplicacao.tema
	WHERE cod_tema = 'AREA_USO_RESTRITO_PANTANEIRA';

	SELECT  idt_tema
	INTO  v_idt_app_total
	FROM  usr_geocar_aplicacao.tema
	WHERE cod_tema = 'APP_TOTAL';

	SELECT  idt_tema
	INTO  v_idt_area_servidao_administrativa_total
	FROM  usr_geocar_aplicacao.tema
	WHERE cod_tema = 'AREA_SERVIDAO_ADMINISTRATIVA_TOTAL';

	SELECT  idt_tema
	INTO  v_idt_arl_total
	FROM  usr_geocar_aplicacao.tema
	WHERE cod_tema = 'ARL_TOTAL';

	SELECT  idt_tema
	INTO  v_idt_corpo_dagua
	FROM  usr_geocar_aplicacao.tema
	WHERE cod_tema = 'CORPO_DAGUA';

	SELECT  usr_geocar_aplicacao.utmzone(ST_Centroid(the_geom)) 
	INTO  v_srid
	FROM  analise.imovel_geometria 
	WHERE id_analise = v_id_analise
	AND id_tema = v_idt_area_imovel; --tema area imovel
    
	IF v_srid IS NOT NULL THEN 

		DELETE FROM analise.imovel_sobreposicao_tema WHERE id_analise = v_id_analise;

		--Classificação CAR

		SELECT  String_Agg('WITH sobreposicoes_imoveis as (

		SELECT 	ST_CollectionExtract(ST_Intersection_Error(i.geo_area_imovel, iso.geo_area_imovel), 3) AS the_geom_intersecao,
			i.id_analise,
			i.idt_imovel,
			i.cod_imovel,
			i.num_area_imovel,
			i.num_area_sobreposicao,
			iso.idt_imovel AS idt_imovel_sobreposicao,
			iso.cod_imovel AS cod_imovel_sobreposicao,
			i.area_imovel_sobreposicao 
		FROM  
			(SELECT a.id_analise,
				i.idt_imovel,
				i.cod_imovel,
				i.num_area_imovel,
				iso.num_area_sobreposicao,
				iso.num_percentual_sobreposicao,
				i.geo_area_imovel,
				Unnest(arr_imoveis_areas[1:(array_length(arr_imoveis_areas, 1))][1:1]) AS cod_imovel_sobreposicao,
				Unnest(arr_imoveis_areas[1:(array_length(arr_imoveis_areas, 1))][2:2]) AS area_imovel_sobreposicao,
				Unnest(arr_imoveis_areas[1:(array_length(arr_imoveis_areas, 1))][3:3]) AS percentual_imovel_sobreposicao
			FROM  	analise.analise a
				INNER JOIN
				usr_geocar_aplicacao.imovel i
				ON a.id_imovel = i.idt_imovel
				INNER JOIN
				usr_geocar_aplicacao.imovel_sobreposicao iso
				ON i.cod_imovel = iso.cod_imovel
			WHERE a.id_analise = '|| v_id_analise||' and iso.num_percentual_sobreposicao >= 0.1) i

			INNER JOIN
			usr_geocar_aplicacao.imovel iso
			ON i.cod_imovel_sobreposicao = iso.cod_imovel

		WHERE 	iso.flg_ativo = TRUE AND i.percentual_imovel_sobreposicao::numeric > 0.1)

		INSERT INTO analise.imovel_sobreposicao_tema(id_analise, cod_imovel_sobreposto, tp_origem, id_tema, nu_area, the_geom)

		SELECT 	a.id_analise, a.cod_imovel_sobreposicao, 1, a.id_tema, a.nu_area, a.the_geom
		FROM 	(
			SELECT  i.id_analise,
				i.cod_imovel_sobreposicao,
				1,
				'|| id_tema || ' as id_tema,
				ST_Area(ST_Transform(ST_CollectionExtract(ST_Intersection_Error(i.the_geom_intersecao, ST_Union(c.the_geom)), 3), ' || v_srid || ')) / 10000 AS nu_area,
				ST_CollectionExtract(ST_Intersection_Error(i.the_geom_intersecao, ST_Union(c.the_geom)), 3) AS the_geom
			FROM 	sobreposicoes_imoveis i

				INNER JOIN
				' || nm_esquema_camada || '.' || nm_tabela_camada || ' c
				ON c.the_geom && i.the_geom_intersecao
				AND ST_Intersects_Error(c.the_geom, i.the_geom_intersecao)

			GROUP BY i.the_geom_intersecao,
				i.id_analise,
				i.idt_imovel,
				i.cod_imovel,
				i.idt_imovel_sobreposicao,
				i.cod_imovel_sobreposicao,
				i.area_imovel_sobreposicao) a
				WHERE nu_area > 0 AND nu_area IS NOT NULL;', '
		')
		INTO  v_sql
		FROM  analise.tema_analise
		WHERE id_tema_analise IN (1, 2, 4, 5);

		EXECUTE v_sql;

	--Vetorizacao Cadastrante

        WITH sobreposicoes_imoveis as (

	SELECT 	ST_CollectionExtract(ST_Intersection_Error(i.geo_area_imovel, iso.geo_area_imovel), 3) AS the_geom_intersecao,
		i.id_analise,
		i.idt_imovel,
		i.cod_imovel,
		i.num_area_imovel,
		i.num_area_sobreposicao,
		iso.idt_imovel AS idt_imovel_sobreposicao,
		iso.cod_imovel AS cod_imovel_sobreposicao,
		i.area_imovel_sobreposicao 
	FROM  
		(SELECT a.id_analise,
			i.idt_imovel,
			i.cod_imovel,
			i.num_area_imovel,
			iso.num_area_sobreposicao,
			iso.num_percentual_sobreposicao,
			i.geo_area_imovel,
			Unnest(arr_imoveis_areas[1:(array_length(arr_imoveis_areas, 1))][1:1]) AS cod_imovel_sobreposicao,
			Unnest(arr_imoveis_areas[1:(array_length(arr_imoveis_areas, 1))][2:2]) AS area_imovel_sobreposicao,
			Unnest(arr_imoveis_areas[1:(array_length(arr_imoveis_areas, 1))][3:3]) AS percentual_imovel_sobreposicao
		FROM  	analise.analise a
			INNER JOIN
			usr_geocar_aplicacao.imovel i
			ON a.id_imovel = i.idt_imovel
			INNER JOIN
			usr_geocar_aplicacao.imovel_sobreposicao iso
			ON i.cod_imovel = iso.cod_imovel
		WHERE a.id_analise = v_id_analise and iso.num_percentual_sobreposicao >= 0.1) i
      
		INNER JOIN
		usr_geocar_aplicacao.imovel iso
		ON i.cod_imovel_sobreposicao = iso.cod_imovel

	WHERE iso.flg_ativo = TRUE AND i.percentual_imovel_sobreposicao::numeric > 0.1)
    
	INSERT INTO analise.imovel_sobreposicao_tema(id_analise, cod_imovel_sobreposto, tp_origem, id_tema, nu_area, the_geom)
    
	SELECT 	a.id_analise, a.cod_imovel_sobreposicao, 0, a.id_tema, a.nu_area, a.the_geom
	FROM 
		(SELECT  i.id_analise,
			i.cod_imovel_sobreposicao,
			0,
			id_tema,
			ST_Area(ST_Transform(ST_CollectionExtract(ST_Intersection_Error(i.the_geom_intersecao, ST_Union(c.the_geom)), 3), v_srid)) / 10000 AS nu_area,
			ST_CollectionExtract(ST_Intersection_Error(i.the_geom_intersecao, ST_Union(c.the_geom)), 3) AS the_geom
        
		FROM  sobreposicoes_imoveis i

		INNER JOIN

		analise.imovel_geometria c
		ON i.id_analise = c.id_analise
		AND c.the_geom && i.the_geom_intersecao
		AND ST_Intersects_Error(c.the_geom, i.the_geom_intersecao)

	WHERE id_tema IN (v_idt_area_consolidada, v_idt_area_antropizada, v_idt_vegetacao_nativa, v_idt_area_uso_restrito_declividade_25_a_45, v_idt_area_uso_restrito_pantaneira, 
		v_idt_app_total, v_idt_area_servidao_administrativa_total, v_idt_arl_total, v_idt_corpo_dagua)

	GROUP BY i.the_geom_intersecao,
		i.id_analise,
		i.cod_imovel_sobreposicao,
		id_tema) a
  WHERE nu_area > 0 AND nu_area IS NOT NULL;

    RETURN 1;

  END IF;
    
    RETURN 0;

END;$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION analise.imovel_sobreposicao_tema(integer)
  OWNER TO postgres;




-- Function: analise.regularidade_imovel_areas_app(integer, double precision, integer[])

-- DROP FUNCTION analise.regularidade_imovel_areas_app(integer, double precision, integer[]);

CREATE OR REPLACE FUNCTION analise.regularidade_imovel_areas_app(
    v_id_analise integer,
    v_area_corte double precision,
    v_ids_imovel_geometria integer[])
  RETURNS integer AS
$BODY$

DECLARE
    v_idt_area_imovel INTEGER;
    v_idt_vegetacao_nativa INTEGER;
    v_idt_area_consolidada INTEGER;
    v_idt_area_nao_classificada INTEGER;
    v_idt_app_lago_natural INTEGER;
    v_idt_app_nascente_olho_dagua INTEGER;
    v_idt_app_rio_acima_600 INTEGER;
    v_idt_app_vereda INTEGER;
    v_idt_app_rio_50_a_200 INTEGER;
    v_idt_app_rio_200_a_600 INTEGER;
    v_idt_app_rio_ate_10 INTEGER;
    v_idt_app_rio_10_a_50 INTEGER;
    v_idt_app_escadinha_rio_ate_10 INTEGER;
    v_idt_app_escadinha_rio_10_a_50 INTEGER;
    v_idt_app_escadinha_rio_50_a_200 INTEGER;
    v_idt_app_escadinha_rio_200_a_600 INTEGER;
    v_idt_app_escadinha_rio_acima_600 INTEGER;
    v_idt_app_escadinha_vereda INTEGER;
    v_idt_app_escadinha_lago_natural INTEGER;
    v_idt_app_escadinha_nascente_olho_dagua INTEGER;
    v_srid INTEGER;


BEGIN
    SELECT idt_tema INTO v_idt_area_imovel                 FROM usr_geocar_aplicacao.tema WHERE cod_tema = 'AREA_IMOVEL';
    SELECT idt_tema INTO v_idt_vegetacao_nativa            FROM usr_geocar_aplicacao.tema WHERE cod_tema = 'VEGETACAO_NATIVA';
    SELECT idt_tema INTO v_idt_area_consolidada            FROM usr_geocar_aplicacao.tema WHERE cod_tema = 'AREA_CONSOLIDADA';
    SELECT idt_tema INTO v_idt_area_nao_classificada       FROM usr_geocar_aplicacao.tema WHERE cod_tema = 'AREA_NAO_CLASSIFICADA';
    SELECT idt_tema INTO v_idt_app_lago_natural            FROM usr_geocar_aplicacao.tema WHERE cod_tema = 'APP_LAGO_NATURAL';
    SELECT idt_tema INTO v_idt_app_nascente_olho_dagua     FROM usr_geocar_aplicacao.tema WHERE cod_tema = 'APP_NASCENTE_OLHO_DAGUA';
    SELECT idt_tema INTO v_idt_app_rio_acima_600           FROM usr_geocar_aplicacao.tema WHERE cod_tema = 'APP_RIO_ACIMA_600';
    SELECT idt_tema INTO v_idt_app_vereda                  FROM usr_geocar_aplicacao.tema WHERE cod_tema = 'APP_VEREDA';
    SELECT idt_tema INTO v_idt_app_rio_50_a_200            FROM usr_geocar_aplicacao.tema WHERE cod_tema = 'APP_RIO_50_A_200';
    SELECT idt_tema INTO v_idt_app_rio_200_a_600           FROM usr_geocar_aplicacao.tema WHERE cod_tema = 'APP_RIO_200_A_600';
    SELECT idt_tema INTO v_idt_app_rio_ate_10              FROM usr_geocar_aplicacao.tema WHERE cod_tema = 'APP_RIO_ATE_10';
    SELECT idt_tema INTO v_idt_app_rio_10_a_50             FROM usr_geocar_aplicacao.tema WHERE cod_tema = 'APP_RIO_10_A_50';
    SELECT idt_tema INTO v_idt_app_escadinha_rio_ate_10    FROM usr_geocar_aplicacao.tema WHERE cod_tema = 'APP_ESCADINHA_RIO_ATE_10';
    SELECT idt_tema INTO v_idt_app_escadinha_rio_10_a_50   FROM usr_geocar_aplicacao.tema WHERE cod_tema = 'APP_ESCADINHA_RIO_10_A_50';
    SELECT idt_tema INTO v_idt_app_escadinha_rio_50_a_200  FROM usr_geocar_aplicacao.tema WHERE cod_tema = 'APP_ESCADINHA_RIO_50_A_200';
    SELECT idt_tema INTO v_idt_app_escadinha_rio_200_a_600 FROM usr_geocar_aplicacao.tema WHERE cod_tema = 'APP_ESCADINHA_RIO_200_A_600';
    SELECT idt_tema INTO v_idt_app_escadinha_rio_acima_600 FROM usr_geocar_aplicacao.tema WHERE cod_tema = 'APP_ESCADINHA_RIO_ACIMA_600';
    SELECT idt_tema INTO v_idt_app_escadinha_vereda        FROM usr_geocar_aplicacao.tema WHERE cod_tema = 'APP_ESCADINHA_VEREDA';
    SELECT idt_tema INTO v_idt_app_escadinha_lago_natural  FROM usr_geocar_aplicacao.tema WHERE cod_tema = 'APP_ESCADINHA_LAGO_NATURAL';
    SELECT idt_tema INTO v_idt_app_escadinha_nascente_olho_dagua FROM usr_geocar_aplicacao.tema WHERE cod_tema = 'APP_ESCADINHA_NASCENTE_OLHO_DAGUA';
    
    SELECT usr_geocar_aplicacao.utmzone(ST_Centroid(the_geom)) INTO v_srid
    
    FROM   analise.imovel_geometria 
    WHERE   id_analise = v_id_analise
        AND id_tema = v_idt_area_imovel; 

    DELETE FROM analise.area_app_regularidade_imovel 
    WHERE id_analise = v_id_analise AND id_tema IN (
        v_idt_app_lago_natural, 
        v_idt_app_nascente_olho_dagua, 
        v_idt_app_rio_acima_600, 
        v_idt_app_vereda, 
        v_idt_app_rio_50_a_200,
        v_idt_app_rio_200_a_600,
        v_idt_app_rio_ate_10,
        v_idt_app_rio_10_a_50);


    INSERT INTO analise.area_app_regularidade_imovel(
        id_analise, 
        id_tema, 
        nu_area_total, 
        nu_area_recomposicao,
        nu_area_intersecao_vn, 
        nu_area_intersecao_ac_nao_passivel_recomposicao,
        nu_area_intersecao_ac_recomposicao,  
        nu_area_intersecao_aa_recomposicao,         
        fl_alerta_vermelho, 
        fl_alerta_amarelo,
        the_geom_area_recomposicao) 

    SELECT id_analise,

        id_tema,

        area_app_total,
        
        COALESCE(ST_Area(ST_Transform(COALESCE(ST_Union(app_recompor_ac, app_recompor_aa), app_recompor_ac, app_recompor_aa), v_srid)) / 10000, 0) AS nu_area_recomposicao,
        
        area_app_total_vn,
        
        area_app_total_ac - COALESCE(ST_Area(ST_Transform(app_recompor_ac, v_srid)) / 10000, 0) as nu_area_intersecao_ac_nao_passivel_recomposicao,
        
        COALESCE(ST_Area(ST_Transform(app_recompor_ac, v_srid)) / 10000, 0) AS nu_area_intersecao_ac_recomposicao, -- Resultado AREA RECOMPOR AC
        
        COALESCE(ST_Area(ST_Transform(app_recompor_aa, v_srid)) / 10000, 0) AS nu_area_intersecao_aa_recomposicao, -- Resultado AREA RECOMPOR AA
        
        fl_alerta_vermelho,

        fl_alerta_amarelo,

        COALESCE(ST_Union(app_recompor_ac, app_recompor_aa), app_recompor_ac, app_recompor_aa) as the_geom_area_recomposicao -- Resultado GEOM APP A RECOMPOR

    FROM
        (SELECT app_total.id_analise, -- Resultado ID_ANALISE,

            app_total.id_tema, -- Resultado ID_TEMA,

            COALESCE(ST_Area(ST_Transform(app_total.the_geom, v_srid)) / 10000, 0) AS area_app_total, -- Resultado APP TOTAL
            
            COALESCE(ST_Area(ST_Transform(ST_Union(ST_Intersection_Error(app_total.the_geom, vn.the_geom)), v_srid)) / 10000, 0) AS area_app_total_vn, -- Resultado APP EM VN
            
            ST_Union(
                CASE WHEN app_inconsistente.fl_escadinha IS TRUE
                    THEN  ST_Intersection_Error(app_inconsistente.the_geom, ac.the_geom)
                    END
            ) AS app_recompor_ac,

            
            ST_Union(ST_Intersection_Error(app_inconsistente.the_geom, aa.the_geom)) AS app_recompor_aa,
            
            COALESCE(ST_Area(ST_Transform(ST_Union(ST_Intersection_Error(app_total.the_geom, ac.the_geom)), v_srid)) / 10000, 0) AS area_app_total_ac,
            
            CASE WHEN COALESCE(ST_Area(ST_Transform(ST_Union(ST_Intersection_Error(app_total.the_geom, aa.the_geom)), v_srid)) / 10000, 0) > v_area_corte 
                THEN TRUE
                ELSE FALSE
                END AS fl_alerta_vermelho, -- Resultado ALERTA VERMELHO
            
            CASE WHEN COALESCE(ST_Area(ST_Transform(ST_Union(app_escadinha.the_geom), v_srid)) / 10000, 0) > 0
                THEN TRUE
                ELSE FALSE
                END AS fl_alerta_amarelo

        FROM
            (SELECT id_analise,
                id_tema,
                ST_Union(the_geom) AS the_geom
            FROM analise.imovel_geometria
            WHERE id_analise = v_id_analise AND id_tema IN (
                v_idt_app_lago_natural, 
                v_idt_app_nascente_olho_dagua, 
                v_idt_app_rio_acima_600, 
                v_idt_app_vereda, 
                v_idt_app_rio_50_a_200,
                v_idt_app_rio_200_a_600,
                v_idt_app_rio_ate_10,
                v_idt_app_rio_10_a_50)
            GROUP BY id_analise, id_tema) 
            AS app_total

            LEFT OUTER JOIN

            (SELECT id_analise,
                id_tema,
                ST_Union(the_geom) AS the_geom,
                CASE WHEN id_tema IN (
                    v_idt_app_escadinha_rio_ate_10,
                    v_idt_app_escadinha_rio_10_a_50,
                    v_idt_app_escadinha_rio_50_a_200,
                    v_idt_app_escadinha_rio_200_a_600,
                    v_idt_app_escadinha_rio_acima_600,
                    v_idt_app_escadinha_nascente_olho_dagua,
                    v_idt_app_escadinha_lago_natural,
                    v_idt_app_escadinha_vereda) THEN TRUE
                ELSE FALSE
                END as fl_escadinha

            FROM analise.imovel_geometria
            WHERE id_analise = v_id_analise AND id_imovel_geometria IN (SELECT UNNEST(v_ids_imovel_geometria)) -- Parametros ids
            GROUP BY id_analise, id_tema) 
            AS app_inconsistente

            ON  app_total.id_analise = app_inconsistente.id_analise
                AND ((app_total.id_tema = v_idt_app_rio_ate_10 AND app_inconsistente.id_tema IN (v_idt_app_escadinha_rio_ate_10, v_idt_app_rio_ate_10))
                OR (app_total.id_tema = v_idt_app_rio_10_a_50 AND app_inconsistente.id_tema IN (v_idt_app_escadinha_rio_10_a_50, v_idt_app_rio_10_a_50))
                OR (app_total.id_tema = v_idt_app_rio_50_a_200 AND app_inconsistente.id_tema IN (v_idt_app_escadinha_rio_50_a_200, v_idt_app_rio_50_a_200))
                OR (app_total.id_tema = v_idt_app_rio_200_a_600 AND app_inconsistente.id_tema IN (v_idt_app_escadinha_rio_200_a_600, v_idt_app_rio_200_a_600))
                OR (app_total.id_tema = v_idt_app_rio_acima_600  AND app_inconsistente.id_tema IN (v_idt_app_escadinha_rio_acima_600, v_idt_app_rio_acima_600))
                OR (app_total.id_tema = v_idt_app_nascente_olho_dagua AND app_inconsistente.id_tema IN (v_idt_app_escadinha_nascente_olho_dagua, v_idt_app_nascente_olho_dagua))
                OR (app_total.id_tema = v_idt_app_lago_natural AND app_inconsistente.id_tema IN (v_idt_app_escadinha_lago_natural, v_idt_app_lago_natural))
                OR (app_total.id_tema = v_idt_app_vereda AND app_inconsistente.id_tema IN (v_idt_app_escadinha_vereda, v_idt_app_vereda)))

            LEFT OUTER JOIN

            (SELECT id_analise,
                id_tema,
                ST_Union(the_geom) AS the_geom
            FROM analise.imovel_geometria
            WHERE id_analise = v_id_analise AND id_tema IN (
                v_idt_app_escadinha_rio_ate_10,
                v_idt_app_escadinha_rio_10_a_50,
                v_idt_app_escadinha_rio_50_a_200,
                v_idt_app_escadinha_rio_200_a_600,
                v_idt_app_escadinha_rio_acima_600,
                v_idt_app_escadinha_nascente_olho_dagua,
                v_idt_app_escadinha_lago_natural,
                v_idt_app_escadinha_vereda)
            GROUP BY id_analise, id_tema) 
            AS app_escadinha

            ON  app_total.id_analise = app_escadinha.id_analise
                AND ((app_total.id_tema = v_idt_app_rio_ate_10 AND app_escadinha.id_tema = v_idt_app_escadinha_rio_ate_10)
                OR (app_total.id_tema = v_idt_app_rio_10_a_50 AND app_escadinha.id_tema = v_idt_app_escadinha_rio_10_a_50)
                OR (app_total.id_tema = v_idt_app_rio_50_a_200 AND app_escadinha.id_tema = v_idt_app_escadinha_rio_50_a_200)
                OR (app_total.id_tema = v_idt_app_rio_200_a_600 AND app_escadinha.id_tema = v_idt_app_escadinha_rio_200_a_600)
                OR (app_total.id_tema = v_idt_app_rio_acima_600  AND app_escadinha.id_tema = v_idt_app_escadinha_rio_acima_600)
                OR (app_total.id_tema = v_idt_app_nascente_olho_dagua AND app_escadinha.id_tema = v_idt_app_escadinha_nascente_olho_dagua)
                OR (app_total.id_tema = v_idt_app_lago_natural AND app_escadinha.id_tema = v_idt_app_escadinha_lago_natural)
                OR (app_total.id_tema = v_idt_app_vereda AND app_escadinha.id_tema = v_idt_app_escadinha_vereda))

            LEFT OUTER JOIN

            (SELECT id_analise,
                ST_Union(the_geom) AS the_geom
            FROM analise.imovel_geometria 
            WHERE id_analise = v_id_analise AND id_tema = v_idt_area_nao_classificada
            GROUP BY id_analise) 
            AS aa
                    
            ON app_total.id_analise = aa.id_analise

            LEFT OUTER JOIN

            (SELECT id_analise,
                ST_Union(the_geom) AS the_geom
            FROM analise.imovel_geometria 
            WHERE id_analise = v_id_analise AND id_tema = v_idt_area_consolidada
            GROUP BY id_analise) 
            AS ac
            
            ON app_total.id_analise = ac.id_analise

            LEFT OUTER JOIN

            (SELECT id_analise,
                ST_Union(the_geom) AS the_geom
            FROM analise.imovel_geometria 
            WHERE id_analise = v_id_analise AND id_tema =  v_idt_vegetacao_nativa
            GROUP BY id_analise) 
            AS vn

            ON app_total.id_analise = vn.id_analise

        GROUP BY app_total.id_analise,
            app_total.id_tema,
            app_total.the_geom


        ) temp;
    RETURN 1;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION analise.regularidade_imovel_areas_app(integer, double precision, integer[])
  OWNER TO postgres;






-- Function: analise.regularidade_imovel_areas_app_especial(integer, double precision, integer[])

-- DROP FUNCTION analise.regularidade_imovel_areas_app_especial(integer, double precision, integer[]);

CREATE OR REPLACE FUNCTION analise.regularidade_imovel_areas_app_especial(
    v_id_analise integer,
    v_area_corte double precision,
    v_ids_imovel_geometria integer[])
  RETURNS integer AS
$BODY$
DECLARE

v_idt_area_imovel INTEGER;
v_srid INTEGER;
v_idt_vegetacao_nativa INTEGER;
v_idt_area_consolidada INTEGER;
v_idt_area_nao_classificada INTEGER;
v_idt_app_area_topo_morro INTEGER;
v_idt_app_manguezal INTEGER;
v_idt_app_area_altitude_superior_1800 INTEGER;
v_idt_app_borda_chapada INTEGER;
v_idt_app_restinga INTEGER;
v_idt_app_area_declividade_maior_45 INTEGER;
v_idt_app_reservatorio_artificial_decorrente_barramento INTEGER;
v_idt_app_banhado INTEGER;
v_idt_app_reservatorio_geracao_energia_ate_24_08_2001 INTEGER;

BEGIN
    SELECT  idt_tema
    INTO    v_idt_area_imovel
    FROM    usr_geocar_aplicacao.tema
    WHERE   cod_tema = 'AREA_IMOVEL';

    SELECT  idt_tema
    INTO    v_idt_vegetacao_nativa
    FROM    usr_geocar_aplicacao.tema
    WHERE   cod_tema = 'VEGETACAO_NATIVA';

    SELECT  idt_tema
    INTO    v_idt_area_consolidada
    FROM    usr_geocar_aplicacao.tema
    WHERE   cod_tema = 'AREA_CONSOLIDADA';

    SELECT  idt_tema
    INTO    v_idt_area_nao_classificada
    FROM    usr_geocar_aplicacao.tema
    WHERE   cod_tema = 'AREA_NAO_CLASSIFICADA';

    SELECT  idt_tema
    INTO    v_idt_app_area_topo_morro
    FROM    usr_geocar_aplicacao.tema
    WHERE   cod_tema = 'APP_AREA_TOPO_MORRO';

    SELECT  idt_tema
    INTO    v_idt_app_manguezal
    FROM    usr_geocar_aplicacao.tema
    WHERE   cod_tema = 'APP_MANGUEZAL';

    SELECT  idt_tema
    INTO    v_idt_app_area_altitude_superior_1800
    FROM    usr_geocar_aplicacao.tema
    WHERE   cod_tema = 'APP_AREA_ALTITUDE_SUPERIOR_1800';

    SELECT  idt_tema
    INTO    v_idt_app_borda_chapada
    FROM    usr_geocar_aplicacao.tema
    WHERE   cod_tema = 'APP_BORDA_CHAPADA';

    SELECT  idt_tema
    INTO    v_idt_app_restinga
    FROM    usr_geocar_aplicacao.tema
    WHERE   cod_tema = 'APP_RESTINGA';

    SELECT  idt_tema
    INTO    v_idt_app_area_declividade_maior_45
    FROM    usr_geocar_aplicacao.tema
    WHERE   cod_tema = 'APP_AREA_DECLIVIDADE_MAIOR_45';

    SELECT  idt_tema
    INTO    v_idt_app_reservatorio_artificial_decorrente_barramento
    FROM    usr_geocar_aplicacao.tema
    WHERE   cod_tema = 'APP_RESERVATORIO_ARTIFICIAL_DECORRENTE_BARRAMENTO';

    SELECT  idt_tema
    INTO    v_idt_app_reservatorio_artificial_decorrente_barramento
    FROM    usr_geocar_aplicacao.tema
    WHERE   cod_tema = 'APP_RESERVATORIO_ARTIFICIAL_DECORRENTE_BARRAMENTO';

    SELECT  idt_tema
    INTO    v_idt_app_banhado
    FROM    usr_geocar_aplicacao.tema
    WHERE   cod_tema = 'APP_BANHADO';

    SELECT  idt_tema
    INTO    v_idt_app_reservatorio_geracao_energia_ate_24_08_2001
    FROM    usr_geocar_aplicacao.tema
    WHERE   cod_tema = 'APP_RESERVATORIO_GERACAO_ENERGIA_ATE_24_08_2001';

    SELECT  usr_geocar_aplicacao.utmzone(ST_Centroid(the_geom)) 
    INTO    v_srid
    FROM    analise.imovel_geometria 
    WHERE   id_analise = v_id_analise
        AND id_tema = v_idt_area_imovel;

    DELETE FROM analise.area_app_regularidade_imovel 
    WHERE id_analise = v_id_analise AND id_tema IN (
        v_idt_app_area_topo_morro, 
        v_idt_app_manguezal, 
        v_idt_app_area_altitude_superior_1800, 
        v_idt_app_borda_chapada,
        v_idt_app_restinga, 
        v_idt_app_area_declividade_maior_45, 
        v_idt_app_reservatorio_artificial_decorrente_barramento,
        v_idt_app_banhado, 
        v_idt_app_reservatorio_geracao_energia_ate_24_08_2001);

    INSERT INTO analise.area_app_regularidade_imovel(
        id_analise, id_tema, nu_area_total, nu_area_recomposicao, nu_area_intersecao_vn, nu_area_intersecao_ac_nao_passivel_recomposicao, 
        nu_area_intersecao_ac_recomposicao, nu_area_intersecao_aa_recomposicao, fl_alerta_vermelho, fl_alerta_amarelo, the_geom_area_recomposicao)

    SELECT  id_analise,

        id_tema,

        area_app_total,

        COALESCE(ST_Area(ST_Transform(COALESCE(ST_Union(app_recompor_ac, app_recompor_aa), app_recompor_ac, app_recompor_aa), v_srid)) / 10000, 0) AS nu_area_recomposicao,

        area_app_total_vn,

        area_app_total_ac - COALESCE(ST_Area(ST_Transform(app_recompor_ac, v_srid)) / 10000, 0) as nu_area_intersecao_ac_nao_passivel_recomposicao,

        COALESCE(ST_Area(ST_Transform(app_recompor_ac, v_srid)) / 10000, 0) AS nu_area_intersecao_ac_recomposicao,

        COALESCE(ST_Area(ST_Transform(app_recompor_aa, v_srid)) / 10000, 0) AS nu_area_intersecao_aa_recomposicao,

        vermelho,

        amarelo,

        COALESCE(ST_Union(app_recompor_ac, app_recompor_aa), app_recompor_ac, app_recompor_aa) as the_geom_area_recomposicao -- Resultado GEOM APP A RECOMPOR

    FROM
        (SELECT rtip_total.id_analise, -- Resultado ID_ANALISE

            rtip_total.id_tema, -- Resultado ID_TEMA

            COALESCE(ST_Area(ST_Transform(rtip_total.the_geom, v_srid)) / 10000, 0) AS area_app_total, -- Resultado APP TOTAL

            COALESCE(ST_Area(ST_Transform(ST_Union(ST_Intersection_Error(rtip_total.the_geom, vn.the_geom)), v_srid)) / 10000, 0) AS area_app_total_vn, -- Resultado APP EM VN

            ST_Union(ST_Intersection_Error(app_inconsistente.the_geom, ac.the_geom)) AS app_recompor_ac,

            ST_Union(ST_Intersection_Error(app_inconsistente.the_geom, aa.the_geom)) AS app_recompor_aa,    

            COALESCE(ST_Area(ST_Transform(ST_Union(ST_Intersection_Error(rtip_total.the_geom, ac.the_geom)), v_srid)) / 10000, 0) AS area_app_total_ac,
            
            CASE    WHEN COALESCE(ST_Area(ST_Transform(ST_Union(ST_Intersection_Error(rtip_total.the_geom, aa.the_geom)), v_srid)) / 10000, 0) > v_area_corte THEN TRUE
                ELSE FALSE
            END AS vermelho,

            CASE    WHEN COALESCE(ST_Area(ST_Transform(ST_Union(ST_Intersection_Error(rtip_total.the_geom, ac.the_geom)), v_srid)) / 10000, 0) > v_area_corte THEN TRUE
                ELSE FALSE
            END AS amarelo

        FROM    

            (SELECT id_analise,
                    id_tema,
                    ST_Union(the_geom) AS the_geom
            FROM    analise.imovel_geometria 
            WHERE   id_analise = v_id_analise 
                    AND id_tema IN (
                        v_idt_app_area_topo_morro, 
                        v_idt_app_manguezal, 
                        v_idt_app_area_altitude_superior_1800, 
                        v_idt_app_borda_chapada,
                        v_idt_app_restinga,
                        v_idt_app_area_declividade_maior_45, 
                        v_idt_app_reservatorio_artificial_decorrente_barramento,
                        v_idt_app_banhado, 
                        v_idt_app_reservatorio_geracao_energia_ate_24_08_2001)
            GROUP BY    id_analise, id_tema) rtip_total

            LEFT OUTER JOIN

            (SELECT id_analise,
                    id_tema,
                    ST_Union(the_geom) AS the_geom
            FROM    analise.imovel_geometria 
            WHERE   id_analise = v_id_analise 
                    AND id_imovel_geometria IN (SELECT UNNEST(v_ids_imovel_geometria)) -- Parametros ids
            GROUP BY    id_analise, id_tema) app_inconsistente

            ON  rtip_total.id_analise = app_inconsistente.id_analise
            AND ((rtip_total.id_tema = v_idt_app_area_topo_morro AND app_inconsistente.id_tema = v_idt_app_area_topo_morro)
            OR   (rtip_total.id_tema = v_idt_app_manguezal AND app_inconsistente.id_tema = v_idt_app_manguezal)
            OR   (rtip_total.id_tema = v_idt_app_area_altitude_superior_1800 AND app_inconsistente.id_tema = v_idt_app_area_altitude_superior_1800)
            OR   (rtip_total.id_tema = v_idt_app_borda_chapada AND app_inconsistente.id_tema = v_idt_app_borda_chapada)
            OR   (rtip_total.id_tema = v_idt_app_restinga AND app_inconsistente.id_tema = v_idt_app_restinga)
            OR   (rtip_total.id_tema = v_idt_app_area_declividade_maior_45 AND app_inconsistente.id_tema = v_idt_app_area_declividade_maior_45)
            OR   (rtip_total.id_tema = v_idt_app_reservatorio_artificial_decorrente_barramento AND app_inconsistente.id_tema = v_idt_app_reservatorio_artificial_decorrente_barramento)
            OR   (rtip_total.id_tema = v_idt_app_banhado AND app_inconsistente.id_tema = v_idt_app_banhado)
            OR   (rtip_total.id_tema = v_idt_app_reservatorio_geracao_energia_ate_24_08_2001 AND app_inconsistente.id_tema = v_idt_app_reservatorio_geracao_energia_ate_24_08_2001))
            
            LEFT OUTER JOIN

            (SELECT ST_Union(the_geom) AS the_geom,
                id_analise
            FROM    analise.imovel_geometria 
            WHERE   id_analise = v_id_analise
                AND id_tema = v_idt_area_nao_classificada
            GROUP BY id_analise) aa
            ON rtip_total.id_analise = aa.id_analise
            
            LEFT OUTER JOIN

            (SELECT ST_Union(the_geom) AS the_geom,
                id_analise
            FROM    analise.imovel_geometria 
            WHERE   id_analise = v_id_analise
                AND id_tema =  v_idt_vegetacao_nativa
            GROUP BY id_analise) vn 
            ON rtip_total.id_analise = vn.id_analise
            
            LEFT OUTER JOIN

            (SELECT ST_Union(the_geom) AS the_geom,
                id_analise
            FROM    analise.imovel_geometria 
            WHERE   id_analise = v_id_analise
                AND id_tema = v_idt_area_consolidada
            GROUP BY id_analise) ac
            ON rtip_total.id_analise = ac.id_analise

        GROUP BY rtip_total.id_analise,
            rtip_total.id_tema,
            rtip_total.the_geom
            
        ) a;

    RETURN 1;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION analise.regularidade_imovel_areas_app_especial(integer, double precision, integer[])
  OWNER TO postgres;


-- Function: analise.regularidade_imovel_areas_fora_app_rl_ur(integer)

-- DROP FUNCTION analise.regularidade_imovel_areas_fora_app_rl_ur(integer);

CREATE OR REPLACE FUNCTION analise.regularidade_imovel_areas_fora_app_rl_ur(v_id_analise integer)
  RETURNS integer AS
$BODY$
DECLARE

v_idt_area_imovel INTEGER;
v_idt_app_total INTEGER;
v_idt_arl_total INTEGER;
v_idt_area_uso_restrito_declividade_25_a_45 INTEGER;
v_idt_area_uso_restrito_pantaneira INTEGER;
v_idt_area_imovel_liquida_analise INTEGER;
v_idt_vegetacao_nativa INTEGER; 
v_idt_area_consolidada INTEGER;
v_idt_area_pousio INTEGER;
v_idt_area_nao_classificada INTEGER; 
v_idt_corpo_dagua INTEGER;
v_srid INTEGER;

BEGIN

	SELECT	idt_tema
	INTO	v_idt_area_imovel
	FROM 	usr_geocar_aplicacao.tema
	WHERE	cod_tema = 'AREA_IMOVEL';

	SELECT	idt_tema
	INTO	v_idt_app_total
	FROM 	usr_geocar_aplicacao.tema
	WHERE	cod_tema = 'APP_TOTAL';

	SELECT	idt_tema
	INTO	v_idt_arl_total
	FROM 	usr_geocar_aplicacao.tema
	WHERE	cod_tema = 'ARL_TOTAL';

	SELECT	idt_tema
	INTO	v_idt_area_uso_restrito_declividade_25_a_45
	FROM 	usr_geocar_aplicacao.tema
	WHERE	cod_tema = 'AREA_USO_RESTRITO_DECLIVIDADE_25_A_45';

	SELECT	idt_tema
	INTO	v_idt_area_uso_restrito_pantaneira
	FROM 	usr_geocar_aplicacao.tema
	WHERE	cod_tema = 'AREA_USO_RESTRITO_PANTANEIRA';

	SELECT	idt_tema
	INTO	v_idt_area_imovel_liquida_analise
	FROM 	usr_geocar_aplicacao.tema
	WHERE	cod_tema = 'AREA_IMOVEL_LIQUIDA_ANALISE';

	SELECT	idt_tema
	INTO	v_idt_vegetacao_nativa
	FROM 	usr_geocar_aplicacao.tema
	WHERE	cod_tema = 'VEGETACAO_NATIVA';

	SELECT	idt_tema
	INTO	v_idt_area_consolidada
	FROM 	usr_geocar_aplicacao.tema
	WHERE	cod_tema = 'AREA_CONSOLIDADA';

	SELECT	idt_tema
	INTO	v_idt_area_pousio
	FROM 	usr_geocar_aplicacao.tema
	WHERE	cod_tema = 'AREA_POUSIO';

	SELECT	idt_tema
	INTO	v_idt_area_nao_classificada
	FROM 	usr_geocar_aplicacao.tema
	WHERE	cod_tema = 'AREA_NAO_CLASSIFICADA';

	SELECT	idt_tema
	INTO	v_idt_corpo_dagua
	FROM 	usr_geocar_aplicacao.tema
	WHERE	cod_tema = 'CORPO_DAGUA';

	SELECT	usr_geocar_aplicacao.utmzone(ST_Centroid(the_geom)) 
	INTO 	v_srid
	FROM	analise.imovel_geometria 
	WHERE	id_analise = v_id_analise
		AND id_tema = v_idt_area_imovel; 

	DELETE FROM analise.area_regularidade_imovel WHERE id_analise = v_id_analise AND tp_area_regularidade_imovel = 0;

	INSERT INTO analise.area_regularidade_imovel(id_analise, tp_area_regularidade_imovel, nu_area_total, id_tema_sobreposicao, nu_area_sobreposicao, the_geom)
		
	SELECT	v_id_analise,
		0, --áreas fora de APP
		area_total,
		id_tema,
		ST_Area(ST_Transform(geometria_tema, v_srid)) / 10000 as area_tema,
		geometria_tema

	FROM	(SELECT	ST_Area(ST_Transform(ST_Union(imovel_menos_app_rl_ur.the_geom), v_srid)) / 10000 as area_total,
			uso_solo.id_tema,
			ST_Area(ST_Transform(ST_Union(ST_Intersection_Error(imovel_menos_app_rl_ur.the_geom, uso_solo.the_geom)), v_srid)) / 10000 as area_tema,
			ST_CollectionExtract(ST_Union(ST_Intersection_Error(imovel_menos_app_rl_ur.the_geom, uso_solo.the_geom)), 3) AS geometria_tema

		FROM	(SELECT	imovel.id_analise,
				CASE	WHEN ST_Union(app_rl_ur.the_geom) IS NULL THEN imovel.the_geom
					ELSE ST_Difference_Error(imovel.the_geom, ST_Union(app_rl_ur.the_geom))
				END AS the_geom
				
			FROM	analise.imovel_geometria imovel
			
				LEFT OUTER JOIN
				(SELECT	*
				FROM	analise.imovel_geometria
				WHERE	id_analise = v_id_analise
					AND id_tema IN (v_idt_app_total, v_idt_arl_total, v_idt_area_uso_restrito_declividade_25_a_45, v_idt_area_uso_restrito_pantaneira) 
				) app_rl_ur
				ON imovel.id_analise = app_rl_ur.id_analise
				
			WHERE	imovel.id_analise = v_id_analise
				AND imovel.id_tema = v_idt_area_imovel_liquida_analise
				
			GROUP BY imovel.id_analise,
				imovel.the_geom
			) imovel_menos_app_rl_ur
				
			LEFT OUTER JOIN
			(SELECT	id_analise,
				id_tema,
				ST_Union(the_geom) AS the_geom
			FROM	analise.imovel_geometria
			WHERE	id_analise = v_id_analise
				AND id_tema IN (v_idt_vegetacao_nativa, v_idt_area_consolidada, v_idt_area_pousio, v_idt_area_nao_classificada, v_idt_corpo_dagua)
				AND tp_geometria = 0
			GROUP BY id_analise,
				id_tema
			) uso_solo
			ON uso_solo.id_analise = imovel_menos_app_rl_ur.id_analise
			AND ST_Intersects_Error(imovel_menos_app_rl_ur.the_geom, uso_solo.the_geom)
			
		GROUP BY imovel_menos_app_rl_ur.id_analise,
			uso_solo.id_tema
		) a
	WHERE	GeometryType(geometria_tema) IN ('MULTIPOLYGON', 'POLYGON');		

	RETURN 1;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION analise.regularidade_imovel_areas_fora_app_rl_ur(integer)
  OWNER TO postgres;




-- Function: analise.regularidade_imovel_areas_rl(integer, double precision)

-- DROP FUNCTION analise.regularidade_imovel_areas_rl(integer, double precision);

CREATE OR REPLACE FUNCTION analise.regularidade_imovel_areas_rl(
    v_id_analise integer,
    v_area_corte double precision)
  RETURNS integer AS
$BODY$
DECLARE

v_idt_area_imovel INTEGER;
v_idt_arl_proposta INTEGER;
v_idt_arl_averbada INTEGER;
v_idt_arl_aprovada_nao_averbada INTEGER;
v_idt_vegetacao_nativa INTEGER;
v_idt_area_consolidada INTEGER;
v_idt_area_nao_classificada INTEGER;
v_idt_app INTEGER;
v_srid INTEGER;

BEGIN

	SELECT	idt_tema
	INTO	v_idt_area_imovel
	FROM 	usr_geocar_aplicacao.tema
	WHERE	cod_tema = 'AREA_IMOVEL';

	SELECT	idt_tema
	INTO	v_idt_arl_proposta
	FROM 	usr_geocar_aplicacao.tema
	WHERE	cod_tema = 'ARL_PROPOSTA';

	SELECT	idt_tema
	INTO	v_idt_arl_averbada
	FROM 	usr_geocar_aplicacao.tema
	WHERE	cod_tema = 'ARL_AVERBADA';

	SELECT	idt_tema
	INTO	v_idt_arl_aprovada_nao_averbada
	FROM 	usr_geocar_aplicacao.tema
	WHERE	cod_tema = 'ARL_APROVADA_NAO_AVERBADA';

	SELECT	idt_tema
	INTO	v_idt_vegetacao_nativa
	FROM 	usr_geocar_aplicacao.tema
	WHERE	cod_tema = 'VEGETACAO_NATIVA';

	SELECT	idt_tema
	INTO	v_idt_area_consolidada
	FROM 	usr_geocar_aplicacao.tema
	WHERE	cod_tema = 'AREA_CONSOLIDADA';

	SELECT	idt_tema
	INTO	v_idt_area_nao_classificada
	FROM 	usr_geocar_aplicacao.tema
	WHERE	cod_tema = 'AREA_NAO_CLASSIFICADA';

	SELECT	idt_tema
	INTO	v_idt_app
	FROM 	usr_geocar_aplicacao.tema
	WHERE	cod_tema = 'APP_TOTAL';

	SELECT	usr_geocar_aplicacao.utmzone(ST_Centroid(the_geom)) INTO v_srid
	FROM	analise.imovel_geometria 
	WHERE	id_analise = v_id_analise
		AND id_tema = v_idt_area_imovel; 

	DELETE FROM analise.area_rl_regularidade_imovel WHERE id_analise = v_id_analise;

	INSERT INTO analise.area_rl_regularidade_imovel(
		id_analise, id_tema, nu_area_total, nu_area_cadastrante, nu_area_tecnico, nu_area_recomposicao, nu_area_intersecao_vn, 
		nu_area_intersecao_ac, nu_area_intersecao_aa, fl_alerta_vermelho, fl_alerta_amarelo, the_geom_area_recomposicao, 
		nu_area_intersecao_app, nu_area_intersecao_app_recompor)

	SELECT	id_analise,
		idt_tema,
		area_total,
		COALESCE(area_total_cadastrante, 0),
		COALESCE(area_total_tecnico, 0),
		COALESCE((ST_Area(ST_Transform(intersecao_rl_ac, v_srid)) / 10000), 0) + COALESCE((ST_Area(ST_Transform(intersecao_rl_aa, v_srid)) / 10000), 0) AS area_recompor,
		COALESCE(area_intersecao_rl_vn, 0) as area_intersecao_rl_vn,
		COALESCE(ST_Area(ST_Transform(intersecao_rl_ac, v_srid)) / 10000, 0) as area_intersecao_rl_ac,
		COALESCE(ST_Area(ST_Transform(intersecao_rl_aa, v_srid)) / 10000, 0) as area_intersecao_rl_aa,	
		CASE	WHEN (ST_Area(ST_Transform(intersecao_rl_aa, v_srid)) / 10000) > v_area_corte THEN TRUE
			ELSE FALSE
		END AS vermelho,
		CASE	WHEN (ST_Area(ST_Transform(intersecao_rl_ac, v_srid)) / 10000) > v_area_corte THEN TRUE
			ELSE FALSE
		END AS amarelo,
		ST_CollectionExtract(ST_Collect(intersecao_rl_aa, intersecao_rl_ac), 3) AS the_geom_area_recompor,
		COALESCE(area_intersecao_rl_app, 0),
		COALESCE(area_intersecao_rl_app_recompor, 0)
	FROM	(SELECT	rtip.id_analise,
			t.idt_tema,
			t.nom_tema,
			ST_Area(ST_Transform(rtip.the_geom, v_srid)) / 10000 AS area_total,
			ST_Area(ST_Transform(rtip.the_geom_cadastrante, v_srid)) / 10000 AS area_total_cadastrante,
			ST_Area(ST_Transform(rtip.the_geom_tecnico, v_srid)) / 10000 AS area_total_tecnico,
			ST_Area(ST_Transform(ST_Intersection_Error(rtip.the_geom, vn.the_geom), v_srid)) / 10000 AS area_intersecao_rl_vn,
			ST_Intersection_Error(rtip.the_geom, aa.the_geom) AS intersecao_rl_aa,
			ST_Intersection_Error(rtip.the_geom, ac.the_geom) AS intersecao_rl_ac,
			aa.the_geom AS aa_the_geom,
			ac.the_geom AS ac_the_geom,
			ST_Area(ST_Transform(ST_Intersection_Error(rtip.the_geom, app.the_geom), v_srid)) / 10000 AS area_intersecao_rl_app,
			ST_Area(ST_Transform(ST_Intersection_Error(rtip.the_geom, app_recompor.the_geom), v_srid)) / 10000 AS area_intersecao_rl_app_recompor
		FROM	(SELECT	a.id_analise,
				t.idt_tema AS id_tema,
				CASE	WHEN rtip.the_geom IS NULL AND igt.the_geom IS NOT NULL THEN igt.the_geom
					WHEN igt.the_geom IS NULL AND rtip.the_geom IS NOT NULL THEN rtip.the_geom
					WHEN igt.the_geom IS NULL AND rtip.the_geom IS NULL THEN NULL
					ELSE ST_Union(rtip.the_geom, igt.the_geom)
				END AS the_geom,
				rtip.the_geom AS the_geom_cadastrante,
				igt.the_geom AS the_geom_tecnico
				
			FROM	analise.analise a

				CROSS JOIN
				usr_geocar_aplicacao.tema t

				LEFT OUTER JOIN
				(SELECT	ST_Union(the_geom) AS the_geom,
					id_analise,
					id_tema
				FROM	analise.imovel_geometria 
				WHERE	id_analise = v_id_analise
					AND id_tema IN (v_idt_arl_proposta, v_idt_arl_averbada, v_idt_arl_aprovada_nao_averbada)
				GROUP BY id_analise,
					id_tema) rtip
				ON a.id_analise = rtip.id_analise
				AND t.idt_tema = rtip.id_tema
				
				LEFT OUTER JOIN
				(SELECT	ST_Union(the_geom) AS the_geom,
					id_analise,
					id_tema
				FROM	analise.imovel_geometria_tecnico igt
				WHERE	id_analise = v_id_analise
					AND igt.id_tema IN (v_idt_arl_averbada, v_idt_arl_aprovada_nao_averbada)
				GROUP BY id_analise,
					id_tema
				) igt
				ON a.id_analise = igt.id_analise
				AND t.idt_tema = igt.id_tema
				
			WHERE	a.id_analise = v_id_analise
				AND t.idt_tema IN (v_idt_arl_proposta, v_idt_arl_averbada, v_idt_arl_aprovada_nao_averbada)
			) rtip
			
			LEFT OUTER JOIN
			(SELECT	ST_Union(the_geom) AS the_geom,
				id_analise
			FROM	analise.imovel_geometria 
			WHERE	id_analise = v_id_analise
				AND id_tema = v_idt_vegetacao_nativa
			GROUP BY id_analise
			) vn
			ON rtip.id_analise = vn.id_analise
				
			LEFT OUTER JOIN
			(SELECT	ST_Union(the_geom) AS the_geom,
				id_analise
			FROM	analise.imovel_geometria 
			WHERE	id_analise = v_id_analise
				AND id_tema = v_idt_area_nao_classificada
			GROUP BY id_analise
			) aa
			ON rtip.id_analise = aa.id_analise
			
			LEFT OUTER JOIN
			(SELECT	ST_Union(the_geom) AS the_geom,
				id_analise
			FROM	analise.imovel_geometria 
			WHERE	id_analise = v_id_analise
				AND id_tema = v_idt_area_consolidada
			GROUP BY id_analise
			) ac
			ON rtip.id_analise = ac.id_analise

			LEFT OUTER JOIN
			(SELECT	ST_Union(the_geom) AS the_geom,
				id_analise
			FROM	analise.imovel_geometria 
			WHERE	id_analise = v_id_analise
				AND id_tema = v_idt_app
			GROUP BY id_analise
			) app
			ON rtip.id_analise = app.id_analise
	
			LEFT OUTER JOIN
			(SELECT	ST_CollectionExtract(ST_Union(the_geom_area_recomposicao), 3) AS the_geom,
				id_analise
			FROM	analise.area_app_regularidade_imovel 
			WHERE	id_analise = v_id_analise
				AND the_geom_area_recomposicao IS NOT NULL
				AND nu_area_recomposicao > 0
			GROUP BY id_analise
			) app_recompor
			ON rtip.id_analise = app_recompor.id_analise
			
			LEFT OUTER JOIN
			usr_geocar_aplicacao.tema t
			ON rtip.id_tema = t.idt_tema
		
		WHERE 	rtip.the_geom IS NOT NULL
		) a;

	RETURN 1;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION analise.regularidade_imovel_areas_rl(integer, double precision)
  OWNER TO postgres;






-- Function: analise.regularidade_imovel_areas_ur(integer)

-- DROP FUNCTION analise.regularidade_imovel_areas_ur(integer);

CREATE OR REPLACE FUNCTION analise.regularidade_imovel_areas_ur(v_id_analise integer)
  RETURNS integer AS
$BODY$
DECLARE

v_idt_area_imovel INTEGER;
v_idt_area_uso_restrito_declividade_25_a_45 INTEGER;
v_idt_area_uso_restrito_pantaneira INTEGER;
v_idt_vegetacao_nativa INTEGER; 
v_idt_area_consolidada INTEGER;
v_idt_area_pousio INTEGER;
v_idt_area_nao_classificada INTEGER; 
v_idt_corpo_dagua INTEGER;
v_srid INTEGER;

BEGIN

	SELECT	idt_tema
	INTO	v_idt_area_imovel
	FROM 	usr_geocar_aplicacao.tema
	WHERE	cod_tema = 'AREA_IMOVEL';

	SELECT	idt_tema
	INTO	v_idt_area_uso_restrito_declividade_25_a_45
	FROM 	usr_geocar_aplicacao.tema
	WHERE	cod_tema = 'AREA_USO_RESTRITO_DECLIVIDADE_25_A_45';

	SELECT	idt_tema
	INTO	v_idt_area_uso_restrito_pantaneira
	FROM 	usr_geocar_aplicacao.tema
	WHERE	cod_tema = 'AREA_USO_RESTRITO_PANTANEIRA';

	SELECT	idt_tema
	INTO	v_idt_vegetacao_nativa
	FROM 	usr_geocar_aplicacao.tema
	WHERE	cod_tema = 'VEGETACAO_NATIVA';

	SELECT	idt_tema
	INTO	v_idt_area_consolidada
	FROM 	usr_geocar_aplicacao.tema
	WHERE	cod_tema = 'AREA_CONSOLIDADA';

	SELECT	idt_tema
	INTO	v_idt_area_pousio
	FROM 	usr_geocar_aplicacao.tema
	WHERE	cod_tema = 'AREA_POUSIO';

	SELECT	idt_tema
	INTO	v_idt_area_nao_classificada
	FROM 	usr_geocar_aplicacao.tema
	WHERE	cod_tema = 'AREA_NAO_CLASSIFICADA';

	SELECT	idt_tema
	INTO	v_idt_corpo_dagua
	FROM 	usr_geocar_aplicacao.tema
	WHERE	cod_tema = 'CORPO_DAGUA';

	SELECT	usr_geocar_aplicacao.utmzone(ST_Centroid(the_geom)) INTO v_srid
	FROM	analise.imovel_geometria 
	WHERE	id_analise = v_id_analise
		AND id_tema = v_idt_area_imovel;

	INSERT INTO analise.area_regularidade_imovel(id_analise, tp_area_regularidade_imovel, nu_area_total, id_tema_sobreposicao, nu_area_sobreposicao, the_geom)	

	SELECT * FROM (
		SELECT	v_id_analise,
			1, --UR
			ST_Area(ST_Transform(ST_Union(uso_restrito.the_geom), v_srid)) / 10000 AS area_total,
			uso_solo.id_tema,
			ST_Area(ST_Transform(ST_Union(ST_Intersection_Error(uso_restrito.the_geom, uso_solo.the_geom)), v_srid)) / 10000 AS area_tema,
			ST_CollectionExtract(ST_Union(ST_Intersection_Error(uso_restrito.the_geom, uso_solo.the_geom)), 3) AS geometria_tema

		FROM	(SELECT	ST_Union(the_geom) AS the_geom,
				id_analise
			FROM	analise.imovel_geometria 
			WHERE	id_tema IN (v_idt_area_uso_restrito_declividade_25_a_45, v_idt_area_uso_restrito_pantaneira)
				AND id_analise = v_id_analise
			GROUP BY id_analise
			) uso_restrito
			
			LEFT OUTER JOIN
			(SELECT	id_analise,
				id_tema,
				ST_Union(the_geom) AS the_geom
			FROM	analise.imovel_geometria 
			WHERE	id_analise = v_id_analise
				AND id_tema IN (v_idt_vegetacao_nativa, v_idt_area_consolidada, v_idt_area_pousio, v_idt_area_nao_classificada, v_idt_corpo_dagua) 
				AND tp_geometria = 0
			GROUP BY id_analise,
				id_tema
			) uso_solo
			ON uso_solo.id_analise = uso_restrito.id_analise
			AND ST_Intersects(uso_restrito.the_geom, uso_solo.the_geom)
			
		GROUP BY uso_solo.id_tema) a
	WHERE area_tema > 0 AND geometria_tema IS NOT NULL;

	RETURN 1;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION analise.regularidade_imovel_areas_ur(integer)
  OWNER TO postgres;


-- Function: analise.f_criar_vistoria_tx_protocolo()

-- DROP FUNCTION analise.f_criar_vistoria_tx_protocolo();

CREATE OR REPLACE FUNCTION analise.f_criar_vistoria_tx_protocolo()
  RETURNS trigger AS
$BODY$ 
DECLARE

	v_cod_estado character varying(2);
	v_ano   integer;
	v_count integer; 

BEGIN

        IF new.dt_validacao IS NOT NULL AND new.tx_protocolo IS NULL THEN 
        
		SELECT 	m.cod_estado
		INTO	v_cod_estado
		FROM 	analise.vistoria v		
			INNER JOIN  analise.analise a 
			ON v.id_analise = a.id_analise		
			INNER JOIN usr_geocar_aplicacao.imovel i 		
			ON a.id_imovel = i.idt_imovel 
			INNER JOIN usr_geocar_aplicacao.municipio m 
			ON i.idt_municipio = m.idt_municipio
		WHERE 	v.id_vistoria = old.id_vistoria;

		SELECT	CAST(substring(tx_protocolo from 8 for 4) AS integer),
			CAST(substring(tx_protocolo from 13) AS integer)
		INTO    v_ano, v_count
		FROM	analise.vistoria
		WHERE	id_vistoria = 
				(SELECT id_vistoria
				FROM 	analise.vistoria v		
					INNER JOIN  analise.analise a 
					ON v.id_analise = a.id_analise		
					INNER JOIN usr_geocar_aplicacao.imovel i 		
					ON a.id_imovel = i.idt_imovel 
					INNER JOIN usr_geocar_aplicacao.municipio m 
					ON i.idt_municipio = m.idt_municipio
				WHERE 	cod_estado = v_cod_estado 					
					AND v.dt_validacao IS NOT NULL
				ORDER BY dt_validacao DESC LIMIT 1);	   	

		IF (v_ano < extract (year from now())) OR (v_ano IS NULL) THEN			
			
			new.tx_protocolo = CAST(v_cod_estado || '-VIS-' || extract (year from now()) || '-' || '000001' AS text);
		
			RETURN new;			 

		ELSE	
			new.tx_protocolo = CAST(v_cod_estado || '-VIS-' || v_ano || '-' || LTrim(TO_CHAR(v_count + 1,'000000')) AS text);

			RETURN new;			

		END IF; 

	END IF;      

	RETURN new;
	
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION analise.f_criar_vistoria_tx_protocolo()
  OWNER TO postgres;



-- Function: analise.f_imovel_geometria_tecnico_nu_area()

-- DROP FUNCTION analise.f_imovel_geometria_tecnico_nu_area();

CREATE OR REPLACE FUNCTION analise.f_imovel_geometria_tecnico_nu_area()
  RETURNS trigger AS
$BODY$ 
DECLARE

BEGIN

	new.nu_area := (ST_Area(ST_Transform(new.the_geom, usr_geocar_aplicacao.utmzone(ST_Centroid(new.the_geom)))) / 10000);
 
	RETURN new;
	
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION analise.f_imovel_geometria_tecnico_nu_area()
  OWNER TO postgres;

-- Function: analise.f_inconsistencia_geometria_nu_area()

-- DROP FUNCTION analise.f_inconsistencia_geometria_nu_area();

CREATE OR REPLACE FUNCTION analise.f_inconsistencia_geometria_nu_area()
  RETURNS trigger AS
$BODY$ 
DECLARE

BEGIN

	new.nu_area := (ST_Area(ST_Transform(new.the_geom, usr_geocar_aplicacao.utmzone(ST_Centroid(new.the_geom)))) / 10000);
 
	RETURN new;
	
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION analise.f_inconsistencia_geometria_nu_area()
  OWNER TO postgres;



-- Function: analise.f_regiao_analise_nu_municipios()

-- DROP FUNCTION analise.f_regiao_analise_nu_municipios();

CREATE OR REPLACE FUNCTION analise.f_regiao_analise_nu_municipios()
  RETURNS trigger AS
$BODY$ 
DECLARE

	v_cod_estado character varying(2);
	
BEGIN

	IF TG_OP = 'INSERT' THEN	
		
		SELECT  cod_estado  
		INTO 	v_cod_estado 
		FROM 	usr_geocar_aplicacao.municipio 
		WHERE 	idt_municipio = new.id_municipio;
		
		UPDATE 	analise.regiao_analise 
		SET 	nu_municipios = nu_municipios - 1 
		WHERE 	cod_estado = v_cod_estado
			AND fl_padrao = 'TRUE'; 

		UPDATE  analise.regiao_analise  
		SET  	nu_municipios = nu_municipios + 1 
		WHERE 	id_regiao_analise =  new.id_regiao_analise;
		
		RETURN new;
		
	ELSE 
		IF TG_OP = 'UPDATE' THEN
		
			IF new.id_regiao_analise <> old.id_regiao_analise THEN 

				UPDATE 	analise.regiao_analise 
				SET 	nu_municipios = nu_municipios - 1 
				WHERE 	id_regiao_analise = old.id_regiao_analise;   					
						
				UPDATE	analise.regiao_analise 
				SET 	nu_municipios = nu_municipios + 1 
				WHERE   id_regiao_analise = new.id_regiao_analise;
										
				RETURN new;					
					
			END IF;

			RETURN new;	
		ELSE 			
			IF TG_OP = 'DELETE' THEN

				UPDATE 	analise.regiao_analise 
				SET 	nu_municipios = nu_municipios - 1
				WHERE  	id_regiao_analise = old.id_regiao_analise;
				
				SELECT  cod_estado  
				INTO 	v_cod_estado 
				FROM 	usr_geocar_aplicacao.municipio 
				WHERE 	idt_municipio = old.id_municipio;
				
				UPDATE 	analise.regiao_analise 
				SET 	nu_municipios = nu_municipios + 1
				WHERE  	cod_estado = v_cod_estado
					AND fl_padrao = 'TRUE'; 
				
				RETURN old;
				
			END IF;
			
		END IF;
	END IF;	

	COMMIT;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION analise.f_regiao_analise_nu_municipios()
  OWNER TO postgres;



