//
//  FlutterBaiduadEvent.h
//  flutter_baiduad
//
//  Created by gstory on 2021/11/27.
//

#import <Foundation/Foundation.h>
#import <Flutter/Flutter.h>

NS_ASSUME_NONNULL_BEGIN

@interface FlutterBaiduadEvent : NSObject
+ (instancetype)sharedInstance;
- (void)initEvent:(NSObject<FlutterPluginRegistrar>*)registrar;
- (void)sentEvent:(NSDictionary*)arguments;
@end

NS_ASSUME_NONNULL_END
