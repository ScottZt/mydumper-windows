# Windows 鎿嶄綔鎵嬪唽锛坢ydumper/myloader锛?
鏈枃妗ｉ潰鍚戝皬鐧界敤鎴凤紝鐩爣鏄敤鏈€灏戞搷浣滃畬鎴愶細
- 澶囦唤鎸囧畾搴?- 鍚屾鎭㈠鍒版柊搴撳悕锛堟紨缁冨簱锛?- 杩囩▼鍙杩涘害锛屽憡璀﹀啓鏃ュ織锛岄伩鍏嶅埛灞?
---

## 1. 瀹夎鍚庝綘浼氬緱鍒颁粈涔?
榛樿瀹夎璺緞锛?- `C:\Program Files\mydumper\bin\mydumper.exe`
- `C:\Program Files\mydumper\bin\myloader.exe`
- `C:\Program Files\mydumper\bin\BackupWizard.ps1`锛堝浠藉悜瀵硷級
- `C:\Program Files\mydumper\bin\RestoreWizard.ps1`锛堟仮澶嶅悜瀵硷級

---

## 2. 涓€閿浠斤紙鎺ㄨ崘锛?
鍦?PowerShell 鎵ц锛?
```powershell
& "C:\Program Files\mydumper\bin\BackupWizard.ps1"
```

鎸夋彁绀鸿緭鍏ワ細
- MySQL 涓绘満锛堥粯璁?`127.0.0.1`锛?- 绔彛锛堥粯璁?`3306`锛?- 鐢ㄦ埛鍚?瀵嗙爜
- 搴撳悕鍒楄〃锛堥€楀彿鍒嗛殧锛屼緥濡傦細`trading_db,tick_monitor`锛?- 杈撳嚭鐩綍锛堥粯璁?`D:\backup`锛?
缁撴灉锛?- 鑷姩鐢熸垚澶囦唤鐩綍锛歚D:\backup\dump_YYYYMMDD_HHMMSS`
- 灞忓箷鏄剧ず杩涘害锛堝啓鍏ヤ綋绉?GB锛?- 璇︾粏鏃ュ織锛歚<澶囦唤鐩綍>\mydumper.log`

---

## 3. 涓€閿仮澶嶅埌鏂板簱鍚嶏紙婕旂粌搴擄級

鍦?PowerShell 鎵ц锛?
```powershell
& "C:\Program Files\mydumper\bin\RestoreWizard.ps1"
```

鎸夋彁绀鸿緭鍏ワ細
- 澶囦唤鐩綍锛堜緥濡傦細`D:\backup\dump1`锛?- 鏄犲皠锛堟簮搴?鐩爣搴擄紝閫楀彿鍒嗛殧锛? 
  绀轰緥锛歚trading_db:trading_db_restore,tick_monitor:tick_monitor_restore`

濡傛灉鐩爣搴撳凡鏈夎〃锛岄渶瑕佽鐩栵細

```powershell
& "C:\Program Files\mydumper\bin\RestoreWizard.ps1" `
  -BackupDir "D:\backup\dump1" `
  -Mappings "trading_db:trading_db_restore,tick_monitor:tick_monitor_restore" `
  -DropTables
```

---

## 4. 涓轰粈涔堣繖涓祦绋嬫洿绋?
鍚戝宸茶嚜鍔ㄨ閬垮父瑙佸潙锛?- 鑷姩淇 `metadata` 鐨?CRLF 琛屽熬闂锛堥伩鍏?`\u000d= 1` 鎶ラ敊锛?- 澶囦唤鐢ㄦ椂闂存埑鐩綍锛岄伩鍏嶁€滅洰褰曢潪绌衡€濆啿绐?- 缁熶竴浣跨敤閫楀彿鍒嗛殧搴撳悕锛岄伩鍏?`-B` 瑕嗙洊瀵艰嚧鍙浠戒竴涓簱
- 鍛婅鍐欐棩蹇楋紝涓嶅湪缁堢鍒峰睆

---

## 5. 濡備綍纭鎴愬姛

### 5.1 澶囦唤鎴愬姛
- 澶囦唤鐩綍瀛樺湪 `metadata`
- `metadata` 鏈€鍚庢湁锛?  - `# Finished dump at: ...`

### 5.2 鎭㈠鎴愬姛
- myloader 鍛戒护閫€鍑哄悗娌℃湁 `CRITICAL` / `ERROR`
- 鐩爣搴撹兘鐪嬪埌琛ㄥ苟鏌ュ埌琛屾暟锛屼緥濡傦細

```sql
SHOW TABLES FROM tick_monitor_restore;
SELECT COUNT(*) FROM tick_monitor_restore.ticks;

SHOW TABLES FROM trading_db_restore;
SELECT COUNT(*) FROM trading_db_restore.orders;
```

---

## 6. 甯歌闂閫熸煡

### Q1锛氭彁绀烘壘涓嶅埌 mydumper/myloader
鐢ㄧ粷瀵硅矾寰勬墽琛岋紙瑙佷笂鏂囧懡浠わ級锛屾垨鎶?`C:\Program Files\mydumper\bin` 鍔犲埌 PATH銆?
### Q2锛氭仮澶嶆椂鎶ヨ〃宸插瓨鍦?鎭㈠鍛戒护鍔?`-DropTables`銆?
### Q3锛氬嚭鐜?gzip/zstd 璀﹀憡
濡傛灉澶囦唤鏄?`.sql` 鏂囦欢鍙拷鐣ワ紱鍙湁 `.gz/.zst` 澶囦唤鎵嶉渶瑕佸搴斿伐鍏枫€?
### Q4锛氭仮澶嶆椂鍋跺彂 1213 姝婚攣
閫氬父鏄苟鍙?DDL/DML 鍐茬獊锛岄噸璇曚竴娆″嵆鍙紱蹇呰鏃跺厛鏆傚仠鐩爣搴撲笂鐨勫叾浠栧彉鏇存搷浣溿€?
### Q5锛氳繍琛?BackupWizard 鎶モ€滄棤娉曡鐩栧彉閲?Host鈥?杩欐槸鏃х増鑴氭湰鍙傛暟鍚嶄笌 PowerShell 鍐呯疆鍙鍙橀噺 `$Host` 鍐茬獊瀵艰嚧銆? 
瑙ｅ喅鏂规硶锛?- 浣跨敤鏈€鏂板畨瑁呭寘閲嶆柊瀹夎锛涙垨
- 灏?`BackupWizard.ps1` 鏇挎崲涓洪」鐩噷鐨勬渶鏂扮増锛堝弬鏁板悕宸叉敼涓?`DbHost/DbPort/DbUser/DbPassword`锛夈€?- 鍙洿鎺ヨ鐩栧畨瑁呯洰褰曡剼鏈細
  ```powershell
  Copy-Item "D:\AI\mydumper\package\windows\BackupWizard.ps1" "C:\Program Files\mydumper\bin\BackupWizard.ps1" -Force
  Copy-Item "D:\AI\mydumper\package\windows\RestoreWizard.ps1" "C:\Program Files\mydumper\bin\RestoreWizard.ps1" -Force
  ```

---

## 7. 鏈€绠€浣跨敤寤鸿

1. 鍏堢敤 `BackupWizard.ps1` 鍋氫竴娆℃寚瀹氬簱澶囦唤  
2. 鍐嶇敤 `RestoreWizard.ps1` 鎸夆€滄簮搴?鏂板簱鈥濇槧灏勫仛婕旂粌鎭㈠  
3. 鏈€鍚庣敤 `SHOW TABLES` 鍜?`COUNT(*)` 鏍￠獙

濡傛灉鏈夋姤閿欙紝鎶婃棩蹇楁渶鍚?30 琛岃创缁欐垜鍗冲彲蹇€熷畾浣嶃€? 

---

## 8. 瀹夎鍚庣涓€姝ワ細妫€鏌ユ槸鍚︿负鏈€鏂拌剼鏈?
鍦?PowerShell 鎵ц杩欐潯鍛戒护锛?
```powershell
Get-Content "C:\Program Files\mydumper\bin\BackupWizard.ps1" -TotalCount 30 | Select-String "DbHost|璇疯緭鍏ヨ澶囦唤鐨勬暟鎹簱"
```

鍒ゅ畾鏍囧噯锛?- 鑻ヨ兘鐪嬪埌 `DbHost` 鎴?`璇疯緭鍏ヨ澶囦唤鐨勬暟鎹簱`锛岃鏄庝綘宸叉槸鏈€鏂扮増鑴氭湰銆?- 鑻ョ湅涓嶅埌锛屽缓璁噸鏂板畨瑁呮渶鏂?exe锛屾垨鎵嬪姩瑕嗙洊鑴氭湰鏂囦欢銆?
