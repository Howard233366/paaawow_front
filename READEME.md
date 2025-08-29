安卓启动流程：
安装flutter：
在编辑器中的扩展下载，注意左下角提示，会连带安装所需的其他东西，全部同意

dart、gradle等配置，你应该已经下载，可能需要在项目中修改路径


### 以下命令按顺序执行：
项目启动前先检查flutter配置状态
flutter doctor 

检查项目问题报错
flutter analyze

安装项目依赖
flutter pub get


### 在配置完环境后，可以开始运行

    1.运行到连接的设备
    flutter run

    2.指定设备运行
    flutter run -d <设备ID>

    3.用Android studio运行

### 一些其他命令

##### 创建apk文件，检查项目的问题
flutter build apk --debug

##### 构建发布包
flutter build apk --release  # Android
flutter build ios --release  # iOS

flutter run --debug --verbose

flutter logs


跨平台运行：
    flutter run -d ios
    # iOS不像Android那样开放
    Android: 可以直接安装APK文件
    iOS: 必须通过App Store或开发者签名安装
    # Xcode包含：
    - iOS SDK: iOS系统API和框架
    - iOS模拟器: 在Mac上模拟iPhone/iPad
    - 编译工具链: 将代码编译为iOS可执行文件
    - 签名工具: 应用签名和证书管理

    # Flutter iOS构建流程：
    1. Flutter代码 → Dart编译器
    2. 生成iOS项目 → 需要iOS SDK
    3. 编译原生iOS代码 → 需要Xcode工具链
    4. 打包签名 → 需要Xcode签名工具
    5. 安装到设备 → 需要iOS部署工具

    flutter run -d android

地图功能：
    SHA1指纹： 90:0C:46:9E:55:96:6C:6E:A1:64:D8:FB:3D:F8:C6:6F:B3:8F:4C:C3
    PackageName: com.pettalk.translator.pet_talk


