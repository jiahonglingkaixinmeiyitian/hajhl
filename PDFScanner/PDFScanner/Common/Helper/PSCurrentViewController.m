//
//  PSCurrentViewController.m
//  PDFScanner
//
//  Created by heartjhl on 2020/5/29.
//  Copyright © 2020 cdants. All rights reserved.
//

#import "PSCurrentViewController.h"

@implementation PSCurrentViewController
// 获取顶部控制器.
+ (UIViewController *)topViewController:(UIViewController *)vc {
    // 递归去找最上层的viewcontroller. 判断不同类型的vc,然后获取
    if (vc.presentedViewController) {
        return [PSCurrentViewController topViewController:vc.presentedViewController];
    } else if ([vc isKindOfClass:[UISplitViewController class]]) {
        UISplitViewController *svc = (UISplitViewController*)vc;
        if (svc.viewControllers.count > 0) {
            return [PSCurrentViewController topViewController:svc.viewControllers.lastObject];
        } else {
            return vc;
        }
    } else if ([vc isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navC = (UINavigationController*)vc;
        if (navC.viewControllers.count > 0) {
            return [PSCurrentViewController topViewController:navC.topViewController];
        } else {
            return vc;
        }
    } else if ([vc isKindOfClass:[UITabBarController class]]) {
        UITabBarController *tabC = (UITabBarController*)vc;
        if (tabC.viewControllers.count > 0) {
            return [PSCurrentViewController topViewController:tabC.selectedViewController];
        } else {
            return vc;
        }
    } else {
        return vc;
    }
}

// 当前控制器
+ (UIViewController *)currentViewController {
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    UIViewController *vc = [self topViewController:keyWindow.rootViewController];
    return vc;
}
@end
