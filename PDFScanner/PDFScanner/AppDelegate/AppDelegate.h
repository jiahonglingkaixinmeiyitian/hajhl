//
//  AppDelegate.h
//  PDFScanner
//
//  Created by Lucy Benson on 2020/4/23.
//  Copyright © 2020 cdants. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow * window;

/**
 比例适配
 */
@property (nonatomic,assign)float autoSizeScaleX;
@property (nonatomic,assign)float autoSizeScaleY;
@property (nonatomic,assign)float autoSizeScaleYN;
@property (nonatomic,assign)float autoSizeScaleYT;
@property (nonatomic,assign)float autoSizeScaleYNONT;

@end

