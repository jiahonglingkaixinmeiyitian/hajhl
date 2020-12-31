//
//  NSDate+String.h
//  PDFScanner
//
//  Created by Lcyu on 2020/5/15.
//  Copyright © 2020 cdants. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDate (String)
+(NSString *)formatwithTimeInterval:(NSTimeInterval)timeInterval formatStr:(NSString *)formatStr;

+(NSString *)getCurrentEnglishDateStr;

@end

NS_ASSUME_NONNULL_END
