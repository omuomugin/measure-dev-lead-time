#!/bin/sh

source .env

gh api graphql --paginate -F owner="${REPO_OWNER}" -F name="${REPO_NAME}" -F queryStr="repo:${REPO_OWNER}/${REPO_NAME} is:pr is:merged merged:${MERGED_QUERY} sort:created-asc" -f query='
  query($queryStr: String!, $endCursor: String) {
    search(query: $queryStr, type: ISSUE, first: 100, after: $endCursor) {
      nodes {
        ... on PullRequest {
          number
          reviews(first: 100) {
            nodes {
              author { login }
              state
            }
          }
        }
      }
      pageInfo {
        hasNextPage
        endCursor
      }
    }
  }
' \
--jq '
  ["number", "author", "isApprove"],
  (
    .data.search.nodes[] |
    .number as $number |
    .reviews.nodes |
    group_by(.author.login) |
    select(length > 0) |
    map({number: $number, author: .[0].author.login, isApprove: map(.state) | unique | any(.== "APPROVED")}) |
    map([.number, .author, .isApprove]) |
    .[]
  ) | @csv
' | sed "s/\"/'/g" > ../bi/sources/review/review.csv