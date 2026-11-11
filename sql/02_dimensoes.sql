-- dimensões de empresa, aeroporto e data

CREATE OR REPLACE TABLE dim_empresa AS
SELECT DISTINCT
    empresa_icao AS icao,
    CASE empresa_icao
        WHEN 'AZU' THEN 'Azul'
        WHEN 'TAM' THEN 'LATAM'
        WHEN 'GLO' THEN 'Gol'
        WHEN 'ACN' THEN 'Azul Conecta'
        WHEN 'PTB' THEN 'VoePass'
        WHEN 'PAM' THEN 'MAP Linhas Aéreas'
        WHEN 'ABJ' THEN 'Abaeté'
        ELSE empresa_icao
    END AS nome
FROM staging_vra
ORDER BY icao;

CREATE OR REPLACE TABLE dim_aeroporto AS
WITH aeroportos_vra AS (
    SELECT DISTINCT origem_icao AS icao FROM staging_vra
    UNION
    SELECT DISTINCT destino_icao AS icao FROM staging_vra
),
mapa_uf AS (
    SELECT icao, nome, municipio,
        CASE uf
            WHEN 'Acre' THEN 'AC'
            WHEN 'Alagoas' THEN 'AL'
            WHEN 'Amapá' THEN 'AP'
            WHEN 'Amazonas' THEN 'AM'
            WHEN 'Bahia' THEN 'BA'
            WHEN 'Ceará' THEN 'CE'
            WHEN 'Distrito Federal' THEN 'DF'
            WHEN 'Espírito Santo' THEN 'ES'
            WHEN 'Goiás' THEN 'GO'
            WHEN 'Maranhão' THEN 'MA'
            WHEN 'Mato Grosso' THEN 'MT'
            WHEN 'Mato Grosso do Sul' THEN 'MS'
            WHEN 'Minas Gerais' THEN 'MG'
            WHEN 'Pará' THEN 'PA'
            WHEN 'Paraíba' THEN 'PB'
            WHEN 'Paraná' THEN 'PR'
            WHEN 'Pernambuco' THEN 'PE'
            WHEN 'Piauí' THEN 'PI'
            WHEN 'Rio de Janeiro' THEN 'RJ'
            WHEN 'Rio Grande do Norte' THEN 'RN'
            WHEN 'Rio Grande do Sul' THEN 'RS'
            WHEN 'Rondônia' THEN 'RO'
            WHEN 'Roraima' THEN 'RR'
            WHEN 'Santa Catarina' THEN 'SC'
            WHEN 'São Paulo' THEN 'SP'
            WHEN 'Sergipe' THEN 'SE'
            WHEN 'Tocantins' THEN 'TO'
        END AS uf_sigla
    FROM staging_aerodromos
)
SELECT
    v.icao,
    m.nome,
    m.municipio,
    m.uf_sigla AS uf,
    CASE
        WHEN m.uf_sigla IN ('AC', 'AP', 'AM', 'PA', 'RO', 'RR', 'TO') THEN 'Norte'
        WHEN m.uf_sigla IN ('AL', 'BA', 'CE', 'MA', 'PB', 'PE', 'PI', 'RN', 'SE') THEN 'Nordeste'
        WHEN m.uf_sigla IN ('DF', 'GO', 'MT', 'MS') THEN 'Centro-Oeste'
        WHEN m.uf_sigla IN ('ES', 'MG', 'RJ', 'SP') THEN 'Sudeste'
        WHEN m.uf_sigla IN ('PR', 'RS', 'SC') THEN 'Sul'
    END AS regiao
FROM aeroportos_vra v
LEFT JOIN mapa_uf m ON v.icao = m.icao
ORDER BY v.icao;

CREATE OR REPLACE TABLE dim_data AS
WITH datas AS (
    SELECT generate_series::DATE AS data
    FROM generate_series(DATE '2025-01-01', DATE '2025-12-31', INTERVAL 1 DAY)
)
SELECT
    data,
    YEAR(data) AS ano,
    MONTH(data) AS mes,
    CASE MONTH(data)
        WHEN 1 THEN 'Janeiro' WHEN 2 THEN 'Fevereiro' WHEN 3 THEN 'Março'
        WHEN 4 THEN 'Abril' WHEN 5 THEN 'Maio' WHEN 6 THEN 'Junho'
        WHEN 7 THEN 'Julho' WHEN 8 THEN 'Agosto' WHEN 9 THEN 'Setembro'
        WHEN 10 THEN 'Outubro' WHEN 11 THEN 'Novembro' WHEN 12 THEN 'Dezembro'
    END AS nome_mes,
    DAYOFWEEK(data) AS dia_semana,
    CASE DAYOFWEEK(data)
        WHEN 0 THEN 'Domingo' WHEN 1 THEN 'Segunda' WHEN 2 THEN 'Terça'
        WHEN 3 THEN 'Quarta' WHEN 4 THEN 'Quinta' WHEN 5 THEN 'Sexta'
        WHEN 6 THEN 'Sábado'
    END AS nome_dia,
    CASE WHEN DAYOFWEEK(data) IN (0, 6) THEN 1 ELSE 0 END AS fim_de_semana
FROM datas;
