//
//  PSSubscriptionGuideViewController.m
//  PDFScanner
//
//  Created by Lucy Benson on 2020/5/11.
//  Copyright © 2020 cdants. All rights reserved.
//

#import "PSSubscriptionGuideViewController.h"
#import "UIView+RoundedCorner.h"
#import "PSPageControl.h"
#import "PSSubscriptionPurchaseViewController.h"

@interface PSSubscriptionGuideViewController ()

@property (strong, nonatomic) IBOutlet UIButton *subscribeButton;
@property (strong, nonatomic) IBOutlet PSPageControl *pageControl;
@property (strong, nonatomic) IBOutlet UIScrollView *horizontalScrollView;

@end

@implementation PSSubscriptionGuideViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpView];
    [self setNavigationItem];
}

- (void)setUpView {
    self.pageControl.numberOfPages = 3;
    self.pageControl.currentPage = 0;
    WS(ws)
    [self.pageControl setTapPageBlock:^(NSInteger tapIndex) {
        [ws.horizontalScrollView setContentOffset:CGPointMake(SCREEN_WIDTH * tapIndex, 0) animated:YES];
    }];
}

- (void)setNavigationItem {
    self.navigationController.navigationBar.barTintColor = [UIColor mainBackgroundColor];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_down_icon"] style:UIBarButtonItemStylePlain target:self action:@selector(dismiss:)];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat width = scrollView.frame.size.width;
    NSInteger page = (scrollView.contentOffset.x + (0.5f * width)) / width;
    self.pageControl.currentPage = page;
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self.subscribeButton ps_applyGradientColors:@[(id)UIColorFromRGB(0xF35533).CGColor, (id)UIColorFromRGB(0xFF7F49).CGColor]];
}

#pragma mark - Action Methods

- (void)dismiss:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)subscribe:(id)sender {
    PSSubscriptionPurchaseViewController *vc = [[PSSubscriptionPurchaseViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
