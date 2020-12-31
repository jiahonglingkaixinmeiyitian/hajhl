//
//  PSUserInfoManager.m
//  PDFScanner
//
//  Created by heartjhl on 2020/5/27.
//  Copyright © 2020 cdants. All rights reserved.
//

#import "PSUserInfoManager.h"

static NSString* const userInfoCacheKey = @"userInfoCache";

@interface PSUserInfoManager ()
/**  */
@property (nonatomic,strong,readwrite) PSUserModel *userModel;
@end
@implementation PSUserInfoManager

+ (instancetype)sharedInstance{
    static PSUserInfoManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
//        创建实例 super:规避循环引用
        manager = [[super allocWithZone:NULL] init];
    });
    return manager;
}

// 重写方法【必不可少】,避免外界使用 allocWithZone 再创建新对象
+ (id)allocWithZone:(struct _NSZone *)zone{
    return [self sharedInstance];
}

// 重写方法【必不可少】,避免copy新对象
- (id)copyWithZone:(nullable NSZone *)zone{
    return self;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        [self getUserModel];
    }
    return self;
}

-(void)setUserVIPStatus:(BOOL)isVIP{
    PSUserModel *model = self.userModel;;
    model.is_vip = isVIP;
    [self saveUserModel:model];
}

- (void)setAppVersion:(NSString *)version{
    PSUserModel *model = self.userModel;;
    model.appVersion = version;
    [self saveUserModel:model];
}

- (void)setUserLocationInBr:(BOOL)isInBr inUs:(BOOL)isInUs productId:(nonnull NSString *)productId{
    PSUserModel *model = self.userModel;;
    model.isInBr = isInBr;
    model.isInUs = isInUs;
    model.productId = productId;
    [self saveUserModel:model];
}

-(void)saveUserModel:(PSUserModel *)model{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
       [self archiverDataToUserDefaults:model withKey:userInfoCacheKey];
    });
}

-(void)getUserModel{
    NSData *saveData = [[NSUserDefaults standardUserDefaults] objectForKey:userInfoCacheKey];
    if (!saveData) {//下载后第一次启动为空
        return;
    }
    NSError *error;
    self.userModel = [NSKeyedUnarchiver unarchivedObjectOfClass:[PSUserModel class] fromData:saveData error:&error];
    if (error) {
        @throw [NSException exceptionWithName:error.localizedDescription reason:error.localizedFailureReason userInfo:error.userInfo];
    }
}

//归档数据
-(void)archiverDataToUserDefaults:(PSUserModel *)archiceData withKey:(NSString *)key{
    NSError *error;
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:archiceData requiringSecureCoding:YES error:&error];
    if (error) {
     @throw [NSException exceptionWithName:error.localizedDescription reason:error.localizedFailureReason userInfo:error.userInfo];
    }

    [[NSUserDefaults standardUserDefaults] setObject:data forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (PSUserModel *)userModel{
    if (!_userModel) {
        _userModel = [[PSUserModel alloc]init];
    }
    return _userModel;
}

@end

PSUserModel* _Nullable USER(void){
    return [PSUserInfoManager sharedInstance].userModel;
}
