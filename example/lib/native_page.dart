import 'package:flutter/material.dart';
import 'package:flutter_baiduad/flutter_baiduad.dart';

/// @Author: gstory
/// @CreateDate: 2021/11/24 2:41 下午
/// @Email gstory0404@gmail.com
/// @Description: native信息流广告

class NativePage extends StatefulWidget {
  const NativePage({Key? key}) : super(key: key);

  @override
  _NativePageState createState() => _NativePageState();
}

class _NativePageState extends State<NativePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("native信息流广告"),
      ),
      body: ListView(
        children: [
          FlutterBaiduad.nativeAdView(
              //android广告ID
              androidId: "7792005",
              //ios广告ID
              iosId: "8279206",
              //广告宽 单位dp   初始大小 广告加载完成会自动设置成广告大小
              viewWidth: 400,
              //广告高  单位dp
              viewHeight: 200,
              //超时
              timeOut: 5000,
              //是否wifi缓存视频物料
              isCacheVideo: true,
              //广告回调
              callBack: FlutterBaiduAdNativeCallBack(onShow: () {
                print("信息流广告显示了");
              }, onClose: () {
                print("信息流广告关闭了");
              }, onFail: (code, message) {
                print("信息流广告错误了 $code $message");
              }, onClick: () {
                print("信息流广告点击了");
              }, onExpose: () {
                print("信息流广告曝光了");
              }, onDisLike: () {
                print("信息流广告点击了不感兴趣");
              })),
          FlutterBaiduad.nativeAdView(
              androidId: "7792005",
              iosId: "8279206",
              viewWidth: 300.0,
              viewHeight: 100.0),
          FlutterBaiduad.nativeAdView(
              androidId: "7792005",
              iosId: "8279206",
              viewWidth: 320.0,
              viewHeight: 180.0)
        ],
      ),
    );
  }
}
