import { CI } from './ci'

export const JenkinsCI: CI = {
  getBranch(): string | undefined {
    return process.env.GIT_BRANCH
  },

  getCommitHash(): string | undefined {
    return process.env.GIT_COMMIT
  },

  getBuildId(): string | undefined {
    return process.env.BUILD_ID
  },
}
