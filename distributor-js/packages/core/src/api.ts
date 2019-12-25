import Axios, { AxiosInstance } from 'axios';
import axiosRetry, {exponentialDelay} from 'axios-retry';
import {
  DISTRIBUTOR_API_TOKEN,
  DISTRIBUTOR_API_URL,
  DISTRIBUTOR_BUILD_ID,
  DISTRIBUTOR_NODE_INDEX,
  DISTRIBUTOR_NODE_TOTAL
} from './env';

const axios: AxiosInstance = Axios.create({
  baseURL: DISTRIBUTOR_API_URL,
  headers: {
    Authorization: DISTRIBUTOR_API_TOKEN
  },
  timeout: 10000
})

axiosRetry(axios, {
  retries: 2,
  retryDelay: exponentialDelay
})


export const registerNode = async () => {
  const specFiles: string[] = []
  await axios.post('/jobs', {
    build_id: DISTRIBUTOR_BUILD_ID,
    node_index: DISTRIBUTOR_NODE_INDEX,
    node_total: DISTRIBUTOR_NODE_TOTAL,
    spec_files: specFiles
  })
}


export const requestSpecFiles = async (): Promise<string[]> => {
  const {data} = await axios.get(`/jobs/${DISTRIBUTOR_BUILD_ID}/spec`)
  return data.spec_files
}

export const recordFiles = async ({
  files,
  success
}: {
  files: string[],
  success: boolean
}): Promise<any> => {
  await axios.post(`/jobs/${DISTRIBUTOR_BUILD_ID}`, {
    spec_files: files,
    success
  })
}
