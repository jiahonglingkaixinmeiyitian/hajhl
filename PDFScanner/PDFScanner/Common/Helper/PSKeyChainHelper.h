//
//  PSKeyChainHelper.h
//  PDFScanner
//
//  Created by Lucy Benson on 2020/5/8.
//  Copyright © 2020 cdants. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PSKeyChainHelper : NSObject

+ (NSString *)passwordForAppLock; // if not nil, lock app in setting is switched on.
+ (void)setAppLockPassword:(NSString *)password;
+ (BOOL)deleteAppLockPassword;

@end

