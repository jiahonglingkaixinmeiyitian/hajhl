//
//  PSTrainedDataDownloader.m
//  PDFScanner
//
//  Created by Lucy Benson on 2020/5/9.
//  Copyright © 2020 cdants. All rights reserved.
//

#import "PSTrainedDataDownloader.h"
#import <AFNetworking/AFNetworking.h>

NSString *const PSTrainedDataDownloaderProgressNotification = @"PSTrainedDataDownloaderProgressNotification";

@interface PSTrainedDataDownloader ()

@property (nonatomic, strong) AFURLSessionManager *sessionManager;
@property (nonatomic, strong) NSURLSessionDownloadTask *downloadTask;

@end

@implementation PSTrainedDataDownloader

+ (instancetype)sharedDownloader {
    static dispatch_once_t pred;
    static id sharedDownloader = nil;
    dispatch_once(&pred, ^{
        sharedDownloader = [[self alloc] init];
    });
    return sharedDownloader;
}

- (void)downloadTraindDataWithLanguage:(NSString *)language completionHandler:(DownloadCompletionBlock)completionHandler {
    
    if ([self detectTrainedDataIsDownloading]) {
        // 一次只能下载一个训练数据包
        return;
    }
    
    // check tessdata path is exsited, if not, create it.
    NSURL *documentDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
    NSURL *tessDataURL = [documentDirectoryURL URLByAppendingPathComponent:@"tessdata"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:tessDataURL.path]) {
        [[NSFileManager defaultManager] createDirectoryAtURL:tessDataURL withIntermediateDirectories:YES attributes:nil error:NULL];
    }
    
    NSString *fileName = [NSString stringWithFormat:@"%@.traineddata", language];
    NSURL *fileURL = [tessDataURL URLByAppendingPathComponent:fileName];
    if ([[NSFileManager defaultManager] fileExistsAtPath:fileURL.path]) {
        // 已经下载过
        return;
    }
    
    [ScannerEventManager eventWithName:ocr_language_download parameters:@{@"code": language}];
    
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@.traineddata", kOCRLanguageCDNDomain, language]];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];

    self.downloadTask = [self.sessionManager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        //
        NSLog(@"progress:%f", downloadProgress.fractionCompleted);
        [[NSNotificationCenter defaultCenter] postNotificationName:PSTrainedDataDownloaderProgressNotification object:@{@"progress": downloadProgress, @"languageCode": language}];
    } destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        
        return [documentDirectoryURL URLByAppendingPathComponent:[NSString stringWithFormat:@"tessdata/%@.traineddata", language]];
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        NSLog(@"File downloaded to: %@", filePath);
        if (!error) {
            [ScannerEventManager eventWithName:ocr_language_download_success parameters:@{@"code": language}];
        }
        !completionHandler?:completionHandler(filePath, error);
    }];
    
    /// 下载前有一段空闲时间，先发过去
    [[NSNotificationCenter defaultCenter] postNotificationName:PSTrainedDataDownloaderProgressNotification object:@{@"languageCode": language}];
    
    [self.downloadTask resume];
}

- (BOOL)trainedDataDownloadedForLanguage:(NSString *)language {
    
    NSURL *documentDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
    NSURL *trainedDataPathURL = [documentDirectoryURL URLByAppendingPathComponent:[NSString stringWithFormat:@"tessdata/%@.traineddata", language]];
    if ([[NSFileManager defaultManager] fileExistsAtPath:trainedDataPathURL.path]) {
        return YES;
    } else {
        return NO;
    }
}

- (BOOL)detectTrainedDataIsDownloading {
    if (self.downloadTask) {
        if (self.downloadTask.state == NSURLSessionTaskStateRunning) {
            return YES;
        }
    }
    return NO;
}

#pragma Property Getters

- (AFURLSessionManager *)sessionManager {
    if (!_sessionManager) {
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        _sessionManager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    }
    return _sessionManager;
}

@end
