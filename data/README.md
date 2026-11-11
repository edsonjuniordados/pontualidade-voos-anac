# Dados

## Fonte

Dados abertos da ANAC (Agência Nacional de Aviação Civil):
- **VRA (Voo Regular Ativo)**: registro mensal de todos os voos regulares operados no Brasil
- **Aeródromos públicos**: cadastro de aeroportos com código OACI

Dados disponibilizados no âmbito do Plano de Dados Abertos da ANAC. Termo de uso específico do VRA não localizado no portal.

## Escopo

Voos nacionais (tipo de linha N) de janeiro a dezembro de 2025. ~850 MB no total (12 arquivos CSV mensais).

## Suposição de fuso horário

Os horários parecem estar em horário de Brasília (UTC-3). Confirmação: voos internacionais como Madri→Guarulhos partem às 19:55 e chegam às 06:30 do dia seguinte, compatível com fuso de Brasília. Documentação oficial não encontrada.

## Dicionário da fato_voo

| Campo | Tipo | Descrição |
|-------|------|-----------|
| data_partida_prevista | DATE | Data da partida prevista |
| hora_partida_prevista | INT | Hora 0-23 da partida prevista |
| empresa_icao | VARCHAR | Código ICAO da empresa |
| origem_icao | VARCHAR | Código ICAO do aeroporto de origem |
| destino_icao | VARCHAR | Código ICAO do aeroporto de destino |
| situacao | VARCHAR | REALIZADO ou CANCELADO |
| cancelado | INT | 1 se cancelado, 0 se realizado |
| atraso_partida_min | INT | Minutos de atraso na partida (negativo = adiantado) |
| atraso_chegada_min | INT | Minutos de atraso na chegada (negativo = adiantado) |
| pontual_15 | INT | 1 se voo realizado com atraso <= 15 min (padrão A15) |
| atraso_suspeito | INT | 1 se atraso > 24h (possível erro de dados) |

## Regra A15

Pontualidade medida pelo padrão internacional A15: voo é considerado pontual se chega com até 15 minutos de atraso em relação ao horário previsto. Voos cancelados não entram no cálculo de pontualidade.

## Outliers de atraso

Em janeiro/2025: 8 voos com atraso > 24h, sendo o maior de 44.625 minutos (31 dias). Casos marcados com `atraso_suspeito = 1` para análise posterior. Podem ser voos remarcados ou erros de registro.
