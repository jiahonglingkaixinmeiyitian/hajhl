//
//  PSPurchaseManager.m
//  PDFScanner
//
//  Created by heartjhl on 2020/5/27.
//  Copyright © 2020 cdants. All rights reserved.
//

#import "PSPurchaseManager.h"
#import "PDFScanner-Swift.h"

@implementation PSPurchaseManager
+ (instancetype)sharedInstance{
    static PSPurchaseManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
//        创建实例 super:规避循环引用
        manager = [[super allocWithZone:NULL] init];;
    });
    return manager;
}

// 重写方法【必不可少】,避免外界使用 allocWithZone 再创建新对象
+ (id)allocWithZone:(struct _NSZone *)zone{
    return [self sharedInstance];
}

// 重写方法【必不可少】,避免copy新对象
- (id)copyWithZone:(nullable NSZone *)zone{
    return self;
}

- (void)registerTransactionObserverCompletion:(void(^)(NSString *,NSString *,BOOL))completion{
        [PSPurchaseAPI.shared registerTransactionObserverAPIWithCompletion:completion];
}

-(void)retrieveProductsInfo:(NSSet<NSString *> *)productId completion:(void(^)(NSDictionary *,BOOL ))completion{
       [PSPurchaseAPI.shared retrieveProductsInfoAPIWithProductIds:productId completiton:completion];
}

-(void)purchaseProduct:(NSString *)productid completion:(void(^)(NSString *,NSString *,BOOL))completion{
    [PSPurchaseAPI.shared purchaseProductAPIWithProductid:productid completion:completion];
}

- (void)restorePurchaseCompletion:(void(^)(NSString *,NSString *,BOOL))completion{
    [PSPurchaseAPI.shared restorePurchaseAPIWithCompletion:completion];
}

- (void)shoudAddPurchaseCompletion:(void(^)(NSString *,NSString *,BOOL))completion {
    [PSPurchaseAPI.shared shoudAddPurchaseAPIWithCompletion:completion];
}

-(void)finishTransaction{
    [PSPurchaseAPI.shared finishTransaction];
}

-(void)existReceiptInfo:(void(^)(BOOL exist))completion{
    [PSPurchaseAPI.shared existReceiptInfo:completion];
}
@end
