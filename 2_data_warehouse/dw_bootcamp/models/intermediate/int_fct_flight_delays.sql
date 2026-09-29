-- FATO: os números (voos, atrasos, cancelamentos), com códigos em vez de nomes.
-- Não agrupa nada — mantém a mesma granularidade do staging
-- (uma linha por mês + companhia + aeroporto, como veio do CSV).

with stg as (
    select * from {{ ref('stg_airline_delay_cause') }}
),

fct as (
    select
        -- chaves do DW: renomeadas pra bater com o padrão *_id das dimensões
        stg.year_month_key                       as month_id,
        stg.carrier                              as carrier_id,
        stg.airport                              as airport_id,

        -- métricas de volume de voos
        stg.arr_flights,
        stg.arr_del15,
        stg.arr_cancelled,
        stg.arr_diverted,

        -- atrasos, em minutos
        stg.arr_delay,
        stg.carrier_delay,
        stg.weather_delay,
        stg.nas_delay,
        stg.security_delay,
        stg.late_aircraft_delay,

        -- contagens por causa (ocorrências fracionárias)
        stg.carrier_ct,
        stg.weather_ct,
        stg.nas_ct,
        stg.security_ct,
        stg.late_aircraft_ct

    from stg
)

select * from fct
-- Repara: não tem GROUP BY, não tem JOIN com as dimensões.
-- A fato só renomeia colunas do staging. O join com as dimensões
-- (pra trocar o código pelo nome) só acontece lá na frente, nos marts.
