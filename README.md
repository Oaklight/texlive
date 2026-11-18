# texlive

[中文版](./README_zh.md)

Customized TeX Live Docker images for LaTeX compilation. Available in both Debian and Alpine variants.

## DockerHub Image

* [oaklight/texlive](https://hub.docker.com/r/oaklight/texlive)

## Why This Image?

This Docker image ensures that you can compile LaTeX documents locally even when you cannot connect to Overleaf. It provides a consistent and reproducible environment for LaTeX compilation, including all necessary packages and tools.

## Available Tags

| Tag | Base | TeX Live | Description |
|-----|------|----------|-------------|
| `latest` | Alpine 3.24 | 2026 | Alias for `alpine-science` |
| **Alpine** | | | |
| `alpine-base` | Alpine 3.24 | 2026 | Core LaTeX + LuaTeX + XeTeX + biber |
| `alpine-science` | Alpine 3.24 | 2026 | + science/math/fonts packages |
| `alpine-base-cn` | Alpine 3.24 | 2026 | Base + Chinese (ctex, xeCJK, CJKutf8) |
| `alpine-science-cn` | Alpine 3.24 | 2026 | Science + Chinese |
| `alpine-base-jp` | Alpine 3.24 | 2026 | Base + Japanese (luatexja, platex, uplatex) |
| `alpine-science-jp` | Alpine 3.24 | 2026 | Science + Japanese |
| `alpine-base-kr` | Alpine 3.24 | 2026 | Base + Korean (kotex, nanumtype1) |
| `alpine-science-kr` | Alpine 3.24 | 2026 | Science + Korean |
| **Debian** | | | |
| `debian-base` / `base` | Debian trixie | 2024 | Core LaTeX + LuaTeX + XeTeX + biber |
| `debian-science` / `science` | Debian trixie | 2024 | + science/math/fonts packages |
| `debian-base-cn` / `base-cn` | Debian trixie | 2024 | Base + Chinese |
| `debian-science-cn` / `science-cn` | Debian trixie | 2024 | Science + Chinese |
| `debian-base-jp` / `base-jp` | Debian trixie | 2024 | Base + Japanese |
| `debian-science-jp` / `science-jp` | Debian trixie | 2024 | Science + Japanese |
| `debian-base-kr` / `base-kr` | Debian trixie | 2024 | Base + Korean |
| `debian-science-kr` / `science-kr` | Debian trixie | 2024 | Science + Korean |

> Each language variant installs the language-specific TeX packages for that country. CN/JP/KR images are independently built with different contents.
>
> **Platform support:** Alpine and Debian images are published for `linux/amd64` and `linux/arm64`. The `tex-fmt` binary is only available for Alpine `amd64`; Alpine `arm64` images omit it.

## Features

* **Two base OS choices**: Alpine (smaller, newer TeX Live) and Debian (backward-compatible).
* Pre-configured with `pdflatex`, `lualatex`, `xelatex`, `latexmk`, `biber`, and other essential LaTeX tools.
* Includes [`tex-fmt`](https://github.com/WGUNDERWOOD/tex-fmt) for LaTeX source formatting.
* Includes common LaTeX packages for academic writing (e.g., `natbib`, `graphicx`, `amsmath`). The `ucetd` class is not bundled; see [`test-uchicago/`](./test-uchicago/) for a working example.
* Optimized for use with VSCode's LaTeX Workshop extension.
* CI/CD via GitHub Actions for automated builds and pushes.
* CI generates SPDX JSON SBOMs for each published image (primary tag) and uploads them as workflow artifacts. Alias tags such as `latest` and `debian-*` share the same digest and SBOM, so they are not scanned separately. SBOMs are not embedded in the image manifest or attestation index. SBOM generation uses a digest-pinned `anchore/syft` container and retries transient failures.

## How to Use with VSCode LaTeX Workshop

### Prerequisites

1. Install [Docker](https://www.docker.com/).
2. Install the [LaTeX Workshop](https://marketplace.visualstudio.com/items?itemName=James-Yu.latex-workshop) extension in VSCode.

### Configuration

Add the following settings to your `settings.json` in VSCode to use the Docker image for LaTeX compilation:

```json
"latex-workshop.docker.enabled": true,
"latex-workshop.docker.image.latex": "oaklight/texlive:latest",
"latex-workshop.latex.clean.subfolder.enabled": true,
"latex-workshop.latex.recipes": [
  {
    "name": "latexmk",
    "tools": [
      "latexmk"
    ]
  }
],
"latex-workshop.latex.tools": [
  {
    "name": "latexmk",
    "command": "latexmk",
    "args": [
      "-synctex=1",
      "-interaction=nonstopmode",
      "-file-line-error",
      "-lualatex",
      "-outdir=%OUTDIR%",
      "%DOC%"
    ],
    "env": {}
  }
],
"latex-workshop.latex.autoBuild.run": "onSave",
"latex-workshop.latex.clean.method": "glob"
```

### Steps

1. Pull the Docker image:

```bash
docker pull oaklight/texlive:latest
```

2. Open your LaTeX project in VSCode.
3. Save your `settings.json` with the above configuration.
4. Open a `.tex` file and start editing. The LaTeX Workshop extension will automatically use the Docker image for compilation.

## Building Locally

### Debian images

```bash
make build
```

### Alpine images

```bash
make alpine-build
```

### Using mirrors (for users in China)

```bash
make alpine-build REGISTRY_MIRROR=docker.1ms.run APK_MIRROR=mirrors.tuna.tsinghua.edu.cn
```

### Pushing images

```bash
make push-all    # push both Debian and Alpine
make push        # push Debian only
make alpine-push # push Alpine only
```

### Cleaning up

```bash
make clean-all   # remove all images
make clean       # remove Debian images only
make alpine-clean # remove Alpine images only
```

Run `make help` for a full list of targets and variables.

## Supported LaTeX Features

* Compilation with `pdflatex`, `lualatex`, `xelatex`, and `latexmk`.
* A working University of Chicago thesis example under [`test-uchicago/`](./test-uchicago/) (the `ucetd` class is not installed in the image).
* Common packages like `natbib`, `graphicx`, `amsmath`, and more.
* CJK language support (Chinese, Japanese, Korean) in `-cn` / `-jp` / `-kr` variants.

## Runtime notes

* The images run as `root` by default. When you mount a project directory, pass the host UID/GID so generated files stay editable:

  ```bash
  docker run --rm --user "$(id -u):$(id -g)" -e HOME=/tmp \
    -v "$PWD:/workspace" -w /workspace oaklight/texlive:latest latexmk -pdf main.tex
  ```

* Alpine images use the distro TeX Live packages, so `tlmgr` is absent. Debian images ship `tlmgr`, but it runs in user mode and cannot update the system installation. Pull a newer image instead.
* `minted` does not work out of the box: Alpine has no Python/LatexMinted, Debian has no Pygments, and the default recipe does not pass `-shell-escape`. Use `listings` or `tex-fmt` instead.
* Alpine images include the `arara` wrapper, but it requires Java, which is not installed. Use `latexmk` or `make` instead.
* Alpine images ship no system fonts (`fc-list` is empty). CJK works through TeX fonts (Fandol, HaranoAji, Nanum); `fontspec` by system font name and `ctex` fontsets such as `noto` are unavailable.

## Troubleshooting

* If you encounter missing packages, ensure they are installed in the Docker image. You can modify the corresponding Dockerfile under `docker/` to include additional packages.
* Check the `main.log` file for detailed error messages during compilation.

## License

This project is licensed under the MIT License. See the `LICENSE` file for details.
