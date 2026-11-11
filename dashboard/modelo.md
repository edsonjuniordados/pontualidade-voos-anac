# Modelo no Power BI

Anotação de como montei o modelo no Power BI Desktop a partir dos parquets de `data/modelo/`, gerados por `src/construir_base.py`. Modo Import, sem DirectQuery: são 804.861 linhas na fato, cabe folgado.

## Como carregar

Criei um parâmetro `PastaModelo` (Página Inicial > Transformar dados > Gerenciar parâmetros > Novo, tipo Texto) com o caminho da pasta, terminando em barra:

```
C:\...\pontualidade-voos-anac\data\modelo\
```

Depois, uma consulta nula por tabela (Nova fonte > Consulta nula) apontando pro arquivo. O conector Parquet da tela "Obter dados" também funciona, mas pede o caminho completo de cada arquivo e quem clonar o repo teria que trocar quatro caminhos em vez de um.

`fato_voo`:

```m
let
    Fonte = Parquet.Document(File.Contents(PastaModelo & "fato_voo.parquet")),
    Tipos = Table.TransformColumnTypes(Fonte, {
        {"data_partida_prevista", type date},
        {"hora_partida_prevista", Int64.Type},
        {"cancelado", Int64.Type},
        {"atraso_partida_min", Int64.Type},
        {"atraso_chegada_min", Int64.Type},
        {"pontual_15", Int64.Type},
        {"atraso_suspeito", Int64.Type}
    }),
    // o prefixo de hora faz a ordem alfabética bater com a ordem do dia, sem coluna de classificação
    Faixa = Table.AddColumn(Tipos, "faixa_horario", each
        if [hora_partida_prevista] = null then "sem horário"
        else if [hora_partida_prevista] <= 4 then "00h-04h madrugada"
        else if [hora_partida_prevista] <= 6 then "05h-06h primeira onda"
        else if [hora_partida_prevista] <= 11 then "07h-11h manhã"
        else if [hora_partida_prevista] <= 16 then "12h-16h tarde"
        else if [hora_partida_prevista] <= 20 then "17h-20h fim de tarde"
        else "21h-23h noite", type text),
    Rota = Table.AddColumn(Faixa, "rota", each [origem_icao] & " > " & [destino_icao], type text)
in
    Rota
```

`dim_aeroporto` (11 aeroportos vêm sem cadastro na ANAC; sem o tratamento eles viram linha em branco na hierarquia):

```m
let
    Fonte = Parquet.Document(File.Contents(PastaModelo & "dim_aeroporto.parquet")),
    SemCadastro = Table.ReplaceValue(Fonte, null, "Sem cadastro", Replacer.ReplaceValue, {"regiao", "uf"}),
    Rotulo = Table.AddColumn(SemCadastro, "aeroporto", each
        [icao] & " " & (if [municipio] = null then "sem cadastro"
            else Text.Replace(Text.Proper([municipio]), " De ", " de ")), type text)
in
    Rotulo
```

`dim_empresa` e `dim_data` entram só com o `Parquet.Document`, sem passo extra. Conferir se `dim_data[data]` ficou como Data (não Data/Hora).

## Tabelas e grão

| Tabela | Linhas | Grão |
|---|---|---|
| fato_voo | 804.861 | um voo previsto (empresa, número, origem, destino, horário) |
| dim_empresa | 14 | uma empresa (código ICAO) |
| dim_aeroporto | 180 | um aeródromo (código ICAO) |
| dim_data | 365 | um dia de 2025 |
| _Medidas | 1 | tabela vazia só pra guardar as medidas (Inserir dados, uma coluna, depois ocultar a coluna) |

## Relações

| De (muitos) | Para (um) | Ativa | Filtro |
|---|---|---|---|
| fato_voo[empresa_icao] | dim_empresa[icao] | sim | único |
| fato_voo[origem_icao] | dim_aeroporto[icao] | sim | único |
| fato_voo[destino_icao] | dim_aeroporto[icao] | não | único |
| fato_voo[data_partida_prevista] | dim_data[data] | sim | único |

Todas muitos-para-um, filtro só da dimensão pra fato. Nenhuma bidirecional.

### Por que uma dim_aeroporto só, com destino inativo

A fato tem duas chaves pro mesmo aeroporto. Pensei em duplicar a dimensão ("Aeroporto Origem" e "Aeroporto Destino"), que é o jeito mais comum, e desisti por causa do visual principal da página de aeroportos: A15 de partida e A15 de chegada do mesmo aeroporto lado a lado, na mesma linha. Com duas dimensões isso não sai numa tabela só, e quem usa o painel teria dois filtros de aeroporto e de região pra entender qual afeta o quê.

Com uma dimensão:
- o filtro de Região > UF > Aeroporto vale pela origem do voo em todas as medidas;
- as medidas que terminam em "(destino)" ativam a relação de destino com `USERELATIONSHIP`, que desliga a de origem dentro da conta. Na linha "SBGR Guarulhos" a coluna de chegada mostra os voos que chegaram em Guarulhos.

O que fica de fora: não dá pra filtrar origem e destino ao mesmo tempo por slicer. Pra isso tem a coluna `rota` na fato, que já resolve a página de rotas. Se um dia precisar de matriz origem x destino com nome de cidade nas duas pontas, aí vale duplicar a dimensão.

Escrevi no painel, em texto pequeno embaixo do slicer: "Filtro de aeroporto e região considera a origem do voo".

### Datas nulas e o voo de 2026

- 15.167 voos realizados vêm sem horário previsto, então `data_partida_prevista` é nula. Eles caem no membro em branco da `dim_data`. Nos cartões sem filtro de data eles contam em Voos (804.861), mas não entram na A15 porque `pontual_15` é nulo.
- 1 voo previsto pra 01/01/2026 veio no arquivo de dezembro e não existe na `dim_data`. Também cai no membro em branco.
- Nos visuais com eixo de data, filtro de nível de visual "mes não está em branco". Assim janeiro mostra 69.708 voos, igual ao notebook, e não aparece barra "(Em branco)".
- Não coloquei filtro de página `ano = 2025`: ele tira os 15.167 sem horário do denominador de cancelamento e o % cancelado deixa de bater com o notebook (1,75%).

## Colunas ocultas

- fato_voo: todas as chaves (`empresa_icao`, `origem_icao`, `destino_icao`, `data_partida_prevista`) e todas as numéricas que só servem pra medida (`cancelado`, `atraso_partida_min`, `atraso_chegada_min`, `pontual_15`, `atraso_suspeito`). Ficam visíveis `situacao`, `hora_partida_prevista`, `faixa_horario` e `rota`, na pasta de exibição "Atributos do voo".
- dim_empresa: `icao` (usar `nome`).
- dim_aeroporto: `icao` e `nome` (o nome oficial é longo demais, tipo "Guarulhos - Governador André Franco Montoro"; usar `aeroporto`).
- dim_data: `mes` e `dia_semana` (só pra classificação).
- Nas numéricas que ficaram visíveis (`hora_partida_prevista`), Resumir por = Nenhum.

## Classificação e tabela de datas

- `dim_data` marcada como tabela de data, coluna `data`. Sem isso `PREVIOUSMONTH` e `DATESINPERIOD` não funcionam direito.
- `nome_mes` classificada por `mes`.
- `nome_dia` classificada por `dia_semana` (0 = domingo, igual ao DuckDB).

## Hierarquias

- dim_aeroporto, "Localização": `regiao` > `uf` > `aeroporto`
- dim_data, "Calendário": `ano` > `nome_mes` > `data`

## Formatação

| Tipo de medida | Formato |
|---|---|
| contagens | `#,0` |
| percentuais (% A15, % Cancelado etc.) | `0.0%` |
| atraso em minutos | `0" min"` |
| variação em pontos percentuais | `+0.0" pp";-0.0" pp";0.0" pp"` |
| dias | `0` |

Com a localidade do arquivo em Português (Brasil), `0.0%` aparece como 85,8%.
