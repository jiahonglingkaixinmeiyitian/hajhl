//
//  PSRemoteConfig.m
//  PDFScanner
//
//  Created by heartjhl on 2020/6/1.
//  Copyright © 2020 cdants. All rights reserved.
//

#import "PSRemoteConfig.h"
@import Firebase;

NSString *const kLocationUSConfigKey = @"location_us_key";
NSString *const kLocationBRConfigKey = @"location_br_key";

///美国
static NSString* const kLocationUSConfigValueIn = @"in_us";
///巴西
static NSString* const kLocationBRConfigValueIn = @"in_br";

static NSString* const valueA = @"A";
static NSString* const valueB = @"B";
static NSString* const valueC = @"C";

@interface PSRemoteConfig ()
@property (nonatomic, strong) FIRRemoteConfig *remoteConfig;
@end
@implementation PSRemoteConfig
+ (instancetype)sharedInstance{
    static PSRemoteConfig *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[PSRemoteConfig alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        self.remoteConfig = [FIRRemoteConfig remoteConfig];
        FIRRemoteConfigSettings *remoteConfigSettings = [[FIRRemoteConfigSettings alloc] init];
        remoteConfigSettings.minimumFetchInterval = 0;
        self.remoteConfig.configSettings = remoteConfigSettings;
        [self.remoteConfig setDefaultsFromPlistFileName:@"RemoteConfigDefaults"];
        
        [self fetchConfig];
    }
    return self;
}

-(void)fetchConfig{
//    [[PSUserInfoManager sharedInstance] setUserLocationInBr:NO inUs:YES productId:[self fetchProductIdWithPlan:valueB]];
//    return;
    #if DEBUG
        long expirationDuration = 30;
    #else
        long expirationDuration = 12*60*60;
    #endif
    
    [self.remoteConfig fetchWithExpirationDuration:expirationDuration completionHandler:^(FIRRemoteConfigFetchStatus status, NSError *error) {
        if (status == FIRRemoteConfigFetchStatusSuccess) {
            [self.remoteConfig activateWithCompletion:^(BOOL changed, NSError * _Nullable error) {
                NSLog(@"🍉🍉🍉🍉🍉🍉---changed：%d",changed);
                if (!error&&changed) {
                    NSString* strUs = self.remoteConfig[kLocationUSConfigKey].stringValue;
                    NSString* strBr = self.remoteConfig[kLocationBRConfigKey].stringValue;
                    
                    NSArray *usArr = [strUs componentsSeparatedByString:@"||"];
                    NSArray *brArr = [strBr componentsSeparatedByString:@"||"];
                    
                    BOOL isInUs = [usArr.firstObject isEqualToString:kLocationUSConfigValueIn];
                    BOOL isInBr = [brArr.firstObject isEqualToString:kLocationBRConfigValueIn];
                    
                    NSString *productId = nil;
                    if (isInUs) {
                        productId = [self fetchProductIdWithPlan:usArr.lastObject];
                    }else if (isInBr){
                        productId = [self fetchProductIdWithPlan:brArr.lastObject];
                    }else{
                        productId = [self fetchProductIdWithPlan:valueB];//默认计划B
                    }
                    
                    [[PSUserInfoManager sharedInstance] setUserLocationInBr:isInBr inUs:isInUs productId:productId];
                    
                    NSLog(@"🍉🍉🍉🍉🍉🍉远程配置获取成功:%@****:%@",strUs,strBr);
                }else{
                    NSLog(@"🍉🍉🍉🍉🍉🍉获取失败：%@",error);
                }
            }];
            
        } else {
            NSLog(@"Config not fetched");
            NSLog(@"Error %@", error.localizedDescription);
        }
    }];
}

-(NSString *)fetchProductIdWithPlan:(NSString *)plan{
    if ([plan isEqualToString:valueA]) {
        return subscribe1wTrialProductId;
    }else if ([plan isEqualToString:valueB]){
        return subscribe1mTrialProductId;
    }else{
        return subscribe1yTrialProductId;
    }
}

@end
