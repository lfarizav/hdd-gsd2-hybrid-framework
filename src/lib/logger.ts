// Minimal structured logger.
// Replace with pino, winston, or your preferred library.

const LOG_LEVEL = process.env.LOG_LEVEL ?? 'info'

export const logger = {
  info: (msg: string, data?: unknown) => {
    if (['info', 'debug'].includes(LOG_LEVEL)) console.log(JSON.stringify({ level: 'info', msg, ...toObj(data) }))
  },
  warn: (msg: string, data?: unknown) => {
    console.warn(JSON.stringify({ level: 'warn', msg, ...toObj(data) }))
  },
  error: (msg: string, data?: unknown) => {
    console.error(JSON.stringify({ level: 'error', msg, ...toObj(data) }))
  },
  debug: (msg: string, data?: unknown) => {
    if (LOG_LEVEL === 'debug') console.log(JSON.stringify({ level: 'debug', msg, ...toObj(data) }))
  },
}

function toObj(data: unknown): Record<string, unknown> {
  if (data == null) return {}
  if (typeof data === 'object') return data as Record<string, unknown>
  return { data }
}
