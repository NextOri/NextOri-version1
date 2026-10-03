import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import fs from 'fs'
import path from 'path'
import { fileURLToPath, pathToFileURL } from 'url'

const __filename = fileURLToPath(import.meta.url)
const __dirname = path.dirname(__filename)

// Charger les variables .env de la racine
const rootEnvPath = path.resolve(__dirname, '../.env')
if (fs.existsSync(rootEnvPath)) {
  const envContent = fs.readFileSync(rootEnvPath, 'utf-8')
  envContent.split('\n').forEach(line => {
    const trimmed = line.trim()
    if (trimmed && !trimmed.startsWith('#') && trimmed.includes('=')) {
      const idx = trimmed.indexOf('=')
      const key = trimmed.substring(0, idx).trim()
      const val = trimmed.substring(idx + 1).trim()
      if (!process.env[key]) {
        process.env[key] = val
      }
    }
  })
}

function apiServerPlugin() {
  return {
    name: 'api-server-middleware',
    configureServer(server) {
      server.middlewares.use(async (req, res, next) => {
        if (!req.url || !req.url.startsWith('/api')) {
          return next()
        }

        try {
          const apiIndexPath = path.resolve(__dirname, '../api/index.js')
          const apiModule = await server.ssrLoadModule(apiIndexPath)
          const handler = apiModule.default

          const executeHandler = async () => {
            res.status = function(code) {
              res.statusCode = code
              return res
            }
            res.json = function(data) {
              res.setHeader('Content-Type', 'application/json')
              res.end(JSON.stringify(data))
              return res
            }
            res.send = function(data) {
              res.end(data)
              return res
            }

            const parsedUrl = new URL(req.url, `http://${req.headers.host || 'localhost'}`)
            req.query = {}
            for (const [key, value] of parsedUrl.searchParams.entries()) {
              req.query[key] = value
            }

            await handler(req, res)
          }

          if (['POST', 'PUT', 'PATCH', 'DELETE'].includes(req.method)) {
            let bodyData = ''
            req.on('data', chunk => {
              bodyData += chunk
            })
            req.on('end', async () => {
              try {
                req.body = bodyData ? JSON.parse(bodyData) : {}
              } catch {
                req.body = bodyData
              }
              await executeHandler()
            })
          } else {
            req.body = {}
            await executeHandler()
          }
        } catch (error) {
          console.error('API middleware error:', error)
          res.statusCode = 500
          res.setHeader('Content-Type', 'application/json')
          res.end(JSON.stringify({ success: false, error: error.message }))
        }
      })
    }
  }
}

// https://vite.dev/config/
export default defineConfig({
  plugins: [react(), apiServerPlugin()],
})

