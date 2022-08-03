import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_baiduad/flutter_baiduad.dart';

/// @Author: gstory
/// @CreateDate: 2021/11/22 6:11 下午
/// @Email gstory0404@gmail.com
/// @Description: 信息流

class NativeAdView extends StatefulWidget {
  final String androidId;
  final String iosId;
  final String? appSid;
  final bool? isCacheVideo;
  final int? timeOut;
  final double viewWidth;
  final double viewHeight;
  final bool? isExpress;
  final FlutterBaiduAdNativeCallBack? callBack;

  const NativeAdView(
      {Key? key,
      required this.androidId,
      required this.iosId,
      this.appSid,
      required this.viewWidth,
      required this.viewHeight,
      this.callBack,
      this.isCacheVideo,
      this.isExpress,
      this.timeOut})
      : super(key: key);

  @override
  _NativeAdViewState createState() => _NativeAdViewState();
}

class _NativeAdViewState extends State<NativeAdView> {
  final String _viewType = "com.gstory.flutter_baiduad/NativeAdView";

  MethodChannel? _channel;

  //广告是否显示
  bool _isShowAd = true;

  double _width = 0;
  double _height = 0;

  @override
  void initState() {
    super.initState();
    _isShowAd = true;
    _width = widget.viewWidth;
    _height = widget.viewHeight;
  }

  @override
  Widget build(BuildContext context) {
    if (!_isShowAd) {
      return Container();
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      return SizedBox(
        width: _width,
        height: _height,
        child: AndroidView(
          viewType: _viewType,
          creationParams: {
            "androidId": widget.androidId,
            "appSid": widget.appSid,
            "isCacheVideo": widget.isCacheVideo,
            "timeOut": widget.timeOut,
            "viewWidth": widget.viewWidth,
            "viewHeight": widget.viewHeight,
            "isExpress": widget.isExpress,
          },
          onPlatformViewCreated: _registerChannel,
          creationParamsCodec: const StandardMessageCodec(),
        ),
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return SizedBox(
        width: _width,
        height: _height,
        child: UiKitView(
          viewType: _viewType,
          creationParams: {
            "iosId": widget.iosId,
            "appSid": widget.appSid,
            "viewWidth": widget.viewWidth,
            "viewHeight": widget.viewHeight,
            "isCacheVideo": widget.isCacheVideo,
            "timeOut": widget.timeOut,
            "isExpress": widget.isExpress,
          },
          onPlatformViewCreated: _registerChannel,
          creationParamsCodec: const StandardMessageCodec(),
        ),
      );
    } else {
      return Container();
    }
  }

  //注册cannel
  void _registerChannel(int id) {
    _channel = MethodChannel("${_viewType}_$id");
    _channel?.setMethodCallHandler(_platformCallHandler);
  }

  //监听原生view传值
  Future<dynamic> _platformCallHandler(MethodCall call) async {
    print("信息流传回值===》${call.arguments}");
    switch (call.method) {
      //显示广告
      case FlutterBaiduAdMethod.onShow:
        Map map = call.arguments;
        if (mounted) {
          setState(() {
            _width = (map["width"]).toDouble();
            _height = (map["height"]).toDouble();
          });
        }
        widget.callBack?.onShow!();
        break;
      //广告加载失败
      case FlutterBaiduAdMethod.onFail:
        if (mounted) {
          setState(() {
            _isShowAd = false;
          });
        }
        Map map = call.arguments;
        widget.callBack?.onFail!(map["code"], map["message"]);
        break;
      //点击
      case FlutterBaiduAdMethod.onClick:
        widget.callBack?.onClick!();
        break;
      //曝光
      case FlutterBaiduAdMethod.onExpose:
        widget.callBack?.onExpose!();
        break;
      //关闭
      case FlutterBaiduAdMethod.onClose:
        if (mounted) {
          setState(() {
            _isShowAd = false;
          });
        }
        widget.callBack?.onClose!();
        break;
      //不感兴趣
      case FlutterBaiduAdMethod.onDisLike:
        if (mounted) {
          setState(() {
            _isShowAd = false;
          });
        }
        widget.callBack?.onDisLike!();
        break;
    }
  }
}
