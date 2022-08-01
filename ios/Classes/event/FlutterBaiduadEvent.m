//
//  FlutterBaiduadEvent.m
//  flutter_baiduad
//
//  Created by gstory on 2021/11/27.
//

#import "FlutterBaiduadEvent.h"
#import <Flutter/Flutter.h>

@interface FlutterBaiduadEvent()<FlutterStreamHandler>
@property(nonatomic,strong) FlutterEventSink eventSink;
@end

@implementation FlutterBaiduadEvent

+ (instancetype)sharedInstance{
    static FlutterBaiduadEvent *myInstance = nil;
    if(myInstance == nil){
        myInstance = [[FlutterBaiduadEvent alloc]init];
    }
    return myInstance;
}


- (void)initEvent:(NSObject<FlutterPluginRegistrar>*)registrar{
    FlutterEventChannel *eventChannel = [FlutterEventChannel eventChannelWithName:@"com.gstory.flutter_baiduad/adevent"   binaryMessenger:[registrar messenger]];
    [eventChannel setStreamHandler:self];
}

-(void)sentEvent:(NSDictionary*)arguments{
    self.eventSink(arguments);
}



#pragma mark - FlutterStreamHandler
- (FlutterError * _Nullable)onCancelWithArguments:(id _Nullable)arguments {
    self.eventSink = nil;
    return nil;
}

- (FlutterError * _Nullable)onListenWithArguments:(id _Nullable)arguments eventSink:(nonnull FlutterEventSink)events {
    self.eventSink = events;
    return nil;
}

@end
