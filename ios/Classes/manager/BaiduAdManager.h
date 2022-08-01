//
//  BaiduAdManager.h
//  flutter_baiduad
//
//  Created by gstory on 2021/11/29.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BaiduAdManager : NSObject
+ (instancetype)sharedInstance;
- (void)initAppId:(NSString*)appId;
- (NSString*)getAppId;
@end

NS_ASSUME_NONNULL_END
