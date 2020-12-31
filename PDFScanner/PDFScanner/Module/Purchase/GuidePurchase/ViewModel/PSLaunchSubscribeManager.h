//
//  PSLaunchSubscribeManager.h
//  PDFScanner
//
//  Created by heartjhl on 2020/5/27.
//  Copyright © 2020 cdants. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PSLaunchSubscribeManager : NSObject
///单利
+ (instancetype)sharedInstance;

///应用启动后的请求
-(void)launchIAPRequest;

///验证是否是VIP
-(void)verifyVIP;

///引导页配置
-(void)getGuidePageConfigInfo;

///恢复购买失败
-(void)restorePurchaseFailed:(UIViewController *)controler;

///VIP过期
-(void)restorePurchaseExpired:(UIViewController *)controler;

///恢复购买成功
-(void)restorePurchaseSuccess:(UIViewController *)controler successBlock:(void(^)(void))successBlock;

@end

NS_ASSUME_NONNULL_END
