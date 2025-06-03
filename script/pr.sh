#!/bin/sh

gh api graphql --paginate -F queryStr="repo:${REPO_NAME} is:pr is:merged merged:${MERGED_QUERY} sort:created-asc" -f query='
  query($queryStr: String!, $endCursor: String) {
    search(query: $queryStr, type: ISSUE, first: 100, after: $endCursor) {
      nodes {
        ... on PullRequest {
          number
          title
          author { login }
          createdAt
          mergedAt
          first_submitted_review: reviews(first: 1) {
            nodes {
              submittedAt
            }
          },
          first_approved_review: reviews(states: APPROVED, first: 1) {
            nodes {
              submittedAt
            }
          }
        }
      }
      pageInfo {
        hasNextPage,
        hasPreviousPage,
        startCursor,
        endCursor
      }
    }
  }
' |
sed "s/\'//g" |
jq -s '
  [.[].data.search.nodes] | add as $all_nodes |
  {
    data: {
      search: {
        nodes: $all_nodes
      }
    }
  }
' > bin/pr.json

cat bin/pr.json | jq -r --arg repository "${REPO_NAME}" '
  .data.search.nodes |
  map({
    repository: $repository,
    number:.number,
    title:.title,
    author:.author.login,
    createdAt:.createdAt,
    mergedAt:.mergedAt,
    firstReviewedAt: (.first_submitted_review.nodes[0].submittedAt // .mergedAt),
    firstApprovedAt: (.first_approved_review.nodes[0].submittedAt // .mergedAt)
  }) |
  .[] |
  [.repository, .number, .title, .author, .createdAt, .mergedAt, .firstReviewedAt, .firstApprovedAt] |
  @csv
'

rm -f bin/pr.json
