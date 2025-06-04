---
title: PR リードタイム
queries:
  - authors: github_authors.sql
  - repo: github_repo.sql
---

<Alert status="info">
TBD: このページがどのように使われるかの説明
</Alert>

<Dropdown name=selected_author data={authors} value=author>
    <DropdownOption value="%" valueLabel="全ての author"/>
</Dropdown>

<Dropdown name=selected_repo data={repo} value=repository>
    <DropdownOption value="%" valueLabel="全ての repo"/>
</Dropdown>

<Dropdown name=target_days defaultValue="14 days">
    <DropdownOption valueLabel="7 days" value="7 days" />
    <DropdownOption valueLabel="14 days" value="14 days" />
    <DropdownOption valueLabel="30 days" value="30 days" />
</Dropdown>

## Pull Request 数

```sql pull_request_count_by_day
select
  date_trunc('day', mergedAt) as day,
  count(*) as pr_count
from github.pr
where mergedAt >= date_trunc('day', current_date) - interval '${inputs.target_days.value}'
    and date_trunc('day', mergedAt) <> date_trunc('day', current_date)
    and author like '${inputs.selected_author.value}'
    and repository like '${inputs.selected_repo.value}'
group by day
order by day desc
```

<LineChart
    data={pull_request_count_by_day}
    x=day
    y=pr_count
    xAxisTitle="week"
    yAxisTitle="count"
/>

## Pull Request リードタイム

```sql pull_request_avg_lead_time_by_day
select
  date_trunc('day', mergedAt) as day,
  avg(extract(epoch from mergedAt - createdAt) / 3600) as avg_total_hours,
  avg(extract(epoch from firstReviewedAt - createdAt) / 3600) as avg_time_to_first_review_hours,
  avg(extract(epoch from firstApprovedAt - firstReviewedAt) / 3600) as avg_time_to_approve_hours,
  avg(extract(epoch from mergedAt - firstApprovedAt) / 3600) as avg_time_to_merge_after_approve_hours
from github.pr
where mergedAt >= date_trunc('day', current_date) - interval '${inputs.target_days.value}'
  and date_trunc('day', mergedAt) <> date_trunc('day', current_date)
  and repository like '${inputs.selected_repo.value}'
group by day
order by day desc
```

<LineChart
    data={pull_request_avg_lead_time_by_day}
    x=day
    y={['avg_total_hours','avg_time_to_first_review_hours','avg_time_to_approve_hours','avg_time_to_merge_after_approve_hours']}
/>

### Pull Request 一覧

```sql pull_request_list
select
    repository,
    concat('#', cast(cast(number as int) as varchar)) as number,
    author,
    (extract(epoch from mergedAt - createdAt) / 3600) as time_to_merge_hours,
    (extract(epoch from firstReviewedAt - createdAt) / 3600) as time_to_first_review_hours,
    (extract(epoch from firstApprovedAt - firstReviewedAt) / 3600) as time_to_approve_hours,
    (extract(epoch from mergedAt - firstApprovedAt) / 3600) as time_to_merge_after_approve_hours,
    createdAt,
    mergedAt,
    firstReviewedAt,
    firstApprovedAt,
    concat('https://github.com/',repository,'/pull/',cast(cast(number as int) as varchar)) as pr_url
from github.pr
where mergedAt >= date_trunc('day', current_date) - interval '${inputs.target_days.value}'
    and author like '${inputs.selected_author.value}'
    and repository like '${inputs.selected_repo.value}'
order by time_to_merge_hours desc
```

<DataTable data={pull_request_list}>
    <Column id=repository />
    <Column id=pr_url contentType=link linkLabel=number />
    <Column id=author />
    <Column id=time_to_merge_hours contentType=number />
    <Column id=time_to_first_review_hours contentType=number />
    <Column id=time_to_approve_hours contentType=number />
    <Column id=time_to_merge_after_approve_hours contentType=number />
    <Column id=createdAt />
    <Column id=mergedAt />
    <Column id=firstReviewedAt />
    <Column id=firstApprovedAt />
</DataTable>

```sql pull_request_list_reverse
select
    *
from ${pull_request_list}
order by time_to_merge_hours asc
```

<LineChart
    data={pull_request_list_reverse}
    x=number
    y=time_to_merge_hours
    yAxisTitle="time_to_merge_hours"
    sort=false
/>