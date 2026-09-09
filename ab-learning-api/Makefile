.PHONY: run build test vet fmt up down logs reseed

# Local dev: requires a running MySQL (see `make up` for one via Docker) and
# a .env file (copy .env.example).
run:
	go run ./cmd/api

build:
	go build -o bin/api ./cmd/api

test:
	go test ./...

vet:
	go vet ./...

fmt:
	gofmt -l .

# --- Docker Compose (MySQL + API together) ---

up:
	docker compose up --build -d
	@echo "API:    http://localhost:8080/health"
	@echo "MySQL:  localhost:3306 (ab_app / ab_app_pw)"

down:
	docker compose down

logs:
	docker compose logs -f api

# Wipes the MySQL volume so db/init/*.sql reruns from scratch on next `up`.
# Use after editing 04-schema.sql or seed.sql during development.
reseed:
	docker compose down -v
	$(MAKE) up
