//
//  PSKeyChainManager.h
//  PDFScanner
//
//  Created by heartjhl on 2020/5/27.
//  Copyright © 2020 cdants. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PSKeyChainManager : NSObject
///从钥匙串中拿到UUID
+(NSString *)uuidFormeKeyChain;

///从钥匙串中拿到app版本
+(NSString *)appVersionFormeKeyChain;

///判断是否是新用户
+(BOOL)isNewUser;
@end

NS_ASSUME_NONNULL_END
