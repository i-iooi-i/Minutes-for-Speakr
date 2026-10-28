# Minutes for Speakr 简体中文版

本分支基于 [Inrego/Minutes-for-Speakr](https://github.com/Inrego/Minutes-for-Speakr)，保留原项目的布局、配色、录音和 Speakr API 功能。原项目作者及 MIT 许可证保持不变。

## 使用

- 默认使用简体中文。在“设置 → 外观 → 界面语言”中切换 English / 简体中文，选择会保存在本机。
- 首次连接页面也可切换语言。窄窗口的入口在“设置 → 显示”。
- 使用你自己的 Speakr 服务器地址和 API 令牌，不需要修改 NAS 端服务。
- 汉化包含主界面、录音设置、自动录音、自动上传、说话人编辑、对话框、Windows 托盘、迷你录音窗口及日期显示。
- 录音标题、标签、服务器返回的摘要和转录正文不会被翻译。转录语言仍由服务器及上传设置决定。
- 自动上传沿用上游行为：成功上传后会删除本机源文件；启用前请阅读界面说明。

## Windows 构建

本次开发使用 Flutter 3.47.8 / Dart 3.13.7 和 Visual Studio 2022 C++ Build Tools（需包含 ATL 组件，凭据存储插件依赖它）。版本号为 `0.3.0+6`。

```powershell
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter analyze
flutter test
flutter build windows --release
```

产物位于 `build/windows/x64/runner/Release/`。必须分发整个目录，不能只复制 EXE。升级前完整备份旧程序目录；原路径、Windows 用户和凭据存储标识保持一致时，可沿用现有连接配置。

如果 Windows 的 Git 依赖检出遇到 `Filename too long`，可仅对当前终端启用 Git 长路径支持：

```powershell
$env:GIT_CONFIG_COUNT = '1'
$env:GIT_CONFIG_KEY_0 = 'core.longpaths'
$env:GIT_CONFIG_VALUE_0 = 'true'
flutter pub get
```

## 翻译维护

- 文案表：`lib/l10n/zh_cn.dart`；英文原文作为稳定检索键。
- `tr('English text')` 获取文案；动态内容用 `{0}` 等占位符和参数列表传入。
- 含翻译的 Widget 在 build 中调用 `LanguageScope.watch(context)`，语言切换时重新构建，同时保留页面和录音状态。
- Material 控件使用 Flutter 官方中文本地化；中文字体使用本地系统字体回退，不访问字体 CDN。
- API 状态、JSON 键、路由、用户内容和诊断日志不翻译。服务器的英文日期解析明确固定为 `en_US`。
- Windows 托盘通过 `speakr/tray` 同步语言；迷你窗口通过已有状态 IPC 同步，录音数据字段保持原样。
- 更新上游后，检查新增文案，并运行 `test/localization_test.dart` 及完整测试套件。

本次交付主要验证 Windows；Android/iOS 的共享界面已接入翻译，但不代表完成了移动端实机验收。
