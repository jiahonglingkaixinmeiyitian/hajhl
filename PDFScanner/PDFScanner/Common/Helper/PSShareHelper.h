//
//  PSShareHelper.h
//  PDFScanner
//
//  Created by Lucy Benson on 2020/5/14.
//  Copyright © 2020 cdants. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PSShareHelper : NSObject

+ (void)shareWithText:(NSString *)text inViewController:(UIViewController *)viewController;

// share with pdf or image
+ (void)shareWithDatas:(NSArray<NSData *> *)datas fileNames:(NSArray<NSString *> *)fileNames inViewController:(UIViewController *)viewController;

@end
