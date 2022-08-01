//
//  SplashAd.m
//  flutter_baiduad
//
//  Created by gstory on 2021/11/29.
//

#import "BdSplashAd.h"
#import "BaiduMobAdSDK/BaiduMobAdSplash.h"
#import "StringUtls.h"
#import "BaiduAdManager.h"
#import "BdLogUtil.h"

@implementation BdSplashAdFactory{
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
    BdSplashAd * splashAd = [[BdSplashAd alloc] initWithWithFrame:frame viewIdentifier:viewId arguments:args binaryMessenger:_messenger];
    
    return splashAd;
    
}

@end

@interface BdSplashAd()<BaiduMobAdSplashDelegate>
@property (nonatomic, strong) BaiduMobAdSplash *splash;
@property(nonatomic,strong) UIView *container;
@property(nonatomic,assign) CGRect frame;
@property(nonatomic,assign) NSInteger viewId;
@property(nonatomic,strong) FlutterMethodChannel *channel;
@property(nonatomic,strong) NSString *appSid;
@property(nonatomic,strong) NSString *codeId;
@property(nonatomic,strong) NSNumber *timeout;
@end

@implementation BdSplashAd

- (instancetype)initWithWithFrame:(CGRect)frame viewIdentifier:(int64_t)viewId arguments:(id)args binaryMessenger:(NSObject<FlutterBinaryMessenger> *)messenger{
    if ([super init]) {
        NSDictionary *dic = args;
        _frame = frame;
        _viewId = viewId;
        _appSid = dic[@"appSid"];
        _codeId = dic[@"iosId"];
        _timeout =dic[@"timeout"];                
        NSString* channelName = [NSString stringWithFormat:@"com.gstory.flutter_baiduad/SplashAdView_%lld", viewId];
        _channel = [FlutterMethodChannel methodChannelWithName:channelName binaryMessenger:messenger];
        [self loadSplashAd];
    }
    return self;
}

- (NSString *)publisherId {
    if([StringUtls isStringEmpty:self.appSid]){
        return [BaiduAdManager sharedInstance].getAppId;
    }
    return self.appSid;
}

- (nonnull UIView *)view {
    return _container;
}

//加载广告
-(void)loadSplashAd{
    _splash = [[BaiduMobAdSplash alloc] init];
    _splash.delegate = self;
    _splash.AdUnitTag =_codeId;
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    _container = [[UIView alloc] initWithFrame:CGRectMake(0,0,window.frame.size.width,window.frame.size.height)];
    _splash.adSize = CGSizeMake(window.frame.size.width, window.frame.size.height);
    [self.splash loadAndDisplayUsingContainerView:_container];
}

# pragma mark -- delegate
/**
 *  广告曝光成功
 */
- (void)splashDidExposure:(BaiduMobAdSplash *)splash{
    GLog(@"开屏广告曝光成功");
    [_channel invokeMethod:@"onExposure" arguments:nil result:nil];
}

/**
 *  广告展示成功
 */
- (void)splashSuccessPresentScreen:(BaiduMobAdSplash *)splash{
    GLog(@"开屏广告展示成功");
    [_channel invokeMethod:@"onShow" arguments:nil result:nil];
}

/**
 *  广告展示失败
 */
- (void)splashlFailPresentScreen:(BaiduMobAdSplash *)splash withError:(BaiduMobFailReason) reason{
    GLog(@"开屏广告展示失败 %d",reason);
    NSDictionary *dictionary = @{@"code":@(0),@"message":@"广告展示失败"};
    [_channel invokeMethod:@"onClose" arguments:dictionary result:nil];
    [self.splash stop];
}

/**
 *  广告被点击
 */
- (void)splashDidClicked:(BaiduMobAdSplash *)splash{
    GLog(@"开屏广告被点击");
    [_channel invokeMethod:@"onClick" arguments:nil result:nil];
}

/**
 *  广告展示结束
 */
- (void)splashDidDismissScreen:(BaiduMobAdSplash *)splash{
    GLog(@"开屏广告展示结束");
    [_channel invokeMethod:@"onClose" arguments:nil result:nil];
    [self.splash stop];
}

/**
 *  广告详情页消失
 */
- (void)splashDidDismissLp:(BaiduMobAdSplash *)splash{
    GLog(@"开屏广告详情页消失");
}

/**
 *  广告加载完成
 *  adType:广告类型 BaiduMobMaterialType
 *  videoDuration:视频时长，仅广告为视频时出现。非视频类广告默认0。 单位ms
 */
- (void)splashDidReady:(BaiduMobAdSplash *)splash
             AndAdType:(NSString *)adType
         VideoDuration:(NSInteger)videoDuration{
    GLog(@"广告加载完成");
}

/**
 * 开屏广告请求成功
 *
 * @param splash 开屏广告对象
 */
- (void)splashAdLoadSuccess:(BaiduMobAdSplash *)splash{
    GLog(@"开屏广告请求成功");
}

/**
 * 开屏广告请求失败
 *
 * @param splash 开屏广告对象
 */
- (void)splashAdLoadFail:(BaiduMobAdSplash *)splash{
    GLog(@"开屏广告请求失败");
    NSDictionary *dictionary = @{@"code":@(0),@"message":@"开屏广告请求失败"};
    [_channel invokeMethod:@"onClose" arguments:dictionary result:nil];
    [self.splash stop];
}

@end
