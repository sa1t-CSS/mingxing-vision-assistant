# 明行——面向视障人群的实时视觉辅助系统

基于 Flutter 与 Android 原生推理的课程/团队项目。手机相机采集画面，在设备端完成识别，通过中文语音和振动提供环境提示。

## 技术栈

Flutter / Dart / Kotlin / JNI / C++ / NCNN。

## 主要功能

- 相机预览、检测框叠加、环境感知展示与运行设置。
- 障碍物、盲道、楼梯、交通灯相关提示，中文语音与振动提醒。
- Flutter → MethodChannel → Kotlin → JNI/C++ → NCNN 推理链路。
- 核心推理与提示可离线执行；包含模型、类别表、预处理配置和 arm64-v8a 原生运行库。

## 个人贡献

负责移动端界面开发、模型接入与功能测试，完成 Flutter、Kotlin/JNI 与 NCNN 推理链路对接；实现提示逻辑，参与 Android 真机联调与 APK 打包。团队项目的完整实现不应全部归为个人独立开发成果。

## 运行与构建

需要 Flutter SDK（Dart >=3.3、<4.0）、Android SDK、JDK 17，以及 Android 原生构建所需的 NDK/CMake。当前仅配置 `arm64-v8a`。

1. 克隆仓库后，复制 `android/local.properties.example` 为 `android/local.properties`，填写本机 `flutter.sdk` 和 `sdk.dir`。该文件不提交。
2. 在项目根目录执行：

```bash
flutter pub get
flutter analyze
flutter run
```

连接 Android 真机并授权 USB 调试、相机权限。打包调试版本：

```bash
flutter build apk --debug
```

输出通常位于 `build/app/outputs/flutter-apk/app-debug.apk`。首次准备环境和下载依赖需要网络，安装后的核心识别流程可离线运行。

## 目录

| 路径 | 内容 |
| --- | --- |
| `lib/` | Flutter 界面、桥接、提醒逻辑 |
| `android/app/src/main/kotlin/` | Android 方法通道 |
| `android/app/src/main/cpp/` | JNI、推理与 NCNN 头文件 |
| `android/app/src/main/jniLibs/` | arm64-v8a NCNN 运行库 |
| `assets/models/` | 模型与预处理配置 |
| `third_party/flutter_plugin_android_lifecycle/` | 本地依赖覆盖，构建所必需 |
| `docs/algorithm_interface.md` | 算法输入输出协议 |

## 实现边界

当前捆绑模型采用 COCO 类别输出；盲道、楼梯使用轻量图像线索补充，交通灯颜色由附加逻辑判断。它们并非都来自专门训练的四分类模型。模型按 640 输入、8400 候选点适配，替换模型需同步核对输出形状与解码逻辑；当前为 FP32，未宣称完成 INT8 量化或固定推理时延。

这是辅助提示原型，检测和距离估计存在误差，不能据此独立判断道路通行安全。

保留原有第三方声明及代码标注。模型权重与第三方组件的使用和再分发遵循其各自许可；本仓库未额外授予统一开源许可。
