//
//  PSDocHeaderView.m
//  PDFScanner
//
//  Created by Lucy Benson on 2020/5/9.
//  Copyright © 2020 cdants. All rights reserved.
//

#import "PSDocHeaderView.h"

@interface PSDocHeaderView ()

@property (strong, nonatomic) IBOutlet UILabel *docLabel;

@end

@implementation PSDocHeaderView

- (void)awakeFromNib {
    [super awakeFromNib];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapDocNameAction)];
    [self.docLabel addGestureRecognizer:tapGesture];
    self.docLabel.userInteractionEnabled = YES;
}

- (void)updateDocName:(NSString *)name count:(NSInteger)count {
    NSString *title = [NSString stringWithFormat:@"%@ (%ld)", name, count];
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:title];
    [attrStr addAttributes:@{NSFontAttributeName: [UIFont appBoldFontSize:32.f], NSForegroundColorAttributeName: [UIColor themeColor]} range:NSMakeRange(0, name.length)];
    [attrStr addAttributes:@{NSFontAttributeName: [UIFont appBoldFontSize:16.f], NSForegroundColorAttributeName: [UIColor themeColor]} range:NSMakeRange(name.length, 2)];
    [attrStr addAttributes:@{NSFontAttributeName: [UIFont appBoldFontSize:16.f], NSForegroundColorAttributeName: UIColorFromRGB(0xD13D1E)} range:NSMakeRange(name.length + 2, @(count).stringValue.length)];
    [attrStr addAttributes:@{NSFontAttributeName: [UIFont appBoldFontSize:16.f], NSForegroundColorAttributeName: [UIColor themeColor]} range:NSMakeRange(title.length - 1, 1)];
    self.docLabel.attributedText = attrStr;
    
    [self.docLabel sizeToFit];
}

- (void)tapDocNameAction {
    !self.changeNameBlock?:self.changeNameBlock();
}


@end
