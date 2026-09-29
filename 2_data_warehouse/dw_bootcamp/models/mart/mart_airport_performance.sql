-- MART: junta a fato com a dimensão de aeroporto e calcula as métricas
-- finais, prontas pra um dashboard de BI consumir direto.

with fct as (
    select * from {{ ref('int_fct_flight_delays') }}
),
dim_airport as (
    select * from {{ ref('int_dim_airport') }}
)

select
    a.airport_id,
    a.airport_name,

    sum(f.arr_flights) as flights,       -- total de voos, somado de todas as linhas do aeroporto
    sum(f.arr_del15)   as delayed_15m,   -- total de voos atrasados 15+ min

    -- percentual de voos atrasados. o CASE evita erro de "divisão por zero"
    -- pra aeroportos sem nenhum voo (arr_flights = 0)
    case when sum(f.arr_flights) = 0 then 0
         else 1.0 * sum(f.arr_del15) / sum(f.arr_flights)
    end                 as pct_delayed_15m,

    sum(f.arr_cancelled) as cancelled,
    sum(f.arr_delay)     as total_delay_minutes

from fct f
join dim_airport a
    on f.airport_id = a.airport_id
    -- AQUI é o join: liga a fato (números, com o código do aeroporto)
    -- com a dimensão (o nome do aeroporto) usando a chave em comum,
    -- airport_id. É assim que o mart consegue mostrar "Atlanta: 1000
    -- voos" em vez de só "ATL: 1000 voos".
group by 1, 2
-- agrupa pelas 2 primeiras colunas do select (airport_id, airport_name).
-- necessário porque o select tem sum() misturado com colunas simples —
-- toda coluna que não está dentro de uma agregação precisa estar no
-- GROUP BY.
