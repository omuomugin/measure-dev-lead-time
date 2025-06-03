---
title: Pull Request サマリー
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

```sql pull_request_list_limit_to_14_days
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
where mergedAt >= date_trunc('day', current_date) - interval '14 days'
    and author like '${inputs.selected_author.value}'
    and repository like '${inputs.selected_repo.value}'
order by time_to_merge_hours desc
```

<DataTable data={pull_request_list_limit_to_14_days}>
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

```sql pull_request_list_limit_to_14_days_reverse
select
    *
from ${pull_request_list_limit_to_14_days}
order by time_to_merge_hours asc
```

<LineChart
    data={pull_request_list_limit_to_14_days_reverse}
    x=number
    y=time_to_merge_hours
    yAxisTitle="time_to_merge_hours"
    sort=false
/>
