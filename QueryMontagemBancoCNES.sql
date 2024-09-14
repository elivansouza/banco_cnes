-- TRATAMENTOS - TABELA

-- CRIAÇÃO DA TABELA
-- QUANDO ATUALIZAR O BANCO, NECESSÁRIO ATUALIZAR NOMES E SCHEMA
CREATE TABLE cnes.cnes_202407 AS
SELECT
    co_unidade,
    co_cnes,
    tp_pfpj,
    nivel_dep,
    no_razao_social,
    no_fantasia,
    no_logradouro,
    nu_endereco,
    no_complemento,
    no_bairro,
    co_cep,
    nu_telefone,
    no_email,
    nu_cpf,
    nu_cnpj,
    co_atividade,
    co_clientela,
    tp_unidade,
    co_turno_atendimento,
    co_estado_gestor,
    co_municipio_gestor,
    TO_DATE("TO_CHAR(DT_ATUALIZACAO,'DD/MM/YYYY')", 'DD/MM/YYYY') AS "dt_atualizacao",
    co_usuario,
    co_cpfdiretorcln,
    reg_diretorcln,
    st_adesao_filantrop,
    co_motivo_desab,
    nu_latitude,
    nu_longitude,
    TO_DATE("TO_CHAR(DT_ATU_GEO,'DD/MM/YYYY')", 'DD/MM/YYYY') AS "dt_atu_geo",
    no_usuario_geo,
    co_natureza_jur,
    tp_estab_sempre_aberto,
    st_conexao_internet,
    co_tipo_unidade,
    no_fantasia_abrev,
    tp_gestao,
    TO_DATE("TO_CHAR(DT_ATUALIZACAO_ORIGEM,'DD/MM/YYYY')", 'DD/MM/YYYY') AS dt_atualizacao_origem,
    co_tipo_estabelecimento,
    co_atividade_principal,
    st_contrato_formalizado
FROM cnes.tbestabelecimento202407;

-- Adiciona a nova coluna à tabela
ALTER TABLE cnes.cnes_202407 
ADD COLUMN tp_pfpj int8;

-- Altera o tipo de variável
UPDATE cnes.cnes_202407 
SET tp_pfpj = CAST(tp_pfpj AS int8);

-- Adiciona a nova coluna à tabela
ALTER TABLE cnes.cnes_202407
ADD COLUMN ds_tipo_estabelecimento TEXT;

-- Atualiza a nova coluna com os valores da consulta
UPDATE cnes.cnes_202407
SET ds_tipo_estabelecimento = b.ds_tipo_estabelecimento
FROM cnes.tbtipoestabelecimento202407 b
WHERE cnes.cnes_202407.co_tipo_estabelecimento = b.co_tipo_estabelecimento;

-- Adiciona a nova coluna à tabela
ALTER TABLE cnes.cnes_202407
ADD COLUMN ds_clientela TEXT;

-- Atualiza a nova coluna com os valores da consulta
UPDATE cnes.cnes_202407
SET ds_clientela = 
    CASE
        WHEN co_clientela = '00' THEN 'Fluxo de Clientela não exigido'
        WHEN co_clientela = '01' THEN 'Atendimento de demanda espontânea'
        WHEN co_clientela = '02' THEN 'Atendimento de demanda referenciada'
        WHEN co_clientela = '03' THEN 'Atendimento de demanda espontânea e referenciada'
        WHEN co_clientela = '99' THEN 'Fluxo de Clientela não informado'
        ELSE 'Fluxo de Clientela não informado'
    END;

-- Adiciona a nova coluna à tabela
ALTER TABLE cnes.cnes_202407
ADD COLUMN ds_atividade_principal TEXT;

-- Atualiza a nova coluna com os valores da consulta
UPDATE cnes.cnes_202407
SET ds_atividade_principal = b.ds_atividade
FROM cnes.tbatividade202407 AS b
WHERE cnes.cnes_202407.co_atividade_principal = b.co_atividade;

-- Adiciona a nova coluna à tabela
ALTER TABLE cnes.cnes_202407
ADD COLUMN ds_tp_gestao TEXT;

-- Atualiza a nova coluna com os valores da consulta
UPDATE cnes.cnes_202407
SET ds_tp_gestao = 
    CASE
		WHEN tp_gestao = 'Z' THEN 'Não informado'
		WHEN tp_gestao = 'D' THEN 'Dupla'
		WHEN tp_gestao = 'E' THEN 'Estadual'
		WHEN tp_gestao = 'M' THEN 'Municipal'
		WHEN tp_gestao = 'S' THEN 'Sem gestão'
		ELSE NULL
    END;

-- Adiciona a nova coluna à tabela
ALTER TABLE cnes.cnes_202407
ADD COLUMN ds_pfpj TEXT;

-- Atualiza a nova coluna com os valores da consulta
UPDATE cnes.cnes_202407
SET ds_pfpj = 
	CASE
		WHEN tp_pfpj = '1' THEN 'Pessoa física'
		WHEN tp_pfpj = '3' THEN 'Pessoa jurídica'
		ELSE NULL
	END;

-- Adiciona a nova coluna à tabela
ALTER TABLE cnes.cnes_202407
ADD COLUMN ds_nivel_dep TEXT;

-- Atualiza a nova coluna com os valores da consulta
UPDATE cnes.cnes_202407
SET ds_nivel_dep = 
	CASE
	WHEN nivel_dep = '1' THEN 'Individual'
	WHEN nivel_dep = '3' THEN 'Mantida'
	ELSE NULL
END;

-- Adiciona a nova coluna à tabela
ALTER TABLE cnes.cnes_202407
ADD COLUMN ds_tipo_unidade TEXT;

-- Atualiza a nova coluna com os valores da consulta
UPDATE cnes.cnes_202407
SET ds_tipo_unidade = b.ds_tipo_unidade
FROM cnes.tbtipounidade202407 AS b
WHERE cnes.cnes_202407.tp_unidade = b.co_tipo_unidade;

-- Adiciona a nova coluna à tabela
ALTER TABLE cnes.cnes_202407
ADD COLUMN ds_turno_atendimento TEXT;

-- Atualiza a nova coluna com os valores da consulta
UPDATE cnes.cnes_202407
SET ds_turno_atendimento = b.ds_turno_atendimento
FROM cnes.tbturnoatendimento202407 AS b
WHERE cnes.cnes_202407.co_turno_atendimento = b.co_turno_atendimento;

-- Cria a variável de descrição da natureza jurídica
ALTER TABLE cnes.cnes_202407 
ADD COLUMN ds_natureza_jur TEXT;

-- Atualiza a nova coluna com os valores da consulta
UPDATE cnes.cnes_202407
SET ds_natureza_jur = b.ds_natureza_jur
FROM cnes.natureza_juridica AS b
WHERE cnes.cnes_202407.co_natureza_jur = b.co_natureza_jur;

-- Criação de VIEW de tabela de profissionais
CREATE OR REPLACE VIEW cnes.vw_profissionais AS
SELECT
    co_unidade,
    SUM(qtd_profissional) FILTER (WHERE LEFT(co_cbo, 4) = '2232') AS cirurgioes_dentistas,
    SUM(qtd_profissional) FILTER (WHERE LEFT(co_cbo, 4) = '2235') AS enfermeiros,
    SUM(qtd_profissional) FILTER (WHERE LEFT(co_cbo, 4) IN ('2251', '2252', '2253')) AS medicos,
    SUM(qtd_profissional) AS total
FROM (
    SELECT
        a.co_unidade AS co_unidade,
        a.co_cbo AS co_cbo,
        b.titulo AS titulo,
        COUNT(DISTINCT(co_profissional_sus)) AS qtd_profissional
    FROM cnes.rlestabequipeprof202407 AS a
    LEFT JOIN cbo."CBO2002 - Ocupacao" AS b ON a.co_cbo = b.codigo
    WHERE LEFT(a.co_cbo, 4) IN ('2232', '2235', '2251', '2252', '2253')
    GROUP BY 1, 2, 3
) profs
GROUP BY 1;