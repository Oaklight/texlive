#!/bin/sh
# Smoke-test a texlive image.
#
# Usage: sh test/smoke.sh <image>
#
# Compiles the UChicago template, a CJK document, and a biblatex document,
# then checks that the expected tools are present.

set -eu

image=${1:?usage: smoke.sh <image>}
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT

run() {
	dir=$1
	shift
	docker run --rm \
		-u "$(id -u):$(id -g)" \
		-e HOME=/tmp \
		-v "$dir:/workspace" \
		-w /workspace \
		"$image" "$@"
}

echo "== tools =="
docker run --rm "$image" sh -c '
    for t in latexmk biber bibtex synctex; do
        command -v "$t" >/dev/null 2>&1 || { echo "missing: $t" >&2; exit 1; }
    done
    command -v tex-fmt >/dev/null 2>&1 || echo "note: tex-fmt not installed (non-amd64 build)"
'

echo "== UChicago thesis =="
cp -r test-uchicago "$work/uchicago"
find "$work/uchicago" -maxdepth 1 -type f -name 'thesis.*' ! -name 'thesis.tex' -delete
run "$work/uchicago" latexmk -pdf -interaction=nonstopmode -file-line-error thesis.tex
test -s "$work/uchicago/thesis.pdf"

echo "== CJK + SyncTeX =="
mkdir -p "$work/cjk"
cat >"$work/cjk/main.tex" <<'TEX'
\documentclass{ctexart}
\begin{document}
中文测试 Hello \LaTeX
\end{document}
TEX
run "$work/cjk" latexmk -xelatex -synctex=1 -interaction=nonstopmode -file-line-error main.tex
test -s "$work/cjk/main.pdf"
test -s "$work/cjk/main.synctex.gz"

echo "== biblatex + biber =="
mkdir -p "$work/bib"
cat >"$work/bib/main.tex" <<'TEX'
\documentclass{article}
\usepackage[backend=biber]{biblatex}
\addbibresource{refs.bib}
\begin{document}
Cite \cite{key}.
\printbibliography
\end{document}
TEX
cat >"$work/bib/refs.bib" <<'BIB'
@book{key, author={Doe, Jane}, title={Test}, year={2020}, publisher={Example}}
BIB
run "$work/bib" latexmk -pdf -interaction=nonstopmode -file-line-error main.tex
test -s "$work/bib/main.pdf"

echo "smoke: $image OK"
