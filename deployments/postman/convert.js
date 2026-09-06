const fs = require('fs')
const path = require('path')
const yaml = require('js-yaml')
const converter = require('openapi-to-postmanv2')

const openapiPath = path.resolve(__dirname, '../../05-openapi.yaml')
const outPath = path.resolve(__dirname, 'AB-Learning.full.postman_collection.json')

try {
  const content = fs.readFileSync(openapiPath, 'utf8')
  const openapi = yaml.load(content)

  converter.convert({ type: 'json', data: openapi }, {}, (err, result) => {
    if (err) {
      console.error('Conversion error', err)
      process.exit(1)
    }
    if (!result.result) {
      console.error('Conversion failed', result.reason)
      process.exit(1)
    }
    fs.writeFileSync(outPath, JSON.stringify(result.output[0].data, null, 2), 'utf8')
    console.log('Postman collection written to', outPath)
  })
} catch (e) {
  console.error('Failed:', e)
  process.exit(1)
}
