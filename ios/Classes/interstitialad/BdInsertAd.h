//
//  InsertAd.h
//  flutter_baiduad
//
//  Created by gstory on 2021/11/29.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BdInsertAd : NSObject

+ (instancetype)sharedInstance;
- (void)initAd:(NSDictionary *)arguments;
- (void)showInsertAd;

@end

NS_ASSUME_NONNULL_END
