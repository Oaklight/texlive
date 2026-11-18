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
    fc-list :lang=ar family 2>/dev/null | grep -qiE "Noto Sans Arabic|Amiri" || { echo "missing an Arabic system font (expected Noto Sans Arabic or Amiri)" >&2; exit 1; }
    fc-list :lang=ru family 2>/dev/null | grep -q . || { echo "missing a Cyrillic-capable system font" >&2; exit 1; }
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

echo "== French (babel) =="
mkdir -p "$work/fr"
cat >"$work/fr/main.tex" <<'TEX'
\documentclass{article}
\usepackage[french]{babel}
\begin{document}
Bonjour, ceci est un test.
\end{document}
TEX
run "$work/fr" latexmk -pdf -interaction=nonstopmode -file-line-error main.tex
test -s "$work/fr/main.pdf"

echo "== Russian (pdflatex, T2A) =="
mkdir -p "$work/ru"
cat >"$work/ru/main.tex" <<'TEX'
\documentclass{article}
\usepackage[T2A]{fontenc}
\usepackage[utf8]{inputenc}
\usepackage[russian]{babel}
\begin{document}
Привет, мир!
\end{document}
TEX
run "$work/ru" latexmk -pdf -interaction=nonstopmode -file-line-error main.tex
test -s "$work/ru/main.pdf"

echo "== Russian (xelatex, system font) =="
mkdir -p "$work/ru-xe"
cat >"$work/ru-xe/main.tex" <<'TEX'
\documentclass{article}
\usepackage{polyglossia}
\setdefaultlanguage{russian}
\newfontfamily\cyrillicfont{DejaVu Serif}
\begin{document}
Привет, мир!
\end{document}
TEX
run "$work/ru-xe" latexmk -xelatex -interaction=nonstopmode -file-line-error main.tex
test -s "$work/ru-xe/main.pdf"

echo "== Arabic (xelatex, system font) =="
mkdir -p "$work/ar"
cat >"$work/ar/main.tex" <<'TEX'
\documentclass{article}
\usepackage{polyglossia}
\setdefaultlanguage{arabic}
\usepackage{fontspec}
% Pick the Arabic font each variant ships: Noto Sans Arabic on Alpine,
% Amiri on Debian. Failing over keeps the test meaningful on both.
\IfFontExistsTF{Noto Sans Arabic}
  {\newfontfamily\arabicfont[Script=Arabic]{Noto Sans Arabic}}
  {\newfontfamily\arabicfont[Script=Arabic]{Amiri}}
\begin{document}
مرحبا بالعالم
\end{document}
TEX
run "$work/ar" latexmk -xelatex -interaction=nonstopmode -file-line-error main.tex
test -s "$work/ar/main.pdf"

echo "smoke: $image OK"
