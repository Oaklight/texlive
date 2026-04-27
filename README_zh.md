# texlive

[English Version](./README.md)

为 LaTeX 编译定制的 TeX Live Docker 镜像，提供 Debian 和 Alpine 两种变体。

## DockerHub 镜像

* [oaklight/texlive](https://hub.docker.com/r/oaklight/texlive)

## 为什么需要这个镜像？

该 Docker 镜像确保在无法连接 Overleaf 时，您仍然可以本地编译 LaTeX 文档。它提供了一个一致且可复现的 LaTeX 编译环境，包含所有必要的包和工具。

## 可用标签

| 标签 | 基础系统 | TeX Live | 说明 |
|------|----------|----------|------|
| `latest` | Alpine 3.23 | 2025 | `alpine-science` 的别名 |
| **Alpine** | | | |
| `alpine-base` | Alpine 3.23 | 2025 | 核心 LaTeX + LuaTeX + biber |
| `alpine-science` | Alpine 3.23 | 2025 | + 科学/数学/字体包 |
| `alpine-base-cn` | Alpine 3.23 | 2025 | Base + 中日韩语言支持 |
| `alpine-science-cn` | Alpine 3.23 | 2025 | Science + 中日韩语言支持 |
| **Debian** | | | |
| `debian-base` / `base` | Debian bookworm | 2022 | 核心 LaTeX + LuaTeX + biber |
| `debian-science` / `science` | Debian bookworm | 2022 | + 科学/数学/字体包 |
| `debian-base-cn` / `base-cn` | Debian bookworm | 2022 | Base + 中日韩语言支持 |
| `debian-science-cn` / `science-cn` | Debian bookworm | 2022 | Science + 中日韩语言支持 |

> JP 和 KR 标签（如 `alpine-base-jp`、`base-kr`）也可用，它们是对应 CN 标签的别名。

## 功能

* **两种基础系统可选**：Alpine（更小、更新的 TeX Live）和 Debian（向后兼容）。
* 预配置了 `lualatex`、`latexmk`、`biber` 和其他必要的 LaTeX 工具。
* 包含 [`tex-fmt`](https://github.com/WGUNDERWOOD/tex-fmt) 用于 LaTeX 源码格式化。
* 包含学术写作中常用的 LaTeX 包（如 `ucetd` 文档类、`natbib`、`graphicx` 等）。
* 针对 VSCode 的 LaTeX Workshop 扩展进行了优化。
* 通过 GitHub Actions CI/CD 自动构建和推送。

## 如何在 VSCode LaTeX Workshop 中使用

### 前提条件

1. 安装 [Docker](https://www.docker.com/)。
2. 在 VSCode 中安装 [LaTeX Workshop](https://marketplace.visualstudio.com/items?itemName=James-Yu.latex-workshop) 扩展。

### 配置

将以下设置添加到 VSCode 的 `settings.json` 中，以使用 Docker 镜像进行 LaTeX 编译：

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

### 使用步骤

1. 拉取 Docker 镜像：

```bash
docker pull oaklight/texlive:latest
```

2. 在 VSCode 中打开您的 LaTeX 项目。
3. 将上述配置保存到 `settings.json` 中。
4. 打开一个 `.tex` 文件并开始编辑。LaTeX Workshop 扩展将自动使用 Docker 镜像进行编译。

## 本地构建

### Debian 镜像

```bash
make build
```

### Alpine 镜像

```bash
make alpine-build
```

### 使用镜像加速（国内用户）

```bash
make alpine-build REGISTRY_MIRROR=docker.1ms.run APK_MIRROR=mirrors.tuna.tsinghua.edu.cn
```

### 推送镜像

```bash
make push-all    # 推送所有镜像（Debian + Alpine）
make push        # 仅推送 Debian 镜像
make alpine-push # 仅推送 Alpine 镜像
```

### 清理

```bash
make clean-all    # 删除所有镜像
make clean        # 仅删除 Debian 镜像
make alpine-clean # 仅删除 Alpine 镜像
```

运行 `make help` 查看所有可用目标和变量。

## 支持的 LaTeX 功能

* 使用 `lualatex`、`pdflatex` 和 `latexmk` 进行编译。
* 支持 `ucetd` 文档类（芝加哥大学电子论文和学位论文）。
* 包含常用包，如 `natbib`、`graphicx`、`amsmath` 等。
* 中日韩语言支持，通过 `-cn` / `-jp` / `-kr` 变体提供。

## 故障排除

* 如果遇到缺少的包，请确保它们在 Docker 镜像中已安装。您可以修改对应的 `Dockerfile` 以包含其他包。
* 编译过程中，检查 `main.log` 文件以获取详细的错误信息。

## 许可证

本项目采用 MIT 许可证。详情请参阅 `LICENSE` 文件。
