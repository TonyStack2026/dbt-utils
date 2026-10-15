{{ config(tags=['maxcompute', 'prefix_default_boundary']) }}
-- 期望值全部手算，不来自服务端：schema 里以 mc_prefixprobe_ 开头、且不是 dbt 内部对象的关系只有上面两张表。
select 'implicit_names' as case_id, cast('mc_prefixprobe_a,mc_prefixprobe_b' as string) as actual
union all
    select 'explicit_names', cast('mc_prefixprobe_a,mc_prefixprobe_b' as string)
union all
    select 'entry_names', cast('mc_prefixprobe_a,mc_prefixprobe_b' as string)
union all
    select 'implicit_count', cast('2' as string)
union all
    select 'implicit_database_is_target', cast('true' as string)
