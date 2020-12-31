//
//  PSDeviceInfoManager.h
//  PDFScanner
//
//  Created by heartjhl on 2020/5/27.
//  Copyright © 2020 cdants. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PSDeviceInfoManager : NSObject

///获取手机型号，如：iPhone 6
+ (NSString*)deviceVersion;

///获得系统版本 11.4.1
+ (NSString *)systemVersion;

///UUID
+ (NSString*)deviceUUID;

///APP版本号
+ (NSString *)appVersion;

///IDFA
+ (NSString *)deviceIDFA;
@end

NS_ASSUME_NONNULL_END
