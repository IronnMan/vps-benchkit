# ZBench 依赖（随仓库固定版本）

以下文件来自上游 [FunctionClub/ZBench](https://github.com/FunctionClub/ZBench)，供 `ZBench-CN.sh` 优先使用，避免运行期从网络拉取主依赖：

| 文件 | 上游 Raw（示例） |
|------|------------------|
| `besttrace` | `https://raw.githubusercontent.com/FunctionClub/ZBench/master/besttrace` |
| `speedtest.py` | `https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py` |
| `ZPing-CN.py` | `https://raw.githubusercontent.com/FunctionClub/ZBench/master/ZPing-CN.py` |
| `Generate.py` | `https://raw.githubusercontent.com/FunctionClub/ZBench/master/Generate.py` |

若某文件缺失，`ZBench-CN.sh` 会尝试用 **校验 TLS 的** `wget` 下载；仅在设置 `ZBENCH_WGET_INSECURE=1` 时才会使用 `--no-check-certificate`。
