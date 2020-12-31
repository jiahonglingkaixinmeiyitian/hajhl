//
//  PSMainPurchseModel.h
//  PDFScanner
//
//  Created by heartjhl on 2020/6/1.
//  Copyright © 2020 cdants. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PSMainPurchseModel : NSObject
/**  */
@property (nonatomic,copy) NSString *title;
/**  */
@property (nonatomic,copy) NSString *price;
/**  */
@property (nonatomic,copy) NSString *discount;
/**  */
@property (nonatomic,assign) BOOL selected;
@end

NS_ASSUME_NONNULL_END
