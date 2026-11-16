# Layout do painel

Três páginas, todas com o mesmo cabeçalho: caixa de texto com o `[Título Dinâmico]` e slicers de empresa (`dim_empresa[nome]`), mês (`dim_data[nome_mes]`) e região (`dim_aeroporto[regiao]`). Embaixo do slicer de região, em texto pequeno: "Filtro de aeroporto e região considera a origem do voo".

Os números entre parênteses são os do notebook, servem pra conferir se o painel bateu. Os prints de cada página estão em `reports/figuras/` (`painel_visao_geral.png`, `painel_empresas_horarios.png`, `painel_aeroportos_rotas.png`).

## 1. Visão geral

O que a página tem que mostrar: o ano foi de 85,8% de A15, e a queda de dezembro (74,2%) não é o mês inteiro, é um evento de poucos dias.

| Bloco | Visual | Medidas e campos |
|---|---|---|
| Cartões no topo | 6 cartões | `[Voos]` (804.861), `[% A15]` (85,8%), `[% Cancelado]` (1,75%), `[Atraso Mediano Chegada]` (-5 min), `[Atraso P90 Chegada]` (23 min), `[% Voos +60min]` (2,8%) |
| Rodapé dos cartões | cartão pequeno | `[Voos Sem Horário Previsto]` (15.167), com o texto "fora da A15: sem horário previsto" |
| A15 e cancelamento por mês | colunas e linha | eixo `nome_mes`; colunas `[% A15]`, linha `[% Cancelado]` no eixo secundário; dica de ferramenta com `[Variação A15 vs Mês Anterior (pp)]` (dezembro: -11,1 pp) |
| Série diária | gráfico de linhas | eixo `dim_data[data]`; `[% A15]` em linha fina cinza, `[A15 Média Móvel 7 Dias]` em linha grossa, `[Marcador Dia Abaixo de 60%]` só com marcador, sem linha, em vermelho; linha de referência constante em 60% |
| Destaque | cartão | `[Dias Abaixo de 60%]` (6 no ano) |

Os 6 dias abaixo de 60%: 22/09 (48,1%) e 09 a 13/12, com o pior em 11/12 (35,2%) e 10/12 (35,6%, com 19,7% dos voos cancelados). A média móvel chega a 54,5% em 13/12. No gráfico mensal isso vira só "dezembro ruim"; na série diária dá pra ver que são dez dias. Tirando 08 a 17/12, dezembro sobe de 74,2% pra 81,2%, ainda abaixo dos 86,9% de janeiro a novembro.

Média de atraso não entra em nenhum cartão: a média é +1,12 min e a mediana -5 min, a cauda direita distorce.

Nos visuais com eixo de data, filtro "mes não está em branco" (ver `modelo.md`).

## 2. Empresas e horários

O que a página tem que mostrar: no ano a Gol é a mais pontual entre as grandes, mas a diferença só aparece da tarde em diante, e A15 alta sem olhar cancelamento engana.

| Bloco | Visual | Medidas e campos |
|---|---|---|
| Ranking de empresas | barras horizontais | eixo `dim_empresa[nome]`, `[% A15]`; filtro de visual `[Voos]` > 1.000 |
| Tabela de empresas | tabela | `nome`, `[Voos]`, `[% A15]`, `[% Cancelado]`, `[Atraso Médio dos Atrasados]`; filtro `[Voos]` > 1.000; formatação condicional em `[% Cancelado]` |
| Empresa x faixa de horário | matriz | linhas `fato_voo[faixa_horario]`, colunas `dim_empresa[nome]` (filtrado pra Azul, Gol e LATAM), valor `[% A15]` com escala de cor |
| A15 por hora | gráfico de linhas | eixo `fato_voo[hora_partida_prevista]` (tipo categórico), `[% A15]`, legenda `dim_empresa[nome]` (as três grandes) |
| Dia da semana | colunas | eixo `dim_data[nome_dia]`, `[% A15]` e `[% Cancelado]` |

Números pra conferir:
- Gol 88,51%, Azul 86,02%, LATAM 83,78%.
- Abaeté tem 96,92% de A15 mas cancela 12,75%. Azul Conecta (12,23%) e VoePass (11,89%) também cancelam perto de 12%; as três grandes ficam entre 1,05% e 1,68%. Por isso `[% Cancelado]` fica sempre do lado da A15 na tabela.
- Atraso médio de quem atrasou: LATAM 39,0 min, Gol 51,3, Azul 53,2, VoePass 91,9. A LATAM atrasa mais vezes, mas atrasa menos.
- Por hora: 93,8% às 5h, 80,9% às 19h.
- Na primeira onda as três grandes ficam entre 93,4% e 94,0%. Até o fim da tarde a LATAM perde 16,2 pontos (94,0% pra 77,8%), a Azul 11,7 e a Gol 8,1.
- Sábado (89,1%) e domingo (88,7%) são os dias mais pontuais. Nos dias úteis a A15 vai de 85,6% na segunda a 83,5% na sexta.

O intervalo de confiança de Wilson e o qui-quadrado ficam no notebook. No painel não coloquei: o V de Cramér deu 0,054 e com mais de 200 mil voos por empresa os intervalos têm menos de 0,3 ponto de largura, então a barra de erro mal apareceria nas grandes.

## 3. Aeroportos e rotas

O que a página tem que mostrar: Guarulhos é o ponto fora da curva, e boa parte da A15 mais baixa da LATAM vem de lá.

| Bloco | Visual | Medidas e campos |
|---|---|---|
| Aeroportos | tabela | `dim_aeroporto[aeroporto]`, `[Voos]` (partidas), `[% A15 Partida (origem)]`, `[% A15 Chegada (destino)]`, `[Diferença Chegada x Partida (pp)]`, `[% Cancelado]`; filtro de visual `[Voos]` >= 5.000; barras de dados nas duas A15 |
| Partida x chegada | barras agrupadas | eixo `aeroporto` (top 15 por `[Voos]`), valores `[% A15 Partida (origem)]` e `[% A15 Chegada (destino)]` |
| Regiões | matriz com drill | linhas na hierarquia Localização (Região > UF > Aeroporto), `[Voos]`, `[% A15 Partida (origem)]`, `[% A15]`, `[% Cancelado]` |
| Rotas | tabela | `fato_voo[rota]`, `[Voos]`, `[% A15]`, `[% Cancelado]`, `[Empresa Principal]`, `[% Voos da Empresa Principal]`; filtro `[Voos]` >= 1.000; classificado por `[% A15]` crescente |

Números pra conferir:
- Guarulhos: 98.965 partidas, 75,4% de A15 na partida e 82,9% na chegada (7,5 pontos de diferença). O segundo pior entre os aeroportos com 5.000 partidas ou mais é Foz do Iguaçu, com 82,8%.
- Congonhas: 95.003 partidas, 83,2% na partida e 88,2% na chegada.
- Santos Dumont tem a melhor partida do top 15 (90,1%) e o maior cancelamento (2,74%).
- Sudeste: 52,2% dos voos e a pior pontualidade (82,9% na partida). Centro-Oeste é o melhor (88,4%).
- Ponte aérea Santos Dumont-Congonhas: 18.824 e 18.799 voos, A15 de 90,1% e 88,4%, cancelamento de 3,51% e 3,35%.
- 232 rotas com pelo menos 1.000 voos. A pior é Guarulhos-São Luís (72,5%); das dez piores, sete saem de Guarulhos e a LATAM é a empresa principal em oito.

O efeito Guarulhos sai filtrando a página: slicer de empresa em LATAM, depois clicar em SBGR na tabela de aeroportos. Partindo de Guarulhos a LATAM tem 75,1% de A15; nas outras origens, 86,3%, quase igual à Azul (86,0%). Fora de Guarulhos a distância entre Gol e LATAM cai de 4,73 pp pra 3,0 pp. Vale um indicador salvo (bookmark) "LATAM fora de Guarulhos" com todos os aeroportos marcados menos SBGR, pra quem abrir o painel não precisar descobrir sozinho.

A rota aparece como código ICAO (`SBSP > SBRJ`). Se ficar ilegível pra quem não conhece os códigos, o próximo passo é montar a rota com o município no Power Query.
