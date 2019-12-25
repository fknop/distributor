import { registerNode, requestSpecFiles } from './api';

export type OnSuccessFunction = (files: string[]) => Promise<any>
export type OnErrorFunction = (error: any) => Promise<any>

const fetchFiles = async (onSuccess: OnSuccessFunction, onError: OnErrorFunction) => {
  try {
    const pendingSpecFiles = await requestSpecFiles()
    await onSuccess(pendingSpecFiles)
    await fetchFiles(onSuccess, onError)
  } catch (error) {
    await onError(error)
  }
}

export const run = async (onSuccess: OnSuccessFunction, onError: OnErrorFunction) => {
  await registerNode()
  await fetchFiles(onSuccess, onError)
}


