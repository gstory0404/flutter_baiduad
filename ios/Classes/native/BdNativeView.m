//
//  BdNativeView.m
//  flutter_baiduad
//
//  Created by gstory on 2022/7/28.
//

#import <Foundation/Foundation.h>
#import "BdNativeView.h"
#import "BaiduMobAdSDK/BaiduMobAdNative.h"
#import "BaiduMobAdSDK/BaiduMobAdExpressNativeView.h"
#import "StringUtls.h"
#import "BaiduAdManager.h"
#import "BdLogUtil.h"

@implementation BdNativeViewFactory{
    NSObject<FlutterBinaryMessenger>*_messenger;
}

- (instancetype)initWithMessenger:(NSObject<FlutterBinaryMessenger> *)messager{
    self = [super init];
    if (self) {
        _messenger = messager;
    }
    return self;
}

-(NSObject<FlutterMessageCodec> *)createArgsCodec{
    return [FlutterStandardMessageCodec sharedInstance];
}

-(NSObject<FlutterPlatformView> *)createWithFrame:(CGRect)frame viewIdentifier:(int64_t)viewId arguments:(id)args{
    BdNativeView * bdNativeView = [[BdNativeView alloc] initWithWithFrame:frame viewIdentifier:viewId arguments:args binaryMessenger:_messenger];
    return bdNativeView;
}

@end


@interface BdNativeView()<BaiduMobAdNativeAdDelegate>
@property(nonatomic,strong) BaiduMobAdNative *nativeAd;
@property(nonatomic,strong) UIView *container;
@property(nonatomic,assign) NSInteger viewId;
@property(nonatomic,strong) FlutterMethodChannel *channel;
@property(nonatomic,strong) NSString *appSid;
@property(nonatomic,strong) NSString *codeId;
@property(nonatomic,strong) NSNumber *width;
@property(nonatomic,strong) NSNumber *height;
@end

@implementation BdNativeView

- (instancetype)initWithWithFrame:(CGRect)frame viewIdentifier:(int64_t)viewId arguments:(id)args binaryMessenger:(NSObject<FlutterBinaryMessenger> *)messenger{
    if ([super init]) {
        self.viewId = viewId;
        self.appSid = args[@"appSid"];
        self.codeId = args[@"iosId"];
        self.width =args[@"viewWidth"];
        self.height =args[@"viewWidth"];
        self.container= [[UIView alloc] initWithFrame:frame];
        NSString* channelName = [NSString stringWithFormat:@"com.gstory.flutter_baiduad/NativeAdView_%lld", viewId];
        _channel = [FlutterMethodChannel methodChannelWithName:channelName binaryMessenger:messenger];
        [self loadNativeAd];
    }
    return self;
}

//加载广告
-(void)loadNativeAd{
    GLog(@"信息流广告: codeId=>%@",self.codeId);
    [self.container removeFromSuperview];
    if (!self.nativeAd) {
        self.nativeAd = [[BaiduMobAdNative alloc] init];
        self.nativeAd.adDelegate = self;
        if([StringUtls isStringEmpty:self.appSid]){
            self.nativeAd.publisherId = [BaiduAdManager sharedInstance].getAppId;
        }else{
            self.nativeAd.publisherId =self.appSid;
        }
    }
    self.nativeAd.adUnitTag = self.codeId;
    self.nativeAd.baiduMobAdsWidth = self.width;
    // 配置请求优选模板
    self.nativeAd.isExpressNativeAds = YES;
    [self.nativeAd requestNativeAds];
}

//广告请求成功
//请求成功的BaiduMobAdNativeAdObject数组
//如果是优选模板，nativeAds为BaiduMobAdExpressNativeView数组
- (void)nativeAdObjectsSuccessLoad:(NSArray *)nativeAds nativeAd:(BaiduMobAdNative *)nativeAd{
    GLog(@"信息流广告: 请求成功 数量=>%lu",[nativeAds count]);
    for (int i = 0; i < nativeAds.count; i++){
        BaiduMobAdExpressNativeView *view = [nativeAds objectAtIndex:i];
        GLog(@"信息流广告: 请求成功 是否过期=>%d",view.isExpired);
        GLog(@"信息流广告: 请求成功 广告类型=>%ld",view.style_type);
        // 展现前检查是否过期，30分钟广告将过期，如果广告过期，请放弃展示并重新请求
        if ([view isExpired]) {
            continue;
        }
        view.width = self.codeId.floatValue;
        GLog(@"信息流广告: 请求开启渲染 ");
        //开始渲染
        [view render];
        GLog(@"信息流广告: 请求开启渲染 2");
    }
}

//广告请求失败
//失败的错误码 errCode
//失败的原因 message
- (void)nativeAdsFailLoadCode:(NSString *)errCode message:(NSString *)message nativeAd:(BaiduMobAdNative *)nativeAd{
    GLog(@"信息流广告: 请求失败 %@  %@",errCode,message);
    NSDictionary *dictionary = @{@"code":errCode,@"message":message};
      [_channel invokeMethod:@"onFail" arguments:dictionary result:nil];
}

//广告曝光成功
- (void)nativeAdExposure:(UIView *)nativeAdView nativeAdDataObject:(BaiduMobAdNativeAdObject *)object{
    GLog(@"信息流广告: 曝光成功");
    [_channel invokeMethod:@"onExpose" arguments:nil result:nil];
}

//优选模板组件渲染成功
//组件调用render渲染完成后会回调
- (void)nativeAdExpressSuccessRender:(BaiduMobAdExpressNativeView *)express nativeAd:(BaiduMobAdNative *)nativeAd{
    GLog(@"信息流广告: 优选模板组件渲染成功");
    [express trackImpression];
    [self.container addSubview:express];
    NSDictionary *dictionary = @{@"width": @(express.width),@"height":@(express.height)};
     [_channel invokeMethod:@"onShow" arguments:dictionary result:nil];
}

//广告点击
- (void)nativeAdClicked:(UIView *)nativeAdView nativeAdDataObject:(BaiduMobAdNativeAdObject *)object{
    GLog(@"信息流广告: 点击");
    [_channel invokeMethod:@"onClick" arguments:nil result:nil];
}

//广告详情页关闭
- (void)didDismissLandingPage:(UIView *)nativeAdView{
    GLog(@"信息流广告: 广告详情页关闭");
    [_channel invokeMethod:@"onClose" arguments:nil result:nil];
}

//联盟官网点击跳转
- (void)unionAdClicked:(UIView *)nativeAdView nativeAdDataObject:(BaiduMobAdNativeAdObject *)object{
    GLog(@"信息流广告: 联盟官网点击跳转");
}

//广告曝光失败
- (void)nativeAdExposureFail:(UIView *)nativeAdView nativeAdDataObject:(BaiduMobAdNativeAdObject *)object failReason:(int)reason{
    GLog(@"信息流广告: 广告曝光失败");
    NSDictionary *dictionary = @{@"code":@(-1),@"message":@"原生模板广告渲染失败"};
      [_channel invokeMethod:@"onFail" arguments:dictionary result:nil];
}

//优选模板负反馈展现
- (void)nativeAdDislikeShow:(UIView *)adView{
    GLog(@"信息流广告: 优选模板负反馈展现");
}

//优选模板负反馈点击
- (void)nativeAdDislikeClick:(UIView *)adView{
    GLog(@"信息流广告: 优选模板负反馈点击");
    [_channel invokeMethod:@"onDisLike" arguments:nil result:nil];
}

//优选模板负反馈关闭
- (void)nativeAdDislikeClose:(UIView *)adView{
    GLog(@"信息流广告: 优选模板负反馈关闭");
}



-(UIView *)view{
    return self.container;
}

@end
