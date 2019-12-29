import { GithubActionsCI } from './ci/github-actions'
import { JenkinsCI } from './ci/jenkins'
import { CI } from './ci/ci'

const getEnvironmentVariable = (
  env: string,
  options: {
    type?: 'string' | 'boolean' | 'number'
    fallback?: () => any
  }
): any => {
  const { fallback, type } = options

  if (typeof process.env[env] === 'undefined') {
    if (fallback && fallback()) {
      return fallback()
    }

    throw new Error(
      `Environment variable ${env} is required. Read the docs for more information.`
    )
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
}

const ciProviders: CI[] = [GithubActionsCI, JenkinsCI]

const ciEnvironment: CI = {
  getBranch(): string | undefined {
    return ciProviders.find(ci => ci.getBranch())?.getBranch()
  },

  getCommitHash(): string | undefined {
    return ciProviders.find(ci => ci.getCommitHash())?.getCommitHash()
  },

  getBuildId(): string | undefined {
    return ciProviders.find(ci => ci.getBuildId())?.getBuildId()
  },
}

export const DISTRIBUTOR_API_URL: string = getEnvironmentVariable(
  'DISTRIBUTOR_API_URL',
  { type: 'string' }
)

export const DISTRIBUTOR_API_TOKEN: string = getEnvironmentVariable(
  'DISTRIBUTOR_API_TOKEN',
  { type: 'string' }
)

export const DISTRIBUTOR_TEST_SUITE = getEnvironmentVariable(
  'DISTRIBUTOR_TEST_SUITE',
  { type: 'string' }
)

export const DISTRIBUTOR_NODE_INDEX = getEnvironmentVariable(
  'DISTRIBUTOR_NODE_INDEX',
  { type: 'number' }
)

export const DISTRIBUTOR_NODE_TOTAL = getEnvironmentVariable(
  'DISTRIBUTOR_NODE_TOTAL',
  { type: 'number' }
)

export const DISTRIBUTOR_BUILD_ID = getEnvironmentVariable(
  'DISTRIBUTOR_BUILD_ID',
  { type: 'string', fallback: ciEnvironment.getBuildId }
)

export const DISTRIBUTOR_BRANCH = getEnvironmentVariable('DISTRIBUTOR_BRANCH', {
  type: 'string',
  fallback: ciEnvironment.getBranch,
})

export const DISTRIBUTOR_COMMIT_SHA = getEnvironmentVariable(
  'DISTRIBUTOR_COMMIT_SHA',
  { type: 'string', fallback: ciEnvironment.getCommitHash }
)
