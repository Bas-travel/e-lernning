# Generating Postman collection from OpenAPI

This folder contains a small script to convert `05-openapi.yaml` into a Postman collection.

Requirements:

- Node.js (16+)

Usage:

```bash
cd deployments/postman
npm install
npm run generate
# outputs: AB-Learning.full.postman_collection.json
```

You can then import `AB-Learning.full.postman_collection.json` into Postman.
