//
//  PSH5WebViewController.h
//  PDFScanner
//
//  Created by Lucy Benson on 2020/4/23.
//  Copyright © 2020 cdants. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PSBaseVC.h"

@interface PSH5WebViewController : PSBaseVC

- (instancetype)initWithURL:(NSString *)urlString title:(NSString *)title;

- (instancetype)initWithFileURLPath:(NSString *)urlPath title:(NSString *)title;

@end

