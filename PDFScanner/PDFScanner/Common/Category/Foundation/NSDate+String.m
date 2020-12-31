//
//  NSDate+String.m
//  PDFScanner
//
//  Created by Lcyu on 2020/5/15.
//  Copyright © 2020 cdants. All rights reserved.
//

#import "NSDate+String.h"

@implementation NSDate (String)
+(NSString *)formatwithTimeInterval:(NSTimeInterval)timeInterval formatStr:(NSString *)formatStr{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    NSDateFormatter *formatter = [NSDateFormatter new];
    formatter.dateFormat = formatStr;
    return [formatter stringFromDate:date];
    
}

+(NSString *)getCurrentEnglishDateStr{
    return [NSDate formatwithTimeInterval:[NSDate date].timeIntervalSince1970 formatStr:@"MM-dd-yyyy"];
}
@end
