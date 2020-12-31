
#import <Foundation/Foundation.h>
#import "ScannerEventHeader.h"

NS_ASSUME_NONNULL_BEGIN

@interface ScannerEventManager : NSObject

/**
 FireBase/Facebook事件统计
 */
+(void)eventWithName:(NSString *)eventName parameters:(NSDictionary *__nullable)parameters;

///追踪常规事件
+(void)eventTrankingForGeneralEventWithName:(NSString *)name;

/**
 Adjust事件统计
 */
+(void)adjustEventWithName:(NSString *)eventName;
+(void)adjustEventWithName:(NSString *)eventName revenue:(float)revenue;

@end

NS_ASSUME_NONNULL_END
