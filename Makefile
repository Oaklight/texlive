# Variables
IMAGE_NAME = oaklight/texlive
IMAGE_TAG_LATEST = latest
IMAGE_TAG_SCIENCE = latest-science
DOCKERFILE = Dockerfile

# Default target
all: build

# Build the Docker image with multiple tags
build:
	docker build -t $(IMAGE_NAME):$(IMAGE_TAG_LATEST) -t $(IMAGE_NAME):$(IMAGE_TAG_SCIENCE) -f $(DOCKERFILE) .

# Push the Docker image to a registry with multiple tags
push:
	docker push $(IMAGE_NAME):$(IMAGE_TAG_LATEST)
	docker push $(IMAGE_NAME):$(IMAGE_TAG_SCIENCE)

# Clean up (remove the Docker images)
clean:
	docker rmi $(IMAGE_NAME):$(IMAGE_TAG_LATEST) $(IMAGE_NAME):$(IMAGE_TAG_SCIENCE)

# Help target to show available commands
help:
	@echo "Available targets:"
	@echo "  build   - Build the Docker image with tags: $(IMAGE_TAG_LATEST), $(IMAGE_TAG_SCIENCE)"
	@echo "  push    - Push the Docker image to a registry with tags: $(IMAGE_TAG_LATEST), $(IMAGE_TAG_SCIENCE)"
	@echo "  clean   - Remove the Docker images with tags: $(IMAGE_TAG_LATEST), $(IMAGE_TAG_SCIENCE)"
	@echo "  help    - Show this help message"

.PHONY: all build push clean help