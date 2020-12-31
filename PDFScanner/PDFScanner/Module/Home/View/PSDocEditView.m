//
//  PSDocEditView.m
//  PDFScanner
//
//  Created by Lucy Benson on 2020/5/9.
//  Copyright © 2020 cdants. All rights reserved.
//

#import "PSDocEditView.h"

@interface PSDocEditView ()

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *bottomHeightConstraint;
@property (strong, nonatomic) IBOutlet UIButton *moveButton;
@property (strong, nonatomic) IBOutlet UIButton *shareButton;
@property (strong, nonatomic) IBOutlet UIButton *deleteButton;


@end

@implementation PSDocEditView

- (void)awakeFromNib {
    [super awakeFromNib];
    CGFloat bottomSafeAreaHeight = 0;
    if (@available(iOS 11.0, *)) {
        bottomSafeAreaHeight= [UIApplication sharedApplication].keyWindow.safeAreaInsets.bottom;
    }
    self.bottomHeightConstraint.constant += bottomSafeAreaHeight;
}

- (void)operationSelection:(BOOL)selectable {
    self.shareButton.enabled = selectable;
    self.moveButton.enabled = selectable;
    self.deleteButton.enabled = selectable;
}

- (IBAction)clickShareButton:(id)sender {
    if ([self.delegate respondsToSelector:@selector(clickShareButtonWithEditView:)]) {
        [self.delegate clickShareButtonWithEditView:self];
    }
}

- (IBAction)clickMoveButton:(id)sender {
    if ([self.delegate respondsToSelector:@selector(clickMoveButtonWithEditView:)]) {
        [self.delegate clickMoveButtonWithEditView:self];
    }
}

- (IBAction)clickDeleteButton:(id)sender {
    if ([self.delegate respondsToSelector:@selector(clickDeleteButtonWithEditView:)]) {
        [self.delegate clickDeleteButtonWithEditView:self];
    }
}



@end
