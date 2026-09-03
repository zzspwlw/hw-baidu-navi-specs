# HwBaiduNaviKit Spec 仓库

给 HBuilderX 云打包提供 `HwBaiduNaviKit 7.2.0` 的 podspec 索引（二进制 zip 托管在
OSS，podspec 通过 `source.http` 指向它）。

## 目录结构（CocoaPods spec repo 标准布局）

```
HwBaiduNaviKit/7.2.0/HwBaiduNaviKit.podspec.json
```

## 插件 config.json 用法

```json
"dependencies-pods": [
  {
    "name": "HwBaiduNaviKit",
    "version": "7.2.0",
    "source": "<本仓库 git 地址>"
  }
]
```

## 注意

- 仓库必须公网可匿名 clone（gitee / gitcode / github），DCloud 云构建无凭据通道。
- podspec 里的 `source.http` 必须指向 OSS 公共读 zip 直链。
- 不要用 `repo` 字段指向本仓库：`repo` 等价 `pod 'X', :git => ...`，
  会把 git 检出内容当 pod 本体，不会下载 OSS zip。
- 二进制有更新时：替换 OSS zip → 修改 podspec → 重新打 tag（如 `7.2.0`）。
