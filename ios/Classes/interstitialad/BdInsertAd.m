//
//  InsertAd.m
//  flutter_baiduad
//
//  Created by gstory on 2021/11/29.
//

#import "BdInsertAd.h"
#import "BaiduMobAdSDK/BaiduMobAdExpressInterstitial.h"
#import "BdLogUtil.h"
#import "StringUtls.h"
#import "BaiduAdManager.h"
#import "BUIViewController+getCurrentVC.h"
#import "FlutterBaiduadEvent.h"

@interface BdInsertAd()<BaiduMobAdExpressIntDelegate>
@property(nonatomic,strong) BaiduMobAdExpressInterstitial *bdInsertAd;
@property(nonatomic,strong) NSString *codeId;
@property(nonatomic,strong) NSString *appSid;
@property(nonatomic,assign) BOOL isFullScreen;
@end

@implementation BdInsertAd

+ (instancetype)sharedInstance{
    static BdInsertAd *myInstance = nil;
    if(myInstance == nil){
        myInstance = [[BdInsertAd alloc]init];
    }
    return myInstance;
}

-(void)initAd:(NSDictionary*)arguments{
    NSDictionary *dic = arguments;
    _codeId = dic[@"iosId"];
    _appSid = dic[@"appSid"];
    _isFullScreen = [dic[@"isFullScreen"] boolValue];
    [self loadInsertAd];
}

//预加载插屏广告
-(void)loadInsertAd{
    _bdInsertAd = [[BaiduMobAdExpressInterstitial alloc]init];
    _bdInsertAd.adUnitTag = _codeId;
    _bdInsertAd.delegate = self;
    [_bdInsertAd setPublisherId:[BaiduAdManager sharedInstance].getAppId];
//    _bdInsertAd.interstitialType = BaiduMobAdViewTypeInterstitialOther;
    [_bdInsertAd load];
}

//展示广告
-(void)showInsertAd{
    BOOL ready = [_bdInsertAd isReady];
    if (ready) {
        [_bdInsertAd showFromViewController:[UIViewController jsd_getCurrentViewController]];
    }else{
        GLog(@"视频广告不可用");
        NSDictionary *dictionary = @{@"adType":@"interactAd",@"onAdMethod":@"onUnReady"};
        [[FlutterBaiduadEvent sharedInstance] sentEvent:dictionary];
    }
}


#pragma mark - 广告请求BaiduMobAdExpressIntDelegate

/**
 * 广告请求成功
 */
- (void)interstitialAdLoaded:(BaiduMobAdExpressInterstitial *)interstitial{
    GLog(@"插屏广告请求成功");
    NSDictionary *dictionary = @{@"adType":@"interactAd",@"onAdMethod":@"onReady"};
    [[FlutterBaiduadEvent sharedInstance] sentEvent:dictionary];
}

/**
 * 广告请求失败
 */
- (void)interstitialAdLoadFailed:(BaiduMobAdExpressInterstitial *)interstitial withError:(BaiduMobFailReason)reason{
    GLog(@"插屏广告请求失败");
    NSDictionary *dictionary = @{@"adType":@"interactAd",@"onAdMethod":@"onFail",@"code":@(0),@"message":@(reason)};
    [[FlutterBaiduadEvent sharedInstance] sentEvent:dictionary];
}

/**
 *  广告曝光成功
 */
- (void)interstitialAdExposure:(BaiduMobAdExpressInterstitial *)interstitial{
    GLog(@"插屏广告曝光成功");
    NSDictionary *dictionary = @{@"adType":@"interactAd",@"onAdMethod":@"onExpose"};
    [[FlutterBaiduadEvent sharedInstance] sentEvent:dictionary];
}

/**
 *  广告展现失败
 */
- (void)interstitialAdExposureFail:(BaiduMobAdExpressInterstitial *)interstitial withError:(int)reason{
    GLog(@"插屏广告展现失败 %@",@(reason));
}


/**
 *  广告被关闭
 */
- (void)interstitialAdDidClose:(BaiduMobAdExpressInterstitial *)interstitial{
    GLog(@"插屏广告被关闭");
}

/**
 *  广告被点击
 */
- (void)interstitialAdDidClick:(BaiduMobAdExpressInterstitial *)interstitial{
    GLog(@"插屏广告被点击");
}

/**
 *  广告落地页关闭
 */
- (void)interstitialAdDidLPClose:(BaiduMobAdExpressInterstitial *)interstitial{
    GLog(@"插屏广告落地页关闭");
}

/**
 *  视频缓存成功
 */
- (void)interstitialAdDownloadSucceeded:(BaiduMobAdExpressInterstitial *)interstitial{
    GLog(@"插屏广告视频缓存成功");
   
}

/**
 *  视频缓存失败
 */
- (void)interstitialAdDownLoadFailed:(BaiduMobAdExpressInterstitial *)interstitial{
    GLog(@"插屏广告视频缓存失败");
}

@end
