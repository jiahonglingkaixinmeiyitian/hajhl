//
//  PSSubscriptionPurchaseCell.m
//  PDFScanner
//
//  Created by Benson Tommy on 2020/5/27.
//  Copyright © 2020 cdants. All rights reserved.
//

#import "PSSubscriptionPurchaseCell.h"
#import "UIView+RoundedCorner.h"

@interface PSSubscriptionPurchaseCell ()

@property (strong, nonatomic) IBOutlet UIView *bubbleView;
@property (strong, nonatomic) IBOutlet UILabel *bubbleTextLabel;
@property (strong, nonatomic) IBOutlet UIView *container;

@end

@implementation PSSubscriptionPurchaseCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self configContainer];
}

- (void)configContainer {
    self.container.layer.cornerRadius = 12.f;
    self.container.layer.borderWidth = 2.f;
    self.container.layer.borderColor = UIColorFromRGB(0xD13D1E).CGColor;
    self.container.layer.shadowColor = [UIColor colorWithRed:192/255.0 green:193/255.0 blue:206/255.0 alpha:0.4].CGColor;
    self.container.layer.shadowOffset = CGSizeMake(0,5);
    self.container.layer.shadowOpacity = 1;
    self.container.layer.shadowRadius = 20;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.bubbleView ps_roundCorners:UIRectCornerTopLeft | UIRectCornerTopRight | UIRectCornerBottomRight radius:12.f];
}

@end
