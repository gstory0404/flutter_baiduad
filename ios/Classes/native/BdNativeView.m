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
#import "BaiduMobAdSDK/BaiduMobAdNativeAdObject.h"
#import "BaiduMobAdSDK/BaiduMobAdNativeAdView.h"
#import "BaiduMobAdSDK/BaiduMobAdNativeVideoView.h"
#import "BaiduMobAdSDK/BaiduMobAdNativeWebView.h"
#import "BaiduMobAdSDK/BaiduMobAdActButton.h"


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
@property(nonatomic,assign) BOOL isExpress;
@end

@implementation BdNativeView

- (instancetype)initWithWithFrame:(CGRect)frame viewIdentifier:(int64_t)viewId arguments:(id)args binaryMessenger:(NSObject<FlutterBinaryMessenger> *)messenger{
    if ([super init]) {
        self.viewId = viewId;
        self.appSid = args[@"appSid"];
        self.codeId = args[@"iosId"];
        self.width =args[@"viewWidth"];
        self.height =args[@"viewWidth"];
        self.isExpress = [args[@"isExpress"] boolValue];
        self.container= [[UIView alloc] initWithFrame:frame];
        NSString* channelName = [NSString stringWithFormat:@"com.gstory.flutter_baiduad/NativeAdView_%lld", viewId];
        _channel = [FlutterMethodChannel methodChannelWithName:channelName binaryMessenger:messenger];
        [self loadNativeAd];
    }
    return self;
}

//加载广告
-(void)loadNativeAd{
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.width.floatValue, self.height.floatValue)];
    titleLabel.font = [UIFont systemFontOfSize:14.0];
    titleLabel.text = @"123123";
    [self.container addSubview:titleLabel];
    
    GLog(@"信息流广告: codeId=>%@",self.codeId);
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
    GLog(@"信息流广告: 是否是优选 %d",self.isExpress);
    // 配置请求优选模板
    self.nativeAd.isExpressNativeAds = self.isExpress;
    [self.nativeAd requestNativeAds];
}

//广告请求成功
//请求成功的BaiduMobAdNativeAdObject数组
//如果是优选模板，nativeAds为BaiduMobAdExpressNativeView数组
- (void)nativeAdObjectsSuccessLoad:(NSArray *)nativeAds nativeAd:(BaiduMobAdNative *)nativeAd{
    
    if(self.isExpress){
        GLog(@"信息流广告: 优选请求成功 数量=>%lu",[nativeAds count]);
        for (int i = 0; i < nativeAds.count; i++){
            BaiduMobAdExpressNativeView *view = [nativeAds objectAtIndex:i];
//            GLog(@"信息流广告: 请求成功 是否过期=>%d",view.isExpired);
//            GLog(@"信息流广告: 请求成功 广告类型=>%ld",view.style_type);
            // 展现前检查是否过期，30分钟广告将过期，如果广告过期，请放弃展示并重新请求
            if ([view isExpired]) {
                continue;
            }
            if (!view) {
                GLog(@"创建信息流视图失败");
            }
            view.width = self.codeId.floatValue;
            //开始渲染
            [view render];
        }
    }else{
        GLog(@"信息流广告: 自渲染请求成功 数量=>%lu",[nativeAds count]);
        for(int i = 0; i < [nativeAds count]; i++){
            BaiduMobAdNativeAdObject *object = [nativeAds objectAtIndex:i];
            //过滤超过30分钟的广告
            if(object.isExpired){
                GLog(@"信息流广告: 广告已过期");
                continue;
            }
            BaiduMobAdNativeAdView *view = [self createNativeAdViewWithframe:CGRectMake(0, 0, self.width.floatValue, self.height.floatValue) object:object];
            if (!view) {
                GLog(@"信息流广告: 创建信息流视图失败");
            }
            // 加载和显示广告内容
            [view loadAndDisplayNativeAdWithObject:object completion:^(NSArray *errors) {
                GLog(@"信息流广告: 请求开启渲染 %@",errors);
                if (!errors) {
                    
                }
            }];
            [self.container addSubview:view];
        }
    }
}

#pragma mark - 创建广告视图

- (BaiduMobAdNativeAdView *)createNativeAdViewWithframe:(CGRect)frame object:(BaiduMobAdNativeAdObject *)object {
    CGFloat kScreenWidth = [[UIApplication sharedApplication]keyWindow].bounds.size.width;
    CGFloat origin_x = 15;
    CGFloat main_width = kScreenWidth - (origin_x*2);
    CGFloat main_height = main_width*2/3;
    
    //标题
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(85, 20, main_width-85, 20)];
    titleLabel.font = [UIFont systemFontOfSize:14.0];
    
    //描述
    UILabel *textLabel = [[UILabel alloc]initWithFrame:CGRectMake(85, 50, main_width-85, 20)];
    textLabel.font = [UIFont fontWithName:textLabel.font.familyName size:12];
    if (!object.text || [object.text isEqualToString:@""]) {
        object.text = @"广告描述信息";
    }
    
    //Icon
    UIImageView *iconImageView = [[UIImageView alloc]initWithFrame:CGRectMake(origin_x, origin_x, 60, 60)];
    iconImageView.layer.cornerRadius = 3;
    iconImageView.layer.masksToBounds = YES;
    
    //大图
    UIImageView *mainImageView = [[UIImageView alloc]initWithFrame:CGRectMake(origin_x, 85, main_width, main_height)];
    mainImageView.layer.cornerRadius = 5;
    mainImageView.layer.masksToBounds = YES;
    
    //app名字
    UILabel *brandLabel = [[UILabel alloc] initWithFrame:CGRectMake(origin_x, CGRectGetMaxY(mainImageView.frame) + 20, 60, 14)];
    brandLabel.font = [UIFont fontWithName:brandLabel.font.familyName size:13];
    brandLabel.textColor = [UIColor grayColor];
    //广告logo
    UIImageView *baiduLogoView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(brandLabel.frame), CGRectGetMinY(brandLabel.frame), 15, 14)];
    UIImageView *adLogoView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(baiduLogoView.frame), CGRectGetMinY(baiduLogoView.frame), 26, 14)];
    
    BaiduMobAdActButton *actButton = [[BaiduMobAdActButton alloc] initWithFrame:CGRectMake(kScreenWidth - 80 - origin_x, CGRectGetMinY(brandLabel.frame) - 10, 80, 30)];
    [actButton.titleLabel setFont:[UIFont systemFontOfSize:15]];
    
    //多图 Demo  单图和多图按需展示
    NSMutableArray *imageViewArray = [NSMutableArray array];
    if ([object.morepics count] > 0) {
        //多图
        CGFloat margin = 5;//图片间隙
        CGFloat imageWidth = (kScreenWidth-2*origin_x-margin*(object.morepics.count-1))/object.morepics.count;
        CGFloat imageHeight = imageWidth*2/3;
        
        //适配logo位置
        actButton.frame = ({
            CGRect frame = actButton.frame;
            frame.origin.y = imageHeight + 10 + 85;
            frame;
        });
        
        baiduLogoView.frame = ({
            CGRect frame = baiduLogoView.frame;
            frame.origin.y = CGRectGetMinY(actButton.frame) + 10;
            frame;
        });
        
        adLogoView.frame = ({
            CGRect frame = adLogoView.frame;
            frame.origin.y = CGRectGetMinY(baiduLogoView.frame);
            frame;
        });
        
        brandLabel.frame = ({
            CGRect frame = brandLabel.frame;
            frame.origin.y = CGRectGetMinY(baiduLogoView.frame);
            frame;
        });
        
        
        for (int i = 0; i<object.morepics.count; i++) {
            UIImageView *mainImageView = [[UIImageView alloc]initWithFrame:CGRectMake(origin_x, 85, imageWidth, imageHeight)];
            [imageViewArray addObject:mainImageView];
            origin_x+=imageWidth+margin;
        }
    }
    
    BaiduMobAdNativeAdView *nativeAdView;
    nativeAdView.backgroundColor = [UIColor whiteColor];
    if(object.materialType == NORMAL){
        //多图 Demo  单图和多图按需展示
        nativeAdView = [[BaiduMobAdNativeAdView alloc] initWithFrame:frame
                                                           brandName:brandLabel
                                                               title:titleLabel
                                                                text:textLabel
                                                                icon:iconImageView
                                                           mainImage:mainImageView
                                                            morepics:imageViewArray];
        
        nativeAdView.baiduLogoImageView = baiduLogoView;
        [nativeAdView addSubview:baiduLogoView];
        nativeAdView.adLogoImageView = adLogoView;
        [nativeAdView addSubview:adLogoView];
        nativeAdView.actButton = actButton;
        [nativeAdView addSubview:actButton];
        
    }else if (object.materialType == HTML) {
        ///信息流模版广告 模板广告内部已添加百度广告logo和熊掌，开发者无需添加
        BaiduMobAdNativeWebView *webview = [[BaiduMobAdNativeWebView alloc]initWithFrame:frame andObject:object];
        nativeAdView = [[BaiduMobAdNativeAdView alloc]initWithFrame:frame
                                                            webview:webview];
    } else if (object.materialType == VIDEO) {
        //视频
        BaiduMobAdNativeVideoView *video = [[BaiduMobAdNativeVideoView alloc] initWithFrame:frame andObject:object];
        nativeAdView = [[BaiduMobAdNativeAdView alloc] initWithFrame:frame
                                                           brandName:brandLabel
                                                               title:titleLabel
                                                                text:textLabel
                                                                icon:iconImageView
                                                           mainImage:mainImageView
                                                            videoView:video];

    }
    return nativeAdView;
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
