//
//  StringUtls.m
//  flutter_baiduad
//
//  Created by gstory on 2021/11/29.
//

#import "StringUtls.h"

@implementation StringUtls

+ (BOOL)isStringEmpty:(NSString *)string{
    
    if (string == nil) {
        
        return YES;
        
    }
    
    if (string == NULL) {
        
        return YES;
        
    }
    
    if ([string isKindOfClass:[NSNull class]]) {
        
        return YES;
        
    }
    
    if ([[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length]==0) {
        
        return YES;
        
    }
    
    return NO;
    
}
@end
