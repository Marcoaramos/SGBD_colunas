- ====================================================
--  DUCKDB - CONSULTAS DE EXEMPLO
--  SGBD Orientado a Colunas - Análises Práticas
-- ====================================================
-- 
-- Este arquivo contém consultas de exemplo para demonstrar
-- o poder dos bancos de dados orientados a colunas
--
-- Para executar: .read consultas-exemplo.sql
-- ====================================================

-- Verificar dados disponíveis
SELECT '📊 VERIFICAÇÃO DOS DADOS' as info;
.tables
SELECT COUNT(*) as total_registros FROM vendas;

-- ====================================================
-- 1. ANÁLISES BÁSICAS DE AGREGAÇÃO
-- ====================================================

SELECT '🏷️ FATURAMENTO POR CATEGORIA' as analise;
SELECT 
    categoria,
    COUNT(*) as total_vendas,
    SUM(quantidade) as unidades_vendidas,
    ROUND(SUM(quantidade * valor_unitario * (1 - desconto/100)), 2) as faturamento_liquido,
    ROUND(AVG(valor_unitario), 2) as preco_medio,
    ROUND(AVG(desconto), 1) as desconto_medio
FROM vendas 
GROUP BY categoria 
ORDER BY faturamento_liquido DESC;

-- ====================================================
-- 2. ANÁLISE DE PERFORMANCE POR VENDEDOR
-- ====================================================

SELECT '👤 PERFORMANCE DOS VENDEDORES' as analise;
SELECT 
    vendedor,
    regiao,
    COUNT(*) as vendas_realizadas,
    SUM(quantidade) as total_unidades,
    ROUND(SUM(quantidade * valor_unitario * (1 - desconto/100)), 2) as faturamento_total,
    ROUND(AVG(quantidade * valor_unitario * (1 - desconto/100)), 2) as ticket_medio,
    ROUND(SUM(quantidade * valor_unitario * desconto/100), 2) as desconto_concedido
FROM vendas 
GROUP BY vendedor, regiao
ORDER BY faturamento_total DESC;

-- ====================================================
-- 3. ANÁLISE REGIONAL DE VENDAS
-- ====================================================

SELECT '🗺️ DISTRIBUIÇÃO REGIONAL' as analise;
SELECT 
    regiao,
    COUNT(*) as vendas,
    COUNT(DISTINCT vendedor) as vendedores_ativos,
    COUNT(DISTINCT categoria) as categorias_vendidas,
    SUM(quantidade) as total_unidades,
    ROUND(SUM(quantidade * valor_unitario * (1 - desconto/100)), 2) as receita_regional,
    ROUND(AVG(quantidade * valor_unitario * (1 - desconto/100)), 2) as venda_media
FROM vendas 
GROUP BY regiao 
ORDER BY receita_regional DESC;

-- ====================================================
-- 4. TOP PRODUTOS E RANKING
-- ====================================================

SELECT '🏆 RANKING DE PRODUTOS' as analise;
SELECT 
    produto,
    categoria,
    vendedor,
    quantidade,
    valor_unitario,
    desconto,
    ROUND(quantidade * valor_unitario * (1 - desconto/100), 2) as faturamento_produto,
    RANK() OVER (ORDER BY quantidade * valor_unitario * (1 - desconto/100) DESC) as ranking_geral,
    RANK() OVER (PARTITION BY categoria ORDER BY quantidade * valor_unitario * (1 - desconto/100) DESC) as ranking_categoria
FROM vendas 
ORDER BY faturamento_produto DESC;

-- ====================================================
-- 5. ANÁLISE TEMPORAL
-- ====================================================

SELECT '📅 EVOLUÇÃO TEMPORAL DAS VENDAS' as analise;
SELECT 
    data,
    COUNT(*) as vendas_do_dia,
    SUM(quantidade) as unidades_dia,
    ROUND(SUM(quantidade * valor_unitario * (1 - desconto/100)), 2) as faturamento_dia,
    -- Calcular crescimento dia a dia
    LAG(COUNT(*)) OVER (ORDER BY data) as vendas_dia_anterior,
    ROUND(SUM(quantidade * valor_unitario * (1 - desconto/100)) - 
          LAG(SUM(quantidade * valor_unitario * (1 - desconto/100))) OVER (ORDER BY data), 2) as crescimento_faturamento
FROM vendas 
GROUP BY data 
ORDER BY data;

-- ====================================================
-- 6. ANÁLISE DE MARGEM E DESCONTO
-- ====================================================

SELECT '💰 ANÁLISE DE DESCONTOS E MARGEM' as analise;
SELECT 
    categoria,
    ROUND(AVG(desconto), 2) as desconto_medio,
    ROUND(MIN(desconto), 2) as desconto_minimo,
    ROUND(MAX(desconto), 2) as desconto_maximo,
    COUNT(CASE WHEN desconto = 0 THEN 1 END) as vendas_sem_desconto,
    COUNT(CASE WHEN desconto > 0 THEN 1 END) as vendas_com_desconto,
    ROUND(SUM(quantidade * valor_unitario), 2) as faturamento_bruto,
    ROUND(SUM(quantidade * valor_unitario * (1 - desconto/100)), 2) as faturamento_liquido,
    ROUND(SUM(quantidade * valor_unitario * desconto/100), 2) as total_descontos
FROM vendas 
GROUP BY categoria
ORDER BY total_descontos DESC;

-- ====================================================
-- 7. ANÁLISE ESTATÍSTICA AVANÇADA
-- ====================================================

SELECT '📊 ESTATÍSTICAS DESCRITIVAS' as analise;
SELECT 
    categoria,
    COUNT(*) as n_vendas,
    ROUND(AVG(valor_unitario), 2) as preco_medio,
    ROUND(STDDEV(valor_unitario), 2) as desvio_padrao_preco,
    ROUND(MIN(valor_unitario), 2) as preco_minimo,
    ROUND(MAX(valor_unitario), 2) as preco_maximo,
    ROUND(PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY valor_unitario), 2) as quartil_1,
    ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY valor_unitario), 2) as mediana,
    ROUND(PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY valor_unitario), 2) as quartil_3
FROM vendas 
GROUP BY categoria
ORDER BY preco_medio DESC;

-- ====================================================
-- 8. CONSULTAS COM WINDOW FUNCTIONS (FUNÇÕES DE JANELA)
-- ====================================================

SELECT '🪟 ANÁLISE COM FUNÇÕES DE JANELA' as analise;
SELECT 
    data,
    produto,
    categoria,
    quantidade,
    valor_unitario,
    ROUND(quantidade * valor_unitario * (1 - desconto/100), 2) as faturamento,
    -- Soma acumulada
    ROUND(SUM(quantidade * valor_unitario * (1 - desconto/100)) OVER (ORDER BY data), 2) as faturamento_acumulado,
    -- Média móvel de 3 dias
    ROUND(AVG(quantidade * valor_unitario * (1 - desconto/100)) OVER (ORDER BY data ROWS BETWEEN 2 PRECEDING AND CURRENT ROW), 2) as media_movel_3dias,
    -- Percentual do total
    ROUND(100.0 * quantidade * valor_unitario * (1 - desconto/100) / 
          SUM(quantidade * valor_unitario * (1 - desconto/100)) OVER (), 2) as percentual_total
FROM vendas 
ORDER BY data, faturamento DESC;

-- ====================================================
-- 9. ANÁLISE DE CONCENTRAÇÃO (PARETO)
-- ====================================================

SELECT '📈 ANÁLISE PARETO - 80/20' as analise;
WITH vendas_ordenadas AS (
    SELECT 
        produto,
        ROUND(SUM(quantidade * valor_unitario * (1 - desconto/100)), 2) as faturamento,
        ROW_NUMBER() OVER (ORDER BY SUM(quantidade * valor_unitario * (1 - desconto/100)) DESC) as ranking
    FROM vendas 
    GROUP BY produto
),
total_faturamento AS (
    SELECT SUM(faturamento) as total FROM vendas_ordenadas
)
SELECT 
    v.ranking,
    v.produto,
    v.faturamento,
    ROUND(100.0 * v.faturamento / t.total, 2) as percentual_individual,
    ROUND(100.0 * SUM(v.faturamento) OVER (ORDER BY v.ranking) / t.total, 2) as percentual_acumulado
FROM vendas_ordenadas v
CROSS JOIN total_faturamento t
ORDER BY v.ranking;

-- ====================================================
-- 10. COMPARAÇÕES E BENCHMARKS
-- ====================================================

SELECT '⚖️ COMPARAÇÕES ENTRE CATEGORIAS' as analise;
WITH stats_categoria AS (
    SELECT 
        categoria,
        COUNT(*) as vendas,
        ROUND(AVG(quantidade * valor_unitario * (1 - desconto/100)), 2) as ticket_medio,
        ROUND(SUM(quantidade * valor_unitario * (1 - desconto/100)), 2) as faturamento
    FROM vendas 
    GROUP BY categoria
),
media_geral AS (
    SELECT 
        ROUND(AVG(ticket_medio), 2) as ticket_medio_geral,
        ROUND(AVG(faturamento), 2) as faturamento_medio_geral
    FROM stats_categoria
)
SELECT 
    s.categoria,
    s.vendas,
    s.ticket_medio,
    s.faturamento,
    ROUND(s.ticket_medio - m.ticket_medio_geral, 2) as diferenca_ticket_medio,
    CASE 
        WHEN s.ticket_medio > m.ticket_medio_geral THEN '⬆️ Acima da média'
        WHEN s.ticket_medio < m.ticket_medio_geral THEN '⬇️ Abaixo da média'
        ELSE '➡️ Na média'
    END as performance_ticket,
    CASE 
        WHEN s.faturamento > m.faturamento_medio_geral THEN '🔥 Alto faturamento'
        WHEN s.faturamento < m.faturamento_medio_geral THEN '❄️ Baixo faturamento'
        ELSE '📊 Faturamento médio'
    END as performance_faturamento
FROM stats_categoria s
CROSS JOIN media_geral m
ORDER BY s.faturamento DESC;

-- ====================================================
-- 11. CONSULTAS PERSONALIZÁVEIS
-- ====================================================

-- Template: Análise por período personalizado
SELECT '📋 TEMPLATE - ANÁLISE POR PERÍODO' as info;
-- Substitua as datas conforme necessário
SELECT 
    DATE_TRUNC('day', data) as periodo,
    COUNT(*) as vendas,
    SUM(quantidade) as unidades,
    ROUND(SUM(quantidade * valor_unitario * (1 - desconto/100)), 2) as faturamento
FROM vendas 
WHERE data BETWEEN '2024-01-01' AND '2024-01-10'  -- Modifique as datas aqui
GROUP BY DATE_TRUNC('day', data)
ORDER BY periodo;

-- Template: Top N produtos
SELECT '🏅 TEMPLATE - TOP N PRODUTOS' as info;
-- Modifique o LIMIT conforme necessário
SELECT 
    produto,
    categoria,
    SUM(quantidade) as total_vendido,
    ROUND(SUM(quantidade * valor_unitario * (1 - desconto/100)), 2) as receita
FROM vendas 
GROUP BY produto, categoria
ORDER BY receita DESC
LIMIT 5;  -- Altere para ver mais/menos produtos

-- ====================================================
-- 12. COMANDOS ÚTEIS PARA ADMINISTRAÇÃO
-- ====================================================

SELECT '🔧 INFORMAÇÕES DO BANCO' as info;

-- Informações sobre as tabelas
SELECT '📊 Estrutura da tabela vendas:' as info;
.schema vendas

-- Estatísticas da tabela
SELECT '📈 Estatísticas gerais:' as info;
SELECT 
    'vendas' as tabela,
    COUNT(*) as total_registros,
    COUNT(DISTINCT categoria) as categorias_unicas,
    COUNT(DISTINCT vendedor) as vendedores_unicos,
    COUNT(DISTINCT regiao) as regioes_unicas,
    MIN(data) as data_primeira_venda,
    MAX(data) as data_ultima_venda
FROM vendas;

-- ====================================================
-- FIM DO ARQUIVO
-- ====================================================

SELECT '✅ Consultas de exemplo carregadas com sucesso!' as status;
SELECT '💡 Use .help para ver comandos do DuckDB' as dica;
SELECT '📝 Use .tables para listar tabelas disponíveis' as dica;
