//
//  PSDocBaseCell.m
//  PDFScanner
//
//  Created by Lucy Benson on 2020/5/10.
//  Copyright © 2020 cdants. All rights reserved.
//

#import "PSDocBaseCell.h"
#import <BadgeSwift-Swift.h>

@interface PSDocBaseCell ()

@property (strong, nonatomic) IBOutlet UIView *container;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UIView *selectionMaskView;
@property (strong, nonatomic) IBOutlet UIControl *selectionMaskControl;
@property (strong, nonatomic) IBOutlet UIButton *radioButton;
@property (strong, nonatomic) IBOutlet BadgeSwift *contentCountLabel;
@property (strong, nonatomic) IBOutlet UIImageView *fileFirstImageView; // 如果是文件，显示第一张图

@property (nonatomic, strong) PSFileModel *model;

@end

@implementation PSDocBaseCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.selectionMaskView.layer.cornerRadius = 12;
    self.selectionMaskView.layer.masksToBounds = YES;
    self.container.layer.cornerRadius = 12;
    self.container.layer.shadowColor = [UIColor colorWithRed:192/255.0 green:193/255.0 blue:206/255.0 alpha:0.4].CGColor;
    self.container.layer.shadowOffset = CGSizeMake(0,5);
    self.container.layer.shadowOpacity = 1;
    self.container.layer.shadowRadius = 20;
    
}

- (void)configWithModel:(PSFileModel *)model isEditMode:(BOOL)isEditMode {
    self.model = model;
    self.nameLabel.text = model.name;
    self.selectionMaskView.hidden = !isEditMode;
    self.selectionMaskControl.backgroundColor = model.isSelected ? [UIColor clearColor] : [UIColor colorWithWhite:1 alpha:0.5];
    self.radioButton.selected = model.isSelected;
    
    if (model.isDir) {
        self.contentCountLabel.text = @(model.fileOrDirs.count).stringValue;
        self.fileFirstImageView.hidden = YES;
    } else {
        self.contentCountLabel.text = @(model.pictures.count).stringValue;
        self.fileFirstImageView.hidden = NO;
        if (model.pictures.firstObject) {
            self.fileFirstImageView.image = [UIImage imageWithData:model.pictures.firstObject.imageData];
        }
    }
}

- (IBAction)clickRadioButton:(id)sender {
    self.radioButton.selected = !self.radioButton.selected;
    self.selectionMaskControl.backgroundColor = self.radioButton.selected ? [UIColor clearColor] : [UIColor colorWithWhite:1 alpha:0.5];
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm transactionWithBlock:^{
        self.model.isSelected = self.radioButton.selected;
    }];
}

@end
