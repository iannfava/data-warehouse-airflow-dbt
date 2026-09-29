-- STAGING: lê o dado bruto do seed e entrega ele limpo.

with src as (
    -- Pega as colunas do seed (Airline_Delay_Cause) exatamente como estão,
    -- sem transformar nada ainda. Listar as colunas em vez de usar "select *"
    -- deixa explícito quais colunas o model realmente usa.
    select
        year,
        month,
        carrier,
        carrier_name,
        airport,
        airport_name,
        arr_flights,
        arr_del15,
        carrier_ct,
        weather_ct,
        nas_ct,
        security_ct,
        late_aircraft_ct,
        arr_cancelled,
        arr_diverted,
        arr_delay,
        carrier_delay,
        weather_delay,
        nas_delay,
        security_delay,
        late_aircraft_delay
    from {{ ref('Airline_Delay_Cause') }}  -- sintaxe do dbt: aponta pro seed (o CSV carregado como tabela)

),

typed as (
    -- Pega o resultado de "src" e força cada coluna pro tipo certo.
    -- O CSV chega "cru"; o banco não sabe sozinho o que é número e o que é texto.

    select
        cast(year as integer)  as year,
        cast(month as integer) as month,

        cast(carrier as text)       as carrier,       -- código da companhia (ex: AA, DL)
        cast(carrier_name as text)  as carrier_name,   -- nome completo da companhia

        cast(airport as text)       as airport,        -- código do aeroporto (ex: ATL)
        cast(airport_name as text)  as airport_name,   -- nome completo do aeroporto

        cast(arr_flights as integer) as arr_flights,   -- total de voos que chegaram
        cast(arr_del15 as integer)   as arr_del15,     -- voos atrasados 15+ minutos

        -- numeric (com casas decimais) porque são contagens fracionárias:
        -- um voo pode ser atribuído parcialmente a mais de uma causa
        cast(carrier_ct as numeric)       as carrier_ct,
        cast(weather_ct as numeric)       as weather_ct,
        cast(nas_ct as numeric)           as nas_ct,
        cast(security_ct as numeric)      as security_ct,
        cast(late_aircraft_ct as numeric) as late_aircraft_ct,

        cast(arr_cancelled as integer) as arr_cancelled,  -- voos cancelados
        cast(arr_diverted as integer)  as arr_diverted,   -- voos desviados

        -- minutos de atraso: total e por causa
        cast(arr_delay as integer)          as arr_delay,
        cast(carrier_delay as integer)      as carrier_delay,
        cast(weather_delay as integer)      as weather_delay,
        cast(nas_delay as integer)          as nas_delay,
        cast(security_delay as integer)     as security_delay,
        cast(late_aircraft_delay as integer) as late_aircraft_delay,

        -- chave de tempo: junta ano e mês num número só.
        -- ex: ano 2020, mês 8 -> 2020*100 + 8 = 202008
        -- precisa fazer o cast de novo aqui porque o SQL trata cada linha
        -- do select de forma independente, não "lembra" do cast de cima
        (cast(year as integer) * 100 + cast(month as integer)) as year_month_key

    from src
)

-- Resultado final do model: tudo que saiu de "typed", sem filtro nenhum.
select *
from typed        
