select repository from github.pr
union
select repository from github.review
union
select repository from test_coverage.coverage