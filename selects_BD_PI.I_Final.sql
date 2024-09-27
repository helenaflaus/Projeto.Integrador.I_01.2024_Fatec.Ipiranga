-- Active: 1716856021564@@127.0.0.1@5432@BD_PI_012024_G6
-- Listar todas as tabelas no banco de dados
SELECT table_schema, table_name
FROM information_schema.tables
WHERE table_schema NOT IN ('information_schema', 'pg_catalog')
ORDER BY table_schema, table_name ;

-- Listar todas as colunas de cada tabela
SELECT table_schema, table_name, column_name, data_type, character_maximum_length, is_nullable
FROM information_schema.columns
WHERE table_schema NOT IN ('information_schema', 'pg_catalog')
ORDER BY table_schema, table_name, ordinal_position ;

-- Listar todas as propostas populadas
SELECT *
FROM proposta ;

-- Listar todas as propostas com status 'aprovada'
SELECT *
FROM proposta p
WHERE p.id_proposta IN (
    SELECT id_proposta
    FROM status_proposta
    WHERE tipo_status = 'aprovada'
) ;

-- Quantidade total de propostas aprovadas no ano anterior (2023) e valor total $ valor aprovado em 2023
SELECT COUNT(id_proposta) AS "Propostas Aprovadas em 2023",
    TO_CHAR(SUM(valor), 'FM"R$ "9G999G999G999G999') AS "Valor Total"
FROM status_proposta 
WHERE tipo_status = 'aprovada' AND dt_atualizacao BETWEEN '01/01/2023' AND '31/12/2023' ;

-- Valor total $ de propostas aprovadas por ano
SELECT 
    EXTRACT(YEAR FROM dt_atualizacao) AS "Ano",
    COUNT(id_proposta) AS "Propostas Aprovadas",
    TO_CHAR(SUM(valor), 'FM"R$ "9G999G999G999G999') AS "Valor Total"
FROM status_proposta 
WHERE tipo_status = 'aprovada'
GROUP BY EXTRACT(YEAR FROM dt_atualizacao)
ORDER BY "Ano" ;

-- Card: Valor $ médio de todas aprovadas em 2023 
SELECT  TO_CHAR(AVG(valor), 'FM"R$ "9G999G999G999G999') AS "Valor médio propostas aprovadas em 2023"
FROM status_proposta
WHERE tipo_status = 'aprovada' AND dt_atualizacao BETWEEN '01/01/2023' AND '31/12/2023' ;

-- Card: Valor médio de todas propostas ja aprovadas registradas
SELECT  TO_CHAR(AVG(valor), 'FM"R$ "9G999G999G999G999') AS "Valor médio propostas aprovadas"
FROM status_proposta
WHERE tipo_status = 'aprovada' ;

-- Car: Valor total de propostas 'aprovadas'
SELECT TO_CHAR(SUM(valor), 'FM"R$ "9G999G999G999G999') AS "Valor Total de Propostas Aprovadas"
FROM status_proposta
WHERE tipo_status = 'aprovada' ;

-- Contabilizar a quantidade de propostas 'enviadas' por tipo de projeto e ordenar de forma decrescente
SELECT 
    tp.tipo_projeto AS "Tipo de Projeto", 
    COUNT(tp.tipo_projeto) AS "Quantidade de Propostas Enviadas"
FROM proposta p
JOIN tipo_projeto tp ON p.id_tipo_projeto = tp.id_tipo_projeto
JOIN status_proposta sp ON p.id_proposta = sp.id_proposta
WHERE sp.tipo_status = 'enviada'
GROUP BY tp.tipo_projeto
ORDER BY "Quantidade de Propostas Enviadas" DESC ;

-- Soma total dos valores $ orçados de propostas 'enviadas' por tipo de projeto e ordenar de forma decrescente
SELECT
    tp.tipo_projeto AS "Tipo de Projeto",
    TO_CHAR(SUM(sp.valor), 'FM"R$ "9G999G999G999G999') AS "Valor Total Orçado de Propostas Enviadas"
FROM proposta p
JOIN tipo_projeto tp ON p.id_tipo_projeto = tp.id_tipo_projeto
JOIN status_proposta sp ON p.id_proposta = sp.id_proposta
WHERE sp.tipo_status = 'enviada'
GROUP BY tp.tipo_projeto
ORDER BY SUM(sp.valor) DESC ;

-- Mostrar soma total dos valores $ orçados de propostas 'enviadas' após 01/01/2023 por tipo de projeto e ordenar de forma decrescente
SELECT
    tp.tipo_projeto AS "Tipo de Projeto",
    TO_CHAR(SUM(sp.valor), 'FM"R$ "9G999G999G999G999') AS "Valor Total Orçado de Propostas Enviadas"
FROM proposta p
JOIN tipo_projeto tp ON p.id_tipo_projeto = tp.id_tipo_projeto
JOIN status_proposta sp ON p.id_proposta = sp.id_proposta
WHERE sp.tipo_status = 'enviada' AND sp.dt_atualizacao >= '01/01/2023'
GROUP BY tp.tipo_projeto
ORDER BY SUM(sp.valor) DESC ;

-- Proposta de SP com tipo de projeto acima de 15 (setor privado) e com status aprovada ou em analise
SELECT 
    p.id_proposta AS "Codigo Proposta",
    sp.tipo_status AS "Status da Proposta", 
    p.localizacao_uf AS "UF",
    p.localizacao_cidade AS "Cidade", 
    p.area_projeto_m2 AS "Area do Projeto em m²",
    tp.setor AS "Setor", 
    tp.tipo_projeto AS "Tipo de Projeto",
    TO_CHAR(sp.valor, 'FM"R$ "9G999G999D99') AS "Valor da Proposta"
FROM proposta p
JOIN tipo_projeto tp ON p.id_tipo_projeto = tp.id_tipo_projeto
JOIN status_proposta sp ON p.id_proposta = sp.id_proposta
WHERE p.localizacao_uf = 'SP' 
    AND tp.id_tipo_projeto > 15 
    AND (sp.tipo_status = 'aprovada' OR sp.tipo_status = 'em analise')
ORDER BY sp.dt_atualizacao DESC ;
 
-- Quantidade de subcontratados e de etapas das propostas 'enviadas'
SELECT e.id_proposta AS "Proposta",
    COUNT(e.id_subcontratado) AS "Quantidade de subcontratados",
    COUNT(e.id_etapa) AS "Quantidade de etapas"
FROM etapa e
JOIN status_proposta sp ON sp.id_proposta = e.id_proposta
WHERE sp.tipo_status = 'enviada'
GROUP BY e.id_proposta 
ORDER BY e.id_proposta ;

SELECT * FROM status_proposta
WHERE id_proposta = 51 ;
