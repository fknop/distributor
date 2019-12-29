import jest from 'jest'
import minimist from 'minimist'
import { OnSuccessFunction, run } from '@distributor/core'
import { findTestFiles } from './utils'

const argv = process.argv.slice(2)
const jestOptions: any = minimist(argv)

const onSuccess: OnSuccessFunction = async (specs: string[]) => {
  console.log({ specs })
  const { results } = await jest.runCLI(
    {
      ...jestOptions,
      runTestByPath: true,
      _: specs,
    },
    [process.cwd()]
  )

  const { testResults } = results

  testResults.map(testResult => {
    const path = testResult.testFilePath
    // const success = testResult.testResults
    console.log({ path, result: testResult.testResults })
  })

  console.log(results.testResults[0].testResults)
  console.log(results)
}

run({
  onSuccess,
  onError: async (error: any) => {
    console.error(error)
  },
  specFiles: findTestFiles(),
})
