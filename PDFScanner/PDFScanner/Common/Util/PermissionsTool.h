//
//  PermissionsTool.h
//  CaremaDemo
//
//  Created by lcyu on 2020/4/28.
//  Copyright © 2020 lcyu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PermissionsTool : NSObject
//相册权限
+(void)requestToAccessPhotosSuccess:(void(^)(void))successBlock failure:(void(^)(void))failureBlock;
@end

