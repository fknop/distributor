import { CI } from './ci'

export const GithubActionsCI: CI = {
  getBranch(): string | undefined {
    return process.env.GITHUB_REF ?? process.env.GITHUB_SHA
  },

  getCommitHash(): string | undefined {
    return process.env.GITHUB_SHA
  },

  getBuildId(): string | undefined {
    return undefined
  },
}
