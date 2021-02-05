GOLANGCI_LINT_IMAGE_NAME = golangci/golangci-lint:latest-alpine
DOCKER_COMPOSE_PROJECT_NAME = hey-grpc-client

.PHONY: build
build:
		mkdir -p "$(CURDIR)/build"
		go build -o "$(CURDIR)/build/client" -ldflags="-s -w"

.PHONY: test
test:
		go test -v ./...

.PHONY: clean
clean:
		rm -rf "$(CURDIR)/build"

.PHONY: lint
lint:
		docker run --rm \
			-v $(CURDIR):/workspace \
			-v $(GOPATH):/go:ro \
			-w /workspace \
			$(GOLANGCI_LINT_IMAGE_NAME) golangci-lint run

.PHONY: fix-lint
fix-lint:
		docker run --rm \
			-v $(CURDIR):/workspace \
			-v $(GOPATH):/go:ro \
			-w /workspace \
			$(GOLANGCI_LINT_IMAGE_NAME) golangci-lint run --fix

.PHONY: build-docker
build-docker:
		docker-compose -p $(DOCKER_COMPOSE_PROJECT_NAME) build

.PHONY: start
start:
		docker-compose -p $(DOCKER_COMPOSE_PROJECT_NAME) up -d

.PHONY: restart
restart:
		docker-compose -p $(DOCKER_COMPOSE_PROJECT_NAME) restart

.PHONY: stop
stop:
		docker-compose -p $(DOCKER_COMPOSE_PROJECT_NAME) stop

.PHONY: terminate
terminate:
		docker-compose -p $(DOCKER_COMPOSE_PROJECT_NAME) down

.PHONY: status
status:
		docker-compose -p $(DOCKER_COMPOSE_PROJECT_NAME) ps -a

.PHONY: logs
logs:
		docker-compose -p $(DOCKER_COMPOSE_PROJECT_NAME) logs

.PHONY: stream-logs
stream-logs:
		docker-compose -p $(DOCKER_COMPOSE_PROJECT_NAME) logs -f
