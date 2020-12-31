//
//  PSAlertView.m
//  PDFScanner
//
//  Created by heartjhl on 2020/5/27.
//  Copyright © 2020 cdants. All rights reserved.
//

#import "PSAlertView.h"

@implementation PSAlertView
+ (void)alertWithCurrentController:(UIViewController *)currentController title:(NSString *)title message:(NSString *)message actionWithTitle:(NSString *)actionTitle action:(void (^ __nullable)(UIAlertAction *action))actiont {
    
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    [alertVC addAction:[UIAlertAction actionWithTitle:actionTitle style:UIAlertActionStyleDefault handler:actiont]];
    
    [currentController presentViewController:alertVC animated:YES completion:nil];
    
}

+ (void)alertWithCurrentController:(UIViewController *)currentController title:(NSString *)title message:(NSString *)message actionWithTitle:(NSString *)actionTitle confirm:(ConfirmClick)confirm {
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    [alertVC addAction:[UIAlertAction actionWithTitle:actionTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        confirm();
    }]];
    [currentController presentViewController:alertVC animated:YES completion:nil];
}

+ (void)alertWithCurrentController:(UIViewController *)currentController title:(NSString *)title message:(NSString *)message actionWitLeftTitle:(NSString *)actionLeftTitle actionWithRightTitle:(NSString *)actionRightTitle confirm:(ConfirmClick)confirm cancel:(CancelClick)cancel {
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    [alertVC addAction:[UIAlertAction actionWithTitle:actionLeftTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        confirm();
    }]];
    [alertVC addAction:[UIAlertAction actionWithTitle:actionRightTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        cancel();
    }]];
    [currentController presentViewController:alertVC animated:YES completion:nil];
}
@end
