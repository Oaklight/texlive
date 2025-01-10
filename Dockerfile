FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y \
		biber \
		latexmk \
		make \
		texlive-science \
	&& rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get install -y \
		texlive-luatex \
		texlive-latex-extra \
	&& rm -rf /var/lib/apt/lists/*

