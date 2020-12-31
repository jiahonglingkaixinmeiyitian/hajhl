//
//  PSSubscriptionPurchaseCell.h
//  PDFScanner
//
//  Created by Benson Tommy on 2020/5/27.
//  Copyright © 2020 cdants. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class PSMainPurchseModel;
@interface PSSubscriptionPurchaseCell : UICollectionViewCell
/**  */
@property (nonatomic,strong) PSMainPurchseModel *model;
/**  */
@property (nonatomic,strong) NSIndexPath *indexPath;
@end

NS_ASSUME_NONNULL_END
