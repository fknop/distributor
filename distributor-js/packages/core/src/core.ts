import * as Api from './api'

export type OnSuccessFunction = (files: string[]) => Promise<any>
export type OnErrorFunction = (error: any) => Promise<any>

const fetchSpecs = async ({
  specFiles,
  onSuccess,
  onError,
  initialize,
}: {
  specFiles: string[]
  onSuccess: OnSuccessFunction
  onError: OnErrorFunction
  initialize: boolean
}) => {
  try {
    const pendingSpecFiles = await Api.fetchSpecs({ initialize, specFiles })
    await onSuccess(pendingSpecFiles)
    await fetchSpecs({ specFiles, onSuccess, onError, initialize: false })
  } catch (error) {
    await onError(error)
  }
}

export const run = async ({
  specFiles,
  onSuccess,
  onError,
}: {
  specFiles: string[]
  onSuccess: OnSuccessFunction
  onError: OnErrorFunction
}) => {
  await fetchSpecs({
    specFiles,
    onSuccess,
    onError,
    initialize: true,
  })
}
