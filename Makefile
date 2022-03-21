REPO ?= registry.gitlab.com/acnodal/epic
PREFIX = envoy
SUFFIX = ${USER}-dev

TAG=${REPO}/${PREFIX}:${SUFFIX}
DOCKERFILE=Dockerfile

##@ Default Goal
.PHONY: help
help: ## Display this help
	@echo "Usage:"
	@echo "  make <goal> [VAR=value ...]"
	@echo
	@echo "Variables"
	@echo "  PREFIX Docker tag prefix (useful to set the docker registry)"
	@echo "  SUFFIX Docker tag suffix (the part after ':')"
	@awk 'BEGIN {FS = ":.*##"}; \
		/^[a-zA-Z0-9_-]+:.*?##/ { printf "  %-15s %s\n", $$1, $$2 } \
		/^##@/ { printf "\n%s\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

##@ Development Goals

image: ## Build the Docker image
	docker build --file=${DOCKERFILE} --tag=${TAG} .

install:	image ## Push the image to the repo
	docker push ${TAG}
