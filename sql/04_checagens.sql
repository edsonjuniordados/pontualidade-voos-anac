-- checagens de qualidade

SELECT 'Voos por mês' AS checagem;
SELECT
    MONTH(data_partida_prevista) AS mes,
    COUNT(*) AS voos
FROM fato_voo
GROUP BY mes
ORDER BY mes;

SELECT '% de cancelamento' AS checagem;
SELECT
    ROUND(100.0 * SUM(cancelado) / COUNT(*), 2) AS pct_cancelado
FROM fato_voo;

SELECT 'Atrasos extremos (> 24h)' AS checagem;
SELECT COUNT(*) AS casos
FROM fato_voo
WHERE atraso_suspeito = 1;

SELECT 'Voos realizados sem horário real' AS checagem;
SELECT COUNT(*) AS casos
FROM staging_vra
WHERE situacao = 'REALIZADO'
  AND (partida_real IS NULL OR chegada_real IS NULL);

SELECT 'Aeroportos sem cadastro' AS checagem;
SELECT COUNT(DISTINCT icao) AS aeroportos
FROM dim_aeroporto
WHERE nome IS NULL;

SELECT 'Voos sem horário previsto' AS checagem;
SELECT situacao, COUNT(*) AS casos
FROM fato_voo
WHERE data_partida_prevista IS NULL
GROUP BY situacao;
