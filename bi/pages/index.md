---
title: 開発リードタイム
---

## Pull Request 数 (過去12週間)

```pull_request_count_by_week_limit_to_12_weeks
select
  date_trunc('week', mergedAt) as week,
  count(*) as pr_count
from github.pr
where mergedAt >= date_trunc('week', current_date) - interval '12 weeks'
    and date_trunc('week', mergedAt) <> date_trunc('week', current_date)
group by week
order by week desc
```

今週: <Value data={pull_request_count_by_week_limit_to_12_weeks} row=0 column="pr_count" /> ( {pull_request_count_by_week_limit_to_12_weeks[0].pr_count - pull_request_count_by_week_limit_to_12_weeks[1].pr_count} )  
先週: <Value data={pull_request_count_by_week_limit_to_12_weeks} row=1 column="pr_count" />

<LineChart
    data={pull_request_count_by_week_limit_to_12_weeks}
    x=week
    y=pr_count
    xAxisTitle="week"
    yAxisTitle="count"
/>
