# texlive

[中文版](./README_zh.md)

Customized TeX Live Docker image for VSCode LaTeX Workshop.

## Why This Image?

This Docker image ensures that you can compile LaTeX documents locally even when you cannot connect to Overleaf. It provides a consistent and reproducible environment for LaTeX compilation, including all necessary packages and tools.

## Features

* Pre-configured with `lualatex`,   `latexmk`, and other essential LaTeX tools.
* Includes common LaTeX packages for academic writing (e.g.,  `ucetd` class,   `natbib`,   `graphicx`, etc.).
* Optimized for use with VSCode's LaTeX Workshop extension.

## How to Use with VSCode LaTeX Workshop

### Prerequisites

1. Install [Docker](https://www.docker.com/).
2. Install the [LaTeX Workshop](https://marketplace.visualstudio.com/items?itemName=James-Yu.latex-workshop) extension in VSCode.

### Configuration

Add the following settings to your `settings.json` in VSCode to use the Docker image for LaTeX compilation:

```json
"latex-workshop.docker.enabled": true,
"latex-workshop.docker.image.latex": "oaklight/texlive:latest-science",
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
   docker pull oaklight/texlive:latest-science
   ```

2. Open your LaTeX project in VSCode.
3. Save your `settings.json` with the above configuration.
4. Open a `.tex` file and start editing. The LaTeX Workshop extension will automatically use the Docker image for compilation.

### Building the Image Locally

If you want to build the Docker image locally, use the provided `Makefile` :
1. Clone this repository.
2. Run:
   

```bash
   make build
   ```

   This will build the image with the tags `oaklight/texlive:latest` and `oaklight/texlive:latest-science` .

### Pushing the Image (Optional)

If you want to push the image to a Docker registry:

```bash
make push
```

### Cleaning Up

To remove the Docker image:

```bash
make clean
```

## Supported LaTeX Features

* Compilation with `lualatex` and `latexmk`.
* Support for the `ucetd` document class (University of Chicago Electronic Theses and Dissertations).
* Common packages like `natbib`,   `graphicx`,   `amsmath`, and more.

## Troubleshooting

* If you encounter missing packages, ensure they are installed in the Docker image. You can modify the `Dockerfile` to include additional packages.
* Check the `main.log` file for detailed error messages during compilation.

## License

This project is licensed under the MIT License. See the `LICENSE` file for details.
