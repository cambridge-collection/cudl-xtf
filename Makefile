SHELL = /bin/bash
.SHELLFLAGS=-o errexit -c
COMMIT_TAG = $(shell git describe --exact-match HEAD 2>/dev/null)
COMMIT_SHORT_HASH = $(shell git rev-parse --short=4 HEAD)
COMMIT_FULL_HASH = $(shell git rev-parse HEAD)
DOCKER_IMAGE_NAME=camdl/cudl-xtf

ensure-clean-checkout:
# Refuse to build a package with local modifications, as the package may end up
# containing the modifications rather than the committed state.
	@DIRTY_FILES="$$(git status --porcelain)" ; \
	if [ "$$DIRTY_FILES" != "" ]; then \
		echo "Error: git repo has uncommitted changes, refusing to build as the result may not be reproducible" ; \
		echo "$$DIRTY_FILES" ; \
		exit 1 ; \
	fi

docker-image: ensure-clean-checkout
	docker image build \
		$(if $(COMMIT_TAG), --tag "$(DOCKER_IMAGE_NAME):$(COMMIT_TAG)") \
		--tag "$(DOCKER_IMAGE_NAME):$(COMMIT_SHORT_HASH)" \
		--build-arg "COMMIT_FULL_HASH=$(COMMIT_FULL_HASH)" .
