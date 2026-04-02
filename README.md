# vps-benchkit

VPS 综合性能与网络测试菜单脚本：在 **CentOS 7+ / Debian 9+ / Ubuntu 16.04+** 上一键安装依赖并调用多款测速/基准脚本。默认**优先使用仓库内已固定的脚本**，降低运行期拉取未知代码的风险。

## 使用方法（推荐：克隆完整仓库）

本仓库包含 `ZBench-CN.sh`、`vendor/zbench/`、`vendor/remote/` 等依赖，**不能只下载单个 `.sh` 再执行**。从 GitHub 拉取**整个仓库**后再运行主脚本：

```bash
# 将 OWNER 换成你的 GitHub 用户名或组织名
git clone --depth 1 https://github.com/OWNER/vps-benchkit.git
cd vps-benchkit
chmod +x vps-benchkit.sh
sudo ./vps-benchkit.sh
```

若已安装 [GitHub CLI](https://cli.github.com/) 且仓库在你名下，也可：`gh repo clone OWNER/vps-benchkit`。

**已在本地克隆过仓库时**，在仓库根目录执行：

```bash
chmod +x vps-benchkit.sh
sudo ./vps-benchkit.sh
```

需要 root 或具备安装软件包权限的用户（脚本会执行 `yum` / `apt-get install`）。

## 安全相关环境变量

| 变量 | 作用 |
|------|------|
| `VPS_BENCHKIT_ALLOW_REMOTE=1` | 当 `vendor/remote/` 下 **superspeed / LemonBench** 缺失时，允许菜单 1、4 **回退**为从网络拉取（未固定版本，风险更高）。**菜单 3（goback.sh）始终仅使用仓库内文件，无网络回退。** |
| `ZBENCH_UPLOAD=1` | （选项 2）允许向 zbench 云端 **HTTP 明文**上传测评数据并生成在线链接。默认**不上传**。 |
| `ZBENCH_HTTP_REPORT=1` | （选项 2）结束后询问是否启动**仅监听 127.0.0.1** 的临时 HTTP 预览（需 `python3`），建议配合 SSH 端口转发访问。默认**不启用**临时 HTTP。 |
| `ZBENCH_WGET_INSECURE=1` | （选项 2）`wget` 下载依赖时使用 `--no-check-certificate`。默认使用标准 TLS 校验。 |

示例：

```bash
# 仅当信任 zbench 云端时
sudo ZBENCH_UPLOAD=1 ./vps-benchkit.sh

# 需要本地预览且愿意用 python3 开 127.0.0.1 服务
sudo ZBENCH_HTTP_REPORT=1 ./vps-benchkit.sh
```

## 脚本做什么

1. **彩色输出**：定义 `blue` / `green` / `yellow` / `red`，在终端打印带颜色的标题与提示。  
2. **发行版检测**：根据 `/etc/redhat-release`、`/etc/issue`、`/proc/version` 判断发行版并设置 `yum` 或 `apt-get`。  
3. **安装依赖**：执行 `$systemPackage -y install wget curl`。  
4. **交互菜单**：清屏后展示说明与 4 个测试项 + 退出。

## 菜单项说明

| 选项 | 函数 | 作用简述 |
|------|------|----------|
| **1** | `vps_superspeed` | **三网测速**：默认执行 `vendor/remote/superspeed.sh`（来自 [git.io/superspeed](https://git.io/superspeed) 的固定副本）。 |
| **2** | `vps_zbench` | **综合性能**：运行 `ZBench-CN.sh`；依赖优先来自 `vendor/zbench/`（见「ZBench-CN」）。 |
| **3** | `vps_testrace` | **回程路由**：仅执行仓库内 `vendor/remote/goback.sh`（来源见下「goback.sh」）。 |
| **4** | `vps_LemonBenchIntl` | **快速全方位**：默认执行 `vendor/remote/LemonBenchIntl.sh`（[LemonBench/LemonBench](https://github.com/LemonBench/LemonBench) 的 `LemonBench.sh`，`--fast`）。 |
| **0** | — | 退出脚本。 |

输入非法选项会提示后约 2 秒重新显示菜单。

## 各选项与安全（供应链 / 外链）

**总原则**：主菜单在 `vendor/remote/` 与 `vendor/zbench/` **齐全**且**未**设置 `VPS_BENCHKIT_ALLOW_REMOTE=1` 时，**不会**对选项 1、4 使用 `curl URL | bash` 或 `bash <(curl …)` 直接执行网上脚本；选项 3 的主脚本也**只从本仓库读取**。但各选项调用的**子脚本**仍可能自行 `wget`/`curl` 下载依赖或二进制，若上游仓库、CDN、短链被篡改，仍存在**广义供应链风险**（与「主菜单是否 curl|bash」是两层问题）。

| 选项 | 可能遇到的风险（选择前请知悉） |
|------|------------------------------|
| **1 三网测速** | **默认**：执行本地 `superspeed.sh`，但该脚本历史上可能再拉取测速客户端等（见脚本内部）。**若**本地 `superspeed.sh` 缺失且设置了 `VPS_BENCHKIT_ALLOW_REMOTE=1`：会通过短链 `git.io/superspeed` **拉取并立即执行**远端 shell，**内容与版本不固定**，存在与「远程脚本被替换」等价的供应链风险。 |
| **2 ZBench** | 主脚本与依赖以仓库内副本为优先；**若** `vendor/zbench/` 中某文件缺失，会按 `ZBench-CN.sh` 逻辑用 `wget` 从 GitHub 等拉取。**可选**：`ZBENCH_UPLOAD=1` 时向 zbench 服务 **HTTP 明文**上传测评数据；`Generate.py` 等仍可能访问外网 API（如 IP 地理信息）。 |
| **3 回程路由** | 主入口**仅** `vendor/remote/goback.sh`，**无**主菜单层面的远程回退。**但** `goback.sh` 内部仍可能 `wget` 例如 `besttrace` 等（来自上游仓库 URL），若上游文件被篡改，影响的是下载内容而非主菜单再注入一段 shell。 |
| **4 LemonBench** | **默认**：执行本地 `LemonBenchIntl.sh`；脚本运行过程中通常会 **curl** 从 GitHub 拉取 **jq、fio、speedtest、nexttrace** 等预编译包，属**二进制供应链**风险面。**若**本地脚本缺失且 `VPS_BENCHKIT_ALLOW_REMOTE=1`：可能对 `ilemonra.in` 使用 **`curl | bash`**，远端内容不固定，风险与任意「一键脚本」相同。 |

**与「攻击者改掉远程链接上的脚本」的关系**：

- **主菜单已收紧**：在默认配置下，**不再**因选 1、3、4 而必然执行「每次现拉」的远程 shell；选项 3 尤其如此。  
- **仍未消失的风险**：① 设置 `VPS_BENCHKIT_ALLOW_REMOTE=1` 且缺文件时的 **1、4 回退**；② 各子脚本内部的 **运行时下载**；③ 选项 2 的 **可选上传** 与 **Python 脚本访问外网 API**。

## 风险与注意事项（通用）

- **流量与时长**：测速会消耗较多出站流量，运行时间可能较长。  
- **远程回退**：仅菜单 1、4 在缺文件且设置 `VPS_BENCHKIT_ALLOW_REMOTE=1` 时可能从网络拉取并执行脚本；菜单 3 无此行为。  
- **ZBench**：`Generate.py` 等仍可能访问外网 API（如 ip-api）；云端上传与临时 HTTP 已改为**默认关闭**（见上表）。  
- **权限**：多数选项需 root；`goback.sh` 等会使用 `/home/tstrace` 等工作目录（见各脚本）。

## goback.sh（选项 3）

- **用途**：四网回程/路由类测试（脚本内使用 traceroute、mtr、besttrace 等）。  
- **上游仓库**：[V2RaySSR/vps](https://github.com/V2RaySSR/vps)  
- **上游文件**：[goback.sh](https://github.com/V2RaySSR/vps/blob/master/goback.sh)  
- **Raw（核对或手动更新副本时）**：`https://raw.githubusercontent.com/V2RaySSR/vps/master/goback.sh`  
- **本仓库路径**：`vendor/remote/goback.sh`（文件头注释含上述链接）。不提供运行时从 GitHub 拉取的回退，以降低供应链风险。

## ZBench-CN（选项 2）

- **上游**：[FunctionClub/ZBench](https://github.com/FunctionClub/ZBench)，主脚本 [`ZBench-CN.sh`](https://github.com/FunctionClub/ZBench/blob/master/ZBench-CN.sh)。  
- **本仓库**：根目录 `ZBench-CN.sh` + `vendor/zbench/` 下的 `besttrace`、`speedtest.py`、`ZPing-CN.py`、`Generate.py`。缺失时选项 2 会尝试用 `wget`（默认校验证书）下载。  
- 更细的依赖列表见 `vendor/zbench/README.md`。

## 文件说明

- `vps-benchkit.sh` — 主菜单。  
- `ZBench-CN.sh` — ZBench 中文版主脚本。  
- `vendor/zbench/` — ZBench 运行依赖（固定副本）。  
- `vendor/remote/` — 菜单 1、3、4 所用脚本（固定副本），说明见 `vendor/remote/README.md`。

## 许可与来源

菜单与 vendoring 为整理自用；各上游工具的许可证见其各自仓库。
