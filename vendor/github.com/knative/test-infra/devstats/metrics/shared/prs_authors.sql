select
  'pr_auth,All' as repo_group,
  round(count(distinct dup_actor_login) / {{n}}, 2) as authors
from
  gha_pull_requests
where
  created_at >= '{{from}}'
  and created_at < '{{to}}'
  and (lower(dup_actor_login) {{exclude_bots}})
union select sub.repo_group,
  round(count(distinct sub.actor) / {{n}}, 2) as authors
from (
  select 'pr_auth,' || coalesce(ecf.repo_group, r.repo_group) as repo_group,
    pr.dup_actor_login as actor
  from
    gha_repos r,
    gha_pull_requests pr
  left join
    gha_events_commits_files ecf
  on
    ecf.event_id = pr.event_id
  where
    pr.dup_repo_id = r.id
    and pr.created_at >= '{{from}}'
    and pr.created_at < '{{to}}'
    and (lower(pr.dup_actor_login) {{exclude_bots}})
 ) sub
where
  sub.repo_group is not null
group by
  sub.repo_group
order by
  authors desc,
  repo_group asc
;
