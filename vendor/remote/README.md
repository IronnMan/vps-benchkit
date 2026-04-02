# 菜单 1 / 3 / 4 使用的脚本（随仓库固定）

| 文件 | 用途 | 来源说明 |
|------|------|----------|
| `superspeed.sh` | 选项 1 三网测速 | 源自 [git.io/superspeed](https://git.io/superspeed)；本仓库已把其中 **Ookla CLI** 安装改为官方 `install.speedtest.net`（原 Bintray 已失效），并优先使用系统已安装的 `speedtest`。 |
| `goback.sh` | 选项 3 回程 | [V2RaySSR/vps](https://github.com/V2RaySSR/vps/blob/master/goback.sh)（仅本地执行，无网络回退） |
| `LemonBenchIntl.sh` | 选项 4 综合测试 | 与 [LemonBench/LemonBench](https://github.com/LemonBench/LemonBench) 仓库中 `LemonBench.sh` 对应（本仓库以 `--fast` 运行）；短链 `ilemonra.in/LemonBenchIntl` 与上述脚本同源类工具 |

- **goback.sh**：缺失即报错，须自行放入或从上游 Raw 更新。  
- **superspeed.sh、LemonBenchIntl.sh**：若缺少且**未**设置 `VPS_BENCHKIT_ALLOW_REMOTE=1`，菜单将报错；设置该变量后才会从网络拉取（未固定版本，风险更高）。
