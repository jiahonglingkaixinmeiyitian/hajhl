//
//  PSBaseVC.h
//  PDFScanner
//
//  Created by Lcyu on 2020/5/7.
//  Copyright © 2020 cdants. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PSBaseVC : UIViewController
@property (nonatomic, strong) UIView *safeBottomView;
@property (nonatomic, strong, nullable) NSString *titleStr;
@property (nonatomic, assign) bool needTitleView;
@property (nonatomic, copy, nullable) void(^titleViewClickBlock)(void);
-(void)setupViews;
@end

NS_ASSUME_NONNULL_END
