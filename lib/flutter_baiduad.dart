export 'flutter_baiduad_stream.dart';
export 'flutter_baiduad_code.dart';

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_baiduad/banner/banner_ad_view.dart';
import 'package:flutter_baiduad/native/native_ad_view.dart';
import 'package:flutter_baiduad/splash/splash_ad_view.dart';

part 'flutter_baiduad_callback.dart';

class FlutterBaiduad {
  static const MethodChannel _channel = MethodChannel('flutter_baiduad');

  /// # SDK注册初始化
  /// [androidAppId] andorid广告位id
  /// [iosAppId] ios广告位id
  /// [debug] 是否打印日志
  static Future<bool> register({
    required String androidAppId,
    required String iosAppId,
    bool? debug,
  }) async {
    return await _channel.invokeMethod("register", {
      "iosAppId": iosAppId,
      "androidAppId": androidAppId,
      "debug": debug ?? false,
    });
  }

  ///
  /// # 隐私敏感权限API&限制个性化广告推荐
  /// [readDeviceID] 读取设备ID的权限（建议授权）
  /// [appList] 读取已安装应用列表权限（建议授权）
  /// [location] 读取粗略地理位置权限
  /// [storage] 读写外部存储权限
  /// [personalAds] 设置限制个性化广告推荐
  /// [bDPermission] ios 新标志能力，该能力默认开启，如果有监管或隐私要求，在app内配置是否开启该能力。
  ///
  static Future<bool> privacy(
      {bool? readDeviceID,
      bool? appList,
      bool? location,
      bool? storage,
      bool? personalAds,
      bool? bDPermission}) async {
    return await _channel.invokeMethod("privacy", {
      "readDeviceID": readDeviceID ?? true,
      "appList": appList ?? true,
      "location": location ?? true,
      "storage": storage ?? true,
      "personalAds": personalAds ?? true,
      "bDPermission": bDPermission ?? true
    });
  }

  ///
  /// # 获取SDK版本号
  ///getOAID
  static Future<String> getSDKVersion() async {
    return await _channel.invokeMethod("getSDKVersion");
  }

  ///
  /// # 获取SDK版本号
  ///
  static Future<String> getOAID() async {
    return await _channel.invokeMethod("getOAID");
  }

  ///
  /// # 激励视频广告预加载
  ///
  /// [androidId] android广告ID
  ///
  /// [iosId] ios广告ID
  ///
  ///   [appSid] 支持动态设置APPSID，该信息可从移动联盟获得
  ///
  /// [rewardName] 奖励名称
  ///
  /// [rewardAmount] 奖励金额
  ///
  /// [userID] 用户id
  ///
  /// [customData] 扩展参数，服务器回调使用
  ///
  /// [useSurfaceView] 是否使用SurfaceView，默认使用TextureView
  ///
  /// [isShowDialog] 设置点击跳过时是否展示提示弹框
  ///
  /// [useRewardCountdown] 设置是否展示奖励领取倒计时提示
  ///
  static Future<bool> loadRewardAd({
    required String androidId,
    required String iosId,
    String? appSid,
    required String rewardName,
    required int rewardAmount,
    required String userID,
    String? customData,
    bool? useSurfaceView,
    bool? isShowDialog,
    bool? useRewardCountdown,
  }) async {
    return await _channel.invokeMethod("loadRewardAd", {
      "androidId": androidId,
      "iosId": iosId,
      "appSid": appSid ?? "",
      "rewardName": rewardName,
      "rewardAmount": rewardAmount,
      "userID": userID,
      "customData": customData ?? "",
      "useSurfaceView": useSurfaceView ?? false,
      "isShowDialog": isShowDialog ?? false,
      "useRewardCountdown": useRewardCountdown ?? false,
    });
  }

  ///
  /// # 显示激励广告
  ///
  static Future<bool> showRewardVideoAd() async {
    return await _channel.invokeMethod("showRewardAd", {});
  }

  ///
  /// # banner广告
  /// [androidId] android广告ID
  /// [iosId] ios广告ID
  /// [appSid] 支持动态设置APPSID，该信息可从移动联盟获得。
  /// [autoplay] 是否自动播放
  /// [viewWidth] 广告宽 单位dp
  /// [viewHeight] 广告高  单位dp   推荐 20:3 宽高比，其它尺寸选择 7:3，3:2，2:1
  /// [FlutterTencentAdBannerCallBack]  广告回调
  ///
  static Widget bannerAdView(
      {required String androidId,
      required String iosId,
      String? appSid,
      bool? autoplay,
      required double viewWidth,
      required double viewHeight,
      FlutterBaiduAdBannerCallBack? callBack}) {
    return BannerAdView(
      androidId: androidId,
      iosId: iosId,
      appSid: appSid ?? "",
      autoplay: autoplay ?? false,
      viewWidth: viewWidth,
      viewHeight: viewHeight,
      callBack: callBack,
    );
  }

  ///
  /// # banner广告
  /// [androidId] android广告ID
  /// [iosId] ios广告ID
  /// [appSid] 支持动态设置APPSID，该信息可从移动联盟获得。
  /// [fetchDelay] 请求超时时间 默认超时时间为4200，单位：毫秒
  /// [displayDownloadInfo] 是否显示下载类广告的“隐私”、“权限”等字段 默认值为true
  /// [limitClick] 是否限制点击区域，默认不限制
  /// [displayClick] 是否展示点击引导按钮，默认不展示，若设置可限制点击区域，则此选项默认打开
  /// [popDialogDownLoad]  用户点击开屏下载类广告时，是否弹出Dialog
  ///  此选项设置为true的情况下，会覆盖掉 {SplashAd.KEY_DISPLAY_DOWNLOADINFO} 的设置
  /// [FlutterBaiduAdSplashCallBack]  广告回调
  ///
  static Widget splashAdView(
      {required String androidId,
      required String iosId,
      String? appSid,
      int? fetchDelay,
      bool? displayDownloadInfo,
      bool? limitClick,
      bool? displayClick,
      bool? popDialogDownLoad,
      FlutterBaiduAdSplashCallBack? callBack}) {
    return SplashAdView(
      androidId: androidId,
      iosId: iosId,
      appSid: appSid ?? "",
      fetchDelay: fetchDelay ?? 4200,
      displayDownloadInfo: displayDownloadInfo ?? true,
      limitClick: limitClick ?? false,
      displayClick: displayClick ?? true,
      popDialogDownLoad: popDialogDownLoad ?? true,
      callBack: callBack,
    );
  }

  ///
  /// # 信息流广告（自渲染）
  /// [androidId] android广告ID
  /// [iosId] ios广告ID
  /// [appSid] 支持动态设置APPSID，该信息可从移动联盟获得。
  /// [isCacheVideo] 是否wifi缓存视频物料
  /// [timeOut] 超时
  /// [viewWidth] 广告宽 单位dp
  /// [viewHeight] 广告高  单位dp
  /// [isExpress] true优选 false自渲染
  /// [FlutterBaiduAdNativeCallBack]  广告回调
  ///
  static Widget nativeAdView(
      {required String androidId,
        required String iosId,
        String? appSid,
        bool? isCacheVideo,
        int? timeOut,
        required double viewWidth,
        required double viewHeight,
        bool? isExpress,
        FlutterBaiduAdNativeCallBack? callBack}) {
    return NativeAdView(
      androidId: androidId,
      iosId: iosId,
      appSid: appSid ?? "",
      isCacheVideo: isCacheVideo ?? false,
      timeOut: timeOut ?? 5000,
      viewWidth: viewWidth,
      viewHeight: viewHeight,
      isExpress:isExpress ?? false,
      callBack: callBack,
    );
  }



  ///
  /// # 预加载插屏广告（百度优选）
  ///
  /// [androidId] android广告ID
  ///
  /// [iosId] ios广告ID
  ///
  ///  [isFullScreen] 是否全屏
  ///
  static Future<bool> loadInterstitialAd({
    required String androidId,
    required String iosId,
    required bool isFullScreen,
  }) async {
    return await _channel.invokeMethod("loadInterstitialAd", {
      "androidId": androidId,
      "iosId": iosId,
      "isFullScreen": isFullScreen,
    });
  }

  ///
  /// # 显示插屏广告（百度优选）
  ///
  static Future<bool> showInterstitialAd() async {
    return await _channel.invokeMethod("showInterstitialAd", {});
  }

  ///
  /// # 预加载全屏视频广告
  ///
  /// [androidId] android广告ID
  ///
  /// [iosId] ios广告ID
  ///
  ///  [useSurfaceView] 是否使用SurfaceView，默认使用TextureView
  ///
  static Future<bool> loadFullVideoAd({
    required String androidId,
    required String iosId,
    required bool useSurfaceView,
  }) async {
    return await _channel.invokeMethod("loadFullVideoAd", {
      "androidId": androidId,
      "iosId": iosId,
      "useSurfaceView": useSurfaceView,
    });
  }
}
