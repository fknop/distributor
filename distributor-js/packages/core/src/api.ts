import Axios, { AxiosInstance } from 'axios'
import axiosRetry, { exponentialDelay } from 'axios-retry'
import {
  DISTRIBUTOR_API_TOKEN,
  DISTRIBUTOR_API_URL,
  DISTRIBUTOR_BRANCH,
  DISTRIBUTOR_BUILD_ID,
  DISTRIBUTOR_COMMIT_SHA,
  DISTRIBUTOR_NODE_INDEX,
  DISTRIBUTOR_NODE_TOTAL,
  DISTRIBUTOR_TEST_SUITE,
} from './env'

const axios: AxiosInstance = Axios.create({
  baseURL: DISTRIBUTOR_API_URL,
  headers: {
    Authorization: DISTRIBUTOR_API_TOKEN,
  },
  timeout: 10000,
})

axiosRetry(axios, {
  retries: 2,
  retryDelay: exponentialDelay,
})

export const fetchSpecs = async ({
  initialize,
  specFiles,
}: {
  initialize: boolean
  specFiles: string[]
}): Promise<string[]> => {
  return await axios.post('/jobs', {
    build_id: DISTRIBUTOR_BUILD_ID,
    node_index: DISTRIBUTOR_NODE_INDEX,
    node_total: DISTRIBUTOR_NODE_TOTAL,
    test_suite: DISTRIBUTOR_TEST_SUITE,
    api_token: DISTRIBUTOR_API_TOKEN,
    branch: DISTRIBUTOR_BRANCH,
    commit_sha: DISTRIBUTOR_COMMIT_SHA,
    initialize,
    ...(initialize ? { spec_files: specFiles } : {}),
  })
}
