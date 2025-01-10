# texlive

[English Version](./README.md)

为 VSCode LaTeX Workshop 定制的 TeX Live Docker 镜像。

## 为什么需要这个镜像？

该 Docker 镜像确保在无法连接 Overleaf 时，您仍然可以本地编译 LaTeX 文档。它提供了一个一致且可复现的 LaTeX 编译环境，包含所有必要的包和工具。

## 功能

* 预配置了 `lualatex`、`latexmk` 和其他必要的 LaTeX 工具。
* 包含学术写作中常用的 LaTeX 包（如 `ucetd` 文档类、`natbib`、`graphicx` 等）。
* 针对 VSCode 的 LaTeX Workshop 扩展进行了优化。

## 如何在 VSCode LaTeX Workshop 中使用

### 前提条件

1. 安装 [Docker](https://www.docker.com/)。
2. 在 VSCode 中安装 [LaTeX Workshop](https://marketplace.visualstudio.com/items?itemName=James-Yu.latex-workshop) 扩展。

### 配置

将以下设置添加到 VSCode 的 `settings.json` 中，以使用 Docker 镜像进行 LaTeX 编译：

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

### 使用步骤

1. 拉取 Docker 镜像：
   

```bash
   docker pull oaklight/texlive:latest-science
   ```

2. 在 VSCode 中打开您的 LaTeX 项目。
3. 将上述配置保存到 `settings.json` 中。
4. 打开一个 `.tex` 文件并开始编辑。LaTeX Workshop 扩展将自动使用 Docker 镜像进行编译。

### 本地构建镜像

如果您想本地构建 Docker 镜像，可以使用提供的 `Makefile` ：
1. 克隆此仓库。
2. 运行：
   

```bash
   make build
   ```

   这将构建带有 `oaklight/texlive:latest` 和 `oaklight/texlive:latest-science` 标签的镜像。

### 推送镜像（可选）

如果您想将镜像推送到 Docker 仓库：

```bash
make push
```

### 清理

要删除 Docker 镜像：

```bash
make clean
```

## 支持的 LaTeX 功能

* 使用 `lualatex` 和 `latexmk` 进行编译。
* 支持 `ucetd` 文档类（芝加哥大学电子论文和学位论文）。
* 包含常用包，如 `natbib`、`graphicx`、`amsmath` 等。

## 故障排除

* 如果遇到缺少的包，请确保它们在 Docker 镜像中已安装。您可以修改 `Dockerfile` 以包含其他包。
* 编译过程中，检查 `main.log` 文件以获取详细的错误信息。

## 许可证

本项目采用 MIT 许可证。详情请参阅 `LICENSE` 文件。
