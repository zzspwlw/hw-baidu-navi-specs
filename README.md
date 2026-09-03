# HwBaiduNaviKit pod 仓库

给 HBuilderX 云打包提供 `HwBaiduNaviKit 7.2.0`。仓库只放 podspec 文本（几 KB），
二进制 zip（约 187MB）托管在 OSS，pod install 时由 podspec 的 `prepare_command`
下载并解包——既走 DCloud 云打包验证过的 `repo` 集成路径，又不占用 git/LFS 配额。

## 目录结构（pow-bmapx 同款 repo 形态）

```
HwBaiduNaviKit.podspec.json   # podspec 必须在仓库根
```

## 插件 config.json 用法（dev_map_navigation 分支）

```json
"dependencies-pods": [
  {
    "name": "HwBaiduNaviKit",
    "repo": {
      "git": "https://github.com/zzspwlw/hw-baidu-navi-specs.git",
      "tag": "7.2.0"
    }
  }
]
```

## 原理与注意

- `repo` 等价 CocoaPods `pod 'HwBaiduNaviKit', :git => ..., :tag => ...`：
  云端 clone 本仓库根部的 podspec，再执行 `prepare_command`
  （`curl` OSS zip + `unzip`），vendored framework 路径随后即可解析。
- podspec 的 `source.http` 字段保留，作为标准 CocoaPods 语义的兜底声明。
- 仓库必须公网可匿名 clone（当前 GitHub `zzspwlw/hw-baidu-navi-specs`）。
- OSS zip 必须公共读；更新二进制时：换 zip → 改 podspec 版本/URL →
  提交并移动 tag（当前 `7.2.0`）。
- 验证记录：GitHub Actions `pod-probe` 分支实测 repo+prepare_command
  `BUILD SUCCEEDED`，`OTHER_LDFLAGS` 含 `-framework BaiduMapAPI_Base/BaiduMapAPI_Map/BaiduNaviSDK`。
