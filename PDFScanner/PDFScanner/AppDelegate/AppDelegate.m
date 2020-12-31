//
//  AppDelegate.m
//  PDFScanner
//
//  Created by Lucy Benson on 2020/4/23.
//  Copyright © 2020 cdants. All rights reserved.
//

#import "AppDelegate.h"
#import "PSHomeDocViewController.h"
#import "PSScannerSettingModel.h"
#import "PSTrainedDataDownloader.h"
#import "PSLanguageModel.h"
#import <IQKeyboardManager/IQKeyboardManager.h>
#import "AppDelegate+Realm.h"

@import Firebase;

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [self _configThirdParties];
    [self _initializeScannerSetting];
    [self _initializeLanguageList];
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    PSHomeDocViewController *vc = [[PSHomeDocViewController alloc] initWithDirectory:[self _getRootDir]];
    self.window.rootViewController = WrapInNavigationBar(vc);
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)_configThirdParties {
    [FIRApp configure];
    [self configRealm];
    [IQKeyboardManager sharedManager].shouldResignOnTouchOutside = YES;
    [IQKeyboardManager sharedManager].enableAutoToolbar = NO;
    
}

- (PSFileModel *)_getRootDir {
    
    PSFileModel *rootDir = [PSFileModel objectsWhere:@"isRoot == true"].firstObject;
    if (!rootDir) {
        PSFileModel *rootDir = [[PSFileModel alloc] init];
        rootDir.isDir = YES;
        rootDir.name = @"Docs";
        rootDir.isRoot = YES;
        
        // save it.
        RLMRealm *realm = [RLMRealm defaultRealm];
        [realm beginWriteTransaction];
        [realm addObject:rootDir];
        [realm commitWriteTransaction];
    }
    return [PSFileModel objectsWhere:@"isRoot == true"].firstObject;
}

/// 初始化app设置默认值[滤镜，图片质量]
- (void)_initializeScannerSetting {
    if ([PSScannerSettingModel allObjects].count == 0) {
        PSScannerSettingModel *setting = [[PSScannerSettingModel alloc] init];
        RLMRealm *realm = [RLMRealm defaultRealm];
        [realm transactionWithBlock:^{
            [realm addObject:setting];
        }];
    }
}

- (void)_initializeLanguageList {
    if ([PSLanguageModel allObjects].count == 0) {
        RLMRealm *realm = [RLMRealm defaultRealm];
        [realm transactionWithBlock:^{
            NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"languages" ofType:@"plist"];
            NSArray *languageList = [NSArray arrayWithContentsOfFile:plistPath];
            for (NSDictionary *lan in languageList) {
                PSLanguageModel *model = [[PSLanguageModel alloc] init];
                model.languageName = lan[@"languageName"];
                model.languageCode = lan[@"languageCode"];
                if ([model.languageCode isEqualToString:@"eng"]) {
                    model.isSelected = YES; // 英文默认选中
                    [self _initializeDefaultTrainedData]; // 英文包随安装自带
                } else {
                    model.isSelected = NO;
                }
                [realm addObject:model];
            }
        }];
    }
}

/// 默认加载英文训练数据包
- (void)_initializeDefaultTrainedData {
    // check tessdata path is exsited, if not, create it.
    NSURL *documentDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
    NSURL *tessDataURL = [documentDirectoryURL URLByAppendingPathComponent:@"tessdata"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:tessDataURL.path]) {
        [[NSFileManager defaultManager] createDirectoryAtURL:tessDataURL withIntermediateDirectories:YES attributes:nil error:NULL];
        
        NSURL *engURL = [tessDataURL URLByAppendingPathComponent:@"eng.traineddata"];
        NSString *engTrainedPath = [[NSBundle mainBundle] pathForResource:@"eng" ofType:@"traineddata"];
        NSError *error;
        [[NSFileManager defaultManager] copyItemAtPath:engTrainedPath toPath:engURL.path error:&error];
    }
    
}

@end
