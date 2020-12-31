//
//  PSGuidePagePrivacyView.m
//  PDFScanner
//
//  Created by heartjhl on 2020/5/29.
//  Copyright © 2020 cdants. All rights reserved.
//

#import "PSGuidePagePrivacyView.h"
#import "PSH5WebViewController.h"

@interface PSGuidePagePrivacyView ()
/**  */
@property (nonatomic,strong) UIImageView *topImageView;
/**  */
@property (nonatomic,strong) UILabel *titleLabel;
/**  */
@property (nonatomic,strong) YYLabel *privacyLabel;
/**  */
@property (nonatomic,strong) UITextView *textView;
@end
@implementation PSGuidePagePrivacyView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor mainBackgroundColor];
        [self createUI];
        [self policyPolicyAndTermsOfUs];
//        [UPEventTrackManager eventTrankingForGeneralEventWithName:welcome_page_view];
    }
    return self;
}

-(void)createUI{
    [self addSubview:self.topImageView];
    [self.topImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(YNONTFLoatChange(18));
        make.leading.mas_equalTo(FLoatChange(55));
        make.size.mas_equalTo(CGSizeMake(FLoatChange(60), FLoatChange(60)));
    }];

//    [self addSubview:self.closeBtn];
//    [self.closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(self.topImageView);
//        make.trailing.mas_equalTo(-FLoatChange(25));
//        make.size.mas_equalTo(CGSizeMake(FLoatChange(16), FLoatChange(16)));
//    }];

    [self addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.topImageView);
        make.top.equalTo(self.topImageView.mas_bottom).offset(YNONTFLoatChange(15));
    }];
//    self.titleLabel.backgroundColor = [UIColor redColor];

    [self addSubview:self.continueBtn];
    [self.continueBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(-BottomBarHeight - YNONTFLoatChange(58));
        make.centerX.equalTo(self);
        make.size.mas_equalTo(CGSizeMake(FLoatChange(270), FLoatChange(48)));
    }];

    [self addSubview:self.privacyLabel];
    [self.privacyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.continueBtn.mas_bottom).offset(YNONTFLoatChange(10));
        make.centerX.equalTo(self);
    }];

    [self addSubview:self.textView];
    [self.textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleLabel.mas_bottom).offset(YNONTFLoatChange(10));
        make.leading.mas_equalTo(FLoatChange(55));
        make.trailing.mas_equalTo(-FLoatChange(55));
        make.bottom.equalTo(self.continueBtn.mas_top).offset(-YNONTFLoatChange(55));
    }];
    self.textView.backgroundColor = [UIColor mainBackgroundColor];
}

-(void)policyPolicyAndTermsOfUs{
//    self.privacyLabel.backgroundColor = [UIColor redColor];

    NSString *str = @"Privacy Policy & Terms of Service";//By continuing, you accept our\n
    NSMutableAttributedString *text  = [[NSMutableAttributedString alloc] initWithString:str];

//    text.yy_lineSpacing = 10;
    text.yy_font = [UIFont pfscmFont:FLoatChange(12)];
    text.yy_color = COLOR(@"#A2A2A2");
//    text.yy_alignment = NSTextAlignmentCenter;

//    NSString *str1 = @"Privacy Policy & Terms of Service";
    NSString *str2 = @"Privacy Policy";
    NSString *str3 = @"Terms of Service";

    [text addAttribute:NSUnderlineStyleAttributeName value:@(1) range:NSMakeRange(0 , str2.length)];
    [text addAttribute:NSUnderlineStyleAttributeName value:@(1) range:NSMakeRange(str.length - str3.length, str3.length)];

    __weak typeof(self) weakSelf = self;
    [text yy_setTextHighlightRange:NSMakeRange(0, str2.length) color:COLOR(@"#A2A2A2") backgroundColor:COLOR(@"#DBDBDB") tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
        [weakSelf pushHtmlViewControllerWith:YES];
    }];

    [text yy_setTextHighlightRange:NSMakeRange(str.length - str3.length, str3.length) color:COLOR(@"#A2A2A2") backgroundColor:COLOR(@"#DBDBDB") tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
        [weakSelf pushHtmlViewControllerWith:NO];
    }];

    self.privacyLabel.attributedText = text;
}

-(void)pushHtmlViewControllerWith:(BOOL)isPrivacy{
    UIViewController *controller = nil;
    if (isPrivacy) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"privacy" ofType:@"html"];
        controller = [[PSH5WebViewController alloc] initWithFileURLPath:path title:NSLocalizedString(@"setting.h5.privacy_policy.title", nil)];
    }else{
        NSString *path = [[NSBundle mainBundle] pathForResource:@"terms" ofType:@"html"];
        controller = [[PSH5WebViewController alloc] initWithFileURLPath:path title:NSLocalizedString(@"setting.h5.terms_of_use.title", nil)];
    }
    [[PSCurrentViewController currentViewController].navigationController pushViewController:controller animated:YES];
}

- (UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc]init];
        _titleLabel.font = [UIFont pfscmFont:FLoatChange(20)];
        _titleLabel.textColor = COLOR(@"#090A19");
        _titleLabel.numberOfLines = 0;
        NSString *str1 = @"YOUR PRICACY\ncomes first";
        NSString *str2 = @"comes first";
        NSMutableAttributedString *mutaString = [[NSMutableAttributedString alloc]initWithString:str1];
        [mutaString addAttributes:@{NSForegroundColorAttributeName:COLOR(@"#fb7744")} range:NSMakeRange(str1.length - str2.length, str2.length)];
        _titleLabel.attributedText = mutaString;
    }
    return _titleLabel;
}

- (UIImageView *)topImageView{
    if (!_topImageView) {
        _topImageView = [[UIImageView alloc]init];
        _topImageView.image = [UIImage imageNamed:@"privacy_logo_icon"];
        _topImageView.layer.cornerRadius = FLoatChange(15);
        _topImageView.layer.masksToBounds = YES;
    }
    return _topImageView;
}

- (YYLabel *)privacyLabel{
    if (!_privacyLabel) {
        _privacyLabel = [[YYLabel alloc]init];
        _privacyLabel.numberOfLines = 0;
        _privacyLabel.preferredMaxLayoutWidth = SCREEN_WIDTH - FLoatChange(25);
    }
    return _privacyLabel;
}

- (UITextView *)textView{
    if (!_textView) {
        _textView = [[UITextView alloc]init];
        _textView.textColor = COLOR(@"#333333");
        _textView.font = [UIFont pfscmFont:FLoatChange(13)];
        _textView.editable = NO;
        _textView.selectable = NO;
//        _textView.contentOffset = CGPointZero;
//        _textView.contentInset = UIEdgeInsetsMake(-5, 0, 5, 0);
        _textView.text = @"When you use our services, you’re trusting us with your information. We understand this is a big responsibility and work hard to protect your information and put you in control.\n\nWe only collect your information you provide to us for the purpose of building better services, developing new services, providing personalized services, measuring performance and interacting with you directly, such as or troubleshooting issues that you report to us.\n\nBy using Scanner 360, you agree to our Privacy Policy and Terms of Service.";
        if (@available(iOS 11.0, *)) {
            _textView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        } else {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self->_textView.contentOffset = CGPointZero;
            });
        }
    }
    return _textView;
}

- (UIButton *)closeBtn{
    if (!_closeBtn) {
        _closeBtn = [UIButton buttonWithType:0];
        [_closeBtn setBackgroundImage:[UIImage imageNamed:@"icon_close2_30_black"] forState:UIControlStateNormal];
    }
    return _closeBtn;
}

- (UIButton *)continueBtn{
    if (!_continueBtn) {
        _continueBtn = [UIButton buttonWithType:0];
        [_continueBtn setTitleColor:COLOR(@"#FFFFFF") forState:UIControlStateNormal];
        [_continueBtn setTitle:@"Agree and Continue" forState:UIControlStateNormal];
        _continueBtn.titleLabel.font = [UIFont pfscmFont:FLoatChange(18)];
        _continueBtn.layer.cornerRadius = FLoatChange(24);
        _continueBtn.layer.masksToBounds = YES;
    }
    return _continueBtn;
}

@end
