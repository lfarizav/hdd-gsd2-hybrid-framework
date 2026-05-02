describe('logger (default LOG_LEVEL=info)', () => {
  let logSpy: jest.SpyInstance
  let warnSpy: jest.SpyInstance
  let errorSpy: jest.SpyInstance
  let logger: typeof import('../../src/lib/logger').logger

  beforeEach(async () => {
    jest.resetModules()
    delete process.env['LOG_LEVEL']
    logger = (await import('../../src/lib/logger')).logger
    logSpy = jest.spyOn(console, 'log').mockImplementation(() => undefined)
    warnSpy = jest.spyOn(console, 'warn').mockImplementation(() => undefined)
    errorSpy = jest.spyOn(console, 'error').mockImplementation(() => undefined)
  })

  afterEach(() => jest.restoreAllMocks())

  it('exposes info, warn, error, debug methods', () => {
    expect(typeof logger.info).toBe('function')
    expect(typeof logger.warn).toBe('function')
    expect(typeof logger.error).toBe('function')
    expect(typeof logger.debug).toBe('function')
  })

  it('info() calls console.log with structured JSON', () => {
    logger.info('hello')
    expect(logSpy).toHaveBeenCalledTimes(1)
    const parsed = JSON.parse(logSpy.mock.calls[0][0])
    expect(parsed).toMatchObject({ level: 'info', msg: 'hello' })
  })

  it('info() merges object data into the log entry', () => {
    logger.info('with data', { userId: '42' })
    const parsed = JSON.parse(logSpy.mock.calls[0][0])
    expect(parsed).toMatchObject({ level: 'info', msg: 'with data', userId: '42' })
  })

  it('info() wraps non-object data under "data" key', () => {
    logger.info('scalar', 'some string')
    const parsed = JSON.parse(logSpy.mock.calls[0][0])
    expect(parsed).toMatchObject({ level: 'info', msg: 'scalar', data: 'some string' })
  })

  it('info() handles null data gracefully', () => {
    logger.info('null data', null)
    const parsed = JSON.parse(logSpy.mock.calls[0][0])
    expect(parsed).toMatchObject({ level: 'info', msg: 'null data' })
  })

  it('warn() always logs via console.warn', () => {
    logger.warn('a warning')
    expect(warnSpy).toHaveBeenCalledTimes(1)
    const parsed = JSON.parse(warnSpy.mock.calls[0][0])
    expect(parsed).toMatchObject({ level: 'warn', msg: 'a warning' })
  })

  it('error() always logs via console.error', () => {
    logger.error('an error', new Error('boom'))
    expect(errorSpy).toHaveBeenCalledTimes(1)
    const parsed = JSON.parse(errorSpy.mock.calls[0][0])
    expect(parsed).toMatchObject({ level: 'error', msg: 'an error' })
  })

  it('debug() is silent when LOG_LEVEL is "info"', () => {
    logger.debug('hidden')
    expect(logSpy).not.toHaveBeenCalled()
  })
})

describe('logger with LOG_LEVEL=debug', () => {
  let logSpy: jest.SpyInstance
  let logger: typeof import('../../src/lib/logger').logger

  beforeEach(async () => {
    jest.resetModules()
    process.env['LOG_LEVEL'] = 'debug'
    logger = (await import('../../src/lib/logger')).logger
    logSpy = jest.spyOn(console, 'log').mockImplementation(() => undefined)
    jest.spyOn(console, 'warn').mockImplementation(() => undefined)
    jest.spyOn(console, 'error').mockImplementation(() => undefined)
  })

  afterEach(() => {
    jest.restoreAllMocks()
    delete process.env['LOG_LEVEL']
  })

  it('debug() calls console.log when LOG_LEVEL is "debug"', () => {
    logger.debug('visible debug')
    expect(logSpy).toHaveBeenCalledTimes(1)
    const parsed = JSON.parse(logSpy.mock.calls[0][0])
    expect(parsed).toMatchObject({ level: 'debug', msg: 'visible debug' })
  })

  it('info() also logs when LOG_LEVEL is "debug"', () => {
    logger.info('also visible')
    expect(logSpy).toHaveBeenCalledTimes(1)
  })
})
