
#import <Foundation/Foundation.h>
#import "ScannerEventHeader.h"

NS_ASSUME_NONNULL_BEGIN

@interface ScannerEventManager : NSObject

/**
 FireBase/Facebook事件统计
 */
+(void)eventWithName:(NSString *)eventName parameters:(NSDictionary *__nullable)parameters;

/**
 Adjust事件统计
 */
+(void)adjustEventWithName:(NSString *)eventName;
+(void)adjustEventWithName:(NSString *)eventName revenue:(float)revenue;

@end

NS_ASSUME_NONNULL_END
