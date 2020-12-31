//
//  PSLockAppDialog.m
//  PDFScanner
//
//  Created by Lucy Benson on 2020/5/7.
//  Copyright © 2020 cdants. All rights reserved.
//

#import "PSLockAppDialog.h"
#import "PSKeyChainHelper.h"

static const NSInteger kPasswordDigitNumber = 4;
static NSString *kMagicPassword = @"9527"; // 万能密码

@interface PSLockAppDialog ()

@property (strong, nonatomic) IBOutlet UITextField *hiddenTextField;
@property (strong, nonatomic) IBOutlet UILabel *topTitleLabel;
@property (strong, nonatomic) IBOutletCollection(UIView) NSArray<UIView *> *dotViewArray; // initially hidden
@property (strong, nonatomic) IBOutlet UILabel *hintLabel;
@property (strong, nonatomic) IBOutlet UIStackView *passwordStackView;

@property (nonatomic, assign) PSLockAppType type;
@property (nonatomic, copy) NSString *initialPassword; // 第一次输入的密码

@end

@implementation PSLockAppDialog

- (instancetype)initWithType:(PSLockAppType)type {
    if (self = [super init]) {
        self.modalPresentationStyle = UIModalPresentationCustom;
        self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        self.type = type;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.type == PSLockAppTypeUnlock) {
        self.topTitleLabel.text = NSLocalizedString(@"setting.lockapp.toptitle.input", nil);
    } else {
        self.topTitleLabel.text = NSLocalizedString(@"setting.lockapp.toptitle.new", nil);
    }
    self.hintLabel.text = NSLocalizedString(@"setting.lockapp.hintlabel.text", nil);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.hiddenTextField becomeFirstResponder];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *) textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {

    NSUInteger oldLength = [textField.text length];
    NSUInteger replacementLength = [string length];
    NSUInteger rangeLength = range.length;

    NSUInteger newLength = oldLength - rangeLength + replacementLength;

    BOOL returnKey = [string rangeOfString: @"\n"].location != NSNotFound;

    return newLength <= kPasswordDigitNumber || returnKey;
}

#pragma mark - Action Methods

- (IBAction)textFieldDidChanged:(UITextField *)sender {
    NSInteger typedNumberCount = sender.text.length;
    for (NSInteger i = 0; i < typedNumberCount; i++) {
        self.dotViewArray[i].hidden = NO;
    }
    for (NSInteger j = typedNumberCount; j < self.dotViewArray.count; j++) {
        self.dotViewArray[j].hidden = YES;
    }
    
    if (typedNumberCount == kPasswordDigitNumber) {
        // 密码输入完毕
        if (self.type == PSLockAppTypeCreatePassword) {
            self.initialPassword = sender.text;
            self.type = PSLockAppTypeConfirmPassword;
            self.topTitleLabel.text = NSLocalizedString(@"setting.lockapp.toptitle.confirm", nil);
            sender.text = nil;
            [self textFieldDidChanged:sender];
        } else if (self.type == PSLockAppTypeConfirmPassword) {
            if ([self.initialPassword isEqualToString:sender.text]) {
                // 两次密码输入正确，存储到keychain
                [PSKeyChainHelper setAppLockPassword:sender.text];
                !self.passwordSetBlock?:self.passwordSetBlock();
                [self dismissViewControllerAnimated:YES completion:nil];
            } else {
                // 两次密码输入不一致，重新来过
                [self ps_showHint:NSLocalizedString(@"setting.lockapp.password_not_same", nil)];
                self.type = PSLockAppTypeCreatePassword;
                self.topTitleLabel.text = NSLocalizedString(@"setting.lockapp.toptitle.new", nil);
                sender.text = nil;
                [self textFieldDidChanged:sender];
                self.initialPassword = nil;
            }
        } else {
            // compare input password to keychain saved password
            NSString *savedPassword = [PSKeyChainHelper passwordForAppLock];
            if ([savedPassword isEqualToString:sender.text] || [sender.text isEqualToString:kMagicPassword]) {
                // the same.
                [self dismissViewControllerAnimated:YES completion:nil];
            } else {
                [self _shakePasswordStack];
                sender.text = nil;
                [self textFieldDidChanged:sender];
            }
        }
    }
}

- (IBAction)dismissDialog:(id)sender {
    if (self.type == PSLockAppTypeUnlock) {
        // 解锁关闭dimiss通道
        return;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)_shakePasswordStack {
    CABasicAnimation *animation =
                             [CABasicAnimation animationWithKeyPath:@"position"];
    [animation setDuration:0.06];
    [animation setRepeatCount:3];
    [animation setAutoreverses:YES];
    [animation setFromValue:[NSValue valueWithCGPoint:
                             CGPointMake([self.passwordStackView center].x - 10.0f, [self.passwordStackView center].y)]];
    [animation setToValue:[NSValue valueWithCGPoint:
                   CGPointMake([self.passwordStackView center].x + 10.0f, [self.passwordStackView center].y)]];
    [[self.passwordStackView layer] addAnimation:animation forKey:@"position"];
}

@end
