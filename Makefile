DOCKER_USER ?= "dsaenztagarro"
IMAGE = "$(DOCKER_USER)/dev-env-alire" # docker image
CONTAINER = "dev-env-alire" # docker container

LSP_EXE = "./third_party/ada_language_server"
ALIRE_DIR := "$(HOME)/Code/alire"
CURRENT_DIR := $(shell pwd)

# Where the project is bind-mounted inside the container. Username-independent
# (matches the base image's WORKDIR), so it never changes when DEV_USER does.
CONTAINER_WORKDIR = /workspace

.PHONY: third_party image container pause unpause terminal clean help

# alr is fetched (pinned + checksummed) by the Dockerfile now, so only the
# still-vendored Ada Language Server has to be present before a build.
third_party:
	@if [ ! -f $(LSP_EXE) ]; then \
		echo " Error: Executable $(LSP_EXE) does not exist."; \
		exit 1; \
	fi
	@echo "ALIRE_DIR: $(ALIRE_DIR)"

image: third_party
	@echo "  Building image $(IMAGE)..."
	@docker build -t $(IMAGE) .
# -q , quiet

container: image
	@echo "  Starting detached container $(CONTAINER)..."
	@docker run --detach --name $(CONTAINER) --rm -v "$(ALIRE_DIR):$(CONTAINER_WORKDIR)" -w "$(CONTAINER_WORKDIR)" -it $(IMAGE)
# ^
# --rm ,    Automatically remove the container and its associated anonymous volumes when it exits
# -v list , Bind mount a volume
# -p list , Publish a container port to the host (i.e. GDB port)
# -i ,      Keep STDIN open even if not attached (--interactive).
# -t ,      Allocate a pseudo-TTY (--tty).

start:
	@echo "  Starting detached container $(CONTAINER)..."
	@docker run --detach --name $(CONTAINER) --rm -v "$(ALIRE_DIR):$(CONTAINER_WORKDIR)" -w "$(CONTAINER_WORKDIR)" -it $(IMAGE)

stop:
	@echo "  Stopping container $(CONTAINER)..."
	@docker stop $(CONTAINER) || true
	@echo "  Removing container $(CONTAINER)..."
	@docker rm $(CONTAINER) || true

terminal:
	@echo "  Starting terminal on existing container $(CONTAINER)..."
	@docker exec -it $(CONTAINER) /bin/bash

pause:
	@echo "  Pausing container $(CONTAINER)..."
	@docker pause $(CONTAINER)

unpause:
	@echo "  Unpausing container $(CONTAINER)..."
	@docker unpause $(CONTAINER)

clean: stop
	@echo "  Removing image $(IMAGE):latest..."
	@docker rmi $(IMAGE):latest || true
	@echo "Cleanup complete."

help:
	@echo "Targets:"
	@echo "* image\t\tBuild image"
	@echo "* container\t\tBuild container"
	@echo "* terminal\t\tStart terminal"
	@echo "* start\t\tStart detached container"
	@echo "* stop\t\tStop container"
