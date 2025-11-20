.PHONY: help build up down restart logs shell db-shell clean seed backup restore

help:
	@echo "UAEM Evaluation System - Docker Commands"
	@echo ""
	@echo "Available commands:"
	@echo "  make build    - Build all Docker images"
	@echo "  make up       - Start all services"
	@echo "  make down     - Stop all services"
	@echo "  make restart  - Restart all services"
	@echo "  make logs     - View logs from all services"
	@echo "  make shell    - Access backend shell"
	@echo "  make db-shell - Access database shell"
	@echo "  make clean    - Remove all containers and volumes"
	@echo "  make seed     - Seed database with initial data"
	@echo "  make backup   - Backup database"
	@echo "  make restore  - Restore database from backup"

build:
	docker-compose build --no-cache

up:
	docker-compose up -d
	@echo "Services started! Frontend: http://localhost:8080"

down:
	docker-compose down

restart:
	docker-compose restart

logs:
	docker-compose logs -f

shell:
	docker-compose exec backend bash

db-shell:
	docker-compose exec db psql -U postgres -d uaem_evaluation

clean:
	docker-compose down -v
	docker system prune -f

seed:
	docker-compose exec backend python seed_data.py

backup:
	docker-compose exec db pg_dump -U postgres uaem_evaluation > backup_$(shell date +%Y%m%d_%H%M%S).sql
	@echo "Backup created!"

restore:
	@read -p "Enter backup file name: " file; \
	docker-compose exec -T db psql -U postgres uaem_evaluation < $$file
