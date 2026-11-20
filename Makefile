# Raccourcis pour piloter la plateforme Spark locale.
# Lancer `make` (ou `make help`) pour voir les commandes disponibles.

COMPOSE := docker compose --env-file .env -f infra/docker-compose.yml

# Valeurs par défaut, surchargeables : make logs SERVICE=spark-history TAIL=50
SERVICE ?= spark-connect
TAIL ?= 100
JOB ?= jobs/hello_world.py
SUBMIT_ARGS ?= --executor-cores 1 --executor-memory 512m

.DEFAULT_GOAL := help
.PHONY: help build up down restart ps logs follow submit shell ui

help: ## Affiche cette aide
	@grep -E '^[a-zA-Z_-]+:.*## ' $(MAKEFILE_LIST) \
		| awk 'BEGIN {FS = ":.*## "}; {printf "  \033[36m%-10s\033[0m %s\n", $$1, $$2}'

build: ## Construit l'image Spark (dtp-spark)
	$(COMPOSE) build spark-master

up: ## Démarre le cluster (master, workers, connect, history)
	$(COMPOSE) up -d

down: ## Arrête et supprime les conteneurs (les données dans data/ sont conservées)
	$(COMPOSE) down

restart: ## Redémarre un service : make restart SERVICE=spark-connect
	$(COMPOSE) up -d --force-recreate $(SERVICE)

ps: ## Affiche l'état des conteneurs
	$(COMPOSE) ps -a

logs: ## Dernières lignes de logs : make logs SERVICE=spark-history TAIL=50
	$(COMPOSE) logs --tail=$(TAIL) $(SERVICE)

follow: ## Suit les logs en direct (Ctrl+C pour sortir) : make follow SERVICE=spark-master
	$(COMPOSE) logs -f --tail=$(TAIL) $(SERVICE)

submit: ## Lance un job batch : make submit JOB=jobs/mon_job.py
	$(COMPOSE) run --rm submit $(SUBMIT_ARGS) /opt/project/$(JOB)

shell: ## Ouvre un terminal bash dans un service : make shell SERVICE=spark-master
	$(COMPOSE) exec $(SERVICE) bash

ui: ## Affiche les URLs des interfaces web
	@echo "  Spark Master   http://localhost:8080"
	@echo "  Worker 1       http://localhost:8081"
	@echo "  Worker 2       http://localhost:8082"
	@echo "  Spark Connect  http://localhost:4040  (UI)  |  sc://localhost:15002  (client)"
	@echo "  History        http://localhost:18080"
