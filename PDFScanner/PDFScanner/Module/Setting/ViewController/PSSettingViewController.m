//
//  PSSettingViewController.m
//  PDFScanner
//
//  Created by Lucy Benson on 2020/5/7.
//  Copyright © 2020 cdants. All rights reserved.
//

#import "PSSettingViewController.h"
#import "UIView+RoundedCorner.h"
#import "PSH5WebViewController.h"
#import <StoreKit/StoreKit.h>
#import "PSKeyChainHelper.h"
#import "PSLockAppDialog.h"
#import "PSBottomListDrawer.h"
#import "PSSubscriptionGuideViewController.h"
#import "PSScannerSettingModel.h"
#import "PSBottomFilterDrawer.h"

static NSString *iOSAppStoreURLFormat = @"itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%d";

@interface PSSettingViewController ()

@property (strong, nonatomic) IBOutlet UIButton *upgradeButton;
@property (strong, nonatomic) IBOutlet UILabel *versionLabel;
@property (strong, nonatomic) IBOutlet UIView *topGroupShadowView;
@property (strong, nonatomic) IBOutlet UIView *bottomGroupShadowView;
@property (strong, nonatomic) IBOutlet UISwitch *switchControl;
@property (strong, nonatomic) IBOutlet UILabel *pictureQualityLabel;
@property (strong, nonatomic) IBOutlet UILabel *scannerFilterLabel;


@property (nonatomic, strong) UILabel *settingTitleLabel;

@end

@implementation PSSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configNavigationItem];
    [self configView];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self.upgradeButton ps_applyGradientColors:@[(id)UIColorFromRGB(0xF35533).CGColor, (id)UIColorFromRGB(0xFF7F49).CGColor]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.barTintColor = [UIColor mainBackgroundColor];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
}

- (void)configNavigationItem {
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.settingTitleLabel];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_close2_30_black"] style:UIBarButtonItemStylePlain target:self action:@selector(dismiss:)];
}

- (void)configView {
    [self _addShadowForView:self.topGroupShadowView];
    [self _addShadowForView:self.bottomGroupShadowView];
    [self _configPictureQualityAndScannerFilter];
    BOOL switchIsOn = [PSKeyChainHelper passwordForAppLock] != nil;
    [self.switchControl setOn:switchIsOn animated:NO];
    self.versionLabel.text = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"setting.version", nil),AppVersion];;
}

- (void)_configPictureQualityAndScannerFilter {
    self.pictureQualityLabel.text = [[PSScannerSettingModel allObjects].firstObject pictureQualityValue];
    self.scannerFilterLabel.text = [[PSScannerSettingModel allObjects].firstObject scannerFilterValue];
}

- (void)_addShadowForView:(UIView *)view {
    view.layer.backgroundColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0].CGColor;
    view.layer.cornerRadius = 12;
    view.layer.shadowColor = [UIColor colorWithRed:192/255.0 green:193/255.0 blue:206/255.0 alpha:0.4].CGColor;
    view.layer.shadowOffset = CGSizeMake(0,5);
    view.layer.shadowOpacity = 1;
    view.layer.shadowRadius = 20;
}

#pragma mark - Action Methods

- (IBAction)upgradeToPro:(id)sender {
    PSSubscriptionGuideViewController *vc = [[PSSubscriptionGuideViewController alloc] init];
    [self presentViewController:WrapInNavigationBar(vc) animated:YES completion:nil];
}

- (void)dismiss:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)selectPictureQuality:(id)sender {
    NSArray *items = @[
        @{@"leftName": @"home_share_png_icon", @"rightText": NSLocalizedString(@"setting.image_quality.low", nil)},
        @{@"leftName": @"home_share_png_icon", @"rightText": NSLocalizedString(@"setting.image_quality.medium", nil)},
        @{@"leftName": @"home_share_png_icon", @"rightText": NSLocalizedString(@"setting.image_quality.high", nil)},
        @{@"leftName": @"home_share_png_icon", @"rightText": NSLocalizedString(@"setting.image_quality.original", nil)}
    ];
    
    PSBottomListDrawer *qualityDrawer = [[PSBottomListDrawer alloc] initWithItems:items];
    [qualityDrawer setPickListItemBlock:^(NSInteger itemIndex) {
        PSScannerSettingModel *settingModel = [PSScannerSettingModel allObjects].firstObject;
        RLMRealm *realm = [RLMRealm defaultRealm];
        [realm transactionWithBlock:^{
            settingModel.pictureQuality = itemIndex;
        }];
        [self _configPictureQualityAndScannerFilter];
    }];
    [qualityDrawer presentToKeyWindow];
}

- (IBAction)setScannerFilter:(id)sender {
    PSBottomFilterDrawer *drawer = [[PSBottomFilterDrawer alloc] init];
    [drawer setPickListItemBlock:^(NSInteger itemIndex) {
        PSScannerSettingModel *model = [PSScannerSettingModel allObjects].firstObject;
        RLMRealm *realm = [RLMRealm defaultRealm];
        [realm transactionWithBlock:^{
            model.scannerFilter = itemIndex;
        }];
        [self _configPictureQualityAndScannerFilter];
    }];
    [drawer presentToKeyWindow];
}

- (IBAction)lockApp:(id)sender {
    if ([PSKeyChainHelper passwordForAppLock]) {
        // 移除密码
        if ([PSKeyChainHelper deleteAppLockPassword]) {
            [self.switchControl setOn:NO animated:YES];
        }
    } else {
        // 设置密码
        // 先别on
        [self.switchControl setOn:NO animated:YES];
        PSLockAppDialog *dialog = [[PSLockAppDialog alloc] initWithType:PSLockAppTypeCreatePassword];
        WS(ws)
        [dialog setPasswordSetBlock:^{
            [ws.switchControl setOn:YES animated:YES];
        }];
        [self presentViewController:dialog animated:YES completion:nil];
    }
}

- (IBAction)restorePurchases:(id)sender {
    
}

- (IBAction)rateApp:(id)sender {
    if (@available(iOS 10.3, *)) {
        [SKStoreReviewController requestReview];
    } else {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:iOSAppStoreURLFormat, kAppStoreID]] options:@{} completionHandler:nil];
    }
}

- (IBAction)shareApp:(id)sender {
    NSArray *items = @[NSLocalizedString(@"setting.share_app.text", nil), [NSURL URLWithString:[NSString stringWithFormat:iOSAppStoreURLFormat, kAppStoreID]]];
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:items applicationActivities:nil];
    [self presentViewController:activityVC animated:YES completion:nil];
}

- (IBAction)goToSubscriptionsInfo:(id)sender {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"subscription" ofType:@"html"];
    PSH5WebViewController *subInfo = [[PSH5WebViewController alloc] initWithFileURLPath:path title:NSLocalizedString(@"setting.h5.subscriptions_info.title", nil)];
    [self.navigationController pushViewController:subInfo animated:YES];
}

- (IBAction)goToPrivacyPolicy:(id)sender {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"privacy" ofType:@"html"];
    PSH5WebViewController *pp = [[PSH5WebViewController alloc] initWithFileURLPath:path title:NSLocalizedString(@"setting.h5.privacy_policy.title", nil)];
    [self.navigationController pushViewController:pp animated:YES];
}

- (IBAction)goToTermsOfUse:(id)sender {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"terms" ofType:@"html"];
    PSH5WebViewController *tou = [[PSH5WebViewController alloc] initWithFileURLPath:path title:NSLocalizedString(@"setting.h5.terms_of_use.title", nil)];
    [self.navigationController pushViewController:tou animated:YES];
}

- (IBAction)goToHelp:(id)sender {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"help" ofType:@"html"];
    PSH5WebViewController *help = [[PSH5WebViewController alloc] initWithFileURLPath:path title:NSLocalizedString(@"setting.h5.help.title", nil)];
    [self.navigationController pushViewController:help animated:YES];
}

#pragma mark - Property Getters

- (UILabel *)settingTitleLabel {
    if (!_settingTitleLabel) {
        _settingTitleLabel = [[UILabel alloc] init];
        _settingTitleLabel.text = NSLocalizedString(@"setting.toptitle", nil);
        _settingTitleLabel.font = [UIFont appBoldFontSize:32.f];
        _settingTitleLabel.textColor = [UIColor themeColor];
    }
    return _settingTitleLabel;
}

@end
