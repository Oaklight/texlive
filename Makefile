# Variables
IMAGE_NAME = oaklight/texlive

# Optional mirrors (for use behind GFW or slow networks)
REGISTRY_MIRROR ?= docker.io
APK_MIRROR ?=

# Debian image tags (backward-compatible short names + explicit debian- prefix)
IMAGE_TAG_BASE = base
IMAGE_TAG_BASE_CN = base-cn
IMAGE_TAG_BASE_JP = base-jp
IMAGE_TAG_BASE_KR = base-kr
IMAGE_TAG_SCIENCE = science
IMAGE_TAG_SCIENCE_CN = science-cn
IMAGE_TAG_SCIENCE_JP = science-jp
IMAGE_TAG_SCIENCE_KR = science-kr
DEBIAN_TAG_BASE = debian-base
DEBIAN_TAG_BASE_CN = debian-base-cn
DEBIAN_TAG_BASE_JP = debian-base-jp
DEBIAN_TAG_BASE_KR = debian-base-kr
DEBIAN_TAG_SCIENCE = debian-science
DEBIAN_TAG_SCIENCE_CN = debian-science-cn
DEBIAN_TAG_SCIENCE_JP = debian-science-jp
DEBIAN_TAG_SCIENCE_KR = debian-science-kr

# latest -> alpine-science
IMAGE_TAG_LATEST = latest

# Alpine image tags
ALPINE_TAG_BASE = alpine-base
ALPINE_TAG_BASE_CN = alpine-base-cn
ALPINE_TAG_BASE_JP = alpine-base-jp
ALPINE_TAG_BASE_KR = alpine-base-kr
ALPINE_TAG_SCIENCE = alpine-science
ALPINE_TAG_SCIENCE_CN = alpine-science-cn
ALPINE_TAG_SCIENCE_JP = alpine-science-jp
ALPINE_TAG_SCIENCE_KR = alpine-science-kr

TEX_FMT_BINARY = tex-fmt

# Fetch the latest version of tex-fmt
TEX_FMT_VERSION = $(shell curl -s https://api.github.com/repos/WGUNDERWOOD/tex-fmt/releases/latest | grep -oP '"tag_name": "\K[^"]+')
TEX_FMT_URL = https://github.com/WGUNDERWOOD/tex-fmt/releases/download/$(TEX_FMT_VERSION)/tex-fmt-x86_64-linux.tar.gz
TEX_FMT_ALPINE_URL = https://github.com/WGUNDERWOOD/tex-fmt/releases/download/$(TEX_FMT_VERSION)/tex-fmt-x86_64-alpine.tar.gz

# Build args for mirror support
BUILD_ARGS =
ifneq ($(APK_MIRROR),)
BUILD_ARGS += --build-arg APK_MIRROR=$(APK_MIRROR)
endif

# Default target
all: build

# ============================================================
# tex-fmt download
# ============================================================

get-tex-fmt:
	curl -LO $(TEX_FMT_URL)
	tar -xzf tex-fmt-x86_64-linux.tar.gz
	rm tex-fmt-x86_64-linux.tar.gz
	chmod +x $(TEX_FMT_BINARY)

get-tex-fmt-alpine:
	curl -LO $(TEX_FMT_ALPINE_URL)
	tar -xzf tex-fmt-x86_64-alpine.tar.gz
	rm tex-fmt-x86_64-alpine.tar.gz
	chmod +x $(TEX_FMT_BINARY)

# ============================================================
# Debian targets (original)
# ============================================================

build-base: get-tex-fmt
	docker build \
		--build-arg TEX_FMT_BINARY=$(TEX_FMT_BINARY) \
		-t $(IMAGE_NAME):$(IMAGE_TAG_BASE) \
		-t $(IMAGE_NAME):$(DEBIAN_TAG_BASE) \
		-f Dockerfile.base .

build-base-cn: build-base
	docker build \
		-t $(IMAGE_NAME):$(IMAGE_TAG_BASE_CN) \
		-t $(IMAGE_NAME):$(DEBIAN_TAG_BASE_CN) \
		-f Dockerfile.eastasia \
		--build-arg BASE_IMAGE=$(IMAGE_NAME):$(IMAGE_TAG_BASE) \
		.

retag-base-jp-kr: build-base-cn
	docker tag $(IMAGE_NAME):$(IMAGE_TAG_BASE_CN) $(IMAGE_NAME):$(IMAGE_TAG_BASE_JP)
	docker tag $(IMAGE_NAME):$(IMAGE_TAG_BASE_CN) $(IMAGE_NAME):$(IMAGE_TAG_BASE_KR)
	docker tag $(IMAGE_NAME):$(IMAGE_TAG_BASE_CN) $(IMAGE_NAME):$(DEBIAN_TAG_BASE_JP)
	docker tag $(IMAGE_NAME):$(IMAGE_TAG_BASE_CN) $(IMAGE_NAME):$(DEBIAN_TAG_BASE_KR)

build-science: build-base
	docker build \
		-t $(IMAGE_NAME):$(IMAGE_TAG_SCIENCE) \
		-t $(IMAGE_NAME):$(DEBIAN_TAG_SCIENCE) \
		-f Dockerfile.science \
		--build-arg BASE_IMAGE=$(IMAGE_NAME):$(IMAGE_TAG_BASE) \
		.

build-science-cn: build-science
	docker build \
		-t $(IMAGE_NAME):$(IMAGE_TAG_SCIENCE_CN) \
		-t $(IMAGE_NAME):$(DEBIAN_TAG_SCIENCE_CN) \
		-f Dockerfile.eastasia \
		--build-arg BASE_IMAGE=$(IMAGE_NAME):$(IMAGE_TAG_SCIENCE) \
		.

retag-science-jp-kr: build-science-cn
	docker tag $(IMAGE_NAME):$(IMAGE_TAG_SCIENCE_CN) $(IMAGE_NAME):$(IMAGE_TAG_SCIENCE_JP)
	docker tag $(IMAGE_NAME):$(IMAGE_TAG_SCIENCE_CN) $(IMAGE_NAME):$(IMAGE_TAG_SCIENCE_KR)
	docker tag $(IMAGE_NAME):$(IMAGE_TAG_SCIENCE_CN) $(IMAGE_NAME):$(DEBIAN_TAG_SCIENCE_JP)
	docker tag $(IMAGE_NAME):$(IMAGE_TAG_SCIENCE_CN) $(IMAGE_NAME):$(DEBIAN_TAG_SCIENCE_KR)

build: build-base build-base-cn retag-base-jp-kr build-science build-science-cn retag-science-jp-kr

# ============================================================
# Alpine targets
# ============================================================

alpine-build-base: get-tex-fmt-alpine
	docker build \
		--build-arg REGISTRY_MIRROR=$(REGISTRY_MIRROR) \
		--build-arg TEX_FMT_BINARY=$(TEX_FMT_BINARY) \
		$(BUILD_ARGS) \
		-t $(IMAGE_NAME):$(ALPINE_TAG_BASE) \
		-f Dockerfile.alpine-base .

alpine-build-base-cn: alpine-build-base
	docker build \
		--build-arg BASE_IMAGE=$(IMAGE_NAME):$(ALPINE_TAG_BASE) \
		$(BUILD_ARGS) \
		-t $(IMAGE_NAME):$(ALPINE_TAG_BASE_CN) \
		-f Dockerfile.alpine-eastasia .

alpine-retag-base-jp-kr: alpine-build-base-cn
	docker tag $(IMAGE_NAME):$(ALPINE_TAG_BASE_CN) $(IMAGE_NAME):$(ALPINE_TAG_BASE_JP)
	docker tag $(IMAGE_NAME):$(ALPINE_TAG_BASE_CN) $(IMAGE_NAME):$(ALPINE_TAG_BASE_KR)

alpine-build-science: alpine-build-base
	docker build \
		--build-arg BASE_IMAGE=$(IMAGE_NAME):$(ALPINE_TAG_BASE) \
		$(BUILD_ARGS) \
		-t $(IMAGE_NAME):$(ALPINE_TAG_SCIENCE) \
		-t $(IMAGE_NAME):$(IMAGE_TAG_LATEST) \
		-f Dockerfile.alpine-science .

alpine-build-science-cn: alpine-build-science
	docker build \
		--build-arg BASE_IMAGE=$(IMAGE_NAME):$(ALPINE_TAG_SCIENCE) \
		$(BUILD_ARGS) \
		-t $(IMAGE_NAME):$(ALPINE_TAG_SCIENCE_CN) \
		-f Dockerfile.alpine-eastasia .

alpine-retag-science-jp-kr: alpine-build-science-cn
	docker tag $(IMAGE_NAME):$(ALPINE_TAG_SCIENCE_CN) $(IMAGE_NAME):$(ALPINE_TAG_SCIENCE_JP)
	docker tag $(IMAGE_NAME):$(ALPINE_TAG_SCIENCE_CN) $(IMAGE_NAME):$(ALPINE_TAG_SCIENCE_KR)

alpine-build: alpine-build-base alpine-build-base-cn alpine-retag-base-jp-kr alpine-build-science alpine-build-science-cn alpine-retag-science-jp-kr

# ============================================================
# Push
# ============================================================

push:
	docker push $(IMAGE_NAME):$(IMAGE_TAG_BASE)
	docker push $(IMAGE_NAME):$(IMAGE_TAG_BASE_CN)
	docker push $(IMAGE_NAME):$(IMAGE_TAG_BASE_JP)
	docker push $(IMAGE_NAME):$(IMAGE_TAG_BASE_KR)
	docker push $(IMAGE_NAME):$(IMAGE_TAG_SCIENCE)
	docker push $(IMAGE_NAME):$(IMAGE_TAG_SCIENCE_CN)
	docker push $(IMAGE_NAME):$(IMAGE_TAG_SCIENCE_JP)
	docker push $(IMAGE_NAME):$(IMAGE_TAG_SCIENCE_KR)
	docker push $(IMAGE_NAME):$(DEBIAN_TAG_BASE)
	docker push $(IMAGE_NAME):$(DEBIAN_TAG_BASE_CN)
	docker push $(IMAGE_NAME):$(DEBIAN_TAG_BASE_JP)
	docker push $(IMAGE_NAME):$(DEBIAN_TAG_BASE_KR)
	docker push $(IMAGE_NAME):$(DEBIAN_TAG_SCIENCE)
	docker push $(IMAGE_NAME):$(DEBIAN_TAG_SCIENCE_CN)
	docker push $(IMAGE_NAME):$(DEBIAN_TAG_SCIENCE_JP)
	docker push $(IMAGE_NAME):$(DEBIAN_TAG_SCIENCE_KR)

alpine-push:
	docker push $(IMAGE_NAME):$(ALPINE_TAG_BASE)
	docker push $(IMAGE_NAME):$(ALPINE_TAG_BASE_CN)
	docker push $(IMAGE_NAME):$(ALPINE_TAG_BASE_JP)
	docker push $(IMAGE_NAME):$(ALPINE_TAG_BASE_KR)
	docker push $(IMAGE_NAME):$(ALPINE_TAG_SCIENCE)
	docker push $(IMAGE_NAME):$(ALPINE_TAG_SCIENCE_CN)
	docker push $(IMAGE_NAME):$(ALPINE_TAG_SCIENCE_JP)
	docker push $(IMAGE_NAME):$(ALPINE_TAG_SCIENCE_KR)
	docker push $(IMAGE_NAME):$(IMAGE_TAG_LATEST)

push-all: push alpine-push

# ============================================================
# Clean
# ============================================================

clean:
	docker rmi $(IMAGE_NAME):$(IMAGE_TAG_BASE) $(IMAGE_NAME):$(IMAGE_TAG_BASE_CN) $(IMAGE_NAME):$(IMAGE_TAG_BASE_JP) $(IMAGE_NAME):$(IMAGE_TAG_BASE_KR) $(IMAGE_NAME):$(IMAGE_TAG_SCIENCE) $(IMAGE_NAME):$(IMAGE_TAG_SCIENCE_CN) $(IMAGE_NAME):$(IMAGE_TAG_SCIENCE_JP) $(IMAGE_NAME):$(IMAGE_TAG_SCIENCE_KR) || true
	docker rmi $(IMAGE_NAME):$(DEBIAN_TAG_BASE) $(IMAGE_NAME):$(DEBIAN_TAG_BASE_CN) $(IMAGE_NAME):$(DEBIAN_TAG_BASE_JP) $(IMAGE_NAME):$(DEBIAN_TAG_BASE_KR) $(IMAGE_NAME):$(DEBIAN_TAG_SCIENCE) $(IMAGE_NAME):$(DEBIAN_TAG_SCIENCE_CN) $(IMAGE_NAME):$(DEBIAN_TAG_SCIENCE_JP) $(IMAGE_NAME):$(DEBIAN_TAG_SCIENCE_KR) || true
	rm -f $(TEX_FMT_BINARY) $(TEX_FMT_BINARY).tar.gz

alpine-clean:
	docker rmi $(IMAGE_NAME):$(ALPINE_TAG_BASE) $(IMAGE_NAME):$(ALPINE_TAG_BASE_CN) $(IMAGE_NAME):$(ALPINE_TAG_BASE_JP) $(IMAGE_NAME):$(ALPINE_TAG_BASE_KR) $(IMAGE_NAME):$(ALPINE_TAG_SCIENCE) $(IMAGE_NAME):$(ALPINE_TAG_SCIENCE_CN) $(IMAGE_NAME):$(ALPINE_TAG_SCIENCE_JP) $(IMAGE_NAME):$(ALPINE_TAG_SCIENCE_KR) || true
	rm -f $(TEX_FMT_BINARY) $(TEX_FMT_BINARY).tar.gz

clean-all: clean alpine-clean

# ============================================================
# Help
# ============================================================

help:
	@echo "Available targets:"
	@echo ""
	@echo "  Debian:"
	@echo "    build-base           - Build the base Docker image"
	@echo "    build-base-cn        - Build the base CN Docker image"
	@echo "    retag-base-jp-kr     - Retag base CN to base JP and base KR"
	@echo "    build-science        - Build the science Docker image"
	@echo "    build-science-cn     - Build the science CN Docker image"
	@echo "    retag-science-jp-kr  - Retag science CN to science JP and science KR"
	@echo "    build                - Build all Debian images"
	@echo "    push                 - Push all Debian images"
	@echo ""
	@echo "  Alpine:"
	@echo "    alpine-build-base         - Build the Alpine base image"
	@echo "    alpine-build-base-cn      - Build the Alpine base CN image"
	@echo "    alpine-build-science      - Build the Alpine science image"
	@echo "    alpine-build-science-cn   - Build the Alpine science CN image"
	@echo "    alpine-build              - Build all Alpine images"
	@echo "    alpine-push               - Push all Alpine images"
	@echo ""
	@echo "  Common:"
	@echo "    push-all             - Push all images (Debian + Alpine)"
	@echo "    clean                - Remove Debian images and downloaded files"
	@echo "    alpine-clean         - Remove Alpine images and downloaded files"
	@echo "    clean-all            - Remove all images and downloaded files"
	@echo "    help                 - Show this help message"
	@echo ""
	@echo "Variables:"
	@echo "  REGISTRY_MIRROR=<host>  - Docker registry mirror (default: docker.io)"
	@echo "  APK_MIRROR=<host>       - Alpine APK mirror host (e.g., mirrors.tuna.tsinghua.edu.cn)"
	@echo ""
	@echo "Examples:"
	@echo "  make alpine-build"
	@echo "  make alpine-build APK_MIRROR=mirrors.ustc.edu.cn"
	@echo "  make alpine-build REGISTRY_MIRROR=docker.1ms.run APK_MIRROR=mirrors.tuna.tsinghua.edu.cn"

.PHONY: all build build-base build-base-cn retag-base-jp-kr build-science build-science-cn retag-science-jp-kr push clean help
.PHONY: get-tex-fmt get-tex-fmt-alpine
.PHONY: alpine-build alpine-build-base alpine-build-base-cn alpine-retag-base-jp-kr alpine-build-science alpine-build-science-cn alpine-retag-science-jp-kr
.PHONY: alpine-push alpine-clean push-all clean-all
