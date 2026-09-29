-- MART: transforma as 5 colunas de causa de atraso em LINHAS,
-- com uma coluna "cause" dizendo qual causa é. Isso se chama UNPIVOT
-- (o oposto de pivot: colunas viram linhas).
-- Serve pra facilitar filtro e gráfico de barras empilhadas no BI:
-- em vez de 5 colunas fixas, fica 1 coluna "cause" que dá pra filtrar.

with fct as (
    select * from {{ ref('int_fct_flight_delays') }}
),

unpivoted as (
    -- Cada bloco abaixo pega as mesmas 3 chaves (month_id, carrier_id,
    -- airport_id) e SÓ UMA das colunas de causa, dando um nome fixo
    -- pra ela ('carrier', 'weather', etc). UNION ALL empilha os 5
    -- resultados um embaixo do outro.

    select month_id, carrier_id, airport_id, 'carrier' as cause, carrier_delay as delay_minutes from fct
    union all
    select month_id, carrier_id, airport_id, 'weather' as cause, weather_delay as delay_minutes from fct
    union all
    select month_id, carrier_id, airport_id, 'nas' as cause, nas_delay as delay_minutes from fct
    union all
    select month_id, carrier_id, airport_id, 'security' as cause, security_delay as delay_minutes from fct
    union all
    select month_id, carrier_id, airport_id, 'late_aircraft' as cause, late_aircraft_delay as delay_minutes from fct

)

select * from unpivoted

-- Resultado: se a fato tem 318 mil linhas, esse mart tem 5x mais
-- (uma linha por causa, pra cada linha original da fato).
--
-- UNION ALL x UNION: o "ALL" é importante aqui. UNION (sem ALL)
-- removeria linhas duplicadas entre os blocos; UNION ALL mantém
-- todas, mesmo repetidas. Como cada bloco já é uma causa diferente,
-- não tem duplicata de verdade — usar ALL só evita um trabalho
-- desnecessário do banco de checar duplicidade.
