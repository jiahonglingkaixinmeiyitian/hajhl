//
//  PSBottomFilterDrawerCell.h
//  PDFScanner
//
//  Created by Lucy Benson on 2020/5/15.
//  Copyright © 2020 cdants. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PSScannerSettingModel.h"

@interface PSBottomFilterDrawerCell : UICollectionViewCell

- (void)configWithFilterType:(PSSettingScannerFilter)filter;

@end

