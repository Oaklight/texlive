# ==== Base Image ====
FROM debian:bookworm-slim AS base

# Install required packages for the base version
RUN apt-get update && apt-get install -y \
        biber \
        latexmk \
        make \
        texlive-plain-generic \
        texlive-luatex \
    && rm -rf /var/lib/apt/lists/*

# Copy the tex-fmt binary (downloaded by the Makefile)
ARG TEX_FMT_BINARY
COPY ${TEX_FMT_BINARY} /usr/local/bin/tex-fmt
RUN chmod +x /usr/local/bin/tex-fmt

# ==== Base CN Image ====
FROM base AS base-cn

# Add Chinese language support
RUN apt-get update && apt-get install -y \
        texlive-lang-chinese \
    && rm -rf /var/lib/apt/lists/*

# ==== Science Image ====
FROM base AS science

# Install additional packages for the science version
RUN apt-get update && apt-get install -y \
        texlive-science \
        texlive-latex-extra \
        texlive-extra-utils \
    && rm -rf /var/lib/apt/lists/*

# ==== Science CN Image ====
FROM science AS science-cn

# Add Chinese language support
RUN apt-get update && apt-get install -y \
        texlive-lang-chinese \
    && rm -rf /var/lib/apt/lists/*