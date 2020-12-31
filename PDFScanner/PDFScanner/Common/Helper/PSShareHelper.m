//
//  PSShareHelper.m
//  PDFScanner
//
//  Created by Lucy Benson on 2020/5/14.
//  Copyright © 2020 cdants. All rights reserved.
//

#import "PSShareHelper.h"
#import "PSPDFUtil.h"

@implementation PSShareHelper

+ (void)shareWithText:(NSString *)text inViewController:(UIViewController *)viewController {
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:@[text] applicationActivities:nil];
    [viewController presentViewController:activityVC animated:YES completion:nil];
}

+ (void)shareWithDatas:(NSArray<NSData *> *)datas fileNames:(NSArray<NSString *> *)fileNames inViewController:(UIViewController *)viewController {
    
    NSMutableArray *tmpURLArray = @[].mutableCopy;
    for (int i = 0; i < datas.count; i++) {
        NSData *data = datas[i];
        NSString *tmpPath = [NSTemporaryDirectory() stringByAppendingPathComponent:fileNames[i]];
        BOOL success = [data writeToFile:tmpPath atomically:YES];
        if (success) {
            [tmpURLArray addObject:[NSURL fileURLWithPath:tmpPath]];
        }
    }
    
    UIActivityViewController * activity = [[UIActivityViewController alloc]initWithActivityItems:tmpURLArray
    applicationActivities:nil];
    [viewController presentViewController:activity animated:YES completion:nil];
    
}

@end
