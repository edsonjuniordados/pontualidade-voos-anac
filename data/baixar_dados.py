import urllib.parse
import urllib.request
from pathlib import Path

PASTA_RAW = Path(__file__).resolve().parent / "raw"
BASE_URL = "https://sistemas.anac.gov.br/dadosabertos/"
PASTA_VRA = "Voos e operações aéreas/Voo Regular Ativo (VRA)/2025/"
MESES = ["Janeiro", "Fevereiro", "Março", "Abril", "Maio", "Junho",
         "Julho", "Agosto", "Setembro", "Outubro", "Novembro", "Dezembro"]


def baixar(caminho_remoto, destino):
    if destino.exists():
        print(destino.name, "já existe")
        return
    print("baixando", destino.name)
    # baixa num .part e só renomeia no fim, assim download interrompido não passa por arquivo pronto
    temporario = destino.with_suffix(".part")
    urllib.request.urlretrieve(BASE_URL + urllib.parse.quote(caminho_remoto), temporario)
    temporario.rename(destino)


if __name__ == "__main__":
    PASTA_RAW.mkdir(parents=True, exist_ok=True)
    for mes, nome in enumerate(MESES, start=1):
        # pasta "01 - Janeiro", arquivo VRA_20251.csv (mês sem zero à esquerda no nome do arquivo)
        baixar(f"{PASTA_VRA}{mes:02d} - {nome}/VRA_2025{mes}.csv", PASTA_RAW / f"vra_{mes:02d}.csv")
    baixar("Aerodromos/Aeródromos Públicos/Lista de aeródromos públicos/AerodromosPublicos.csv",
           PASTA_RAW / "aerodromos.csv")
