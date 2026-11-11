-- leitura dos arquivos brutos e filtragem de voos nacionais
-- horários vêm às vezes como texto 'null' e às vezes com fração de segundo (06:55:00.100000000)

CREATE OR REPLACE TABLE staging_vra AS
SELECT
    "ICAO Empresa Aérea" AS empresa_icao,
    "Número Voo" AS numero_voo,
    "Código Tipo Linha" AS tipo_linha,
    "ICAO Aeródromo Origem" AS origem_icao,
    "ICAO Aeródromo Destino" AS destino_icao,
    TRY_CAST(NULLIF("Partida Prevista", 'null') AS TIMESTAMP) AS partida_prevista,
    TRY_CAST(NULLIF("Partida Real", 'null') AS TIMESTAMP) AS partida_real,
    TRY_CAST(NULLIF("Chegada Prevista", 'null') AS TIMESTAMP) AS chegada_prevista,
    TRY_CAST(NULLIF("Chegada Real", 'null') AS TIMESTAMP) AS chegada_real,
    "Situação Voo" AS situacao
FROM read_csv('data/raw/vra_*.csv',
    delim=';',
    header=true,
    skip=1,
    ignore_errors=true,
    all_varchar=true
)
WHERE "Código Tipo Linha" = 'N';

CREATE OR REPLACE TABLE staging_aerodromos AS
SELECT
    "Código OACI" AS icao,
    Nome AS nome,
    Município AS municipio,
    UF AS uf
FROM read_csv('data/raw/aerodromos.csv',
    delim=';',
    header=true,
    skip=1,
    encoding='latin1'
);
