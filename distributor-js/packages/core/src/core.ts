import * as Api from './api'
import { TestResult } from './types'
import { recordSpecs } from './api'

export type RunSpecsFunction = (files: string[]) => Promise<TestResult[]>
export type OnErrorFunction = (error: any) => Promise<any>

const fetchSpecs = async ({
  specFiles,
  runSpecs,
  onError,
  initialize,
}: {
  specFiles: string[]
  runSpecs: RunSpecsFunction
  onError: OnErrorFunction
  initialize: boolean
}) => {
  try {
    const pendingSpecFiles = await Api.fetchSpecs({ initialize, specFiles })

    if (pendingSpecFiles.length === 0) {
      return
    }

    const results = await runSpecs(pendingSpecFiles)
    if (results?.length > 0) {
      await recordSpecs({ results })
    }

    await fetchSpecs({ specFiles, runSpecs, onError, initialize: false })
  } catch (error) {
    await onError(error)
  }
}

export const run = async ({
  specFiles,
  runSpecs,
  onError,
}: {
  specFiles: string[]
  runSpecs: RunSpecsFunction
  onError: OnErrorFunction
}) => {
  await fetchSpecs({
    specFiles,
    runSpecs,
    onError,
    initialize: true,
  })
}
