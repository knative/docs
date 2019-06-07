with prev as (
  select distinct user_id
  from
    gha_pull_requests
  where
    merged = true
    and merged_at < '{{from}}'
    and (lower(dup_actor_login) {{exclude_bots}})
), contributors as (
  select distinct pr.user_id,
    first_value(pr.merged_at) over prs_by_merged_at as merged_at,
    first_value(pr.dup_repo_id) over prs_by_merged_at as repo_id,
    first_value(pr.dup_repo_name) over prs_by_merged_at as repo_name,
    first_value(pr.event_id) over prs_by_merged_at as event_id
  from
    gha_pull_requests pr
  where
    pr.merged = true
    and pr.merged_at >= '{{from}}'
    and pr.merged_at < '{{to}}'
    and pr.user_id not in (select user_id from prev)
    and (lower(pr.dup_actor_login) {{exclude_bots}})
  window
    prs_by_merged_at as (
      partition by pr.user_id
      order by
        pr.merged_at asc,
        pr.event_id asc
      range between unbounded preceding
      and current row
    )
)
select
  'ncd,All' as metric,
  c.merged_at,
  0.0 as value,
  case a.name is null when true then a.login else case a.name when '' then a.login else a.name || ' (' || a.login || ')' end end as contributor
from
  contributors c,
  gha_actors a
where
  c.user_id = a.id
union select 'ncd,' || coalesce(ecf.repo_group, r.repo_group) as metric,
  c.merged_at,
  0.0 as value,
  case a.name is null when true then a.login else case a.name when '' then a.login else a.name || ' (' || a.login || ')' end end as contributor
from
  gha_actors a,
  gha_repos r,
  contributors c
left join
  gha_events_commits_files ecf
on
  ecf.event_id = c.event_id
where
  c.user_id = a.id
  and c.repo_id = r.id
  and c.repo_name = r.name
  and r.repo_group is not null
order by
  metric asc,
  merged_at asc,
  contributor asc
;
