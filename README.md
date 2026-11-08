# Anarcute 简体中文补丁

给 Unity 游戏 **Anarcute**（Steam AppID `390720`）做的简体中文汉化补丁。

游戏自带一份 `Translations.csv`，但中文列是早期机翻（Credits→积分、Exit→出口、Gear→齿轮），而且中文字体是只含 500 多个字的静态图集，很多常用字直接不显示（“输入”只剩“入”、“删除进度”只剩“删除进”）。

本补丁做两件事：

1. **重译** `Translations.csv` 的简体中文列（349 行：菜单、设置、教程、关卡名、动物图鉴、成就等），保留 `[c]`、`[highlight]`、`[LevelName]` 等富文本标签；
2. **换字体**：把游戏里的 `Regular_NotoChinese` / `Small_NotoChinese` 两张静态图集字体，改成基于思源/Noto 中文 TTF 的动态字体，并分别借用未使用的动态字体的材质与纹理，避免共用图集互相覆盖。

补丁只改一个文件：`anarcute_Data/resources.assets`（约 110MB）。**不需要**改 `Assembly-CSharp.dll`。

## 下载

到 [Releases](../../releases) 页面下载最新的 `anarcute_zh_patch_v1.9.0.zip`（约 68MB）。

> 仓库里只有脚本，不含游戏资源；`resources.assets` 体积超过 GitHub 单文件 100MB 上限，所以放在 Release 附件里。

## 安装

1. 解压 zip 到任意目录（不要在压缩包里直接运行）。
2. 关闭游戏和 Steam。
3. 双击 **`一键安装.bat`**。它会：
   - 从注册表和 `libraryfolders.vdf` 自动找到 Anarcute 的安装目录；
   - 结束 `anarcute` / `steam` 进程；
   - 把原 `resources.assets` 备份为 `resources.assets.zhbak`；
   - 覆盖补丁并校验字节数；
   - 把 `appmanifest_390720.acf` 里本游戏的语言从 `english` 改成 `schinese`。
4. 启动 Steam，再启动游戏。

手动安装（PowerShell）：

```powershell
powershell -ExecutionPolicy Bypass -File .\install.ps1
# 自动找不到游戏时：
powershell -ExecutionPolicy Bypass -File .\install.ps1 -GameDir "D:\Steam\steamapps\common\Anarcute"
```

## 卸载

双击 **`一键卸载.bat`**（还原 `resources.assets.zhbak`），或在 Steam 里对游戏执行「验证文件完整性」。

## 已知限制

- 教程里的按键提示（`Left Stick to move`、`Move with WASD`）、Logo、城市名 `Tokyo`、关卡名 `Tsubomi` 等是烘焙进贴图/预制体的图片，不在 CSV 里，仍是英文。
- 只做了简体中文；繁体（`tchinese`）列未处理。
- 游戏更新后 `resources.assets` 会被 Steam 覆盖，需要重新运行安装脚本。

## 仓库内容

```
install.ps1        自动安装（检测路径 / 备份 / 改语言）
uninstall.ps1      卸载还原
一键安装.bat        双击运行 install.ps1
一键卸载.bat        双击运行 uninstall.ps1
安装说明.md         面向玩家的说明
tools/
  anarcute_patch2.py   生成 349 行中文 CSV 并回写 TextAsset
  anarcute_conv.py     字体改造（中文 TTF + 独立材质/纹理）
  anarcute_zh.json     中文译文表（idx → 文本）
  anarcute_rows.json   CSV 原始 11 列数据
```

重建补丁需要 Python 3.10+ 与 `UnityPy`：

```powershell
pip install UnityPy
python tools\anarcute_patch2.py
python tools\anarcute_conv.py
```

## 说明

- 仅供个人学习与单机使用，请自备正版游戏。
- 补丁不含游戏本体，仓库与 Release 里也不含原始游戏文件，只有翻译文本与字体改写脚本；分发的 `resources.assets` 是玩家本机资源被修改后的副本。
- 游戏版权归 Anarteam 所有。

## License

脚本与译文以 MIT 协议发布，见 [LICENSE](LICENSE)。
