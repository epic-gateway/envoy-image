REPO ?= quay.io/epic-gateway
PREFIX ?= envoy
SUFFIX ?= ${USER}-dev

TAG ?= ${REPO}/${PREFIX}:${SUFFIX}

##@ Default Goal
.PHONY: help
help: ## Display this help
	@echo "Usage:"
	@echo "  make <goal> [VAR=value ...]"
	@echo
	@echo "Variables"
	@echo "  REPO   The registry part of the Docker tag"
	@echo "  PREFIX Image tag prefix (usually the image name)"
	@echo "  SUFFIX Image tag suffix (the part after ':')"
	@awk 'BEGIN {FS = ":.*##"}; \
		/^[a-zA-Z0-9_-]+:.*?##/ { printf "  %-15s %s\n", $$1, $$2 } \
		/^##@/ { printf "\n%s\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

##@ Development Goals

.PHONY: image-build
image-build: ## Build the Docker image
	docker build --tag=${TAG} ${DOCKER_BUILD_OPTIONS} .

.PHONY: image-test
image-push:	## Push the image to the repo
	docker push ${TAG}
