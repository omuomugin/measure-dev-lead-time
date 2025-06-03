---
title: トレンド (週次)
queries:
  - authors: github_pr_authors.sql
---

<Dropdown name=selected_item data={authors} value=author>
    <DropdownOption value="%" valueLabel="全ての author"/>
</Dropdown>

過去12週間のチームのトレンドを確認できます。

## Pull Request 数

```sql pull_request_count_by_week_limit_to_12_weeks
select
  date_trunc('week', mergedAt) as week,
  count(*) as pr_count
from github.pr
where mergedAt >= date_trunc('week', current_date) - interval '12 weeks'
    and date_trunc('week', mergedAt) <> date_trunc('week', current_date)
    and author like '${inputs.selected_item.value}'
group by week
order by week desc
```

<LineChart
    data={pull_request_count_by_week_limit_to_12_weeks}
    x=week
    y=pr_count
    xAxisTitle="week"
    yAxisTitle="count"
/>

## Pull Request リードタイム

```sql pull_request_avg_lead_time_stacked_by_week_limit_to_12_weeks
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
where mergedAt >= date_trunc('week', current_date) - interval '12 weeks'
  and date_trunc('week', mergedAt) <> date_trunc('week', current_date)
group by week
order by week desc
```

<AreaChart
    data={pull_request_avg_lead_time_stacked_by_week_limit_to_12_weeks}
    x=week
    y={['avg_time_to_first_review_hours', 'avg_time_to_approve_hours', 'avg_time_to_merge_after_approve_hours']}
    type=stacked100
/>

<Tabs>

<Tab label="ALL">

```sql pull_request_all_time_to_merge_by_week_limit_to_12_weeks
select
  date_trunc('week', mergedAt) as week,
  avg(extract(epoch from mergedAt - createdAt) / 3600) as total_avg_time_to_merge_hours,
  median(extract(epoch from mergedAt - createdAt) / 3600) as total_median_time_to_merge_hours
from github.pr
where mergedAt >= date_trunc('week', current_date) - interval '12 weeks'
  and date_trunc('week', mergedAt) <> date_trunc('week', current_date)
  and author like '${inputs.selected_item.value}'
group by week
order by week desc
```

<LineChart
    data={pull_request_all_time_to_merge_by_week_limit_to_12_weeks}
    x=week
    y={['total_avg_time_to_merge_hours', 'total_median_time_to_merge_hours']}
    yAxisTitle="hours"
/>

</Tab>

<Tab label="Average">

```sql pull_request_avg_time_to_merge_by_week_limit_to_12_weeks
select
  date_trunc('week', mergedAt) as week,
  avg(extract(epoch from firstReviewedAt - createdAt) / 3600) as time_to_first_review_hours,
  avg(extract(epoch from firstApprovedAt - firstReviewedAt) / 3600) as time_to_approve_hours,
  avg(extract(epoch from mergedAt - firstApprovedAt) / 3600) as time_to_merge_after_approve_hours
from github.pr
where mergedAt >= date_trunc('week', current_date) - interval '12 weeks'
  and date_trunc('week', mergedAt) <> date_trunc('week', current_date)
  and author like '${inputs.selected_item.value}'
group by week
order by week desc
```

<LineChart
    data={pull_request_avg_time_to_merge_by_week_limit_to_12_weeks}
    x=week
    y={['time_to_first_review_hours', 'time_to_approve_hours', 'time_to_merge_after_approve_hours']}
    yAxisTitle="hours"
/>

</Tab>

<Tab label="Median">

```sql pull_request_median_time_to_merge_by_week_limit_to_12_weeks
select
  date_trunc('week', mergedAt) as week,
  median(extract(epoch from firstReviewedAt - createdAt) / 3600) as time_to_first_review_hours,
  median(extract(epoch from firstApprovedAt - firstReviewedAt) / 3600) as time_to_approve_hours,
  median(extract(epoch from mergedAt - firstApprovedAt) / 3600) as time_to_merge_after_approve_hours
from github.pr
where mergedAt >= date_trunc('week', current_date) - interval '12 weeks'
  and date_trunc('week', mergedAt) <> date_trunc('week', current_date)
  and author like '${inputs.selected_item.value}'
group by week
order by week desc
```

<LineChart
data={pull_request_median_time_to_merge_by_week_limit_to_12_weeks}
x=week
y={['time_to_first_review_hours', 'time_to_approve_hours', 'time_to_merge_after_approve_hours']}
yAxisTitle="hours"
/>

</Tab>

</Tabs>
