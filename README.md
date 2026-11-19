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
* CI publishes a SPDX JSON SBOM for each published image as a workflow artifact. See [Security and supply chain](#security-and-supply-chain).

## Security and supply chain

* **Reproducible bases.** The Debian and Alpine base images are pinned by digest in the Dockerfiles. The tag stays in the reference so the intended release line is visible; the digest fixes the content.
* **Updates.** Dependabot opens weekly PRs for base-image digests and for GitHub Actions pinned by commit SHA. The images are also rebuilt monthly and on every merged change to the Dockerfiles or the build workflow.
* **SBOM.** Every published image gets a SPDX JSON SBOM, uploaded as a workflow artifact. Alias tags (`latest`, `debian-*`) share the digest and SBOM of their primary tag and are not scanned twice. SBOMs are not embedded in the image manifest or the attestation index.
* **Vulnerability scanning.** A weekly Trivy scan covers `alpine-science-cn` and `debian-science-cn`, reports fixed HIGH/CRITICAL OS package vulnerabilities, and uploads the report and SARIF file as workflow artifacts. The scan is report-only: it does not block releases, because the TeX Live package set carries findings that upstream has not fixed.
* **Runtime.** Images run as root by default. When compiling untrusted documents, run the container with `--user`, no network, and a read-only mount of the source (see [Runtime notes](#runtime-notes)).

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
make alpine-build APK_MIRROR=mirrors.tuna.tsinghua.edu.cn
```

Base images are pinned by digest. To mirror Docker Hub, configure the Docker
daemon instead of passing a build argument:

```json
// /etc/docker/daemon.json
{"registry-mirrors": ["https://docker.1ms.run"]}
```

Digest pulls go through the daemon mirror. `REGISTRY_MIRROR` is no longer a
Makefile variable because a variable `FROM` would hide the base reference from
Dependabot and defeat digest updates.

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
* CJK language support (Chinese, Japanese, Korean) in the `-cn` / `-jp` / `-kr` variants.
* European languages via babel (French, German, Spanish, Italian) and Cyrillic (Russian, Ukrainian) with `pdflatex` or `xelatex`. Arabic uses `xelatex` + `polyglossia`.

## Runtime notes

* The images run as `root` by default. When you mount a project directory, pass the host UID/GID so generated files stay editable:

  ```bash
  docker run --rm --user "$(id -u):$(id -g)" -e HOME=/tmp \
    -v "$PWD:/workspace" -w /workspace oaklight/texlive:latest latexmk -pdf main.tex
  ```

* Alpine images use the distro TeX Live packages, so `tlmgr` is absent. Debian images ship `tlmgr`, but it runs in user mode and cannot update the system installation. Pull a newer image instead.
* `minted` is intentionally not supported. It needs Python/Pygments in the image and `-shell-escape` in every compile invocation; adding both grows the images and raises the CVE surface, and enabling shell escape by default is a security regression for a tool that compiles untrusted documents. Use the `listings` package for highlighted listings, or `tex-fmt` for formatting LaTeX source. If you control your own copy of the image and your documents, install `pygments` and pass `-shell-escape` yourself; the recipe in this repository will not do it for you.
* Alpine images include the `arara` wrapper, but it requires Java, which is not installed. Use `latexmk` or `make` instead.
* Science images now ship system fonts (DejaVu for Cyrillic, Noto Sans Arabic on Alpine, Amiri on Debian) so `fontspec` can select them by name. `alpine-base` and `debian-base` still have no system fonts; use a science image for Cyrillic/Arabic.

## Troubleshooting

* If you encounter missing packages, ensure they are installed in the Docker image. You can modify the corresponding Dockerfile under `docker/` to include additional packages.
* Check the `main.log` file for detailed error messages during compilation.

## License

This project is licensed under the MIT License. See the `LICENSE` file for details.
