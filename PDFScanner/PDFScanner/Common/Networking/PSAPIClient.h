//
//  PSAPIClient.h
//  PDFScanner
//
//  Created by Lucy Benson on 2020/4/26.
//  Copyright © 2020 cdants. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^PSSuccessBlock)(id responseObject);
typedef void(^PSProgressBlock)(NSProgress *progress);
typedef void(^PSErrorBlock)(NSError * error);

@interface PSAPIClient : NSObject

+ (instancetype)defaultClient;

- (void)GET:(NSString *)GET parameters:(id)parameters successBlock:(PSSuccessBlock)successBlock errorBlock:(PSErrorBlock)errorBlock;

- (void)POST:(NSString *)POST parameters:(id)parameters modelClass:(Class _Nullable)modelClass completeBlock:(void (^_Nonnull)(id _Nullable responseObject,NSError * _Nullable error))completeBlockBlock;

- (void)cancelAllOperations;

@end
