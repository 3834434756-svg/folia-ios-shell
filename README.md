# Folia iOS（WebView 壳）

把 [Folia](https://github.com/chthollyphile/folia-major) 音乐播放器装到 iPhone 上的最小原生壳。

## 原理

- App 只有一个全屏 `WKWebView`，加载 Folia 在线版 **https://folia-ce.cn/**。
- 界面、歌词动画、可视化等全部由 Web 应用渲染，**UI 与官方在线版一致**。
- 原生侧只做三件事：全屏容器、后台音频会话（锁屏继续播放）、加载失败重试。
- 由 GitHub Actions 在 macOS 云主机上用 XcodeGen + xcodebuild 编译，产出**未签名 IPA**。

## 目录

```
project.yml                               XcodeGen 工程描述
WebShell/AppDelegate.swift                 App 入口
WebShell/ViewController.swift              WKWebView 容器
.github/workflows/build-unsigned-ipa.yml    云编译工作流
```

## 改地址

编辑 `WebShell/ViewController.swift` 里的 `targetURL`，指向你自己部署的 Folia Web 版即可。

## 签名与安装

产物是**未签名 IPA**，不能直接用 App Store / 普通方式安装。任选一种：

- **TrollStore（巨魔）**：直接导入 IPA 永久安装（需系统支持）。
- **Sideloadly / AltStore / SideStore**：用免费 Apple ID 自签，7 天有效，到期重签。

## 已知限制

- 本质是网页壳，不是 Folia 的原生移植：依赖网络；无后端 API 时在线音源不可用。
- 纯 WebView 壳不符合 App Store 审核指南 4.2，仅供自用/侧载，不要提交审核。
- folia-ce.cn 为社区部署版，与官方 Web 版并非完全一致。

## 许可

Folia 本体为 AGPL-3.0，见上游仓库 LICENSE。本壳工程仅提供构建配置。
