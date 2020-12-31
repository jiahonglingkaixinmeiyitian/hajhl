//
//  PSSubscriptionPurchaseCell.m
//  PDFScanner
//
//  Created by Benson Tommy on 2020/5/27.
//  Copyright © 2020 cdants. All rights reserved.
//

#import "PSSubscriptionPurchaseCell.h"
#import "PSMainPurchseModel.h"

@interface PSSubscriptionPurchaseCell ()

@property (strong, nonatomic) IBOutlet UIView *bubbleView;
@property (strong, nonatomic) IBOutlet UILabel *bubbleTextLabel;
@property (strong, nonatomic) IBOutlet UIView *container;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *discountLabel;

@end

@implementation PSSubscriptionPurchaseCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self configContainer];
}

- (void)configContainer {
    self.container.layer.cornerRadius = 12.f;
//    self.container.layer.borderWidth = 2.f;
    self.container.layer.borderColor = UIColorFromRGB(0xD13D1E).CGColor;
    self.container.layer.shadowColor = [UIColor colorWithRed:192/255.0 green:193/255.0 blue:206/255.0 alpha:0.4].CGColor;
    self.container.layer.shadowOffset = CGSizeMake(0,5);
    self.container.layer.shadowOpacity = 1;
    self.container.layer.shadowRadius = 20;
    self.discountLabel.font = [UIFont gibFont:FLoatChange(18)];
//    [self.discountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.height.mas_equalTo(FLoatChange(20));
//    }];
}

- (void)setModel:(PSMainPurchseModel *)model{
    _model = model;
    self.priceLabel.hidden = YES;
    self.container.layer.borderWidth = model.selected?2.f:0.f;
    self.bubbleView.hidden = !_indexPath.item;
    self.titleLabel.text = model.title;
    self.discountLabel.text = model.price;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.bubbleView ps_roundCorners:UIRectCornerTopLeft | UIRectCornerTopRight | UIRectCornerBottomRight radius:12.f];
}

@end
