-- DIMENSÃO: uma linha por mês (ano + mês), sem repetição.
-- Diferente das outras duas dimensões: usa DISTINCT em vez de GROUP BY + max().

with base as (
    -- SELECT DISTINCT: pega essas 3 colunas e remove as linhas repetidas.
    -- Não precisa de max() aqui porque year, month e year_month_key
    -- já vêm juntos e sempre iguais entre si (não tem 2 nomes possíveis
    -- pra combinação, como podia acontecer com airport_name).
    select distinct
        year,
        month,
        year_month_key
    from {{ ref('stg_airline_delay_cause') }}
)

select
    year_month_key                       as month_id,  -- chave da dimensão (ex: 202008)
    year,
    month
from base

-- Por que aqui é DISTINCT e nas outras duas é GROUP BY + max()?
-- Nas dimensões de aeroporto/companhia, o "nome" é uma coluna extra
-- que precisa ser resumida (max) depois de agrupar pelo código.
-- Aqui, year/month/year_month_key SÃO a própria informação, sem
-- coluna extra pra resumir — só precisa remover repetição, e é
-- exatamente pra isso que o DISTINCT serve.
