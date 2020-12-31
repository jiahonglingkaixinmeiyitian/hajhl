//
//  PSDocBaseCell.h
//  PDFScanner
//
//  Created by Lucy Benson on 2020/5/10.
//  Copyright © 2020 cdants. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PSFileModel.h"

@interface PSDocBaseCell : UICollectionViewCell

- (void)configWithModel:(PSFileModel *)model isEditMode:(BOOL)isEditMode;

@end

