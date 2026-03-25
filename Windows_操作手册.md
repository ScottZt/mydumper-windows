# Windows 操作手册（mydumper/myloader）

本文档面向小白用户，目标是用最少操作完成：
- 备份指定库
- 同步恢复到新库名（演练库）
- 过程可见进度，告警写日志，避免刷屏

---

## 1. 安装后你会得到什么

默认安装路径：
- `C:\Program Files\mydumper\bin\mydumper.exe`
- `C:\Program Files\mydumper\bin\myloader.exe`
- `C:\Program Files\mydumper\bin\BackupWizard.ps1`（备份向导）
- `C:\Program Files\mydumper\bin\RestoreWizard.ps1`（恢复向导）

---

## 2. 一键备份（推荐）

在 PowerShell 执行：

```powershell
& "C:\Program Files\mydumper\bin\BackupWizard.ps1"
```

按提示输入：
- MySQL 主机（默认 `127.0.0.1`）
- 端口（默认 `3306`）
- 用户名/密码
- 库名列表（逗号分隔，例如：`trading_db,tick_monitor`）
- 输出目录（默认 `D:\backup`）

结果：
- 自动生成备份目录：`D:\backup\dump_YYYYMMDD_HHMMSS`
- 屏幕显示进度（写入体积 GB）
- 详细日志：`<备份目录>\mydumper.log`

---

## 3. 一键恢复到新库名（演练库）

在 PowerShell 执行：

```powershell
& "C:\Program Files\mydumper\bin\RestoreWizard.ps1"
```

按提示输入：
- 备份目录（例如：`D:\backup\dump1`）
- 映射（源库:目标库，逗号分隔）  
  示例：`trading_db:trading_db_restore,tick_monitor:tick_monitor_restore`

如果目标库已有表，需要覆盖：

```powershell
& "C:\Program Files\mydumper\bin\RestoreWizard.ps1" `
  -BackupDir "D:\backup\dump1" `
  -Mappings "trading_db:trading_db_restore,tick_monitor:tick_monitor_restore" `
  -DropTables
```

---

## 4. 为什么这个流程更稳

向导已自动规避常见坑：
- 自动修复 `metadata` 的 CRLF 行尾问题（避免 `\u000d= 1` 报错）
- 备份用时间戳目录，避免“目录非空”冲突
- 统一使用逗号分隔库名，避免 `-B` 覆盖导致只备份一个库
- 告警写日志，不在终端刷屏

---

## 5. 如何确认成功

### 5.1 备份成功
- 备份目录存在 `metadata`
- `metadata` 最后有：
  - `# Finished dump at: ...`

### 5.2 恢复成功
- myloader 命令退出后没有 `CRITICAL` / `ERROR`
- 目标库能看到表并查到行数，例如：

```sql
SHOW TABLES FROM tick_monitor_restore;
SELECT COUNT(*) FROM tick_monitor_restore.ticks;

SHOW TABLES FROM trading_db_restore;
SELECT COUNT(*) FROM trading_db_restore.orders;
```

---

## 6. 常见问题速查

### Q1：提示找不到 mydumper/myloader
用绝对路径执行（见上文命令），或把 `C:\Program Files\mydumper\bin` 加到 PATH。

### Q2：恢复时报表已存在
恢复命令加 `-DropTables`。

### Q3：出现 gzip/zstd 警告
如果备份是 `.sql` 文件可忽略；只有 `.gz/.zst` 备份才需要对应工具。

### Q4：恢复时偶发 1213 死锁
通常是并发 DDL/DML 冲突，重试一次即可；必要时先暂停目标库上的其他变更操作。

### Q5：运行 BackupWizard 报“无法覆盖变量 Host”
这是旧版脚本参数名与 PowerShell 内置只读变量 `$Host` 冲突导致。  
解决方法：
- 使用最新安装包重新安装；或
- 将 `BackupWizard.ps1` 替换为项目里的最新版（参数名已改为 `DbHost/DbPort/DbUser/DbPassword`）。
- 可直接覆盖安装目录脚本：
  ```powershell
  Copy-Item "D:\AI\mydumper\package\windows\BackupWizard.ps1" "C:\Program Files\mydumper\bin\BackupWizard.ps1" -Force
  Copy-Item "D:\AI\mydumper\package\windows\RestoreWizard.ps1" "C:\Program Files\mydumper\bin\RestoreWizard.ps1" -Force
  ```

---

## 7. 最简使用建议

1. 先用 `BackupWizard.ps1` 做一次指定库备份  
2. 再用 `RestoreWizard.ps1` 按“源库:新库”映射做演练恢复  
3. 最后用 `SHOW TABLES` 和 `COUNT(*)` 校验

如果有报错，把日志最后 30 行贴给我即可快速定位。  
