//
//  UIResponder+Router.h
//  PDFScanner
//
//  Created by Lucy Benson on 2020/5/12.
//  Copyright © 2020 cdants. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIResponder (Router)

- (void)routerWithEventName:(NSString *)eventName userInfo:(NSDictionary *)userInfo;

@end
