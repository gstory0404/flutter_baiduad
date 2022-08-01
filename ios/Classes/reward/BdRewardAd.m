//
//  RewardAd.m
//  flutter_baiduad
//
//  Created by gstory on 2021/11/27.
//

#import "BdRewardAd.h"
#import "BaiduMobAdSDK/BaiduMobAdRewardVideo.h"
#import "FlutterBaiduadEvent.h"
#import "BaiduAdManager.h"
#import "BdLogUtil.h"
#import "StringUtls.h"

@interface BdRewardAd()<BaiduMobAdRewardVideoDelegate>

@property(nonatomic,strong) BaiduMobAdRewardVideo *reward;
@property(nonatomic,strong) NSString *codeId;
@property(nonatomic,strong) NSString *appSid;
@property(nonatomic,strong) NSString *rewardName;
@property(nonatomic,strong) NSString *rewardAmount;
@property(nonatomic,strong) NSString *userID;
@property(nonatomic,strong) NSString *customData;
@property(nonatomic,assign) BOOL useRewardCountdown;

@end

@implementation BdRewardAd

+ (instancetype)sharedInstance{
    static BdRewardAd *myInstance = nil;
    if(myInstance == nil){
        myInstance = [[BdRewardAd alloc]init];
    }
    return myInstance;
}

//预加载激励广告
-(void)initAd:(NSDictionary*)arguments{
    self.reward = [[BaiduMobAdRewardVideo alloc] init];
    self.codeId = arguments[@"iosId"];
    self.appSid = arguments[@"appSid"];
    self.rewardName = arguments[@"rewardName"];
    self.rewardAmount = arguments[@"rewardAmount"];
    self.userID = arguments[@"userID"];
    self.customData = arguments[@"customData"];
//    self.useRewardCountdown = [arguments[@"useRewardCountdown"] boolValue];
    
    self.reward.delegate = self;
    self.reward.AdUnitTag = self.codeId;
    if([StringUtls isStringEmpty:self.appSid]){
        self.reward.publisherId =[BaiduAdManager sharedInstance].getAppId;
    }else{
        self.reward.publisherId =self.appSid;
    }

    self.reward.useRewardCountdown = YES;
    self.reward.userID = self.userID;
    self.reward.extraInfo = self.customData;
    [self.reward load];
}

//展示广告
-(void)showAd{
    BOOL ready = [self.reward isReady];
    if (ready) {
        [self.reward show];
    }else{
        NSLog(@"视频广告不可用");
        NSDictionary *dictionary = @{@"adType":@"rewardAd",@"onAdMethod":@"onUnReady"};
        [[FlutterBaiduadEvent sharedInstance] sentEvent:dictionary];
    }
}


#pragma mark - 广告请求delegate
/**
 * 激励视频广告请求成功
 */
- (void)rewardedAdLoadSuccess:(BaiduMobAdRewardVideo *)video{
    GLog(@"激励视频广告请求成功");
}

/**
 * 激励视频广告请求失败
 */
- (void)rewardedAdLoadFail:(BaiduMobAdRewardVideo *)video{
    GLog(@"激励视频广告请求失败");
    NSDictionary *dictionary = @{@"adType":@"rewardAd",@"onAdMethod":@"onFail",@"code":@(0),@"message":@"激励视频广告请求失败"};
    [[FlutterBaiduadEvent sharedInstance] sentEvent:dictionary];
}

#pragma mark - 视频缓存delegate
/**
 *  视频缓存成功
 */
- (void)rewardedVideoAdLoaded:(BaiduMobAdRewardVideo *)video{
    GLog(@"视频缓存成功");
    NSDictionary *dictionary = @{@"adType":@"rewardAd",@"onAdMethod":@"onReady"};
    [[FlutterBaiduadEvent sharedInstance] sentEvent:dictionary];
}

/**
 *  视频缓存失败
 */
- (void)rewardedVideoAdLoadFailed:(BaiduMobAdRewardVideo *)video withError:(BaiduMobFailReason)reason{
    GLog(@"视频缓存失败");
}

#pragma mark - 视频播放delegate

/**
 *  视频开始播放
 */
- (void)rewardedVideoAdDidStarted:(BaiduMobAdRewardVideo *)video{
    GLog(@"视频开始播放");
    NSDictionary *dictionary = @{@"adType":@"rewardAd",@"onAdMethod":@"onShow"};
    [[FlutterBaiduadEvent sharedInstance] sentEvent:dictionary];
}

/**
 *  广告展示失败
 */
- (void)rewardedVideoAdShowFailed:(BaiduMobAdRewardVideo *)video withError:(BaiduMobFailReason)reason{
    GLog(@"广告展示失败 %@",reason);
    NSDictionary *dictionary = @{@"adType":@"rewardAd",@"onAdMethod":@"onFail",@"code":@(0),@"message":@(reason)};
    [[FlutterBaiduadEvent sharedInstance] sentEvent:dictionary];
}

/**
 *  广告完成播放
 */
- (void)rewardedVideoAdDidPlayFinish:(BaiduMobAdRewardVideo *)video{
    GLog(@"视频缓存成功");
    NSDictionary *dictionary = @{@"adType":@"rewardAd",@"onAdMethod":@"onFinish"};
    [[FlutterBaiduadEvent sharedInstance] sentEvent:dictionary];
}

/**
 * 成功激励回调
 * 低于30s的视频播放达到90%即会回调
 * 高于30s的视频播放达到27s即会回调
 * @param verify 激励验证，YES为成功
 */
- (void)rewardedVideoAdRewardDidSuccess:(BaiduMobAdRewardVideo *)video verify:(BOOL)verify{
    GLog(@"成功激励回调");
    NSDictionary *dictionary = @{@"adType":@"rewardAd",@"onAdMethod":@"onVerify",@"verify":@(verify),@"rewardName":self.rewardName,@"rewardAmount":self.rewardAmount};
    [[FlutterBaiduadEvent sharedInstance] sentEvent:dictionary];
}

/**
 *  用户点击视频跳过按钮，进入尾帧
 @param progress 当前播放进度 单位百分比 （注意浮点数）
 */
- (void)rewardedVideoAdDidSkip:(BaiduMobAdRewardVideo *)video withPlayingProgress:(CGFloat)progress{
    GLog(@"用户点击视频跳过按钮，进入尾帧");
    NSDictionary *dictionary = @{@"adType":@"rewardAd",@"onAdMethod":@"onSkip"};
    [[FlutterBaiduadEvent sharedInstance] sentEvent:dictionary];
}

/**
 *  视频正常播放完毕，或者视频跳过后，尾帧关闭
 @param progress 当前播放进度 单位百分比 （注意浮点数）
 */
- (void)rewardedVideoAdDidClose:(BaiduMobAdRewardVideo *)video withPlayingProgress:(CGFloat)progress{
    GLog(@"视频正常播放完毕，或者视频跳过后，尾帧关闭");
    NSDictionary *dictionary = @{@"adType":@"rewardAd",@"onAdMethod":@"onClose"};
    [[FlutterBaiduadEvent sharedInstance] sentEvent:dictionary];
}

/**
 *  用户点击下载/查看详情
 @param progress 当前播放进度 单位百分比
 */
- (void)rewardedVideoAdDidClick:(BaiduMobAdRewardVideo *)video withPlayingProgress:(CGFloat)progress{
    GLog(@"用户点击下载/查看详情");
}

@end
