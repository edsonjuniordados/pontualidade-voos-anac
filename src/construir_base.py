import os
from pathlib import Path

import duckdb

RAIZ = Path(__file__).resolve().parents[1]
PASTA_SQL = RAIZ / "sql"
BANCO = RAIZ / "data" / "voos.duckdb"
PASTA_MODELO = RAIZ / "data" / "modelo"
TABELAS_MODELO = ["fato_voo", "dim_empresa", "dim_aeroporto", "dim_data"]


def comandos(con, caminho):
    # o próprio duckdb separa os comandos; split por ; quebraria o delim=';' do read_csv
    return con.extract_statements(caminho.read_text(encoding="utf-8"))


def main():
    # os .sql leem data/raw/ com caminho relativo à raiz do projeto
    os.chdir(RAIZ)
    PASTA_MODELO.mkdir(parents=True, exist_ok=True)
    con = duckdb.connect(str(BANCO))

    for arquivo in sorted(PASTA_SQL.glob("*.sql")):
        print(f"\n{arquivo.name}")
        for comando in comandos(con, arquivo):
            if comando.type == duckdb.StatementType.SELECT:
                print(con.sql(comando.query).df().to_string(index=False))
            else:
                con.execute(comando.query)

    for tabela in TABELAS_MODELO:
        con.execute(f"COPY {tabela} TO '{(PASTA_MODELO / tabela).as_posix()}.parquet' (FORMAT parquet)")
        print(tabela, con.sql(f"select count(*) from {tabela}").fetchall()[0][0])

    con.close()


if __name__ == "__main__":
    main()
