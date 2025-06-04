---
title: PR レビューサマリー
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

## レビューサマリー

```sql pull_request_count_by_day
select
  date_trunc('day', mergedAt) as day,
  count(*) as pr_count
from github.pr
where mergedAt >= date_trunc('day', current_date) - interval '${inputs.target_days.value}'
    and date_trunc('day', mergedAt) <> date_trunc('day', current_date)
    and repository like '${inputs.selected_repo.value}'
group by day
order by day desc
```

Total Pull Request Count

<LineChart
    data={pull_request_count_by_day}
    x=day
    y=pr_count
    xAxisTitle="day"
    yAxisTitle="count"
/>

```sql pull_request_count_by_day_commented_by_author
select
  date_trunc('day', pr.mergedAt) as day,
  count(*) as pr_count
from github.pr pr
where pr.mergedAt >= date_trunc('day', current_date) - interval '${inputs.target_days.value}'
  and date_trunc('day', pr.mergedAt) <> date_trunc('day', current_date)
  and pr.repository like '${inputs.selected_repo.value}'
  and exists (
    select 1 from github.review r
    where r.number = pr.number
      and r.repository = pr.repository
      and r.author like '${inputs.selected_author.value}'
      and r.author <> ''
  )
group by day
order by day desc
```

```sql pull_request_count_by_day_approved_by_author
select
  date_trunc('day', pr.mergedAt) as day,
  count(*) as pr_count
from github.pr pr
where pr.mergedAt >= date_trunc('day', current_date) - interval '${inputs.target_days.value}'
  and date_trunc('day', pr.mergedAt) <> date_trunc('day', current_date)
  and pr.repository like '${inputs.selected_repo.value}'
  and exists (
    select 1 from github.review r
    where r.number = pr.number
      and r.repository = pr.repository
      and r.author like '${inputs.selected_author.value}'
      and r.author <> ''
        and r.isApprove = true
  )
group by day
order by day desc
```

<Grid cols=2>

<Group>
    Reviewed by Author
    <LineChart
        data={pull_request_count_by_day_commented_by_author}
        x=day
        y=pr_count
        xAxisTitle="day"
        yAxisTitle="count"
        emptySet="pass"
    />
</Group>

<Group>
    Approved by Author
    <LineChart
        data={pull_request_count_by_day_approved_by_author}
        x=day
        y=pr_count
        xAxisTitle="day"
        yAxisTitle="count"
        emptySet="pass"
    />
</Group>

</Grid>

```sql review_chanmpion_by_day
select
    r.author,
    count(*) as reviewd_pr_count
from github.review r
     join github.pr pr
         on r.repository = pr.repository
                and r.number = pr.number
where pr.mergedAt >= date_trunc('day', current_date) - interval '${inputs.target_days.value}'
  and pr.repository like '${inputs.selected_repo.value}'
  and r.author is not null
  and r.author <> ''
group by r.author
order by reviewd_pr_count desc
limit 3
```

## Top 3 Reviewers

<DataTable data={review_chanmpion_by_day}/>
