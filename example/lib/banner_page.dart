import 'package:flutter/material.dart';
import 'package:flutter_baiduad/flutter_baiduad.dart';

/// @Author: gstory
/// @CreateDate: 2021/11/24 10:21 上午
/// @Email gstory0404@gmail.com
/// @Description: dart类作用描述

class BannerPage extends StatefulWidget {
  const BannerPage({Key? key}) : super(key: key);

  @override
  _BannerPageState createState() => _BannerPageState();
}

class _BannerPageState extends State<BannerPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Banner横幅广告"),
      ),
      body: Column(
        children: [
          FlutterBaiduad.bannerAdView(
            androidId: "7792006",
            iosId: "7800783",
            viewWidth: 200, //推荐您将Banner的宽高比固定为20：3以获得最佳的广告展示效果
            viewHeight: 30,
            autoplay: true,
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
          FlutterBaiduad.bannerAdView(
            androidId: "7792006",
            iosId: "7800783",
            viewWidth: 200, //推荐您将Banner的宽高比固定为20：3以获得最佳的广告展示效果
            viewHeight: 30,
          ),
          FlutterBaiduad.bannerAdView(
            androidId: "7792006",
            iosId: "7800783",
            viewWidth: 200, //推荐您将Banner的宽高比固定为20：3以获得最佳的广告展示效果
            viewHeight: 30,
          ),
        ],
      ),
    );
  }

  _getAppBar(){
    return Container();
  }
}
