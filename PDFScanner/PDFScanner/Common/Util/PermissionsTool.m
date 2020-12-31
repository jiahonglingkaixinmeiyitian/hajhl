//
//  PermissionsTool.m
//  CaremaDemo
//
//  Created by lcyu on 2020/4/28.
//  Copyright © 2020 lcyu. All rights reserved.
//

#import "PermissionsTool.h"
#import <Photos/Photos.h>

@implementation PermissionsTool
+(void)requestToAccessPhotosSuccess:(void(^)(void))successBlock failure:(void(^)(void))failureBlock{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            dispatch_async(dispatch_get_main_queue(), ^{
                switch (status) {
                    case PHAuthorizationStatusAuthorized:
                        !successBlock?:successBlock();
                        break;
                    default:
                        !failureBlock?:failureBlock();
                        break;
                }
            });
        }];
    });
}

@end
