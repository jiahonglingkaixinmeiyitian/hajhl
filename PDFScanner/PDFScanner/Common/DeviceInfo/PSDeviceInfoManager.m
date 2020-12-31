//
//  PSDeviceInfoManager.m
//  PDFScanner
//
//  Created by heartjhl on 2020/5/27.
//  Copyright © 2020 cdants. All rights reserved.
//

#import "PSDeviceInfoManager.h"
#import "sys/utsname.h"
#import <AdSupport/AdSupport.h>
#import "PSKeyChainManager.h"

@implementation PSDeviceInfoManager

+ (NSString*)deviceVersion{
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString * deviceString = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    //iPhone
    if ([deviceString isEqualToString:@"iPhone5,1" ])    return @"iPhone 5";
    if ([deviceString isEqualToString:@"iPhone5,2" ])    return @"iPhone 5";
    if ([deviceString isEqualToString:@"iPhone5,3" ])    return @"iPhone 5C";
    if ([deviceString isEqualToString:@"iPhone5,4" ])    return @"iPhone 5C";
    if ([deviceString isEqualToString:@"iPhone6,1" ])    return @"iPhone 5S";
    if ([deviceString isEqualToString:@"iPhone6,2" ])    return @"iPhone 5S";
    if ([deviceString isEqualToString:@"iPhone7,1" ])    return @"iPhone 6 Plus";
    if ([deviceString isEqualToString:@"iPhone7,2" ])    return @"iPhone 6";
    if ([deviceString isEqualToString:@"iPhone8,1" ])    return @"iPhone 6s";
    if ([deviceString isEqualToString:@"iPhone8,2" ])    return @"iPhone 6s Plus";
    if ([deviceString isEqualToString:@"iPhone8,4" ])    return @"iPhone 5SE";
    if ([deviceString isEqualToString:@"iPhone9,1" ])    return @"iPhone 7";
    if ([deviceString isEqualToString:@"iPhone9,2" ])    return @"iPhone 7 Plus";
    if ([deviceString isEqualToString:@"iPhone9,3" ])    return @"iPhone 7 Plus Black";
    if ([deviceString isEqualToString:@"iPhone9,4" ])    return @"iPhone 7 Plus Red";
    if ([deviceString isEqualToString:@"iPhone10,1"])    return @"iPhone 8";
    if ([deviceString isEqualToString:@"iPhone10,4"])    return @"iPhone 8";
    if ([deviceString isEqualToString:@"iPhone10,2"])    return @"iPhone 8 Plus";
    if ([deviceString isEqualToString:@"iPhone10,5"])    return @"iPhone 8 Plus";
    if ([deviceString isEqualToString:@"iPhone10,3"])    return @"iPhone X";
    if ([deviceString isEqualToString:@"iPhone10,6"])    return @"iPhone X";
    if ([deviceString isEqualToString:@"iPhone11,2"])    return @"iPhone XS";
    if ([deviceString isEqualToString:@"iPhone11,8"])    return @"iPhone XR";
    if ([deviceString isEqualToString:@"iPhone11,4"])    return @"iPhone XS MAX";
    if ([deviceString isEqualToString:@"iPhone11,6"])    return @"iPhone XS MAX";
    if ([deviceString isEqualToString:@"iPhone12,1"])    return @"iPhone 11";
    if ([deviceString isEqualToString:@"iPhone12,3"])    return @"iPhone 11Pro";
    if ([deviceString isEqualToString:@"iPhone12,5"])    return @"iPhone 11ProMax";
    
    return deviceString;
}

+ (NSString *)systemVersion{
    return [[UIDevice currentDevice] systemVersion];
}

+ (NSString *)deviceUUID{
    return [PSKeyChainManager uuidFormeKeyChain];
}
+ (NSString *)appVersion{
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
}

+ (NSString *)deviceIDFA{
   return [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
}
@end
