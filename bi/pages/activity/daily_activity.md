---
title: アクティビティ (日次)
queries:
  - authors: github_pr_authors.sql
  - repo: github_pr_repo.sql
---

<Dropdown name=selected_author data={authors} value=author>
    <DropdownOption value="%" valueLabel="全ての author"/>
</Dropdown>

<Dropdown name=selected_repo data={repo} value=repository>
    <DropdownOption value="%" valueLabel="全ての repo"/>
</Dropdown>

過去2週間のアクティビティを確認できます。

## Pull Request 数

```sql pull_request_count_by_day_limit_to_14_days
select
  date_trunc('day', mergedAt) as day,
  count(*) as pr_count
from github.pr
where mergedAt >= date_trunc('day', current_date) - interval '14 days'
    and date_trunc('day', mergedAt) <> date_trunc('day', current_date)
    and author like '${inputs.selected_author.value}'
    and repository like '${inputs.selected_repo.value}'
group by day
order by day desc
```

<LineChart
    data={pull_request_count_by_day_limit_to_14_days}
    x=day
    y=pr_count
    xAxisTitle="week"
    yAxisTitle="count"
/>

## Pull Request リードタイム

```sql pull_request_avg_lead_time_stacked_by_day_limit_to_14_days
select
  date_trunc('day', mergedAt) as day,
  avg(extract(epoch from firstReviewedAt - createdAt) / 3600) as avg_time_to_first_review_hours,
  avg(extract(epoch from firstApprovedAt - firstReviewedAt) / 3600) as avg_time_to_approve_hours,
  avg(extract(epoch from mergedAt - firstApprovedAt) / 3600) as avg_time_to_merge_after_approve_hours,
  avg(extract(epoch from mergedAt - createdAt) / 3600) as avg_total_hours,
  avg(extract(epoch from firstReviewedAt - createdAt) / 3600) / avg(extract(epoch from mergedAt - createdAt) / 3600) as avg_time_to_first_review_hours_pct,
  avg(extract(epoch from firstApprovedAt - firstReviewedAt) / 3600) / avg(extract(epoch from mergedAt - createdAt) / 3600) as avg_time_to_approve_hours_pct,
  avg(extract(epoch from mergedAt - firstApprovedAt) / 3600) / avg(extract(epoch from mergedAt - createdAt) / 3600) as avg_time_to_merge_after_approve_hours_pct
from github.pr
where mergedAt >= date_trunc('day', current_date) - interval '14 days'
  and date_trunc('day', mergedAt) <> date_trunc('day', current_date)
  and repository like '${inputs.selected_repo.value}'
group by day
order by day desc
```

<AreaChart
    data={pull_request_avg_lead_time_stacked_by_day_limit_to_14_days}
    x=day
    y={['avg_time_to_first_review_hours', 'avg_time_to_approve_hours', 'avg_time_to_merge_after_approve_hours']}
    type=stacked100
/>

<Tabs>

<Tab label="ALL">

```sql pull_request_all_time_to_merge_by_day_limit_to_14_days
select
  date_trunc('day', mergedAt) as day,
  avg(extract(epoch from mergedAt - createdAt) / 3600) as total_avg_time_to_merge_hours,
  median(extract(epoch from mergedAt - createdAt) / 3600) as total_median_time_to_merge_hours
from github.pr
where mergedAt >= date_trunc('day', current_date) - interval '14 days'
  and date_trunc('day', mergedAt) <> date_trunc('day', current_date)
  and author like '${inputs.selected_author.value}'
  and repository like '${inputs.selected_repo.value}'
group by day
order by day desc
```

<LineChart
    data={pull_request_all_time_to_merge_by_day_limit_to_14_days}
    x=day
    y={['total_avg_time_to_merge_hours', 'total_median_time_to_merge_hours']}
    yAxisTitle="hours"
/>

</Tab>

<Tab label="Average">

```sql pull_request_avg_time_to_merge_by_day_limit_to_14_days
select
  date_trunc('day', mergedAt) as day,
  avg(extract(epoch from firstReviewedAt - createdAt) / 3600) as time_to_first_review_hours,
  avg(extract(epoch from firstApprovedAt - firstReviewedAt) / 3600) as time_to_approve_hours,
  avg(extract(epoch from mergedAt - firstApprovedAt) / 3600) as time_to_merge_after_approve_hours
from github.pr
where mergedAt >= date_trunc('day', current_date) - interval '14 days'
  and date_trunc('day', mergedAt) <> date_trunc('day', current_date)
  and author like '${inputs.selected_author.value}'
  and repository like '${inputs.selected_repo.value}'
group by day
order by day desc
```

<LineChart
    data={pull_request_avg_time_to_merge_by_day_limit_to_14_days}
    x=day
    y={['time_to_first_review_hours', 'time_to_approve_hours', 'time_to_merge_after_approve_hours']}
    yAxisTitle="hours"
/>

</Tab>

<Tab label="Median">

```sql pull_request_median_time_to_merge_by_day_limit_to_14_days
select
  date_trunc('day', mergedAt) as day,
  median(extract(epoch from firstReviewedAt - createdAt) / 3600) as time_to_first_review_hours,
  median(extract(epoch from firstApprovedAt - firstReviewedAt) / 3600) as time_to_approve_hours,
  median(extract(epoch from mergedAt - firstApprovedAt) / 3600) as time_to_merge_after_approve_hours
from github.pr
where mergedAt >= date_trunc('day', current_date) - interval '14 days'
  and date_trunc('day', mergedAt) <> date_trunc('day', current_date)
  and author like '${inputs.selected_author.value}'
  and repository like '${inputs.selected_repo.value}'
group by day
order by day desc
```

<LineChart
    data={pull_request_median_time_to_merge_by_day_limit_to_14_days}
    x=day
    y={['time_to_first_review_hours', 'time_to_approve_hours', 'time_to_merge_after_approve_hours']}
    yAxisTitle="hours"
/>

</Tab>

</Tabs>

