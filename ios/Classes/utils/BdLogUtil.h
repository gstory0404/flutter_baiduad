//
//  BdLogUtil.h
//  Pods
//
//  Created by gstory on 2021/11/29.
//
#ifdef DEBUG
#define GLog(...) NSLog(@"%s\n %@\n\n", __func__, [NSString stringWithFormat:__VA_ARGS__])
#else
#define GLog(...)
#endif
