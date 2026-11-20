<p align="center"><img src="assets/images/logo/logo.png" width="110" height="110" alt="清映图标"></p>

# 清映 Qingying

清映是基于 PiliPlus 的第三方哔哩哔哩 客户端，支持 Android、iOS、macOS、Windows 和 Linux。

**[下载清映](https://github.com/Sonike/Qingying/releases/latest)** · [历史版本](https://github.com/Sonike/Qingying/releases)

## 这一版有什么

- 推荐页依据接口返回的广告标记过滤推广卡片，内容不足时自动补取。动态和评论的带货过滤默认开启。
- 内置空降助手默认开启，可在「设置 → 其它设置 → 空降助手」中调整社区片段的跳过规则。
- 首页、动态和我的使用紧凑的三项底栏。评论区、频道标签与选中状态采用按用途区分的配色。
- 清映使用独立图标、包名和签名，可与 PiliPlus 同时安装。

## 安装与构建

| 系统 | 安装方式 |
| --- | --- |
| Android ARM64 | 安装 APK。Android 7.0 起支持，可覆盖更新已安装的清映。 |
| iPhone / iPad | 下载 `ios-resign.ipa`，用自己的 Apple 签名和描述文件重签后安装。 |
| macOS | 打开 DMG，将 Qingying 拖到「应用程序」。本版使用临时签名，未做 Apple 公证。 |
| Windows x64 | 完整解压 ZIP，运行其中的 `Qingying.exe`。 |
| Ubuntu 24.04 x64 | 在下载目录运行 `sudo apt install ./Qingying-*-linux-amd64.deb`，然后从应用菜单启动清映。 |

本项目的编译环境、补丁和签名步骤见[清映构建说明](清映构建.md)。

## 项目来源

清映基于 [PiliPlus 2.2.1](https://github.com/bggRGjQaUbCoE/PiliPlus/commit/217fb54f51f6764176319bbdedab2a7522d75401)，沿用上游的 GPLv3 许可证。感谢 PiliPlus 及其贡献者。[许可证](LICENSE) · [上游项目说明](README.PiliPlus.md)
