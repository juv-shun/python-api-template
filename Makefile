DOCKER_COMPOSE_PATH := ./docker-compose.yml

.PHONY: build
build:
	docker-compose -f ${DOCKER_COMPOSE_PATH} build

.PHONY: up
up:
	docker-compose -f ${DOCKER_COMPOSE_PATH} up -d && docker exec -ti trial_app bash -c "pipenv install --dev --system"

.PHONY: stop
stop:
	docker-compose -f ${DOCKER_COMPOSE_PATH} stop

.PHONY: down
down:
	docker-compose -f ${DOCKER_COMPOSE_PATH} down

.PHONY: restart
restart:
	docker-compose -f ${DOCKER_COMPOSE_PATH} restart

.PHONY: unittest
unittest:
	docker exec -ti trial_app bash -c "pytest -v"

.PHONY: build_push
build_push:
	./scripts/deploy/build.sh

.PHONY: deploy
deploy:
	./scripts/deploy/deploy.sh
