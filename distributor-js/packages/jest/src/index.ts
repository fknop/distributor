import jest from 'jest'
import minimist from 'minimist'
import { RunSpecsFunction, run } from '@distributor/core'
import { findTestFiles } from './utils'

const argv = process.argv.slice(2)
const jestOptions: any = minimist(argv)

const runSpecs: RunSpecsFunction = async (specs: string[]) => {
  const { results } = await jest.runCLI(
    {
      ...jestOptions,
      runTestByPath: true,
      _: specs,
    },
    [process.cwd()]
  )

  const { testResults } = results

  return testResults.map(result => {
    const name = result.testFilePath
    const success = result.numFailingTests === 0
    const { start, end } = result.perfStats
    const time = end - start
    return {
      name,
      success,
      time,
    }
  })
}

run({
  runSpecs,
  onError: async (error: any) => {
    console.error(error.response.data)
  },
  specFiles: findTestFiles(),
})
