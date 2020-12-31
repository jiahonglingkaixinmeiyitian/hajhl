//
//  PSPurchaseViewModel.h
//  PDFScanner
//
//  Created by heartjhl on 2020/5/27.
//  Copyright © 2020 cdants. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PSPurchaseViewModel : NSObject
///验证购买
-(void)verifySubscriptionsWithPrice:(NSString *)price receipt:(NSString *)receipt modelBlcok:(void(^)(PSVIPInfoModel *model))modelBlock;

///验证恢复购买
-(void)verifyRestorePurchaseWithReceipt:(NSString *)receipt modelBlcok:(void(^)(PSVIPInfoModel *model))modelBlock;

///验证是否是VIP
-(void)verifyIsVIPModelBlcok:(void(^)(PSVIPInfoModel *model))modelBlock;


@end

NS_ASSUME_NONNULL_END
