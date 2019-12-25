const getRequiredEnvironment = (env: string, type: 'string' | 'boolean' | 'number'): any => {
  if (typeof process.env[env] === 'undefined') {
    throw new Error(`Environment variable ${env} is required. Read the docs for more information.`)
  }

  if (type === 'string') {
    return process.env[env] as string
  }

  if (type === 'number') {
    return parseInt(process.env[env] as string, 10) as number
  }

  if (type === 'boolean') {
    return Boolean(process.env[env] as string) as boolean
  }

  throw new Error(`Error loading environment variable ${env}, you might want to check its value.`)
}


export const DISTRIBUTOR_API_URL: string = getRequiredEnvironment('DISTRIBUTOR_API_URL', 'string')
export const DISTRIBUTOR_API_TOKEN: string = getRequiredEnvironment('DISTRIBUTOR_API_TOKEN', 'string')
export const DISTRIBUTOR_BUILD_ID = getRequiredEnvironment('DISTRIBUTOR_BUILD_ID', 'string')
export const DISTRIBUTOR_NODE_INDEX = getRequiredEnvironment('DISTRIBUTOR_NODE_INDEX', 'number')
export const DISTRIBUTOR_NODE_TOTAL = getRequiredEnvironment('DISTRIBUTOR_NODE_TOTAL', 'number')
