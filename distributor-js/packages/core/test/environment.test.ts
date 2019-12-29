describe('Environment variable', () => {
  const originalEnv = { ...process.env }

  beforeEach(() => {
    process.env = { ...originalEnv }
    jest.resetModules()
  })

  it('Should throw if env is missing', () => {
    expect(() => require('../src/env')).toThrow()
  })

  it('Should not throw if all environments are specified', () => {
    process.env = {
      ...process.env,
      DISTRIBUTOR_API_URL: 'http://localhost:4000',
      DISTRIBUTOR_API_TOKEN: 'random-token',
      DISTRIBUTOR_TEST_SUITE: 'test_suite_name',
      DISTRIBUTOR_NODE_INDEX: '0',
      DISTRIBUTOR_NODE_TOTAL: '4',
      DISTRIBUTOR_BUILD_ID: 'build_id',
      DISTRIBUTOR_BRANCH: 'branch',
      DISTRIBUTOR_COMMIT_SHA: 'sha',
    }

    expect(() => require('../src/env')).not.toThrow()
  })

  it('Should throw if one is missing #2', () => {
    process.env = {
      ...process.env,
      DISTRIBUTOR_API_URL: 'http://localhost:4000',
      DISTRIBUTOR_API_TOKEN: 'random-token',
      DISTRIBUTOR_NODE_INDEX: '0',
      DISTRIBUTOR_NODE_TOTAL: '4',
      DISTRIBUTOR_BUILD_ID: 'build_id',
      DISTRIBUTOR_BRANCH: 'branch',
      DISTRIBUTOR_COMMIT_SHA: 'sha',
    }

    expect(() => require('../src/env')).toThrow()
  })

  it('Should throw if one is missing #3', () => {
    process.env = {
      ...process.env,
      DISTRIBUTOR_API_URL: 'http://localhost:4000',
      DISTRIBUTOR_API_TOKEN: 'random-token',
      DISTRIBUTOR_TEST_SUITE: 'test_suite',
      DISTRIBUTOR_NODE_INDEX: '0',
      DISTRIBUTOR_BUILD_ID: 'build_id',
      DISTRIBUTOR_BRANCH: 'branch',
      DISTRIBUTOR_COMMIT_SHA: 'sha',
    }

    expect(() => require('../src/env')).toThrow()
  })

  it('Should throw if one is missing #4', () => {
    process.env = {
      ...process.env,
      DISTRIBUTOR_API_URL: 'http://localhost:4000',
      DISTRIBUTOR_API_TOKEN: 'random-token',
      DISTRIBUTOR_TEST_SUITE: 'test_suite',
      DISTRIBUTOR_NODE_INDEX: '0',
      DISTRIBUTOR_NODE_TOTAL: '4',
      DISTRIBUTOR_BRANCH: 'branch',
      DISTRIBUTOR_COMMIT_SHA: 'sha',
    }

    expect(() => require('../src/env')).toThrow()
  })

  it('Should throw if a number env is not a number', () => {
    process.env = {
      ...process.env,
      DISTRIBUTOR_API_URL: 'http://localhost:4000',
      DISTRIBUTOR_API_TOKEN: 'random-token',
      DISTRIBUTOR_TEST_SUITE: 'test_suite_name',
      DISTRIBUTOR_NODE_INDEX: '0',
      DISTRIBUTOR_NODE_TOTAL: 'abcd',
      DISTRIBUTOR_BUILD_ID: 'build_id',
      DISTRIBUTOR_BRANCH: 'branch',
      DISTRIBUTOR_COMMIT_SHA: 'sha',
    }
    expect(() => require('../src/env')).toThrow()
  })

  it('Should be a correct number after parsing', () => {
    process.env = {
      ...process.env,
      DISTRIBUTOR_API_URL: 'http://localhost:4000',
      DISTRIBUTOR_API_TOKEN: 'random-token',
      DISTRIBUTOR_TEST_SUITE: 'test_suite_name',
      DISTRIBUTOR_NODE_INDEX: '0',
      DISTRIBUTOR_NODE_TOTAL: '4',
      DISTRIBUTOR_BUILD_ID: 'build_id',
      DISTRIBUTOR_BRANCH: 'branch',
      DISTRIBUTOR_COMMIT_SHA: 'sha',
    }

    const {
      DISTRIBUTOR_NODE_TOTAL,
      DISTRIBUTOR_NODE_INDEX,
    } = require('../src/env')
    expect(DISTRIBUTOR_NODE_TOTAL).toEqual(4)
    expect(DISTRIBUTOR_NODE_INDEX).toEqual(0)
  })
})
