//
//  PSAPIClient.m
//  PDFScanner
//
//  Created by Lucy Benson on 2020/4/26.
//  Copyright © 2020 cdants. All rights reserved.
//

#import "PSAPIClient.h"
#import <AFNetworking/AFNetworking.h>
#import <AdSupport/ASIdentifierManager.h>

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
    
    self.httpManager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:HttpApiConfig]];
//    self.httpManager.requestSerializer=  [AFHTTPRequestSerializer serializer];
//    self.httpManager.responseSerializer = [AFHTTPResponseSerializer serializer];
    self.httpManager.requestSerializer.timeoutInterval = 15;
    self.httpManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html", @"text/plain", @"multipart/form-data", nil];
    
    [self.httpManager.requestSerializer setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [self.httpManager.requestSerializer setValue:[PSDeviceInfoManager deviceUUID] forHTTPHeaderField:@"UUID"];
    [self.httpManager.requestSerializer setValue:[PSDeviceInfoManager systemVersion] forHTTPHeaderField:@"OsVersion"];
    [self.httpManager.requestSerializer setValue:@"30001" forHTTPHeaderField:@"ProductId"];
    [self.httpManager.requestSerializer setValue:@"ios" forHTTPHeaderField:@"Os"];
    [self.httpManager.requestSerializer setValue:[PSDeviceInfoManager deviceVersion] forHTTPHeaderField:@"DeviceModel"];
    [self.httpManager.requestSerializer setValue:[PSDeviceInfoManager appVersion] forHTTPHeaderField:@"AppVersion"];
    [self.httpManager.requestSerializer setValue:[PSDeviceInfoManager deviceIDFA] forHTTPHeaderField:@"Idfa"];//nullable
    [self.httpManager.requestSerializer setValue:@"en" forHTTPHeaderField:@"LangCode"];
    //  Token
    [self.httpManager.requestSerializer setValue:@" " forHTTPHeaderField:@"Authorization"];//nullable
}

- (void)GET:(NSString *)GET parameters:(id)parameters successBlock:(PSSuccessBlock)successBlock errorBlock:(PSErrorBlock)errorBlock {
    
    [self.httpManager GET:GET parameters:parameters headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSInteger status = [responseObject[@"code"] integerValue];
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

- (void)POST:(NSString *)POST parameters:(id)parameters modelClass:(Class)modelClass completeBlock:(void (^)(id _Nullable, NSError * _Nullable))completeBlockBlock {
    
    [self.httpManager POST:POST parameters:parameters headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSInteger status = [responseObject[@"code"] integerValue];
        NSLog(@"✈️✈️✈️✈️✈️✈️数据：%@",responseObject);
        id res = nil;
        NSError *error = nil;
        if (status == 0) {
            if (modelClass) {
                res = [modelClass yy_modelWithDictionary:responseObject[@"data"]];
            }else{
                res = responseObject;
            }
        } else {
            error = [NSError errorWithDomain:NSURLErrorDomain code:status userInfo:@{NSLocalizedDescriptionKey: responseObject[@"message"]}];
        }
        !completeBlockBlock?:completeBlockBlock(res,error);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        !completeBlockBlock?:completeBlockBlock(nil,error);
    }];
}

- (void)cancelAllOperations {
    [self.httpManager.operationQueue cancelAllOperations];
}

@end
