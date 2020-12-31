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
}

@end
