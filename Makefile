# Makefile for common developer tasks
API_DIR=ab-learning-api
DEPLOY_DIR=deployments/docker

.PHONY: up build api-run api-build seed migrate test fmt

up:
	cd $(DEPLOY_DIR) && docker compose up --build

build:
	cd $(DEPLOY_DIR) && docker compose build

api-run:
	cd $(API_DIR) && go run ./cmd/api

api-build:
	cd $(API_DIR) && go build -o bin/ab-api ./cmd/api

seed:
	@echo "Run seed SQL files into local mysql (adjust user/password as needed)"
	mysql -u root -p ablearning < db/seed/seed.sql
	mysql -u root -p ablearning < db/seed/lessons_and_quizzes.sql

migrate:
	@echo "Run migrations (requires golang-migrate). Edit DSN in command before running."
	@migrate -path db/migrations -database "mysql://root:rootpass@tcp(localhost:3306)/ablearning" up

test:
	go test ./...

fmt:
	go fmt ./...
