export interface CI {
  getCommitHash(): string | undefined
  getBranch(): string | undefined
  getBuildId(): string | undefined
}
