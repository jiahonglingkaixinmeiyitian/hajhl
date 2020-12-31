//
//  PSLanguageDrawerCell.h
//  PDFScanner
//
//  Created by Lucy Benson on 2020/5/12.
//  Copyright © 2020 cdants. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PSLanguageModel.h"

@interface PSLanguageDrawerCell : UITableViewCell

- (void)configWithLanguage:(PSLanguageModel *)language downloadInfo:(NSDictionary *)downloadInfo;

@end

