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
' > bin/review.json

cat bin/review.json | jq -r '
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
' > ../bi/sources/github/review.csv