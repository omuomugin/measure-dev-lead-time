---
title: テストカバレッジ
queries:
  - repo: github_repo.sql
---

<Alert status="info">
TBD: このページがどのように使われるかの説明
</Alert>

<Dropdown name=selected_repo data={repo} value=repository>
    <DropdownOption value="%" valueLabel="全ての repo"/>
</Dropdown>

<Dropdown name=target_weeks defaultValue="12 weeks">
    <DropdownOption valueLabel="4 weeks" value="4 weeks" />    
    <DropdownOption valueLabel="8 weeks" value="8 weeks" />    
    <DropdownOption valueLabel="12 weeks" value="12 weeks" />
    <DropdownOption valueLabel="24 weeks" value="24 weeks" />
</Dropdown>

## テストカバレッジ

```sql coverage_by_week
select
  DATE_TRUNC('week', date) AS week,
  AVG(cov) AS avg_coverage,
  repository
from test_coverage.coverage
where date >= date_trunc('week', current_date) - interval '${inputs.target_weeks.value}'
  and date_trunc('week', date) <> date_trunc('week', current_date)
  and repository like '${inputs.selected_repo.value}'
group by
  repository,
  week
order by week
```

<LineChart
    data={coverage_by_week}
    x=week
    y=avg_coverage
    xAxisTitle="week"
    yAxisTitle="%"
    series=repository
    yScale=true>
<ReferenceLine y=75 label="目標"/>
</LineChart>
