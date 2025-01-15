# Variables
IMAGE_NAME = oaklight/texlive
IMAGE_TAG_BASE = base
IMAGE_TAG_BASE_CN = base-cn
IMAGE_TAG_SCIENCE = science
IMAGE_TAG_SCIENCE_CN = science-cn
IMAGE_TAG_LATEST_BASE = latest-base
IMAGE_TAG_LATEST_SCIENCE = latest-science
IMAGE_TAG_LATEST = latest
DOCKERFILE = Dockerfile

TEX_FMT_BINARY = tex-fmt
BUILD_CONTEXT = build-context

# Fetch the latest version of tex-fmt
TEX_FMT_VERSION = $(shell curl -s https://api.github.com/repos/WGUNDERWOOD/tex-fmt/releases/latest | grep -oP '"tag_name": "\K[^"]+')
TEX_FMT_URL = https://github.com/WGUNDERWOOD/tex-fmt/releases/download/$(TEX_FMT_VERSION)/tex-fmt-x86_64-linux.tar.gz

# Default target
all: build

# Download and extract the tex-fmt binary
get-tex-fmt:
	curl -LO $(TEX_FMT_URL)
	tar -xzf tex-fmt-x86_64-linux.tar.gz
	rm tex-fmt-x86_64-linux.tar.gz
	chmod +x $(TEX_FMT_BINARY)

# Prepare the build context
build-context: get-tex-fmt
	mkdir -p $(BUILD_CONTEXT)
	cp $(TEX_FMT_BINARY) $(BUILD_CONTEXT)/
	cp $(DOCKERFILE) $(BUILD_CONTEXT)/

# Build the base Docker image
build-base: build-context
	docker build \
		--build-arg TEX_FMT_BINARY=$(TEX_FMT_BINARY) \
		-t $(IMAGE_NAME):$(IMAGE_TAG_BASE) \
		-t $(IMAGE_NAME):$(IMAGE_TAG_LATEST_BASE) \
		--target base \
		-f $(BUILD_CONTEXT)/$(DOCKERFILE) \
		$(BUILD_CONTEXT)

# Build the base CN Docker image
build-base-cn: build-base
	docker build \
		-t $(IMAGE_NAME):$(IMAGE_TAG_BASE_CN) \
		--target base-cn \
		-f $(BUILD_CONTEXT)/$(DOCKERFILE) \
		$(BUILD_CONTEXT)

# Build the science Docker image
build-science: build-base
	docker build \
		-t $(IMAGE_NAME):$(IMAGE_TAG_SCIENCE) \
		-t $(IMAGE_NAME):$(IMAGE_TAG_LATEST_SCIENCE) \
		-t $(IMAGE_NAME):$(IMAGE_TAG_LATEST) \
		--target science \
		-f $(BUILD_CONTEXT)/$(DOCKERFILE) \
		$(BUILD_CONTEXT)

# Build the science CN Docker image
build-science-cn: build-science
	docker build \
		-t $(IMAGE_NAME):$(IMAGE_TAG_SCIENCE_CN) \
		--target science-cn \
		-f $(BUILD_CONTEXT)/$(DOCKERFILE) \
		$(BUILD_CONTEXT)

# Build all images
build: build-base build-base-cn build-science build-science-cn

# Push all images to a registry
push:
	docker push $(IMAGE_NAME):$(IMAGE_TAG_BASE)
	docker push $(IMAGE_NAME):$(IMAGE_TAG_BASE_CN)
	docker push $(IMAGE_NAME):$(IMAGE_TAG_SCIENCE)
	docker push $(IMAGE_NAME):$(IMAGE_TAG_SCIENCE_CN)
	docker push $(IMAGE_NAME):$(IMAGE_TAG_LATEST_BASE)
	docker push $(IMAGE_NAME):$(IMAGE_TAG_LATEST_SCIENCE)
	docker push $(IMAGE_NAME):$(IMAGE_TAG_LATEST)

# Clean up (remove the Docker images, downloaded files, and build context)
clean:
	docker rmi $(IMAGE_NAME):$(IMAGE_TAG_BASE) $(IMAGE_NAME):$(IMAGE_TAG_BASE_CN) $(IMAGE_NAME):$(IMAGE_TAG_SCIENCE) $(IMAGE_NAME):$(IMAGE_TAG_SCIENCE_CN) || true
	docker rmi $(IMAGE_NAME):$(IMAGE_TAG_LATEST_BASE) $(IMAGE_NAME):$(IMAGE_TAG_LATEST_SCIENCE) $(IMAGE_NAME):$(IMAGE_TAG_LATEST) || true
	rm -f $(TEX_FMT_BINARY) $(TEX_FMT_BINARY).tar.gz
	rm -rf $(BUILD_CONTEXT)

# Help target to show available commands
help:
	@echo "Available targets:"
	@echo "  build-base      - Build the base Docker image"
	@echo "  build-base-cn   - Build the base CN Docker image"
	@echo "  build-science   - Build the science Docker image"
	@echo "  build-science-cn - Build the science CN Docker image"
	@echo "  build           - Build all Docker images"
	@echo "  push            - Push all Docker images to a registry"
	@echo "  clean           - Remove the Docker images, downloaded files, and build context"
	@echo "  help            - Show this help message"

.PHONY: all build build-base build-base-cn build-science build-science-cn push clean help