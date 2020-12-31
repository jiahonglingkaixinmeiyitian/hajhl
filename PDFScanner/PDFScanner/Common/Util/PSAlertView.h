//
//  PSAlertView.h
//  PDFScanner
//
//  Created by heartjhl on 2020/5/27.
//  Copyright © 2020 cdants. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
typedef void (^ConfirmClick)(void);
typedef void (^CancelClick)(void);
@interface PSAlertView : NSObject

@property (nonatomic, copy) ConfirmClick confirmClick;
@property (nonatomic, copy) CancelClick cancelClick;

+ (void)alertWithCurrentController:(UIViewController *)currentController title:(NSString *)title message:(NSString *)message actionWithTitle:(NSString *)actionTitle action:(void (^ __nullable)(UIAlertAction *action))actiont;
+ (void)alertWithCurrentController:(UIViewController *)currentController title:(NSString *)title message:(NSString *)message actionWithTitle:(NSString *)actionTitle confirm:(ConfirmClick)confirm;
+ (void)alertWithCurrentController:(UIViewController *)currentController title:(NSString *)title message:(NSString *)message actionWitLeftTitle:(NSString *)actionLeftTitle actionWithRightTitle:(NSString *)actionRightTitle confirm:(ConfirmClick)confirm cancel:(CancelClick)cancel;

@end

NS_ASSUME_NONNULL_END
