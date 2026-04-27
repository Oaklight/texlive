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
| `latest` | Alpine 3.23 | 2025 | Alias for `alpine-science` |
| **Alpine** | | | |
| `alpine-base` | Alpine 3.23 | 2025 | Core LaTeX + LuaTeX + biber |
| `alpine-science` | Alpine 3.23 | 2025 | + science/math/fonts packages |
| `alpine-base-cn` | Alpine 3.23 | 2025 | Base + CJK language support |
| `alpine-science-cn` | Alpine 3.23 | 2025 | Science + CJK language support |
| **Debian** | | | |
| `debian-base` / `base` | Debian bookworm | 2022 | Core LaTeX + LuaTeX + biber |
| `debian-science` / `science` | Debian bookworm | 2022 | + science/math/fonts packages |
| `debian-base-cn` / `base-cn` | Debian bookworm | 2022 | Base + CJK language support |
| `debian-science-cn` / `science-cn` | Debian bookworm | 2022 | Science + CJK language support |

> JP and KR tags (e.g., `alpine-base-jp`, `base-kr`) are also available as aliases for the corresponding CN tags.

## Features

* **Two base OS choices**: Alpine (smaller, newer TeX Live) and Debian (backward-compatible).
* Pre-configured with `lualatex`, `latexmk`, `biber`, and other essential LaTeX tools.
* Includes [`tex-fmt`](https://github.com/WGUNDERWOOD/tex-fmt) for LaTeX source formatting.
* Includes common LaTeX packages for academic writing (e.g., `ucetd` class, `natbib`, `graphicx`, etc.).
* Optimized for use with VSCode's LaTeX Workshop extension.
* CI/CD via GitHub Actions for automated builds and pushes.

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

* Compilation with `lualatex`, `pdflatex`, and `latexmk`.
* Support for the `ucetd` document class (University of Chicago Electronic Theses and Dissertations).
* Common packages like `natbib`, `graphicx`, `amsmath`, and more.
* CJK language support (Chinese, Japanese, Korean) in `-cn` / `-jp` / `-kr` variants.

## Troubleshooting

* If you encounter missing packages, ensure they are installed in the Docker image. You can modify the corresponding `Dockerfile` to include additional packages.
* Check the `main.log` file for detailed error messages during compilation.

## License

This project is licensed under the MIT License. See the `LICENSE` file for details.
