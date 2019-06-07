with prev as (
  select distinct user_id
  from
    gha_pull_requests
  where
    created_at >= date '{{from}}' - '3 months'::interval
    and created_at < '{{from}}'
), prev_cnt as (
  select user_id, count(distinct id) as cnt
  from
    gha_pull_requests
  where
    created_at < '{{from}}'
  group by
    user_id
)
select
  'epis_contrib;All;contrib,prs' as name,
  round(count(distinct pr.user_id) / {{n}}, 2) as contributors,
  round(count(distinct pr.id) / {{n}}, 2) as prs
from
  gha_pull_requests pr
left join
  prev_cnt pc
on
  pc.user_id = pr.user_id
where
  pr.created_at >= '{{from}}'
  and pr.created_at < '{{to}}'
  and pr.user_id not in (select user_id from prev)
  and (pc.user_id is null or pc.cnt <= 12)
union select sub.name,
  round(count(distinct sub.user_id) / {{n}}, 2) as contributors,
  round(count(distinct sub.id) / {{n}}, 2) as prs
from (
    select 'epis_contrib;' || coalesce(ecf.repo_group, r.repo_group) || ';contrib,prs' as name,
    pr.user_id,
    pr.id
  from
    gha_repos r,
    gha_pull_requests pr
  left join
    gha_events_commits_files ecf
  on
    ecf.event_id = pr.event_id
  left join
    prev_cnt pc
  on
    pc.user_id = pr.user_id
  where
    pr.dup_repo_id = r.id
    and pr.created_at >= '{{from}}'
    and pr.created_at < '{{to}}'
    and pr.user_id not in (select user_id from prev)
    and (pc.user_id is null or pc.cnt <= 12)
  ) sub
where
  sub.name is not null
group by
  sub.name
order by
  prs desc,
  name asc
;
