---
title: PR リードタイム
queries:
  - authors: github_authors.sql
  - repo: github_repo.sql
---

<Alert status="info">
TBD: このページがどのように使われるかの説明
</Alert>

<Dropdown name=selected_item data={authors} value=author>
    <DropdownOption value="%" valueLabel="全ての author"/>
</Dropdown>

<Dropdown name=selected_repo data={repo} value=repository>
    <DropdownOption value="%" valueLabel="全ての repo"/>
</Dropdown>

<Dropdown name=target_weeks defaultValue="12 weeks">
    <DropdownOption valueLabel="4 weeks" value="4 weeks" />    
    <DropdownOption valueLabel="8 weeks" value="8 weeks" />    
    <DropdownOption valueLabel="12 weeks" value="12 weeks" />
    <DropdownOption valueLabel="24 weeks" value="24 weeks" />
</Dropdown>

## Pull Request 数

```sql pull_request_count_by_week
select
  date_trunc('week', mergedAt) as week,
  count(*) as pr_count
from github.pr
where mergedAt >= date_trunc('week', current_date) - interval '${inputs.target_weeks.value}'
    and date_trunc('week', mergedAt) <> date_trunc('week', current_date)
    and author like '${inputs.selected_item.value}'
    and repository like '${inputs.selected_repo.value}'
group by week
order by week desc
```

<LineChart
    data={pull_request_count_by_week}
    x=week
    y=pr_count
    xAxisTitle="week"
    yAxisTitle="count"
/>

## Pull Request リードタイム

```sql pull_request_avg_lead_time_stacked_by_week
select
  date_trunc('week', mergedAt) as week,
  avg(extract(epoch from firstReviewedAt - createdAt) / 3600) as avg_time_to_first_review_hours,
  avg(extract(epoch from firstApprovedAt - firstReviewedAt) / 3600) as avg_time_to_approve_hours,
  avg(extract(epoch from mergedAt - firstApprovedAt) / 3600) as avg_time_to_merge_after_approve_hours,
  avg(extract(epoch from mergedAt - createdAt) / 3600) as avg_total_hours,
  avg(extract(epoch from firstReviewedAt - createdAt) / 3600) / avg(extract(epoch from mergedAt - createdAt) / 3600) as avg_time_to_first_review_hours_pct,
  avg(extract(epoch from firstApprovedAt - firstReviewedAt) / 3600) / avg(extract(epoch from mergedAt - createdAt) / 3600) as avg_time_to_approve_hours_pct,
  avg(extract(epoch from mergedAt - firstApprovedAt) / 3600) / avg(extract(epoch from mergedAt - createdAt) / 3600) as avg_time_to_merge_after_approve_hours_pct
from github.pr
where mergedAt >= date_trunc('week', current_date) - interval '${inputs.target_weeks.value}'
  and date_trunc('week', mergedAt) <> date_trunc('week', current_date)
  and repository like '${inputs.selected_repo.value}'
group by week
order by week desc
```

<AreaChart
    data={pull_request_avg_lead_time_stacked_by_week}
    x=week
    y={['avg_time_to_first_review_hours', 'avg_time_to_approve_hours', 'avg_time_to_merge_after_approve_hours']}
    type=stacked100
/>

<Tabs>

<Tab label="ALL">

```sql pull_request_all_time_to_merge_by_week
select
  date_trunc('week', mergedAt) as week,
  avg(extract(epoch from mergedAt - createdAt) / 3600) as total_avg_time_to_merge_hours,
  median(extract(epoch from mergedAt - createdAt) / 3600) as total_median_time_to_merge_hours
from github.pr
where mergedAt >= date_trunc('week', current_date) - interval '${inputs.target_weeks.value}'
  and date_trunc('week', mergedAt) <> date_trunc('week', current_date)
  and author like '${inputs.selected_item.value}'
  and repository like '${inputs.selected_repo.value}'
group by week
order by week desc
```

<LineChart
    data={pull_request_all_time_to_merge_by_week}
    x=week
    y={['total_avg_time_to_merge_hours', 'total_median_time_to_merge_hours']}
    yAxisTitle="hours"
/>

</Tab>

<Tab label="Average">

```sql pull_request_avg_time_to_merge_by_week
select
  date_trunc('week', mergedAt) as week,
  avg(extract(epoch from firstReviewedAt - createdAt) / 3600) as time_to_first_review_hours,
  avg(extract(epoch from firstApprovedAt - firstReviewedAt) / 3600) as time_to_approve_hours,
  avg(extract(epoch from mergedAt - firstApprovedAt) / 3600) as time_to_merge_after_approve_hours
from github.pr
where mergedAt >= date_trunc('week', current_date) - interval '${inputs.target_weeks.value}'
  and date_trunc('week', mergedAt) <> date_trunc('week', current_date)
  and author like '${inputs.selected_item.value}'
  and repository like '${inputs.selected_repo.value}'
group by week
order by week desc
```

<LineChart
    data={pull_request_avg_time_to_merge_by_week}
    x=week
    y={['time_to_first_review_hours', 'time_to_approve_hours', 'time_to_merge_after_approve_hours']}
    yAxisTitle="hours"
/>

</Tab>

<Tab label="Median">

```sql pull_request_median_time_to_merge_by_week
select
  date_trunc('week', mergedAt) as week,
  median(extract(epoch from firstReviewedAt - createdAt) / 3600) as time_to_first_review_hours,
  median(extract(epoch from firstApprovedAt - firstReviewedAt) / 3600) as time_to_approve_hours,
  median(extract(epoch from mergedAt - firstApprovedAt) / 3600) as time_to_merge_after_approve_hours
from github.pr
where mergedAt >= date_trunc('week', current_date) - interval '${inputs.target_weeks.value}'
  and date_trunc('week', mergedAt) <> date_trunc('week', current_date)
  and author like '${inputs.selected_item.value}'
  and repository like '${inputs.selected_repo.value}'
group by week
order by week desc
```

<LineChart
data={pull_request_median_time_to_merge_by_week}
x=week
y={['time_to_first_review_hours', 'time_to_approve_hours', 'time_to_merge_after_approve_hours']}
yAxisTitle="hours"
/>

</Tab>

</Tabs>
