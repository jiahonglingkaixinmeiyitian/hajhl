//
//  PSPurchaseManager.h
//  PDFScanner
//
//  Created by heartjhl on 2020/5/27.
//  Copyright © 2020 cdants. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PSPurchaseManager : NSObject
///创建单利
+ (instancetype)sharedInstance;

///注册交易观察者
- (void)registerTransactionObserverCompletion:(void(^)(NSString *,NSString *,BOOL))completion;

/**
 * 获取内购项目列表
 *
 * @param productId 产品ID
 */
-(void)retrieveProductsInfo:(NSSet<NSString *> *)productId completion:(void(^)(NSDictionary *,BOOL ))completion;

/**
 * 购买产品
 *
 * @param productid 产品ID
 * @param completion 回调的第一个参数为receipt,第二个为价格如：121CNY，BOOL值为YES代表支付成功并取得支付凭据，为NO时代表支付失败
 */
-(void)purchaseProduct:(NSString *)productid completion:(void(^)(NSString *,NSString *,BOOL))completion;

/**
 * 恢复内购
 *
 * @param completion 回调的第一个参数为receipt,第二个为价格如：121CNY，BOOL值为YES代表恢复成功并取得支付凭据，为NO时代表恢复失败
 */
- (void)restorePurchaseCompletion:(void(^)(NSString *,NSString *,BOOL))completion;

/**
 内购推广
 */
- (void)shoudAddPurchaseCompletion:(void(^)(NSString *,NSString *,BOOL))completion;

/**
 服务器验证成功后结束本次交易
 */
-(void)finishTransaction;

/**
 是否有receipt信息,存在收据信息则购买过，不存在收据信息则没有购买过
 
 @param completion 收据信息是否存在的回调，exist为YES，则有收据信息，为NO，则没有收据信息
 */
-(void)existReceiptInfo:(void(^)(BOOL exist))completion;
@end

NS_ASSUME_NONNULL_END
