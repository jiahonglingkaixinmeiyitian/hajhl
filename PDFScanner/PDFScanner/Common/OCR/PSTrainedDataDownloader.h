//
//  PSTrainedDataDownloader.h
//  PDFScanner
//
//  Created by Lucy Benson on 2020/5/9.
//  Copyright © 2020 cdants. All rights reserved.
//

#import <Foundation/Foundation.h>

UIKIT_EXTERN NSString *const PSTrainedDataDownloaderProgressNotification;

typedef void(^DownloadCompletionBlock)(NSURL *filePath, NSError *error);

/// 下载训练数据的下载器
@interface PSTrainedDataDownloader : NSObject

+ (instancetype)sharedDownloader;

/// 下载指定语言数据包
- (void)downloadTraindDataWithLanguage:(NSString *)language completionHandler:(DownloadCompletionBlock)completionHandler;

/// 查询某个语言训练数据包是否已经下载
- (BOOL)trainedDataDownloadedForLanguage:(NSString *)language;

/// 检查当前是否有正在下载的训练数据包
- (BOOL)detectTrainedDataIsDownloading;

@end

