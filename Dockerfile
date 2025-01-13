FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y \
		biber \
		latexmk \
		make \
		texlive-science \
		texlive-luatex \
		texlive-latex-extra \
		texlive-extra-utils \
	&& rm -rf /var/lib/apt/lists/*

