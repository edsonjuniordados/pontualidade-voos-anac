-- tabela fato com métricas de pontualidade

CREATE OR REPLACE TABLE fato_voo AS
WITH voos_unicos AS (
    SELECT DISTINCT *
    FROM staging_vra
),
metricas AS (
    SELECT
        partida_prevista::DATE AS data_partida_prevista,
        HOUR(partida_prevista) AS hora_partida_prevista,
        empresa_icao,
        origem_icao,
        destino_icao,
        situacao,
        CASE WHEN situacao = 'CANCELADO' THEN 1 ELSE 0 END AS cancelado,
        -- atraso só pra voos realizados
        CASE
            WHEN situacao = 'REALIZADO'
            THEN DATEDIFF('minute', partida_prevista, partida_real)
        END AS atraso_partida_min,
        CASE
            WHEN situacao = 'REALIZADO'
            THEN DATEDIFF('minute', chegada_prevista, chegada_real)
        END AS atraso_chegada_min
    FROM voos_unicos
)
SELECT
    *,
    -- A15: chegou até 15 min depois do previsto. cancelado fica nulo pra não entrar na média
    CASE
        WHEN situacao <> 'REALIZADO' OR atraso_chegada_min IS NULL THEN NULL
        WHEN atraso_chegada_min <= 15 THEN 1
        ELSE 0
    END AS pontual_15,
    -- flag pra atrasos extremos (> 24h) que podem ser erro de dados
    CASE
        WHEN atraso_chegada_min > 1440 THEN 1
        ELSE 0
    END AS atraso_suspeito
FROM metricas;
