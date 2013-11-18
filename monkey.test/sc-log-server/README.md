# log服务器上的脚本

* 我们需要将每天的log做一些统计，而统计的根据就是log中所带的信息。
* 目前，我们统计的信息主要是log的获取时机以及log的分类。
* 我们用一个脚本在计划任务中，每天早上解析当前的log，并将结果放在指定的文件中。
* 此处，我们没有使用配置文件，而是直接指令了文件及文件路径。算是图个方便吧，毕竟是自己用的。

- `log_daily_report.sh` 生成每天的数据报告
- `log_distribute.sh` - 分析log的脚本

*  用 `crontab -e` 加入任务 `0 8 * * * /home/mtlog/sc/log_daily_report.sh`

