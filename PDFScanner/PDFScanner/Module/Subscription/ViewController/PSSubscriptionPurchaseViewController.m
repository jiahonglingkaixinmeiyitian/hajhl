//
//  PSSubscriptionPurchaseViewController.m
//  PDFScanner
//
//  Created by Lucy Benson on 2020/5/11.
//  Copyright © 2020 cdants. All rights reserved.
//

#import "PSSubscriptionPurchaseViewController.h"
#import "PSSubscriptionPurchaseCell.h"
#import "PSPurchaseViewModel.h"
#import "PSMainPurchseViewModel.h"
#import "PSMainPurchseModel.h"

@interface PSSubscriptionPurchaseViewController ()<UICollectionViewDelegate, UICollectionViewDataSource>

@property (strong, nonatomic) IBOutlet UIButton *freeTrialButton;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) IBOutlet UICollectionViewFlowLayout *collectionFlowLayout;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UILabel *describeLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
/**  */
@property (nonatomic,copy) NSString *productid;
/**  */
@property (nonatomic,strong) PSPurchaseViewModel *viewModel;

//@property (nonatomic, strong) NSArray *products;
/**  */
@property (nonatomic,strong) UIButton *closeBtn;
/**  */
@property (nonatomic,strong) NSMutableArray *dataSource;
/**  */
@property (nonatomic,strong) PSMainPurchseViewModel *viewModel1;

@end

@implementation PSSubscriptionPurchaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    self.view.backgroundColor = [UIColor mainBackgroundColor];
//    self.view.backgroundColor = [UIColor colorWithHexString:@"#E3ECF4"];
    [self setUpCollectionView];
    [self fetchData];
    [ScannerEventManager eventTrankingForGeneralEventWithName:main_purchase_page_view];
}

- (void)setUpCollectionView {
    [self.containerView addSubview:self.closeBtn];
    [self.closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(StatusBarHeight+YNONTFLoatChange(isFullScreen?-10:10));
        make.trailing.mas_equalTo(-FLoatChange(20));
    }];
    
    [self.collectionView registerNib:[PSSubscriptionPurchaseCell ps_nib] forCellWithReuseIdentifier:[PSSubscriptionPurchaseCell ps_reuseIdentifier]];
    self.collectionView.bounces = NO;
    self.collectionView.scrollEnabled = NO;
}

-(void)fetchData{
    
    [self.dataSource addObjectsFromArray:[self.viewModel1 fetchDataSource]];
    [self.collectionView reloadData];
    
    [self updateContentWithIndex:1];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.collectionView selectItemAtIndexPath:[NSIndexPath indexPathWithIndex:1] animated:NO scrollPosition:UICollectionViewScrollPositionNone];
    });
}

-(void)updateContentWithIndex:(NSInteger)index{
    NSString *type = nil;
    if (index==0) {
        self.productid = subscribe1wTrialProductId;
        type = @"week";
    }else{
        self.productid = subscribe1yTrialProductId;
        type = @"year";
    }
    PSPurchaseModel *model = [PSPurchaseModel sharedInstance];
    NSString *price = model.priceDic[self.productid];
    self.describeLabel.text = [self describeInfoType:type price:price];
    self.priceLabel.text = [NSString stringWithFormat:@"auto-renews %@/%@ thereafter",price,type];
//    self.priceLabel.text = [NSString stringWithFormat:@"Then %@/%@ thereafter",price,type];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self.freeTrialButton ps_applyGradientColors:@[(id)UIColorFromRGB(0xF35533).CGColor, (id)UIColorFromRGB(0xFF7F49).CGColor]];
    
    CGFloat padding = (SCREEN_WIDTH - self.collectionFlowLayout.minimumInteritemSpacing - self.collectionFlowLayout.itemSize.width * 2) / 2;
    self.collectionFlowLayout.sectionInset = UIEdgeInsetsMake(0, padding, 0, padding);
    self.collectionFlowLayout.itemSize = CGSizeMake(FLoatChange(140), 142);
}

-(void)closeAction{
    [ScannerEventManager eventTrankingForGeneralEventWithName:main_purchase_close_click];
    [self dismiss];
}

- (void)dismiss {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Actions

- (IBAction)clickFreeTrialButton:(id)sender {
    // TODO:
    [self subscribe];
    
    [ScannerEventManager eventTrankingForGeneralEventWithName:main_purchase_click];
    [ScannerEventManager eventTrankingForGeneralEventWithName:app_purchase_total_click];
    [ScannerEventManager adjustEventWithName:main_purchase_click_token];
    [ScannerEventManager adjustEventWithName:app_purchase_total_click_token];
    
    if ([self.productid isEqualToString:subscribe1wTrialProductId]) {
        [ScannerEventManager eventTrankingForGeneralEventWithName:main_purchase_w_click];
        [ScannerEventManager adjustEventWithName:main_purchase_w_click_token];
    }else{
        [ScannerEventManager eventTrankingForGeneralEventWithName:main_purchase_y_click];
        [ScannerEventManager adjustEventWithName:main_purchase_y_click_token];
    }

}

-(void)subscribe{
    [self ps_showProgressHUDInWindow];
    [[PSPurchaseManager sharedInstance] purchaseProduct:self.productid completion:^(NSString * _Nonnull receipt, NSString * _Nonnull localPrice, BOOL success) {
        [self ps_hideProgressHUDForWindow];
        if (success) {
            [self verifySubscriptionsWithPrice:localPrice receipt:receipt];
            //先给VIP权限，再验证服务器
            [[PSUserInfoManager sharedInstance]setUserVIPStatus:YES];
            [self ps_showHint:@"Purchase Successfully"];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self dismiss];
            });
            
            [ScannerEventManager eventTrankingForGeneralEventWithName:main_purchase_success];
            [ScannerEventManager eventTrankingForGeneralEventWithName:app_purchase_total_success];
            
            if ([self.productid isEqualToString:subscribe1wTrialProductId]) {
               [ScannerEventManager eventTrankingForGeneralEventWithName:main_purchase_w_success];
            }else{
                [ScannerEventManager eventTrankingForGeneralEventWithName:main_purchase_y_success];
            }
            
        }else{
            if ([receipt isEqualToString:@"Cancel"]) {
                
            }else{
                [self ps_showHint:@"Purchase Failed"];
                [ScannerEventManager eventTrankingForGeneralEventWithName:main_purchase_failure];
                [ScannerEventManager eventTrankingForGeneralEventWithName:app_purchase_total_failure];
                
                if ([self.productid isEqualToString:subscribe1wTrialProductId]) {
                   [ScannerEventManager eventTrankingForGeneralEventWithName:main_purchase_w_failure];
                }else{
                    [ScannerEventManager eventTrankingForGeneralEventWithName:main_purchase_y_failure];
                }
            }
        }
    }];
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
                    [ScannerEventManager eventTrankingForGeneralEventWithName:main_purchase_w_verifySuccess];
                     price = [[subscribe1wTrialPrice substringFromIndex:1] floatValue];
                     [ScannerEventManager adjustEventWithName:main_purchase_w_success_token revenue:price];
                 }else{
                     [ScannerEventManager eventTrankingForGeneralEventWithName:main_purchase_y_verifySuccess];
                     price = [[subscribe1yTrialPrice substringFromIndex:1] floatValue];
                     [ScannerEventManager adjustEventWithName:main_purchase_y_success_token revenue:price];
                 }
                [ScannerEventManager eventTrankingForGeneralEventWithName:main_purchase_verifySuccess];
                [ScannerEventManager eventTrankingForGeneralEventWithName:app_purchase_total_verifySuccess];
                
                [ScannerEventManager adjustEventWithName:main_purchase_success_token];
                [ScannerEventManager adjustEventWithName:app_purchase_total_success_token];
            }else{//非VIP
                [ScannerEventManager eventTrankingForGeneralEventWithName:main_purchase_verifyFailure];
                [ScannerEventManager eventTrankingForGeneralEventWithName:app_purchase_total_verifyFailure];
                
                if ([self.productid isEqualToString:subscribe1wTrialProductId]) {
                   [ScannerEventManager eventTrankingForGeneralEventWithName:main_purchase_w_verifyFailure];
                }else{
                    [ScannerEventManager eventTrankingForGeneralEventWithName:main_purchase_y_verifyFailure];
                }
            }
        }else{
            [ScannerEventManager eventTrankingForGeneralEventWithName:main_purchase_unusualFailure];
            [ScannerEventManager eventTrankingForGeneralEventWithName:app_purchase_total_unusualFailure];
            
            if ([self.productid isEqualToString:subscribe1wTrialProductId]) {
               [ScannerEventManager eventTrankingForGeneralEventWithName:main_purchase_w_unusualFailure];
            }else{
                [ScannerEventManager eventTrankingForGeneralEventWithName:main_purchase_y_unusualFailure];
            }
        }
    }];
}


#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PSSubscriptionPurchaseCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[PSSubscriptionPurchaseCell ps_reuseIdentifier] forIndexPath:indexPath];
    cell.indexPath = indexPath;
    cell.model = self.dataSource[indexPath.row];
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    // TODO:
    NSLog(@"选中");
    [self updateContentWithIndex:indexPath.item];
    PSMainPurchseModel *selectModel = self.dataSource[indexPath.item];
    selectModel.selected = YES;
    for (PSMainPurchseModel *model in self.dataSource) {
        if (![model isEqual:selectModel]) {
            model.selected = NO;
        }
    }
    [self.collectionView reloadData];
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(nonnull NSIndexPath *)indexPath{
    NSLog(@"去除选中");
}

- (PSPurchaseViewModel *)viewModel{
    if (!_viewModel) {
        _viewModel = [[PSPurchaseViewModel alloc]init];
    }
    return _viewModel;
}

- (UIButton *)closeBtn{
    if (!_closeBtn) {
        _closeBtn = [UIButton buttonWithType:0];
        [_closeBtn setBackgroundImage:[UIImage imageNamed:@"icon_close2_30_black"] forState:UIControlStateNormal];
        [_closeBtn addTarget:self action:@selector(closeAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeBtn;
}

- (NSMutableArray *)dataSource{
    if (!_dataSource) {
        _dataSource = [[NSMutableArray alloc]init];
    }
    return _dataSource;
}

- (PSMainPurchseViewModel *)viewModel1{
    if (!_viewModel1) {
        _viewModel1 = [[PSMainPurchseViewModel alloc]init];
    }
    return _viewModel1;
}

-(NSString *)describeInfoType:(NSString *)type price:(NSString *)price{
    return [NSString stringWithFormat:@"By purchasing a subscription, you agree to the Terms of Service and acknowledge the Privacy Policy.Your subscription will automatically renew and your Apple ID account will be charged %@ each %@ until you cancel it at least 24 hours before the end of the then-current subscription period by following these instructions.",price,type];
}

#pragma mark - Property Getters

//- (NSArray *)products {
//    if (!_products) {
//        _products = @[@(1), @(2)]; // replace with SKProduct
//    }
//    return _products;
//}

@end
