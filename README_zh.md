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
| `latest` | Alpine 3.24 | 2026 | `alpine-science` 的别名 |
| **Alpine** | | | |
| `alpine-base` | Alpine 3.24 | 2026 | 核心 LaTeX + LuaTeX + XeTeX + biber |
| `alpine-science` | Alpine 3.24 | 2026 | + 科学/数学/字体包 |
| `alpine-base-cn` | Alpine 3.24 | 2026 | Base + 中文支持（ctex、xeCJK、CJKutf8） |
| `alpine-science-cn` | Alpine 3.24 | 2026 | Science + 中文支持 |
| `alpine-base-jp` | Alpine 3.24 | 2026 | Base + 日文支持（luatexja、platex、uplatex） |
| `alpine-science-jp` | Alpine 3.24 | 2026 | Science + 日文支持 |
| `alpine-base-kr` | Alpine 3.24 | 2026 | Base + 韩文支持（kotex、nanumtype1） |
| `alpine-science-kr` | Alpine 3.24 | 2026 | Science + 韩文支持 |
| **Debian** | | | |
| `debian-base` / `base` | Debian trixie | 2024 | 核心 LaTeX + LuaTeX + XeTeX + biber |
| `debian-science` / `science` | Debian trixie | 2024 | + 科学/数学/字体包 |
| `debian-base-cn` / `base-cn` | Debian trixie | 2024 | Base + 中文支持 |
| `debian-science-cn` / `science-cn` | Debian trixie | 2024 | Science + 中文支持 |
| `debian-base-jp` / `base-jp` | Debian trixie | 2024 | Base + 日文支持 |
| `debian-science-jp` / `science-jp` | Debian trixie | 2024 | Science + 日文支持 |
| `debian-base-kr` / `base-kr` | Debian trixie | 2024 | Base + 韩文支持 |
| `debian-science-kr` / `science-kr` | Debian trixie | 2024 | Science + 韩文支持 |

> 每个语言变体独立构建，安装对应国家的 TeX 语言包。CN/JP/KR 镜像内容各不相同。
>
> **平台支持：** Alpine 和 Debian 镜像均发布 `linux/amd64` 和 `linux/arm64`。`tex-fmt` 二进制仅提供 Alpine `amd64` 版本，因此 Alpine `arm64` 镜像不包含 `tex-fmt`。

## 功能

* **两种基础系统可选**：Alpine（更小、更新的 TeX Live）和 Debian（向后兼容）。
* 预配置了 `pdflatex`、`lualatex`、`xelatex`、`latexmk`、`biber` 和其他必要的 LaTeX 工具。
* 包含 [`tex-fmt`](https://github.com/WGUNDERWOOD/tex-fmt) 用于 LaTeX 源码格式化。
* 包含学术写作中常用的 LaTeX 包（如 `natbib`、`graphicx`、`amsmath` 等）。镜像不包含 `ucetd` 文档类；可参考 [`test-uchicago/`](./test-uchicago/) 中的示例。
* 针对 VSCode 的 LaTeX Workshop 扩展进行了优化。
* 通过 GitHub Actions CI/CD 自动构建和推送。
* CI 为每个发布镜像生成 SPDX JSON SBOM，并作为 workflow artifact 上传。详见[安全与供应链](#安全与供应链)。

## 安全与供应链

* **可复现的基础镜像。** Debian 与 Alpine 基础镜像在 Dockerfile 中按 digest 固定。引用中保留 tag 以显示目标发行版，digest 固定实际内容。
* **更新机制。** Dependabot 每周为基础镜像 digest 和按 commit SHA 固定的 GitHub Actions 提交 PR；镜像同时按月重建，并在 Dockerfile 或构建工作流变更合入时重建。
* **SBOM。** 每个发布镜像都生成 SPDX JSON SBOM，并作为 workflow artifact 上传。`latest`、`debian-*` 等别名 tag 与主 tag 共享 digest 和 SBOM，不重复扫描。SBOM 不写入镜像 manifest 或 attestation index。
* **漏洞扫描。** 每周用 Trivy 扫描 `alpine-science-cn` 与 `debian-science-cn`，报告已修复的 HIGH/CRITICAL 系统包漏洞，并将报告与 SARIF 作为 workflow artifact 上传。扫描目前只报告、不阻断发布，因为 TeX Live 包集中存在上游尚未修复的问题。
* **运行时。** 镜像默认以 root 运行。编译不受信任的文档时，请用 `--user` 运行容器，并断网、只读挂载源码（见[运行时说明](#运行时说明)）。

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
make alpine-build APK_MIRROR=mirrors.tuna.tsinghua.edu.cn
```

基础镜像已固定 digest。要加速 Docker Hub 拉取，请在 Docker 守护进程配置镜像，而不再通过构建参数传入：

```json
// /etc/docker/daemon.json
{"registry-mirrors": ["https://docker.1ms.run"]}
```

按 digest 拉取仍会经过守护进程配置的镜像站。`REGISTRY_MIRROR` 不再是 Makefile 变量：变量形式的 `FROM` 会让 Dependabot 看不到基础镜像引用，从而无法更新 digest。

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

* 使用 `pdflatex`、`lualatex`、`xelatex` 和 `latexmk` 进行编译。
* 提供芝加哥大学论文示例 [`test-uchicago/`](./test-uchicago/)（镜像本身不包含 `ucetd` 文档类）。
* 包含常用包，如 `natbib`、`graphicx`、`amsmath` 等。
* 中日韩语言支持，通过 `-cn` / `-jp` / `-kr` 变体提供。
* 欧洲语言通过 babel 支持（法语、德语、西班牙语、意大利语）；西里尔字母（俄语、乌克兰语）可用 `pdflatex` 或 `xelatex`；阿拉伯语使用 `xelatex` + `polyglossia`。

## 运行时说明

* 镜像默认以 `root` 运行。挂载项目目录时，请传入宿主机的 UID/GID，避免生成的文件所有者变成 root：

  ```bash
  docker run --rm --user "$(id -u):$(id -g)" -e HOME=/tmp \
    -v "$PWD:/workspace" -w /workspace oaklight/texlive:latest latexmk -pdf main.tex
  ```

* Alpine 镜像使用发行版打包的 TeX Live，没有 `tlmgr`。Debian 镜像带有 `tlmgr`，但它以用户模式运行，无法更新系统安装。请拉取更新后的镜像。
* 本仓库有意不支持 `minted`。它需要镜像内安装 Python/Pygments，并要求每次编译都传入 `-shell-escape`；这会增大镜像和 CVE 面，而默认开启 shell escape 对编译不受信任文档的工具而言是安全倒退。请使用 `listings` 包实现带高亮的代码清单，或用 `tex-fmt` 格式化 LaTeX 源码。如果你自己维护镜像副本且信任待编译文档，可自行安装 `pygments` 并传入 `-shell-escape`；本仓库的编译配方不会代为开启。
* Alpine 镜像包含 `arara` 包装脚本，但它需要 Java，而镜像未安装 Java。请改用 `latexmk` 或 `make`。
* science 镜像现在包含系统字体（西里尔用 DejaVu；阿拉伯语在 Alpine 上用 Noto Sans Arabic，在 Debian 上用 Amiri），`fontspec` 可按名称选用。`alpine-base` 与 `debian-base` 仍无系统字体；需要西里尔/阿拉伯语时请使用 science 镜像。

## 故障排除

* 如果遇到缺少的包，请确保它们在 Docker 镜像中已安装。您可以修改 `docker/` 目录下对应的 Dockerfile 以包含其他包。
* 编译过程中，检查 `main.log` 文件以获取详细的错误信息。

## 许可证

本项目采用 MIT 许可证。详情请参阅 `LICENSE` 文件。
