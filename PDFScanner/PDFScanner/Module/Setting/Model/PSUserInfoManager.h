//
//  PSUserInfoManager.h
//  PDFScanner
//
//  Created by heartjhl on 2020/5/27.
//  Copyright © 2020 cdants. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PSUserModel.h"

extern PSUserModel* _Nullable USER(void);
NS_ASSUME_NONNULL_BEGIN

@interface PSUserInfoManager : NSObject
/**  */
@property (nonatomic,strong,readonly) PSUserModel *userModel;
///单例
+ (instancetype)sharedInstance;

///设置是否是VIP
-(void)setUserVIPStatus:(BOOL)isVIP;

///设置用户当前App版本
-(void)setAppVersion:(NSString *)version;

///更新用户的位置
- (void)setUserLocationInBr:(BOOL)isInBr inUs:(BOOL)isInUs productId:(NSString *)productId;
@end

NS_ASSUME_NONNULL_END
