.DEFAULT_GOAL:=help
SHELL:=/bin/bash

ifndef SERVICE
  SERVICE := real-estate-app
endif

ifndef DOCKER_COMPOSE_FILE
  DOCKER_COMPOSE_FILE := docker-compose.yml
endif

ifndef DOCKER_COMPOSE_DOCKELESS_FILE
  DOCKER_COMPOSE_DOCKELESS_FILE := docker-compose.dockerless.yml
endif

ifeq (run,$(firstword $(MAKECMDGOALS)))
  ifndef RUN_ARGS
  	# use the rest as arguments for "run"
  	RUN_ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
  	# ...and turn them into do-nothing targets
  	$(eval $(RUN_ARGS):;@:)
  endif
endif

docker_compose_command := docker compose -f $(DOCKER_COMPOSE_FILE)
docker_compose_dockerless_command := docker compose -f $(DOCKER_COMPOSE_DOCKELESS_FILE)

##@ Containers management

start:  ## Start containers
	$(info Make: Starting containers.)
	@$(docker_compose_command) up -d $(SERVICE)

stop:  ## Stop containers
	$(info Make: Stopping containers.)
	@$(docker_compose_command) stop

down:  ## Down containers
	$(info Make: Shutting down containers.)
	@$(docker_compose_command) down

restart:  ## Restart containers
	$(info Make: Restarting containers.)
	@make -s stop
	@make -s start

reset:  ## Reset containers
	$(info Make: Resetting containers.)
	@make -s down
	@make -s start

run:  ## Run inside delivery-app container
	$(info Make: Running '$(RUN_ARGS)' inside '$(SERVICE)' container.)
	@$(docker_compose_command) run --rm $(SERVICE) $(RUN_ARGS)

clean:  ## Reset docker system
	$(info Make: Resetting docker system.)
	@make -s down
	@docker system prune --volumes --force

##@ App management

build:  ## Build delivery-app image
	$(info Make: Building $(SERVICE) image.)
	@$(docker_compose_command) build $(SERVICE)

prepare_db:  ## Prepare delivery database
	$(info Make: Preparing real-estate database.)
	@make -s run RUN_ARGS='bundle exec rake db:drop db:create db:migrate'

migrate_db:  ## Migrate delivery db
	$(info Make: Migrating real-estate database.)
	@make -s run RUN_ARGS='rake db:migrate'

seed_db:  ## Seed delivery db
	$(info Make: Migrating tracker database.)
	@make -s run RUN_ARGS='rake db:seed'

init:  ## Init delivery-app image
	$(info Make: Initializing $(SERVICE) image.)
	@make -s build
	@make -s run RUN_ARGS='bin/rails db:setup'
	@make -s seed_db

up:  ## Start delivery-app and attach the container
	$(info Make: Starting $(SERVICE) and attaching $(SERVICE) container.)
	@(make -s start && make -s attach 2>&1) | tee /dev/tty | grep -q 'Could not find' && \
		(make -s build && make -s start && make -s attach) || true

attach:  ## Attach to delivery-app container
	$(info Make: Attaching to $(SERVICE) container.)
	@docker attach $(SERVICE)

rspec:  ## Run rspec tests
	$(info Make: Running rspec tests in $(SERVICE) container.)
	@make -s run RUN_ARGS='rspec spec'

bash:  ## Enter bash console
	$(info Make: Entering bash console of $(SERVICE).)
	@make -s run RUN_ARGS='bash'

##@ Dockerless mode. Run app without docker, but services such as db run in docker

dl-server: ## rails server
	$(info Make: Running server)
	@$(docker_compose_dockerless_command) up -d postgres elasticsearch
	bin/dockerless bin/docker-dev-server.sh

dl-s: ## alias rails server
	@make -s dl-server

dl-c: ## rails console
	$(info Make: Running rails console)
	bin/dockerless rails c

dl-db-migrate: ## db:migrate
	$(info Make: Migrate database.)
	bin/dockerless rails db:migrate

dl-db-migrate-status: ## db:migrate:status
	bin/dockerless rails db:migrate:status

dl-db-rollback: ## db:rollback
	$(info Make: Rollback database.)
	bin/dockerless rails db:rollback

dl-rspec:  ## rspec RUN_ARGS=file_path
	$(info Make: Runnig specs.)
	bin/dockerless rspec $(RUN_ARGS)

.PHONY: help

help:  ## Display this help
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m\033[0m\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)
