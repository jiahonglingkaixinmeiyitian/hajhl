
#import "ScannerEventManager.h"
//#import <Firebase.h>
//#import <Adjust/Adjust.h>
//#import <FBSDKCoreKit/FBSDKCoreKit.h>
@import Firebase;

@implementation ScannerEventManager

+(void)eventWithName:(NSString *)eventName parameters:(NSDictionary *__nullable)parameters {
    [FIRAnalytics logEventWithName:eventName parameters:parameters];
    [FBSDKAppEvents logEvent:eventName parameters:parameters];
}

+(void)eventTrankingForGeneralEventWithName:(NSString *)name{
    [FIRAnalytics logEventWithName:name parameters:nil];
    [FBSDKAppEvents logEvent:name];
}

+(void)adjustEventWithName:(NSString *)eventName {
    ADJEvent *event = [ADJEvent eventWithEventToken:eventName];
    [Adjust trackEvent:event];
}

+(void)adjustEventWithName:(NSString *)eventName revenue:(float)revenue {
    ADJEvent *event = [ADJEvent eventWithEventToken:eventName];
    [event setRevenue:revenue currency:@"USD"];
    [Adjust trackEvent:event];
}

@end
