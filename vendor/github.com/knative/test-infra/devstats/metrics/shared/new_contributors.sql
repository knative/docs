with prev as (
  select distinct user_id
  from
    gha_pull_requests
  where
    created_at < '{{from}}'
)
select
  'new_contrib;All;contrib,prs' as name,
  round(count(distinct user_id) / {{n}}, 2) as contributors,
  round(count(distinct id) / {{n}}, 2) as prs
from
  gha_pull_requests
where
  created_at >= '{{from}}'
  and created_at < '{{to}}'
  and user_id not in (select user_id from prev)
union select sub.name,
  round(count(distinct sub.user_id) / {{n}}, 2) as contributors,
  round(count(distinct sub.id) / {{n}}, 2) as prs
from (
    select 'new_contrib;' || coalesce(ecf.repo_group, r.repo_group) || ';contrib,prs' as name,
    pr.user_id,
    pr.id
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
    and pr.user_id not in (select user_id from prev)
  ) sub
where
  sub.name is not null
group by
  sub.name
order by
  prs desc,
  name asc
;
