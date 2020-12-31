//
//  PSBaseNavigationVC.m
//  PDFScanner
//
//  Created by Lucy Benson on 2020/5/7.
//  Copyright © 2020 cdants. All rights reserved.
//

#import "PSBaseNavigationVC.h"

@interface PSBaseNavigationVC ()<UIGestureRecognizerDelegate>

@end

@implementation PSBaseNavigationVC

-(instancetype)init{
    if (self = [super init]) {
        self.navigationBar.translucent = false;
    }
    return self;
}

-(instancetype)initWithRootViewController:(UIViewController *)rootViewController{
    PSBaseNavigationVC *nvc = [super initWithRootViewController:rootViewController];
    nvc.navigationBar.translucent = false;
    nvc.modalPresentationStyle = UIModalPresentationFullScreen;
    return nvc;
}

-(instancetype)initWithNavigationBarClass:(Class)navigationBarClass toolbarClass:(Class)toolbarClass{
    PSBaseNavigationVC *nvc = [super initWithNavigationBarClass:navigationBarClass toolbarClass:toolbarClass];
    nvc.navigationBar.translucent = false;
    return nvc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.interactivePopGestureRecognizer.delegate = self;
}

//iOS中关于NavigationController中UIStatusBar黑白切换以及preferredStatusBarStyle一直不执行的问题  http://blog.csdn.net/deft_mkjing/article/details/51705021

- (UIViewController *)childViewControllerForStatusBarStyle {
    return self.topViewController;
}

- (UIViewController *)childViewControllerForStatusBarHidden {
    return self.topViewController;
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (self.viewControllers.count > 0) {
        viewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navigation_back_icon"] style:UIBarButtonItemStylePlain target:self action:@selector(goBack:)];
        viewController.hidesBottomBarWhenPushed = YES;
    } else {
        viewController.navigationItem.leftBarButtonItem = nil;
    }
    [super pushViewController:viewController animated:animated];
}

- (void)goBack:(id)sender {
    if (self.viewControllers.count > 1) {
        [self popViewControllerAnimated:YES];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

@end
