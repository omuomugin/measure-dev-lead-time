#!/bin/sh

source .env

gh api graphql --paginate -F owner="${REPO_OWNER}" -F name="${REPO_NAME}" -F queryStr="repo:${REPO_OWNER}/${REPO_NAME} is:pr is:merged merged:${MERGED_QUERY} sort:created-asc" -f query='
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
          fisrt_approved_review: reviews(states: APPROVED, first: 1) {
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
' \
--jq '
  .data.search.nodes |
  map({number:.number, title:.title, author:.author.login, createdAt:.createdAt, mergedAt:.mergedAt, firstReviewdAt:.first_submitted_review.nodes[0].submittedAt, firstApprovedAt:.fisrt_approved_review.nodes[0].submittedAt}) |
  .[] |
  if .firstReviewdAt == null then .firstReviewdAt = .mergedAt end |
  if .firstApprovedAt == null then .firstApprovedAt = .mergedAt end |
  [.number, .title, .author, .createdAt, .mergedAt, .firstReviewdAt, .firstApprovedAt] |
  @csv
' |
sed "s/\'//g" |
sed "s/\"/'/g" > bin/pr.csv