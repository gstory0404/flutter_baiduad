//
//  UIViewController+getCurrentVC.h
//  flutter_baiduad
//
//  Created by gstory on 2021/12/13.
//


#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (getCurrentVC)<UIViewControllerAnimatedTransitioning>

+ (UIViewController *)jsd_getCurrentViewController;

+ (UIViewController *)jsd_getRootViewController;

+ (UIViewController *)getCurrentVCWithCurrentView:(UIView *)currentView;

+(UITabBarController *)currentTtabarController;

+(UINavigationController *)currentTabbarSelectedNavigationController;

@end

NS_ASSUME_NONNULL_END
