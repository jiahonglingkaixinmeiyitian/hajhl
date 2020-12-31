//
//  PSAPIClient.m
//  PDFScanner
//
//  Created by Lucy Benson on 2020/4/26.
//  Copyright © 2020 cdants. All rights reserved.
//

#import "PSAPIClient.h"
#import <AFNetworking/AFNetworking.h>

@interface PSAPIClient ()

@property (nonatomic, strong) AFHTTPSessionManager *httpManager;

@end

@implementation PSAPIClient

+ (instancetype)defaultClient {
    static PSAPIClient *client = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        client = [[self alloc] init];
    });
    return client;
}

- (instancetype)init {
    if (self = [super init]) {
        [self setUpHttpManager];
    }
    return self;
}

- (void)setUpHttpManager {
    
    self.httpManager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:kDomainURL]];
    self.httpManager.requestSerializer= [AFJSONRequestSerializer serializer];
    self.httpManager.responseSerializer = [AFJSONResponseSerializer serializer];
}

- (void)GET:(NSString *)GET parameters:(id)parameters successBlock:(PSSuccessBlock)successBlock errorBlock:(PSErrorBlock)errorBlock {
    
    [self.httpManager GET:GET parameters:parameters headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSInteger status = [responseObject[@"status"] integerValue];
        if (status == 200) {
            !successBlock?:successBlock(responseObject[@"data"]);
        } else {
            NSError *error = [NSError errorWithDomain:NSURLErrorDomain code:status userInfo:@{NSLocalizedDescriptionKey: responseObject[@"message"]}];
            !errorBlock?:errorBlock(error);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        !errorBlock?:errorBlock(error);
    }];

}

- (void)POST:(NSString *)POST parameters:(id)parameters successBlock:(PSSuccessBlock)successBlock errorBlock:(PSErrorBlock)errorBlock {
    
    [self.httpManager POST:POST parameters:parameters headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSInteger status = [responseObject[@"status"] integerValue];
        if (status == 200) {
            !successBlock?:successBlock(responseObject[@"data"]);
        } else {
            NSError *error = [NSError errorWithDomain:NSURLErrorDomain code:status userInfo:@{NSLocalizedDescriptionKey: responseObject[@"message"]}];
            !errorBlock?:errorBlock(error);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        !errorBlock?:errorBlock(error);
    }];
}

- (void)cancelAllOperations {
    [self.httpManager.operationQueue cancelAllOperations];
}

@end
