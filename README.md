# 百度 百青藤广告SDK flutter版本插件

<p>
<a href="https://pub.flutter-io.cn/packages/flutter_baiduad"><img src=https://img.shields.io/badge/flutter_baiduad-v0.0.2-success></a>
</p>

## 简介
flutter_baiduad是一款集成了百度广告(百青藤)Android和iOS SDK的Flutter插件,方便直接调用百度广告(百青藤)SDK方法快速开发

由于百青藤需要上架应用才能使用广告，所以demo不能直接运行

## 官方文档
* [Android](https://union.baidu.com/miniappblog/2020/12/01/newAndroidSDK/)
* [IOS](https://union.baidu.com/miniappblog/2020/08/11/iOSSDK/)

## 本地环境
```
[✓] Flutter (Channel stable, 2.2.3, on macOS 11.5.1 20G80 darwin-x64, locale zh-Hans-CN)
[✓] Android toolchain - develop for Android devices (Android SDK version 30.0.2)
[✓] Xcode - develop for iOS and macOS
[✓] Chrome - develop for the web
[✓] Android Studio (version 2020.3)
[✓] VS Code (version 1.56.2)
[✓] Connected device (2 available)

```

## 集成步骤
#### 1、pubspec.yaml
```dart
flutter_baiduad:
    git:
      url: https://github.com/gstory0404/flutter_baiduad.git
      ref: 12fe6829b0947d45caea543f2c2eeacaa07c4649
```
引入
```Dart
import 'package:flutter_baiduad/flutter_baiduad.dart';
```
#### 2、Android
SDK(9.202)已配置插件中无需额外配置，只需要在android目录中AndroidManifest.xml配置
```Java
<manifest ···
    xmlns:tools="http://schemas.android.com/tools"
    ···>

    <!-- SDK相关权限声明 -->
    <!--  -->
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
    <uses-permission android:name="android.permission.ACCESS_WIFI_STATE" />
    <uses-permission android:name="android.permission.READ_PHONE_STATE" />
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" /> <!-- targetSdkVersion >= 26 时需要配置此权限，否则无法进行安装app的动作 -->
    <uses-permission android:name="android.permission.REQUEST_INSTALL_PACKAGES" /> <!-- 如果有视频相关的广告且使用textureView播放，请务必添加，否则黑屏 -->
    <uses-permission android:name="android.permission.WAKE_LOCK" /> <!-- Android 11系统上，如果你的应用targetSdkVersion >= 30，需要配置权限QUERY_ALL_PACKAGES，SDK将通过此权限正常触发广告行为，并保证广告的正确投放。此权限需要在用户隐私文档中声明。 -->
    <uses-permission android:name="android.permission.QUERY_ALL_PACKAGES" /> <!-- Demo 内容联盟锁屏场景 从Android 9.0开始 创建前台Service -->
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE" /> <!-- Demo 内容联盟锁屏场景 悬浮窗权限 -->
    <uses-permission android:name="android.permission.SYSTEM_ALERT_WINDOW" />
  <application
        tools:replace="android:label">
```

#### 3、IOS

SDK(4.861)已配置插件中，其余根据文档配置。因为使用PlatformView，在Info.plist加入
```
 <key>io.flutter.embedded_views_preview</key>
    <true/>
```

## 使用

#### 1、SDK初始化
```Dart
await FlutterBaiduad.register(
    //百青藤广告 Android appid 必填
    androidAppId: "b423d90d",
    iosAppId: "a6b7fed6",
    //是否打印日志 发布时改为false
    debug: true,
);
```
#### 2、获取SDK版本
```Dart
 await FlutterBaiduad.getSDKVersion();
```

#### 3、隐私敏感权限API&限制个性化广告推荐
```dart
await FlutterBaiduad.privacy(
        //android读取设备ID的权限（建议授权）  ios是否新的设备标志能力
        readDeviceID: false,
        //读取已安装应用列表权限（建议授权）
        appList: false,
        //读取粗略地理位置权限
        location: false,
        //读写外部存储权限
        storage: false,
        //设置限制个性化广告推荐
        personalAds: false,
        // ios 新标志能力，该能力默认开启，如果有监管或隐私要求，在app内配置是否开启该能力。
        bDPermission: false,
      );
```

#### 4、banner广告
```Dart
FlutterBaiduad.bannerAdView(
    androidId: "7793088", //android广告位
    iosId: "7800783", //ios广告位
    viewWidth: 200, //推荐您将Banner的宽高比固定为20：3以获得最佳的广告展示效果
    viewHeight: 40,
    callBack: FlutterBaiduAdBannerCallBack(
      onShow: (){
        print("Banner横幅广告显示了");
        },
        onClick: (){
          print("Banner横幅广告点击了");
        },
        onFail: (code,message){
          print("Banner横幅广告失败了 $code $message");
        },
        onClose: (){
          print("Banner横幅广告关闭了");
        }
    ),
),
```

#### 5、开屏广告
```dart
FlutterBaiduad.splashAdView(
            //android广告ID
            androidId: "7792007",
            //ios广告ID
            iosId: "7803231",
            //请求超时时间 默认超时时间为4200，单位：毫秒
            fetchDelay: 3000,
            //是否显示下载类广告的“隐私”、“权限”等字段 默认值为true
            displayDownloadInfo: true,
            //是否限制点击区域，默认不限制
            limitClick: true,
            //是否展示点击引导按钮，默认不展示，若设置可限制点击区域，则此选项默认打开
            displayClick: true,
            //用户点击开屏下载类广告时，是否弹出Dialog
            // 此选项设置为true的情况下，会覆盖掉 {SplashAd.KEY_DISPLAY_DOWNLOADINFO} 的设置
            popDialogDownLoad: true,
            //开屏广告回调
            callBack: FlutterBaiduAdSplashCallBack(onShow: () {
                   print("开屏广告显示了");
                }, onClick: () {
                   print("开屏广告点击了");
                }, onFail: (code, message) {
                   print("开屏广告加载失败了  $code  $message");
                   Navigator.pop(context);
                }, onClose: () {
                   print("开屏广告关闭了");
                   Navigator.pop(context);
            })),
```

#### 6、激励视频广告
预加载激励视频广告
```Dart
await FlutterBaiduad.loadRewardAd(
    //android广告id
    androidId: "7792010",
    //ios广告id
    iosId: "7800949",
    //支持动态设置APPSID，该信息可从移动联盟获得
    appSid: "",
    //用户id
    userID: "123",
    //奖励
    rewardName: "100金币",
    //奖励数
    rewardAmount: 100,
    //扩展参数 服务器验证使用
    customData: "",
    //是否使用SurfaceView
    useSurfaceView: false,
    //设置点击跳过时是否展示提示弹框
    isShowDialog: true,
    //设置是否展示奖励领取倒计时提示
    useRewardCountdown: true,
    );
```
显示激励视频广告
```dart
FlutterBaiduad.showRewardVideoAd();
```
监听激励视频结果

```Dart
 FlutterBaiduAdStream.initAdStream(
//激励广告结果监听
flutterBaiduAdRewardCallBack: FlutterBaiduAdRewardCallBack(
    onShow: () {
      print("激励广告显示");
    },
    onClose: () {
      print("激励广告关闭");
    },
    onFail: (code, message) {
      print("激励广告失败 $code $message");
    },
    onClick: () {
      print("激励广告点击");
    },
    onSkip: () {
      print("激励广告跳过");
    },
    onReady: () {
      print("激励广告预加载准备就绪");
      //展示激励广告
      FlutterBaiduad.showRewardVideoAd();
    },
    onUnReady: () {
      print("激励广告预加载未准备就绪");
    },
    onFinish: () {
      print("激励广告完成");
    },
    onVerify: (verify, rewardName, rewardAmount) {
      print("激励广告奖励  $verify   $rewardName   $rewardAmount");
    },
),
```
#### 7、插屏广告
预加载插屏广告
```dart
FlutterBaiduad.loadInterstitialAd(
    //android广告位id
    androidId: "7792008",
    //ios广告位id
    iosId: "7792008",
    //是否全屏
    isFullScreen: false
);
```

显示插屏广告
```dart
await FlutterBaiduad.showInterstitialAd();
```

插屏广告结果监听
```dart
FlutterBaiduAdStream.initAdStream(
    flutterBaiduAdInteractionCallBack: FlutterBaiduAdInteractionCallBack(
    onClose: () {
      print("插屏广告关闭了");
    },
    onFail: (code, message) {
      print("插屏广告出错了 $code $message");
    },
    onClick: () {
      print("插屏广告点击了");
    },
    onShow: () {
      print("插屏广告显示了");
    },
    onReady: () async{
      print("插屏广告准备就绪"); 
      //展示广告
      await FlutterBaiduad.showInterstitialAd();
    },
    onUnReady: () {
      print("插屏广告未准备就绪");
    },
    onExpose: () {
      print("插屏广告曝光");
    },
    ));
```

## 版本更新

[更新日志](https://github.com/gstory0404/flutter_baiduad/blob/master/CHANGELOG.md)

## 插件链接

|插件|地址|
|:----|:----|
|穿山甲广告插件|[flutter_unionad](https://github.com/gstory0404/flutter_unionad)|
|腾讯优量汇广告插件|[flutter_tencentad](https://github.com/gstory0404/flutter_tencentad)|
|聚合广告插件|[flutter_universalad](https://github.com/gstory0404/flutter_universalad)|
|百度百青藤广告插件|[flutter_baiduad](https://github.com/gstory0404/flutter_baiduad)|
|字节穿山甲内容合作插件|[flutter_pangrowth](https://github.com/gstory0404/flutter_pangrowth)|
|文档预览插件|[file_preview](https://github.com/gstory0404/file_preview)|
|滤镜|[gpu_image](https://github.com/gstory0404/gpu_image)|

## 联系方式
* Email: gstory0404@gmail.com
* Blog：https://gstory.vercel.app/

* QQ群: <a target="_blank" href="https://qm.qq.com/cgi-bin/qm/qr?k=4j2_yF1-pMl58y16zvLCFFT2HEmLf6vQ&jump_from=webapi"><img border="0" src="//pub.idqqimg.com/wpa/images/group.png" alt="649574038" title="flutter交流"></a>
