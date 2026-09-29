-- DIMENSÃO: uma linha por companhia aérea, sem repetição.
-- Mesmo padrão do int_dim_airport.sql, só trocando "airport" por "carrier".

with base as (
    select
        carrier,
        carrier_name
    from {{ ref('stg_airline_delay_cause') }}
)

select
    carrier                              as carrier_id,   -- código da companhia (ex: AA, DL)
    max(carrier_name)                    as carrier_name  -- nome completo (ex: American Airlines)
from base
group by carrier
