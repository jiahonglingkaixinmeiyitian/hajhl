//
//  PSLaunchSubscribeManager.m
//  PDFScanner
//
//  Created by heartjhl on 2020/5/27.
//  Copyright © 2020 cdants. All rights reserved.
//

#import "PSLaunchSubscribeManager.h"
#import "PSPurchaseViewModel.h"
#import "PSAlertView.h"

@interface PSLaunchSubscribeManager ()
/**  */
@property (nonatomic,strong) PSPurchaseViewModel *viewModel;
/**  */
@property (nonatomic,copy) NSString *lastReceipt;
@end
@implementation PSLaunchSubscribeManager

+ (instancetype)sharedInstance{
    static PSLaunchSubscribeManager *priceModel = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        //        创建实例 super:规避循环引用
        priceModel = [[super allocWithZone:NULL] init];
    });
    return priceModel;
}

// 重写方法【必不可少】,避免外界使用 allocWithZone 再创建新对象
+ (id)allocWithZone:(struct _NSZone *)zone{
    return [self sharedInstance];
}

-(void)launchIAPRequest{
    [self launchIAPRequestAuth];
    if(USER().appVersion){//下载后第二次启动，走验证是否是VIP的接口
        [self verifyVIP];
    }else{//第一次下载或者删除后再下载启动后，有购买凭证走恢复，没有走验证是否是VIP接口
        [self restorePurchaseForDownloadAppAuth];
    }
}

-(void)launchIAPRequestAuth{
    [self registerTransactionObserver];//掉单后再次验证
//    [self internalPurchaseExtension];//内购推广
    [self retrieveProductsInfo];//检索产品信息
}

///掉单后再次验证
-(void)registerTransactionObserver{
    [[PSPurchaseManager sharedInstance] registerTransactionObserverCompletion:^(NSString * _Nonnull receipt, NSString * _Nonnull localPrice, BOOL success) {
        if (success) {
            NSLog(@"❄️❄️❄️ 掉单子验证 ❄️❄️❄️");
            if ([self.lastReceipt isEqualToString:receipt]) {//避免重复验证，比如月套餐，假如用户一月份订阅购买了，二月份，三月份没有打开过app，但依然会正常扣费，等四月份打开的时候，就会走三次这里，三次的receip是一样的，只需验证一次，无需多次验证
                [[PSPurchaseManager sharedInstance] finishTransaction];
                return;
            }
            self.lastReceipt = receipt;
            
            NSArray *arr = [localPrice componentsSeparatedByString:@"&"];
            NSString *productId = arr.firstObject;//用于区分套餐
            NSString *applicationUsername = arr.lastObject;//用于区分掉单和续订

            [self.viewModel verifySubscriptionsWithPrice:@"0.00" receipt:receipt modelBlcok:^(PSVIPInfoModel * _Nonnull model) {
                [[PSPurchaseManager sharedInstance] finishTransaction];
                if (model) {
                    [[PSUserInfoManager sharedInstance] setUserVIPStatus:model.is_vip];
                    if (applicationUsername.length>0) {//掉单
                        if (model.is_vip) {//验证成功
                            float price = 0;
                            if ([applicationUsername isEqualToString:subscribe1wTrialProductId]) {
                                [ScannerEventManager eventTrankingForGeneralEventWithName:guide_trail_w_verifySuccess];
                                price = [[subscribe1wTrialPrice substringFromIndex:1] floatValue];
                                [ScannerEventManager adjustEventWithName:guide_trail_w_success_token revenue:price];
                            }else if ([applicationUsername isEqualToString:subscribe1mTrialProductId]){
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
                            
                            [ScannerEventManager eventTrankingForGeneralEventWithName:app_purchaseLoss_total_verifySuccess];
#if DEBUG
                             [self showAleart:YES];
#endif
                        }else{//验证失败
                            if ([applicationUsername isEqualToString:subscribe1wTrialProductId]) {
                                [ScannerEventManager eventTrankingForGeneralEventWithName:guide_trail_w_verifyFailure];
                            }else if ([applicationUsername isEqualToString:subscribe1mTrialProductId]){
                                [ScannerEventManager eventTrankingForGeneralEventWithName:guide_trail_m_verifyFailure];
                            }else{
                                [ScannerEventManager eventTrankingForGeneralEventWithName:guide_trail_y_verifyFailure];
                            }
                            
                            [ScannerEventManager eventTrankingForGeneralEventWithName:guide_subscribe_verifyFailure];
                            [ScannerEventManager eventTrankingForGeneralEventWithName:app_purchase_total_verifyFailure];
                            [ScannerEventManager eventTrankingForGeneralEventWithName:app_purchaseLoss_total_verifyFailure];
#if DEBUG
                            [self showAleart:NO];
#endif
                        }
                    }else{//续订，不处理

                    }
                }else{//没有数据返回
                   [ScannerEventManager eventTrankingForGeneralEventWithName:app_purchaseLoss_total_unusualFailure];
                }
                
            }];
        }
    }];
}

-(void)showAleart:(BOOL)success{
    NSString *msg = @"掉单恢复成功";
    if (!success) {
        if (USER().is_vip) {
           msg = @"VIP续订成功";
        }else{
         msg = @"VIP已经过期，请重新购买";
        }
    }
    [PSAlertView alertWithCurrentController:[UIApplication sharedApplication].keyWindow.rootViewController title:@"" message:msg actionWithTitle:@"确定" action:^(UIAlertAction * _Nonnull action) {
    }];
}

-(void)getGuidePageConfigInfo{
//    [self.viewModel guidePageCloseBtnInfo];
}

///用户是非VIP时，初始化付费页
-(void)retrieveProductsInfo{
    BOOL isVIP = USER().is_vip;
    if (!isVIP) {
        PSPurchaseModel *model = [PSPurchaseModel sharedInstance];
        model.priceDic = @{subscribe1wTrialProductId:subscribe1wTrialPrice,
                          subscribe1mTrialProductId:subscribe1mTrialPrice,
                           subscribe1yTrialProductId:subscribe1yTrialPrice};//默认值
        [[PSPurchaseManager sharedInstance] retrieveProductsInfo:[PSPurchaseModel sharedInstance].productIds completion:^(NSDictionary * _Nonnull priceDic, BOOL success) {
            NSLog(@"🍌🍌🍌🍌🍌🍌获取到的价钱信息：%@",priceDic);
            if (success) {
                model.priceDic = priceDic;
            }
        }];
    }
}

///内购推广
-(void)internalPurchaseExtension{
    [[PSPurchaseManager sharedInstance] shoudAddPurchaseCompletion:^(NSString * _Nonnull indentify, NSString * _Nonnull localPrice, BOOL success) {
//        [UPEventTrackManager eventTrankingForGeneralEventWithName:internal_purchase_extension];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"AppStorePurchaseExtension" object:indentify];
    }];
}

/////验证购买
//-(void)purchaseWithPrice:(NSString *)price receipt:(NSString *)receipt{
//
//}
//
/////验证恢复购买
//-(void)restorePurchaseWithReceipt:(NSString *)receipt{
//
//}

-(void)restorePurchaseForDownloadAppAuth{
     __weak typeof(self) weakSelf = self;
    [[PSPurchaseManager sharedInstance] existReceiptInfo:^(BOOL exist) {
        NSLog(@"🌹🌹🌹🌹🌹🌹收据信息是否存在：%d",exist);
        if (exist) {//存在收据信息
            [weakSelf restorePurchase];
        }else{//不存在收据信息
            [weakSelf verifyVIP];//此处调该接口目的：给服务器同步 header 信息
        }
        
    }];
}

/**
 用户第一次下载后该接口调用的情况描述
 1.用户没有登录appID的情况下打开app，点击取消或者其他按钮，receipt为Cancel或Restore Failed
 2.用户登录appID的情况下打开app，跳出弹框提示："没有提供App内购买的相关信息。请稍后重试"，receipt为Cancel
 */
-(void)restorePurchase{
    [[PSPurchaseManager sharedInstance] restorePurchaseCompletion:^(NSString * _Nonnull receipt, NSString * _Nonnull localPrice, BOOL success) {
        NSLog(@"🌹🌹🌹🌹🌹🌹哈哈哈：%@ 🍎🍎🍎：%d",receipt,success);
        if (success&&receipt&&receipt.length>0) {
            [self verifyRestorePurchaseWithReceipt:receipt];
        }
    }];
}

///验证恢复购买
-(void)verifyRestorePurchaseWithReceipt:(NSString *)receipt{
    [self.viewModel verifyRestorePurchaseWithReceipt:receipt modelBlcok:^(PSVIPInfoModel * _Nonnull model) {
        if (model) {
            [[PSUserInfoManager sharedInstance] setUserVIPStatus:model.is_vip];
        }
    }];
}

///验证是否是VIP
-(void)verifyVIP{
    [self.viewModel verifyIsVIPModelBlcok:^(PSVIPInfoModel * _Nonnull model) {
        if (model) {
            [[PSUserInfoManager sharedInstance] setUserVIPStatus:model.is_vip];
        }
    }];
}


-(void)restorePurchaseFailed:(UIViewController *)controler{
    [PSAlertView alertWithCurrentController:controler title:@"Restore Failed" message:@"Restore failed, please try again. Cannot connect to iTunes Store." actionWithTitle:@"Ok" action:^(UIAlertAction * _Nonnull action) {
    }];
}

-(void)restorePurchaseExpired:(UIViewController *)controler{
    [PSAlertView alertWithCurrentController:controler title:@"Restore Failed" message:@"Restore Failed,your VIP has expired, please buy it again." actionWithTitle:@"Ok" action:^(UIAlertAction * _Nonnull action) {
        
    }];
}

-(void)restorePurchaseSuccess:(UIViewController *)controler successBlock:(void (^)(void))successBlock{
    [PSAlertView alertWithCurrentController:controler title:@"Purchase Restored" message:@"Your previously purchased products have been restored!" actionWithTitle:@"Ok" action:^(UIAlertAction * _Nonnull action) {
        successBlock();
    }];
}

- (PSPurchaseViewModel *)viewModel{
    if (!_viewModel) {
        _viewModel = [[PSPurchaseViewModel alloc]init];
    }
    return _viewModel;
}

@end
