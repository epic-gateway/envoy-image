REPO=registry.gitlab.com/acnodal
PREFIX = envoy-for-egw
SUFFIX = ${USER}-dev
SHELL:=/bin/bash

TAG=${REPO}/${PREFIX}:${SUFFIX}
DOCKERFILE=Dockerfile

##@ Default Goal
.PHONY: help
help: ## Display this help
	@echo -e "Usage:\n  make <goal> [VAR=value ...]"
	@echo -e "\nVariables"
	@echo -e "  PREFIX Docker tag prefix (useful to set the docker registry)"
	@echo -e "  SUFFIX Docker tag suffix (the part after ':')"
	@awk 'BEGIN {FS = ":.*##"}; \
		/^[a-zA-Z0-9_-]+:.*?##/ { printf "  %-15s %s\n", $$1, $$2 } \
		/^##@/ { printf "\n%s\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

##@ Development Goals

image: ## Build the Docker image
	@docker build --file=${DOCKERFILE} --tag=${TAG} .

install:	image ## Push the image to the repo
	docker push ${TAG}
