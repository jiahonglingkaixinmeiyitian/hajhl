//
//  PSSubscriptionGuideViewController.m
//  PDFScanner
//
//  Created by Lucy Benson on 2020/5/11.
//  Copyright © 2020 cdants. All rights reserved.
//

#import "PSSubscriptionGuideViewController.h"
#import "PSPageControl.h"
#import "PSSubscriptionPurchaseViewController.h"
#import "PSPurchaseViewModel.h"
#import "PSGuidePagePrivacyView.h"

@interface PSSubscriptionGuideViewController ()
@property (strong, nonatomic) IBOutlet UIScrollView *horizontalScrollView;
@property (strong, nonatomic) IBOutlet UIView *containerView;
@property (strong, nonatomic) IBOutlet UIView *page1;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *contentLabel;
@property (strong, nonatomic) IBOutlet UIImageView *topImageView;

@property (strong, nonatomic) IBOutlet UIView *page2;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel2;
@property (strong, nonatomic) IBOutlet UILabel *contentLabel2;
@property (strong, nonatomic) IBOutlet UIImageView *topImageView2;

@property (strong, nonatomic) IBOutlet UIView *page3;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel3;
@property (strong, nonatomic) IBOutlet UILabel *contentLabel3;
@property (strong, nonatomic) IBOutlet UIImageView *topImageView3;

@property (strong, nonatomic) IBOutlet PSPageControl *pageControl;
@property (strong, nonatomic) IBOutlet UILabel *trialLabel;
@property (strong, nonatomic) IBOutlet UILabel *priceLabel;
@property (strong, nonatomic) IBOutlet UIButton *subscribeButton;
@property (strong, nonatomic) IBOutlet UILabel *describeLabel;

/**  */
@property (nonatomic,strong) PSPurchaseViewModel *viewModel;
/**  */
@property (nonatomic,strong) PSGuidePagePrivacyView *privacyView;
/**  */
@property (nonatomic,copy) NSString *productid;
/**  */
@property (nonatomic,copy) NSString *countryName;

@end

@implementation PSSubscriptionGuideViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpView];
    [self setNavigationItem];
    [ScannerEventManager eventTrankingForGeneralEventWithName:guide_page_view];
}

- (void)setUpView {
    self.pageControl.numberOfPages = 3;
    self.pageControl.currentPage = 0;
    WS(ws)
    [self.pageControl setTapPageBlock:^(NSInteger tapIndex) {
        [ws.horizontalScrollView setContentOffset:CGPointMake(SCREEN_WIDTH * tapIndex, 0) animated:YES];
    }];
    
    [self.view addSubview:self.privacyView];
    [self.privacyView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [self.privacyView.continueBtn addTarget:self action:@selector(continueAct) forControlEvents:UIControlEventTouchUpInside];
}

-(void)showPackage{
    
    if (USER().isInUs) {
        self.countryName = @"US";
    }else if (USER().isInBr){
        self.countryName = @"BR";
    }else{
        self.countryName = @"other";
    }
    
    NSString *productid = USER().productId;
    if (!productid||productid.length==0) {
        productid = subscribe1mTrialProductId;
    }
    self.productid = productid;
    
    NSString *type = [self fetchTypeWithProductid:productid];
    [self updateContent:productid type:type];
    
    NSString *eventName = [NSString stringWithFormat:@"%@_%@_%@",guide_show_package,self.countryName,type];
    [ScannerEventManager eventTrankingForGeneralEventWithName:eventName];
}

-(void)updateContent:(NSString *)productid type:(NSString *)type{
    PSPurchaseModel *model = [PSPurchaseModel sharedInstance];
    NSString *price = model.priceDic[productid];
//    Then $9.99/month thereafter
    self.priceLabel.text = [NSString stringWithFormat:@"auto-renews %@/%@ thereafter",price,type];
//    self.priceLabel.text = [NSString stringWithFormat:@"Then %@/%@ thereafter",price,type];
//    self.trialLabel.hidden = YES;
    self.describeLabel.text = [self describeInfoType:type price:price];
}

-(NSString *)fetchTypeWithProductid:(NSString *)product{
    if ([product isEqualToString:subscribe1wTrialProductId]) {
        return @"week";
    }else if ([product isEqualToString:subscribe1mTrialProductId]){
        return @"month";
    }else{
        return @"year";
    }
}

-(void)continueAction{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.privacyView.hidden = YES;
        [self.horizontalScrollView setTrasitonAnimation:TransitonAnimationPush duration:0.25 towardType:TansitionAnimationTowardTypeFromRight timingFunc:TransitonAnimTimingFuncLinear];
    });
}

- (void)setNavigationItem {
    self.navigationController.navigationBar.barTintColor = [UIColor mainBackgroundColor];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_close2_30_black"] style:UIBarButtonItemStylePlain target:self action:@selector(closeAction)];
    self.navigationItem.leftBarButtonItem = nil;
    [self.navigationItem setHidesBackButton:YES];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat width = scrollView.frame.size.width;
    NSInteger page = (scrollView.contentOffset.x + (0.5f * width)) / width;
    self.pageControl.currentPage = page;
    
    switch (page) {
        case 0:
            [ScannerEventManager eventTrankingForGeneralEventWithName:guide_page_view1];
            break;
        case 1:
            [ScannerEventManager eventTrankingForGeneralEventWithName:guide_page_view2];
            break;
        case 2:
            [ScannerEventManager eventTrankingForGeneralEventWithName:guide_page_view3];
            break;
        default:
            break;
    }
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self.subscribeButton ps_applyGradientColors:@[(id)UIColorFromRGB(0xF35533).CGColor, (id)UIColorFromRGB(0xFF7F49).CGColor]];
    
    [self.privacyView.continueBtn ps_applyGradientColors:@[(id)UIColorFromRGB(0xF35533).CGColor, (id)UIColorFromRGB(0xFF7F49).CGColor]];
    
//    [self reLayoutSubviews];
}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    [self reLayoutSubviews];
}

-(void)reLayoutSubviews{

    self.titleLabel.font = [UIFont gibFont:FLoatChange(27)];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(self.page1);
//        make.centerX.equalTo(self.page1);
        make.height.mas_equalTo(FLoatChange(30));
    }];
    
    self.titleLabel2.font = [UIFont gibFont:FLoatChange(27)];
    [self.titleLabel2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(FLoatChange(30));
    }];
    
    self.titleLabel3.font = [UIFont gibFont:FLoatChange(27)];
    [self.titleLabel3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(FLoatChange(30));
    }];
//    
//    self.contentLabel.font = [UIFont gibFont:FLoatChange(27)];
//    [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(self.titleLabel.mas_bottom).offset(YNFLoatChange(10));
//        make.centerX.equalTo(self.horizontalScrollView);
//    }];

    CGFloat height = 280;
    if (is_iPhoneP||isIphoneX_XS) {
        height = 297;
    }else if (isIphoneXR_XSMax){
        height = 312;
    }
    
    [self.topImageView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(self.contentLabel);
//        make.trailing.leading.equalTo(self.horizontalScrollView);
//        make.center.equalTo(self.horizontalScrollView);
        make.height.mas_equalTo(YNFLoatChange(height));
    }];
    
    self.trialLabel.font = [UIFont girFont:FLoatChange(16)];
//    [self.trialLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.height.mas_equalTo(FLoatChange(30));
//    }];
    
    self.priceLabel.font = [UIFont gibFont:FLoatChange(16)];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.subscribeButton.titleLabel.font = [UIFont pfscmFont:FLoatChange(20)];
    });
//    self.subscribeButton.titleLabel.font = [UIFont pfscmFont:FLoatChange(18)];
//    [self.subscribeButton mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.size.mas_equalTo(CGSizeMake(FLoatChange(270), FLoatChange(48)));
////        make.bottom.mas_equalTo(-10);
////        make.center.equalTo(self.view);
//    }];
}

#pragma mark - Action Methods

-(void)continueAct{
    [self dismiss];
}

-(void)closeAction{
    [ScannerEventManager eventTrankingForGeneralEventWithName:guide_close_click];
    [self dismiss];
}

- (void)dismiss {
    
    static int i = 0;
    if (i==0) {
        [self showPackage];
        [self continueAction];
    }else{
       [self.navigationController popViewControllerAnimated:NO];
    }
    i++;
}

- (IBAction)subscribe:(id)sender {
    [self subscribeWithProductId:self.productid];
}

-(void)subscribeWithProductId:(NSString *)productId{
    [self ps_showProgressHUDInWindow];
    [[PSPurchaseManager sharedInstance] purchaseProduct:productId completion:^(NSString * _Nonnull receipt, NSString * _Nonnull localPrice, BOOL success) {
        [self ps_hideProgressHUDForWindow];
        if (success) {
            [self verifySubscriptionsWithPrice:localPrice receipt:receipt];
            //先给VIP权限，再验证服务器
            [[PSUserInfoManager sharedInstance]setUserVIPStatus:YES];
            [self ps_showHint:@"Purchase Successfully"];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self dismiss];
            });
            [ScannerEventManager eventTrankingForGeneralEventWithName:guide_subscribe_success];
            [ScannerEventManager eventTrankingForGeneralEventWithName:app_purchase_total_success];
            if ([productId isEqualToString:subscribe1wTrialProductId]) {
                [ScannerEventManager eventTrankingForGeneralEventWithName:guide_trail_w_success];
            }else if ([productId isEqualToString:subscribe1mTrialProductId]){
                [ScannerEventManager eventTrankingForGeneralEventWithName:guide_trail_m_success];
            }else{
                [ScannerEventManager eventTrankingForGeneralEventWithName:guide_trail_y_success];
            }
            
        }else{
            if ([receipt isEqualToString:@"Cancel"]) {
                
            }else{
                [self ps_showHint:@"Purchase Failed"];
                [ScannerEventManager eventTrankingForGeneralEventWithName:guide_subscribe_failure];
                [ScannerEventManager eventTrankingForGeneralEventWithName:app_purchase_total_failure];
                if ([productId isEqualToString:subscribe1wTrialProductId]) {
                    [ScannerEventManager eventTrankingForGeneralEventWithName:guide_trail_w_failure];
                }else if ([productId isEqualToString:subscribe1mTrialProductId]){
                    [ScannerEventManager eventTrankingForGeneralEventWithName:guide_trail_m_failure];
                }else{
                    [ScannerEventManager eventTrankingForGeneralEventWithName:guide_trail_y_failure];
                }

            }
        }
    }];
    
    [ScannerEventManager eventTrankingForGeneralEventWithName:guide_subscribe_click];
    [ScannerEventManager eventTrankingForGeneralEventWithName:app_purchase_total_click];
    
    [ScannerEventManager adjustEventWithName:guide_trail_click_token];
    [ScannerEventManager adjustEventWithName:app_purchase_total_click_token];
    
    if ([productId isEqualToString:subscribe1wTrialProductId]) {
        [ScannerEventManager eventTrankingForGeneralEventWithName:guide_trail_w_click];
        [ScannerEventManager adjustEventWithName:guide_trail_w_click_token];
    }else if ([productId isEqualToString:subscribe1mTrialProductId]){
        [ScannerEventManager eventTrankingForGeneralEventWithName:guide_trail_m_click];
        [ScannerEventManager adjustEventWithName:guide_trail_m_click_token];
    }else{
        [ScannerEventManager eventTrankingForGeneralEventWithName:guide_trail_y_click];
        [ScannerEventManager adjustEventWithName:guide_trail_y_click_token];
    }
}

-(void)verifySubscriptionsWithPrice:(NSString *)price receipt:(NSString *)receipt{
    [self.viewModel verifySubscriptionsWithPrice:price receipt:receipt modelBlcok:^(PSVIPInfoModel * _Nonnull model) {
        NSLog(@"🍊🍊🍊🍊🍊🍊验证结果：%d",model.is_vip);
        if (model) {
            [[PSUserInfoManager sharedInstance]setUserVIPStatus:model.is_vip];
            if (model.is_vip) {//VIP
                [[PSPurchaseManager sharedInstance] finishTransaction];//放到此处目的：验证失败后，按丢单逻辑再处理一次，二次验证
                float price = 0;
                if ([self.productid isEqualToString:subscribe1wTrialProductId]) {
                    [ScannerEventManager eventTrankingForGeneralEventWithName:guide_trail_w_verifySuccess];
                    price = [[subscribe1wTrialPrice substringFromIndex:1] floatValue];
                    [ScannerEventManager adjustEventWithName:guide_trail_w_success_token revenue:price];
                }else if ([self.productid isEqualToString:subscribe1mTrialProductId]){
                    [ScannerEventManager eventTrankingForGeneralEventWithName:guide_trail_m_verifySuccess];
                    price = [[subscribe1mTrialPrice substringFromIndex:1] floatValue];
                    [ScannerEventManager adjustEventWithName:guide_trail_m_success_token revenue:price];
                }else{
                    [ScannerEventManager eventTrankingForGeneralEventWithName:guide_trail_y_verifySuccess];
                    price = [[subscribe1yTrialPrice substringFromIndex:1] floatValue];
                    [ScannerEventManager adjustEventWithName:guide_trail_y_success_token revenue:price];
                }
                [ScannerEventManager eventTrankingForGeneralEventWithName:guide_subscribe_verifySuccess];
                [ScannerEventManager eventTrankingForGeneralEventWithName:app_purchase_total_verifySuccess];
                
                [ScannerEventManager adjustEventWithName:guide_trail_success_token];
                [ScannerEventManager adjustEventWithName:app_purchase_total_success_token];
                
            }else{//非VIP
                [ScannerEventManager eventTrankingForGeneralEventWithName:guide_subscribe_verifyFailure];
                [ScannerEventManager eventTrankingForGeneralEventWithName:app_purchase_total_verifyFailure];
                if ([self.productid isEqualToString:subscribe1wTrialProductId]) {
                    [ScannerEventManager eventTrankingForGeneralEventWithName:guide_trail_w_verifyFailure];
                }else if ([self.productid isEqualToString:subscribe1mTrialProductId]){
                    [ScannerEventManager eventTrankingForGeneralEventWithName:guide_trail_m_verifyFailure];
                }else{
                    [ScannerEventManager eventTrankingForGeneralEventWithName:guide_trail_y_verifyFailure];
                }
            }
        }else{//因为网络等原因没有返回数据
            [ScannerEventManager eventTrankingForGeneralEventWithName:guide_subscribe_unusualFailure];
            [ScannerEventManager eventTrankingForGeneralEventWithName:app_purchase_total_unusualFailure];
            if ([self.productid isEqualToString:subscribe1wTrialProductId]) {
                [ScannerEventManager eventTrankingForGeneralEventWithName:guide_trail_w_unusualFailure];
            }else if ([self.productid isEqualToString:subscribe1mTrialProductId]){
                [ScannerEventManager eventTrankingForGeneralEventWithName:guide_trail_m_unusualFailure];
            }else{
                [ScannerEventManager eventTrankingForGeneralEventWithName:guide_trail_y_unusualFailure];
            }
        }
    }];
}

-(NSString *)describeInfoType:(NSString *)type price:(NSString *)price{
    return [NSString stringWithFormat:@"By purchasing a subscription, you agree to the Terms of Service and acknowledge the Privacy Policy.Your subscription will automatically renew and your Apple ID account will be charged %@ each %@ until you cancel it at least 24 hours before the end of the then-current subscription period by following these instructions.",price,type];
}

- (PSPurchaseViewModel *)viewModel{
    if (!_viewModel) {
        _viewModel = [[PSPurchaseViewModel alloc]init];
    }
    return _viewModel;
}

- (PSGuidePagePrivacyView *)privacyView{
    if (!_privacyView) {
        _privacyView = [[PSGuidePagePrivacyView alloc]init];
    }
    return _privacyView;
}

@end
