-- Confere, mês a mês, se a soma das 5 causas de atraso fica próxima do atraso total.
-- Tolerância: 0,1%. O dado de origem tem pequenas inconsistências conhecidas
-- (494 linhas com arr_delay nulo e 3 linhas com total maior que as causas),
-- que juntas somam cerca de 0,0003% do total.
-- O teste falha se algum mês passar da tolerância.

with m as (
    select
        month_id,
        sum(arr_delay) as total,
        sum(
            coalesce(carrier_delay, 0) + coalesce(weather_delay, 0)
          + coalesce(nas_delay, 0) + coalesce(security_delay, 0)
          + coalesce(late_aircraft_delay, 0)
        ) as soma_causas
    from {{ ref('int_fct_flight_delays') }}
    group by month_id
)

select
    month_id,
    total,
    soma_causas,
    100.0 * abs(total - soma_causas) / nullif(total, 0) as diferenca_pct
from m
where 100.0 * abs(total - soma_causas) / nullif(total, 0) > 0.1