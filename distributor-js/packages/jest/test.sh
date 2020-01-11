#!/usr/bin/env bash

# TODO: delete this file once tests have been implemented
DISTRIBUTOR_API_URL=http://localhost:4000 DISTRIBUTOR_API_TOKEN=api_token DISTRIBUTOR_BUILD_ID=42 DISTRIBUTOR_TEST_SUITE=test_suite DISTRIBUTOR_NODE_INDEX=0 DISTRIBUTOR_NODE_TOTAL=2 DISTRIBUTOR_BRANCH=branch DISTRIBUTOR_COMMIT_SHA=sha DISTRIBUTOR_JEST_PATTERN='**/test/**/*.@(spec|test).@(j|t)s?(x)' node dist/index.js
