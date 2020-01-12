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
import { TestResult } from './types'

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

const environment = {
  build_id: DISTRIBUTOR_BUILD_ID,
  node_index: DISTRIBUTOR_NODE_INDEX,
  node_total: DISTRIBUTOR_NODE_TOTAL,
  test_suite: DISTRIBUTOR_TEST_SUITE,
  api_token: DISTRIBUTOR_API_TOKEN,
  branch: DISTRIBUTOR_BRANCH,
  commit_sha: DISTRIBUTOR_COMMIT_SHA,
}

export const fetchSpecs = async ({
  initialize,
  specFiles,
}: {
  initialize: boolean
  specFiles: string[]
}): Promise<string[]> => {
  const { data } = await axios.post('/jobs', {
    ...environment,
    initialize,
    ...(initialize ? { spec_files: specFiles } : {}),
  })

  return data.spec_files
}

export const recordSpecs = async ({
  results,
}: {
  results: TestResult[]
}): Promise<void> => {
  await axios.post('/record', {
    ...environment,
    initialize: false,
    test_results: results,
  })
}

export const getQueueState = async () => {
  const { data } = await axios.get('/jobs', {
    params: environment,
  })

  return data
}
