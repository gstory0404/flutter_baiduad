//
//  BaiduAdManager.m
//  flutter_baiduad
//
//  Created by gstory on 2021/11/29.
//

#import "BaiduAdManager.h"
#import "BdLogUtil.h"

@interface BaiduAdManager()
@property(nonatomic,strong)NSString *appid;
@end

@implementation BaiduAdManager

+ (instancetype)sharedInstance{
    static BaiduAdManager *myInstance = nil;
    if(myInstance == nil){
        myInstance = [[BaiduAdManager alloc]init];
    }
    return myInstance;
}

//传入appId
-(void)initAppId:(NSString *)appId{
    self.appid = appId;
}

- (NSString*)getAppId{
    return self.appid;
}

@end
