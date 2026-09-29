-- MART: percentual de cada causa de atraso, por mês.
-- Diferente do mart_delay_causes_long (que empilha linhas com UNION ALL),
-- esse mantém uma coluna pra cada causa, mas calcula o percentual dela
-- sobre o total do mês.

with fct as (
    select * from {{ ref('int_fct_flight_delays') }}
),

by_month as (
    -- Soma cada tipo de atraso, agrupado por mês.
    select
        month_id,
        sum(arr_delay)           as total_delay,
        sum(carrier_delay)       as carrier_delay,
        sum(weather_delay)       as weather_delay,
        sum(nas_delay)           as nas_delay,
        sum(security_delay)      as security_delay,
        sum(late_aircraft_delay) as late_aircraft_delay
    from fct
    group by 1
)

select
    month_id,
    total_delay,

    -- percentual de cada causa sobre o total do mês.
    -- mesmo padrão de proteção contra divisão por zero que já vimos
    -- nos marts de airport/carrier performance.
    case when total_delay = 0 then 0 else 1.0 * carrier_delay / total_delay end       as pct_carrier,
    case when total_delay = 0 then 0 else 1.0 * weather_delay / total_delay end       as pct_weather,
    case when total_delay = 0 then 0 else 1.0 * nas_delay / total_delay end           as pct_nas,
    case when total_delay = 0 then 0 else 1.0 * security_delay / total_delay end      as pct_security,
    case when total_delay = 0 then 0 else 1.0 * late_aircraft_delay / total_delay end as pct_late_aircraft

from by_month

-- Por que existem os dois marts de causa (long e share_month)?
-- Servem pra perguntas diferentes:
-- - long: "quanto cada causa atrasou, linha a linha" -> bom pra filtrar/somar no BI
-- - share_month: "qual % cada causa representou em cada mês" -> bom pra ver tendência
