//
//  BannerView.m
//  Pods
//
//  Created by gstory on 2021/11/27.
//

#import <Foundation/Foundation.h>
#import "BdBannerView.h"
#import "BaiduMobAdSDK/BaiduMobAdView.h"
#import "StringUtls.h"
#import "BaiduAdManager.h"
#import "BdLogUtil.h"

@implementation BdBannerViewFactory{
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
    BdBannerView * bannerView = [[BdBannerView alloc] initWithWithFrame:frame viewIdentifier:viewId arguments:args binaryMessenger:_messenger];
    
    return bannerView;
    
}

@end


@interface BdBannerView()<BaiduMobAdViewDelegate>
@property(nonatomic,strong) BaiduMobAdView *bdBannerView;
@property(nonatomic,strong) UIView *container;
@property(nonatomic,assign) NSInteger viewId;
@property(nonatomic,strong) FlutterMethodChannel *channel;
@property(nonatomic,strong) NSString *appSid;
@property(nonatomic,strong) NSString *codeId;
@property(nonatomic,strong) NSNumber *width;
@property(nonatomic,strong) NSNumber *height;
@end

@implementation BdBannerView

- (instancetype)initWithWithFrame:(CGRect)frame viewIdentifier:(int64_t)viewId arguments:(id)args binaryMessenger:(NSObject<FlutterBinaryMessenger> *)messenger{
    if ([super init]) {
        self.viewId = viewId;
        self.appSid = args[@"appSid"];
        self.codeId = args[@"iosId"];
        self.width =args[@"viewWidth"];
        self.height =args[@"viewWidth"];
        self.container= [[UIView alloc] initWithFrame:frame];
        NSString* channelName = [NSString stringWithFormat:@"com.gstory.flutter_baiduad/BannerView_%lld", viewId];
        _channel = [FlutterMethodChannel methodChannelWithName:channelName binaryMessenger:messenger];
        [self loadBannerAd];
    }
    return self;
}

//加载广告
-(void)loadBannerAd{
    //load横幅
    [self.container removeFromSuperview];
    self.bdBannerView = [[BaiduMobAdView alloc] init];
    self.bdBannerView.frame = CGRectMake(0, 0, _width.floatValue, _height.floatValue);
    self.bdBannerView.AdUnitTag = self.codeId;
    self.bdBannerView.AdType = BaiduMobAdViewTypeBanner;
    self.bdBannerView.delegate = self;
    [self.container addSubview:self.bdBannerView];
    [self.bdBannerView start];
}

# pragma mark -- delegate
-(NSString *)publisherId{
    if([StringUtls isStringEmpty:self.appSid]){
        return [BaiduAdManager sharedInstance].getAppId;
    }
    return self.appSid;
}

- (NSString *)channelId{
    return @"";
}
/**
 *  启动位置信息
 */
- (BOOL)enableLocation
{
    return YES;
}

/**
 *  广告将要被载入
 */
- (void)willDisplayAd:(BaiduMobAdView *)adview{
    GLog(@"横幅广告: 加载成功");

}

/**
 *  广告载入失败
 */
- (void)failedDisplayAd:(BaiduMobFailReason)reason{
    GLog(@"横幅广告: 加载失败 %d", reason);
    NSDictionary *dictionary = @{@"code":@(0),@"message":@"广告展示失败"};
    [_channel invokeMethod:@"onClose" arguments:dictionary result:nil];
}


/**
 *  本次广告展示成功时的回调
 */
- (void)didAdImpressed{
    GLog(@"横幅广告: 展示了");
    [_channel invokeMethod:@"onShow" arguments:nil result:nil];
}

/**
 *  本次广告展示被用户点击时的回调
 */
- (void)didAdClicked{
    GLog(@"横幅广告: 点击了");
    [_channel invokeMethod:@"onClick" arguments:nil result:nil];
}

/**
 *  在用户点击完广告条出现全屏广告页面以后，用户关闭广告时的回调
 */
- (void)didDismissLandingPage{
    GLog(@"横幅广告: 关闭落地页");
}

/**
 *  用户点击关闭按钮关闭广告后的回调
 */
- (void)didAdClose{
    GLog(@"横幅广告: 关闭");
    [_channel invokeMethod:@"onClose" arguments:nil result:nil];
}



-(UIView *)view{
    return self.container;
    
}

@end
