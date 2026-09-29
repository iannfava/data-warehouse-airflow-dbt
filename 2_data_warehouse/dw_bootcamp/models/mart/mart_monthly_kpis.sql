-- MART: mesma lógica do mart_airport_performance/mart_carrier_performance,
-- trocando pra mês. Junta a fato com dim_month pela chave month_id e
-- calcula as métricas de KPI mensal. Tem 2 métricas a mais que os outros
-- dois (diverted e arr_diverted) e agrupa por 3 colunas, não 2, porque
-- traz year e month separados além do month_id.

with fct as (
    select * from {{ ref('int_fct_flight_delays') }}
),

dim_month as (
    select * from {{ ref('int_dim_month') }}
)

select
    m.year,
    m.month,
    m.month_id,

    sum(f.arr_flights) as flights,
    sum(f.arr_del15)   as delayed_15m,

    case when sum(f.arr_flights) = 0 then 0
         else 1.0 * sum(f.arr_del15) / sum(f.arr_flights)
    end                 as pct_delayed_15m,

    sum(f.arr_cancelled) as cancelled,
    sum(f.arr_diverted)  as diverted,       -- voos desviados; não aparecia nos outros 2 marts
    sum(f.arr_delay)     as total_delay_minutes

from fct f
join dim_month m
    on f.month_id = m.month_id
group by 1, 2, 3
-- agrupa pelas 3 primeiras colunas do select (year, month, month_id).
-- os marts de airport/carrier agrupam só por 2 colunas (id + nome);
-- esse agrupa por 3 porque year e month vêm separados, além do
-- month_id combinado.
