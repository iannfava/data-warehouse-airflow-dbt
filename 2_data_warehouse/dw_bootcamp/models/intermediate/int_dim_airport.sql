-- DIMENSÃO: uma linha por aeroporto, sem repetição.
-- Serve pra descrever o código do aeroporto que aparece na fato.

with base as (
    -- Pega só as 2 colunas que interessam do staging: o código e o nome do aeroporto.
    -- No staging, cada linha é um mês+companhia+aeroporto, então o mesmo aeroporto
    -- aparece repetido várias vezes aqui dentro do "base".
    select
        airport,
        airport_name
    from {{ ref('stg_airline_delay_cause') }}
)

select
    airport                              as airport_id,   -- renomeia: vira a chave da dimensão
    max(airport_name)                    as airport_name  -- pega 1 nome por aeroporto
from base
group by airport
-- GROUP BY airport: junta todas as linhas repetidas do mesmo aeroporto numa só.
-- MAX(airport_name): como o nome deveria ser sempre igual pra um mesmo código,
-- o max() é só uma forma de "pegar um valor" depois de agrupar — o SQL exige
-- que toda coluna fora do GROUP BY esteja dentro de uma função de agregação
-- (max, sum, count, etc), então max() aqui funciona como um "pega o nome".
