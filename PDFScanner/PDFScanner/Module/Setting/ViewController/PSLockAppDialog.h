//
//  PSLockAppDialog.h
//  PDFScanner
//
//  Created by Lucy Benson on 2020/5/7.
//  Copyright © 2020 cdants. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, PSLockAppType) {
    PSLockAppTypeCreatePassword = 0,  // 设置新密码
    PSLockAppTypeConfirmPassword,     // 确认密码(不用于初始化，内部使用)
    PSLockAppTypeUnlock,     // 解锁密码
};

typedef void(^PasswordDidSetBlock)(void);

@interface PSLockAppDialog : UIViewController

@property (nonatomic, copy) PasswordDidSetBlock passwordSetBlock;

- (instancetype)initWithType:(PSLockAppType)type;

@end

