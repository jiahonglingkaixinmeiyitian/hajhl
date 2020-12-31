//
//  PSAppearanceManager.m
//  PDFScanner
//
//  Created by Lucy Benson on 2020/5/7.
//  Copyright © 2020 cdants. All rights reserved.
//

#import "PSAppearanceManager.h"

@implementation PSAppearanceManager

+ (void)load {
    [self configNavigationBarAppearance];
}

+ (void)configNavigationBarAppearance {
    [UINavigationBar appearance].titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor themeColor], NSFontAttributeName: [UIFont appBoldFontSize:18.f]};
    [UINavigationBar appearance].shadowImage = [UIImage new];
    [UINavigationBar appearance].backIndicatorImage = [UIImage new];
    [UINavigationBar appearance].barTintColor = [UIColor whiteColor];
}

/// Other stuffes such as UITextField...

@end
