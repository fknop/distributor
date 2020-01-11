import glob from 'glob'

const DEFAULT_JEST_PATTERN = '**/__tests__/**/*.@(spec|test).@(j|t)s?(x)'

const testPathPattern: string = process.env.DISTRIBUTOR_JEST_PATTERN
  ? process.env.DISTRIBUTOR_JEST_PATTERN
  : DEFAULT_JEST_PATTERN

export const findTestFiles = (): string[] => {
  const files = glob.sync(testPathPattern, { ignore: '**/node_modules/**' })

  if (files.length === 0) {
    throw new Error(
      `Could not find any tests with pattern: "${testPathPattern}". Make sure to add a correct pattern.`
    )
  }

  return files
}
