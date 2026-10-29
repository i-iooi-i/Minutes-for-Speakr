# Mimio — Speakr 桌面客户端

Mimio 基于 [Inrego/Minutes-for-Speakr](https://github.com/Inrego/Minutes-for-Speakr)，为自托管 Speakr 提供简体中文/英文桌面界面、录音和录音资料管理。保留原项目作者署名和 MIT 许可证。

## Windows 0.3.25

从本仓库 Releases 下载 `Mimio-0.3.25-windows-x64.zip`，完整解压后运行 `speakr_app.exe`。程序尚未进行代码签名。下载后可使用随包发布的 `SHA256SUMS.txt` 校验完整性。

- 重新整理桌面布局、独立录音工作区、录音详情和搜索入口。
- 中英文切换，浅色/深色/跟随系统，以及七种主题色。
- 共用圆角菜单、胶囊控件和面板边框，使用 Mimio M 图标。
- 设置 → 个人资料 → 本地头像：输入 HTTP(S) 图片直链，支持恢复默认和加载失败回退。
- 界面版本号显示为 `0.3.25`，构建序号只用于内部区分。

## 本机数据与隐私

发行包仅包含应用构建产物，不附带开发者的服务器地址、API 令牌、头像链接、录音、转录内容或用户偏好。首次使用请连接你自己的 Speakr 服务器。服务器连接凭据使用系统安全存储；头像链接和界面偏好保存在当前设备，头像链接不写入 Speakr 账号。自定义头像会从你填写的图片地址加载。

在同一个 Windows 用户下升级会继续读取该用户已有的本地配置，这不表示配置包含在发行包里。升级前请备份旧程序目录。不要将 AppData、个人录音文件夹或已使用的安装目录制作成公开分发包。

录音标题、标签、摘要和转录正文属于服务器内容，不随界面语言翻译。自动上传成功后删除本机源文件的行为沿用上游，启用前请阅读设置说明。

## 开发与验证

本版本使用 Flutter 3.47.8 / Dart 3.13.7，Windows 需要 Visual Studio 2022 C++ Build Tools（包含 ATL）。

```powershell
flutter pub get
flutter analyze
flutter test
flutter build windows --release
```

Windows 产物位于 `build/windows/x64/runner/Release/`，必须分发整个目录。图标源通过 `flutter test tools/build_icon_sources.dart` 从侧边栏相同的矢量绘制器生成。界面文案集中在 `lib/l10n/zh_cn.dart`，共用控件说明见 `docs/mimio-controls.md`。

本次发布验证范围为 Windows；没有发布或声称验证 Android/iOS 安装包。
