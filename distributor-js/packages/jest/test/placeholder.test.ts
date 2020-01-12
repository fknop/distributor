describe('Tests', () => {
  jest.setTimeout(100000)

  it('works', async () => {
    await new Promise(resolve => {
      setTimeout(() => {
        resolve()
      }, 2000)
    })
    expect(1 + 1).toEqual(2)
  })

  it('works2', () => {
    expect(1 + 1).toEqual(2)
  })

  it('works3', () => {
    expect(1 + 1).toEqual(2)
  })
})
