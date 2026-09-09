# ---- Build stage ----
FROM golang:1.22-bookworm AS build
WORKDIR /src

COPY go.mod go.sum ./
RUN go mod download

COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -o /out/api ./cmd/api

# ---- Run stage ----
FROM gcr.io/distroless/static-debian12
WORKDIR /app
COPY --from=build /out/api .
EXPOSE 8080
ENTRYPOINT ["/app/api"]
