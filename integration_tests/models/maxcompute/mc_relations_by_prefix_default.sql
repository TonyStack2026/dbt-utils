{{ config(tags=['maxcompute', 'prefix_default_boundary']) }}
{#-
  边界用例：`maxcompute__get_relations_by_prefix` 的 database 默认值（省略实参那条路径）。
  两条调用都在**编译期**展开，下面的 actual 是渲染进 SQL 的字面量：
    - implicit：省略 database 实参，走宏自己的默认表达式；
    - explicit：显式传 target.database。
  期望模型 mc_expected_relations_by_prefix_default 的四行是手算常数，不读服务端。
  depends_on 只为保证两张探针表先建出来（枚举结果要确定），不是数据依赖。
-#}
-- depends_on: {{ ref('mc_prefixprobe_a') }}, {{ ref('mc_prefixprobe_b') }}
{%- set implicit = dbt_utils.maxcompute__get_relations_by_prefix(target.schema, 'mc_prefixprobe_') -%}
{%- set explicit = dbt_utils.maxcompute__get_relations_by_prefix(target.schema, 'mc_prefixprobe_', database=target.database) -%}
{%- set implicit_names = implicit | map(attribute='identifier') | sort | join(',') -%}
{%- set explicit_names = explicit | map(attribute='identifier') | sort | join(',') -%}
{%- set implicit_first_database = (implicit | first).database if (implicit | length) > 0 else '' -%}
{%- set database_ok = (implicit_first_database ~ '') == (target.database ~ '') -%}

select 'implicit_names' as case_id, cast('{{ implicit_names }}' as string) as actual
union all
    select 'explicit_names', cast('{{ explicit_names }}' as string)
union all
    select 'implicit_count', cast('{{ implicit | length }}' as string)
union all
    select 'implicit_database_is_target', cast('{{ "true" if database_ok else "false" }}' as string)
