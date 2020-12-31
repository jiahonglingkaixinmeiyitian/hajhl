//
//  PSKeyChainManager.m
//  PDFScanner
//
//  Created by heartjhl on 2020/5/27.
//  Copyright © 2020 cdants. All rights reserved.
//

#import "PSKeyChainManager.h"
#import <SAMKeychain/SAMKeychain.h>

static NSString* const keyChainService = @"com.scanner360.keyChainService";
static NSString* const uuidAccount = @"uuidAccount";
static NSString* const appVersionAccount = @"appVersionAccount";
static NSString* const scanner360NewUserAccount = @"scanner360NewUserAccount";

@implementation PSKeyChainManager
+(NSString *)uuidFormeKeyChain{
    NSString *uuid = [self getValueWithKey:uuidAccount];
    if (uuid&&uuid.length>0) {
        return uuid;
    }else{
        uuid = [[[UIDevice currentDevice] identifierForVendor] UUIDString];//获得本应用的uuid
        [self saveValue:uuid wihtkey:uuidAccount];
        return uuid;
    }
}

+(NSString *)appVersionFormeKeyChain{
    NSString *appVersion = [self getValueWithKey:appVersionAccount];
    if (appVersion&&appVersion.length>0) {
        return appVersion;
    }else{
        appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
        [self saveValue:appVersion wihtkey:appVersionAccount];
        return appVersion;
    }
}

+(BOOL)isNewUser{
    NSString *newUser = [self getValueWithKey:scanner360NewUserAccount];
    if ([newUser isEqualToString:@"scanner360NewUser"]) {
       return YES;
    }
    [self saveValue:@"scanner360NewUser" wihtkey:scanner360NewUserAccount];
    return NO;
}

+(NSString *)getValueWithKey:(NSString *)key{
    NSError *error = nil;
    NSString *value = [SAMKeychain passwordForService:keyChainService account:key error: &error];
    if([error code] == errSecItemNotFound){
        value = @"";
    }
    return value;
}

+(void)saveValue:(NSString *)value wihtkey:(NSString *)key{
    [SAMKeychain setAccessibilityType:kSecAttrAccessibleWhenUnlockedThisDeviceOnly];//设置该密码的权限只有在手机解锁、此台设备才可获得。
    [SAMKeychain setPassword:value forService:keyChainService account:key];
}
@end
