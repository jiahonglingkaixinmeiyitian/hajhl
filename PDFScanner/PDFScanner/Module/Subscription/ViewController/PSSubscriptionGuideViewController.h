//
//  PSSubscriptionGuideViewController.h
//  PDFScanner
//
//  Created by Lucy Benson on 2020/5/11.
//  Copyright © 2020 cdants. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger,SubscriptionType) {
    SubscriptionTypeGuidePage,
    SubscriptionTypeSettingPage
};
/// 订阅引导页
@interface PSSubscriptionGuideViewController : UIViewController
///**  */
//@property (nonatomic,copy) void (^dismissBlock)(void);
///**  */
//@property (nonatomic,assign) SubscriptionType type;
@end

