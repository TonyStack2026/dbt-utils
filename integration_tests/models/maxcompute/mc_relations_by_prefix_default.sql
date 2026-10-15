{{ config(tags=['maxcompute', 'prefix_default_boundary']) }}
{#-
  边界用例：`maxcompute__get_relations_by_prefix` 的 database 默认值（省略实参那条路径）。
  三条调用都在**编译期**展开，下面的 actual 是渲染进 SQL 的字面量：
    - implicit：省略 database 实参，走宏自己的默认表达式；
    - explicit：显式传 target.database；
    - entry：走公开入口 dbt_utils.get_relations_by_prefix（同样省略 database）。
  期望模型 mc_expected_relations_by_prefix_default 的五行是手算常数，不读服务端。
  exclude 挡掉 dbt create-or-replace 留下的 <name>__dbt_tmp / <name>__dbt_backup：
  一次被中断的跑动就会在同 schema 残留它们，不挡掉的话常数期望会被这些内部对象污染。
  depends_on 只为保证两张探针表先建出来（枚举结果要确定），不是数据依赖。
-#}
-- depends_on: {{ ref('mc_prefixprobe_a') }}, {{ ref('mc_prefixprobe_b') }}
{%- set probe_prefix = 'mc_prefixprobe_' -%}
{%- set dbt_internals = '%__dbt_%' -%}
{%- set implicit = dbt_utils.maxcompute__get_relations_by_prefix(target.schema, probe_prefix, dbt_internals) -%}
{%- set explicit = dbt_utils.maxcompute__get_relations_by_prefix(target.schema, probe_prefix, dbt_internals, database=target.database) -%}
{%- set entry = dbt_utils.get_relations_by_prefix(target.schema, probe_prefix, dbt_internals) -%}
{%- set implicit_names = implicit | map(attribute='identifier') | sort | join(',') -%}
{%- set explicit_names = explicit | map(attribute='identifier') | sort | join(',') -%}
{%- set entry_names = entry | map(attribute='identifier') | sort | join(',') -%}
{%- set implicit_first_database = (implicit | first).database if (implicit | length) > 0 else '' -%}
{%- set database_ok = (implicit_first_database ~ '') == (target.database ~ '') -%}

select 'implicit_names' as case_id, cast('{{ implicit_names }}' as string) as actual
union all
    select 'explicit_names', cast('{{ explicit_names }}' as string)
union all
    select 'entry_names', cast('{{ entry_names }}' as string)
union all
    select 'implicit_count', cast('{{ implicit | length }}' as string)
union all
    select 'implicit_database_is_target', cast('{{ "true" if database_ok else "false" }}' as string)
