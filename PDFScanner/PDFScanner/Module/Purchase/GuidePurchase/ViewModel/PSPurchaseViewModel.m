//
//  PSPurchaseViewModel.m
//  PDFScanner
//
//  Created by heartjhl on 2020/5/27.
//  Copyright © 2020 cdants. All rights reserved.
//

#import "PSPurchaseViewModel.h"

@implementation PSPurchaseViewModel
///验证购买
-(void)verifySubscriptionsWithPrice:(NSString *)price receipt:(NSString *)receipt modelBlcok:(void(^)(PSVIPInfoModel *model))modelBlock{
    NSDictionary *parame = @{@"price":price,@"receipt":receipt};
    [[PSAPIClient defaultClient] POST:@"api/v1/payment/validate-receipt" parameters:parame modelClass:[PSVIPInfoModel class] completeBlock:^(PSVIPInfoModel   * _Nullable responseObject, NSError * _Nullable error) {
        modelBlock(responseObject);
    }];
}

///验证回复购买
-(void)verifyRestorePurchaseWithReceipt:(NSString *)receipt modelBlcok:(void(^)(PSVIPInfoModel *model))modelBlock{
    NSDictionary *parame = @{@"receipt":receipt};
    [[PSAPIClient defaultClient] POST:@"api/v1/payment/restore" parameters:parame modelClass:[PSVIPInfoModel class] completeBlock:^(PSVIPInfoModel  *_Nullable responseObject, NSError * _Nullable error) {
        modelBlock(responseObject);
    }];
}

///验证是否是VIP
-(void)verifyIsVIPModelBlcok:(void(^)(PSVIPInfoModel *model))modelBlock{
    NSDictionary *parame = @{};
    [[PSAPIClient defaultClient] POST:@"api/v1/user/isvip" parameters:parame modelClass:[PSVIPInfoModel class] completeBlock:^(PSVIPInfoModel * _Nullable responseObject, NSError * _Nullable error) {
        modelBlock(responseObject);
    }];
}

@end
