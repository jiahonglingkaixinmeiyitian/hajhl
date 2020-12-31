//
//  PSPurchaseModel.m
//  PDFScanner
//
//  Created by heartjhl on 2020/5/27.
//  Copyright © 2020 cdants. All rights reserved.
//

#import "PSPurchaseModel.h"

//NSString *const subscribe1mPrice = @"$9.99";
//NSString *const subscribe1mProductId = @"scanner360_1m";

NSString *const subscribe1wTrialPrice = @"$4.99";
NSString *const subscribe1wTrialProductId = @"scanner360_trial_1w";

NSString *const subscribe1mTrialPrice = @"$9.99";
NSString *const subscribe1mTrialProductId = @"scanner360_trial_1m";

NSString *const subscribe1yTrialPrice = @"$39.99";
NSString *const subscribe1yTrialProductId = @"scanner360_trial_1y";


@implementation PSPurchaseModel

+ (instancetype)sharedInstance{
    static PSPurchaseModel *priceModel = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        //        创建实例 super:规避循环引用
        priceModel = [[super allocWithZone:NULL] init];;
    });
    return priceModel;
}

// 重写方法【必不可少】,避免外界使用 allocWithZone 再创建新对象
+ (id)allocWithZone:(struct _NSZone *)zone{
    return [self sharedInstance];
}

// 重写方法【必不可少】,避免copy新对象
- (id)copyWithZone:(nullable NSZone *)zone{
    return self;
}

- (NSSet<NSString *> *)productIds{
    return [NSSet setWithArray:@[subscribe1wTrialProductId,
                             subscribe1mTrialProductId,
                             subscribe1yTrialProductId]];
}

@end
