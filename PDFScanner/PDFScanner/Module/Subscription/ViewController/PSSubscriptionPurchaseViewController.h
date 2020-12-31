//
//  PSSubscriptionPurchaseViewController.h
//  PDFScanner
//
//  Created by Lucy Benson on 2020/5/11.
//  Copyright © 2020 cdants. All rights reserved.
//

#import <UIKit/UIKit.h>

/// 付费页面
@interface PSSubscriptionPurchaseViewController : UIViewController
/**  */
@property (nonatomic,copy) void (^dismissBlock)(void);
@end

