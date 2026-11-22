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
	@echo "API:    http://localhost:8080/api/v1/health"
	@echo "MySQL:  127.0.0.1:3307 (ab_app / ab_app_pw), local only"

down:
	docker compose down

logs:
	docker compose logs -f api

# Wipes the LOCAL MySQL volume; migrations + dev seed rerun on the next `up`.
# Destroys local data only. Never point it at a shared database.
reseed:
	docker compose down -v
	$(MAKE) up
