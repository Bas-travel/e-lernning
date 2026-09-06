# Multi-stage Dockerfile for AB Learning Go API
FROM golang:1.21-alpine AS builder

WORKDIR /src

# Install build dependencies
RUN apk add --no-cache git build-base ca-certificates

# Cache modules
COPY go.mod go.sum ./
RUN go mod download

# Copy source
COPY . .

# Build the binary
WORKDIR /src/cmd/api
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 \
    go build -ldflags="-s -w" -o /app/ab-api

FROM alpine:3.18
RUN apk add --no-cache ca-certificates

COPY --from=builder /app/ab-api /usr/local/bin/ab-api

EXPOSE 8080

ENV PORT=8080

ENTRYPOINT ["/usr/local/bin/ab-api"]
