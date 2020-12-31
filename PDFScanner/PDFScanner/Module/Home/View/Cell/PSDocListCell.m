//
//  PSDocListCell.m
//  PDFScanner
//
//  Created by Lucy Benson on 2020/5/9.
//  Copyright © 2020 cdants. All rights reserved.
//

#import "PSDocListCell.h"
#import "UIView+RoundedCorner.h"

@interface PSDocListCell ()

@property (strong, nonatomic) IBOutlet UILabel *dateLabel;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@end

@implementation PSDocListCell

- (void)configWithModel:(PSFileModel *)model isEditMode:(BOOL)isEditMode {
    [super configWithModel:model isEditMode:isEditMode];
    self.dateLabel.text = [self.dateFormatter stringFromDate:model.createdDate];
}

- (NSDateFormatter *)dateFormatter {
    if (!_dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        _dateFormatter.dateFormat = @"yyyy/MM/dd HH:mm:ss";
    }
    return _dateFormatter;
}

@end
