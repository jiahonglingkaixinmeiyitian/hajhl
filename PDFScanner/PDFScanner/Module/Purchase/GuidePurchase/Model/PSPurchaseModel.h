//
//  PSPurchaseModel.h
//  PDFScanner
//
//  Created by heartjhl on 2020/5/27.
//  Copyright © 2020 cdants. All rights reserved.
//

#import <Foundation/Foundation.h>

///一个月的信息
//FOUNDATION_EXTERN NSString * _Nullable const subscribe1mPrice;//（价钱）
//FOUNDATION_EXTERN NSString * _Nullable const subscribe1mProductId;//（没有试用）

///一周的信息（PlanA）
FOUNDATION_EXTERN NSString * _Nullable const subscribe1wTrialPrice;//（价钱）
FOUNDATION_EXTERN NSString * _Nullable const subscribe1wTrialProductId;//（没有试用）

///一个月的信息（PlanB）
FOUNDATION_EXTERN NSString * _Nullable const subscribe1mTrialPrice;//（价钱）
FOUNDATION_EXTERN NSString * _Nullable const subscribe1mTrialProductId;//（没有试用）

///一个年的信息（PlanC）
FOUNDATION_EXTERN NSString * _Nullable const subscribe1yTrialPrice;//（价钱）
FOUNDATION_EXTERN NSString * _Nullable const subscribe1yTrialProductId;//（没有试用）

NS_ASSUME_NONNULL_BEGIN

@interface PSPurchaseModel : NSObject
///创建单利
+ (instancetype)sharedInstance;
/** 从苹果服务器请求回来的价钱 */
@property (nonatomic,copy) NSDictionary *priceDic;
/** 用于向苹果服务器请求产品信息的集合 */
@property (nonatomic,strong) NSSet<NSString *> *productIds;
@end

NS_ASSUME_NONNULL_END
