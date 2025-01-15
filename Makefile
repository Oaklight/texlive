# Variables
IMAGE_NAME = oaklight/texlive
IMAGE_TAG_BASE = base
IMAGE_TAG_BASE_CN = base-cn
IMAGE_TAG_BASE_JP = base-jp
IMAGE_TAG_BASE_KR = base-kr
IMAGE_TAG_SCIENCE = science
IMAGE_TAG_SCIENCE_CN = science-cn
IMAGE_TAG_SCIENCE_JP = science-jp
IMAGE_TAG_SCIENCE_KR = science-kr
IMAGE_TAG_LATEST_BASE = latest-base
IMAGE_TAG_LATEST_SCIENCE = latest-science
IMAGE_TAG_LATEST = latest

TEX_FMT_BINARY = tex-fmt

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

# Build the base Docker image
build-base: get-tex-fmt
	docker build \
		--build-arg TEX_FMT_BINARY=$(TEX_FMT_BINARY) \
		-t $(IMAGE_NAME):$(IMAGE_TAG_BASE) \
		-t $(IMAGE_NAME):$(IMAGE_TAG_LATEST_BASE) \
		-f Dockerfile.base .

# Build the base CN Docker image
build-base-cn: build-base
	docker build \
		-t $(IMAGE_NAME):$(IMAGE_TAG_BASE_CN) \
		-f Dockerfile.eastasia \
		--build-arg BASE_IMAGE=$(IMAGE_NAME):$(IMAGE_TAG_BASE) \
		.

# Retag base CN to base JP and base KR
retag-base-jp-kr: build-base-cn
	docker tag $(IMAGE_NAME):$(IMAGE_TAG_BASE_CN) $(IMAGE_NAME):$(IMAGE_TAG_BASE_JP)
	docker tag $(IMAGE_NAME):$(IMAGE_TAG_BASE_CN) $(IMAGE_NAME):$(IMAGE_TAG_BASE_KR)

# Build the science Docker image
build-science: build-base
	docker build \
		-t $(IMAGE_NAME):$(IMAGE_TAG_SCIENCE) \
		-t $(IMAGE_NAME):$(IMAGE_TAG_LATEST_SCIENCE) \
		-t $(IMAGE_NAME):$(IMAGE_TAG_LATEST) \
		-f Dockerfile.science \
		--build-arg BASE_IMAGE=$(IMAGE_NAME):$(IMAGE_TAG_BASE) \
		.

# Build the science CN Docker image
build-science-cn: build-science
	docker build \
		-t $(IMAGE_NAME):$(IMAGE_TAG_SCIENCE_CN) \
		-f Dockerfile.eastasia \
		--build-arg BASE_IMAGE=$(IMAGE_NAME):$(IMAGE_TAG_SCIENCE) \
		.

# Retag science CN to science JP and science KR
retag-science-jp-kr: build-science-cn
	docker tag $(IMAGE_NAME):$(IMAGE_TAG_SCIENCE_CN) $(IMAGE_NAME):$(IMAGE_TAG_SCIENCE_JP)
	docker tag $(IMAGE_NAME):$(IMAGE_TAG_SCIENCE_CN) $(IMAGE_NAME):$(IMAGE_TAG_SCIENCE_KR)

# Build all images
build: build-base build-base-cn retag-base-jp-kr build-science build-science-cn retag-science-jp-kr

# Push all images to a registry
push:
	docker push $(IMAGE_NAME):$(IMAGE_TAG_BASE)
	docker push $(IMAGE_NAME):$(IMAGE_TAG_BASE_CN)
	docker push $(IMAGE_NAME):$(IMAGE_TAG_BASE_JP)
	docker push $(IMAGE_NAME):$(IMAGE_TAG_BASE_KR)
	docker push $(IMAGE_NAME):$(IMAGE_TAG_SCIENCE)
	docker push $(IMAGE_NAME):$(IMAGE_TAG_SCIENCE_CN)
	docker push $(IMAGE_NAME):$(IMAGE_TAG_SCIENCE_JP)
	docker push $(IMAGE_NAME):$(IMAGE_TAG_SCIENCE_KR)
	docker push $(IMAGE_NAME):$(IMAGE_TAG_LATEST_BASE)
	docker push $(IMAGE_NAME):$(IMAGE_TAG_LATEST_SCIENCE)
	docker push $(IMAGE_NAME):$(IMAGE_TAG_LATEST)

# Clean up (remove the Docker images, downloaded files)
clean:
	docker rmi $(IMAGE_NAME):$(IMAGE_TAG_BASE) $(IMAGE_NAME):$(IMAGE_TAG_BASE_CN) $(IMAGE_NAME):$(IMAGE_TAG_BASE_JP) $(IMAGE_NAME):$(IMAGE_TAG_BASE_KR) $(IMAGE_NAME):$(IMAGE_TAG_SCIENCE) $(IMAGE_NAME):$(IMAGE_TAG_SCIENCE_CN) $(IMAGE_NAME):$(IMAGE_TAG_SCIENCE_JP) $(IMAGE_NAME):$(IMAGE_TAG_SCIENCE_KR) || true
	docker rmi $(IMAGE_NAME):$(IMAGE_TAG_LATEST_BASE) $(IMAGE_NAME):$(IMAGE_TAG_LATEST_SCIENCE) $(IMAGE_NAME):$(IMAGE_TAG_LATEST) || true
	rm -f $(TEX_FMT_BINARY) $(TEX_FMT_BINARY).tar.gz

# Help target to show available commands
help:
	@echo "Available targets:"
	@echo "  build-base      - Build the base Docker image"
	@echo "  build-base-cn   - Build the base CN Docker image"
	@echo "  retag-base-jp-kr - Retag base CN to base JP and base KR"
	@echo "  build-science   - Build the science Docker image"
	@echo "  build-science-cn - Build the science CN Docker image"
	@echo "  retag-science-jp-kr - Retag science CN to science JP and science KR"
	@echo "  build           - Build all Docker images"
	@echo "  push            - Push all Docker images to a registry"
	@echo "  clean           - Remove the Docker images, downloaded files"
	@echo "  help            - Show this help message"

.PHONY: all build build-base build-base-cn retag-base-jp-kr build-science build-science-cn retag-science-jp-kr push clean help