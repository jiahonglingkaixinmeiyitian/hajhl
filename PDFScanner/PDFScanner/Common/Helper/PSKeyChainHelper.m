//
//  PSKeyChainHelper.m
//  PDFScanner
//
//  Created by Lucy Benson on 2020/5/8.
//  Copyright © 2020 cdants. All rights reserved.
//

#import "PSKeyChainHelper.h"
#import <UICKeyChainStore/UICKeyChainStore.h>

static NSString *kServiceName = @"pdf.scan.freeapp.keychain";
static NSString *kLockAppKey = @"kLockAppKey";

@implementation PSKeyChainHelper

+ (NSString *)passwordForAppLock {
    UICKeyChainStore *keychain = [UICKeyChainStore keyChainStoreWithService:kServiceName];
    return keychain[kLockAppKey];
}

+ (void)setAppLockPassword:(NSString *)password {
    UICKeyChainStore *keychain = [UICKeyChainStore keyChainStoreWithService:kServiceName];
    keychain[kLockAppKey] = password;
}

+ (BOOL)deleteAppLockPassword {
    UICKeyChainStore *keychain = [UICKeyChainStore keyChainStoreWithService:kServiceName];
    return [keychain removeItemForKey:kLockAppKey];
}

@end
