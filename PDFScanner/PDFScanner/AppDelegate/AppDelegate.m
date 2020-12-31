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
#import "PSRemoteConfig.h"

@import Firebase;

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [[PSLaunchSubscribeManager sharedInstance] launchIAPRequest];
    [self _configThirdParties];
    [self _initializeScannerSetting];
    [self _initializeLanguageList];
    [self codeAdaptation];
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    PSHomeDocViewController *vc = [[PSHomeDocViewController alloc] initWithDirectory:[self _getRootDir]];
    self.window.rootViewController = WrapInNavigationBar(vc);
    [self.window makeKeyAndVisible];
    [self configAdjust];
    //    facebook login
//    [[FBSDKApplicationDelegate sharedInstance] application:application didFinishLaunchingWithOptions:launchOptions];
    return YES;
}

- (void)_configThirdParties {
    [FIRApp configure];
    [PSRemoteConfig sharedInstance];
}

///配置adjust
-(void)configAdjust{
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSString *environment = ADJEnvironmentProduction;
#if DEBUG
        environment = ADJEnvironmentSandbox;
#endif
        ADJConfig *adjustConfig = [ADJConfig configWithAppToken:UPApplicationID
                                                    environment:environment];
        
//    [adjustConfig setLogLevel:ADJLogLevelVerbose];
        [Adjust addSessionCallbackParameter:@"uuid" value:[PSDeviceInfoManager deviceUUID]];
        [Adjust appDidLaunch:adjustConfig];
        
//        if (![iHKeyChainManager isNewUser]) {
//            [iHEventTrackManager eventTrankingForGeneralEventWithName:iHeart_FirstOpen_Count];
//        }
    });
}

- (PSFileModel *)_getRootDir {
    
    PSFileModel *rootDir = [PSFileModel objectsWhere:@"isRoot == true"].firstObject;
    if (!rootDir) {
        PSFileModel *rootDir = [[PSFileModel alloc] init];
        rootDir.isDir = YES;
        rootDir.name = @"Docs";
        rootDir.fileOrDirs = nil;
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

//7:{810, 1080}}，9.7:{768, 1024}}，11:{834, 1194}}，12.9:{1024, 1366}}
-(void)codeAdaptation{//以6的尺寸适配
    AppDelegate *mydelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = [UIScreen mainScreen].bounds.size.height;
    
    if (iPadMargin) {
        CGFloat refScale = 1.65;//1.46
        mydelegate.autoSizeScaleX = refScale*(width/768);
        mydelegate.autoSizeScaleY = refScale;
        mydelegate.autoSizeScaleYT = refScale;
        mydelegate.autoSizeScaleYN = refScale;
        mydelegate.autoSizeScaleYNONT = refScale*(height/1024);
        return;
    }
    
    CGFloat refWidth = 375.0;
    CGFloat refY = 554.0;
    CGFloat refYT = 618.0;
    CGFloat refYN = 603.0;
    CGFloat refYNONT = 667.0;
    
    mydelegate.autoSizeScaleX = width / refWidth;
//    667.0-64-49 = 554
    mydelegate.autoSizeScaleY = (height-NavigationHeight-TABBAR_HEIGHTHL) / refY;
//    667.0-49 = 618
    mydelegate.autoSizeScaleYT = (height-TABBAR_HEIGHTHL) / refYT;
//    667.0-64 = 603
    mydelegate.autoSizeScaleYN = (height-NavigationHeight) / refYN;
    mydelegate.autoSizeScaleYNONT = height / refYNONT;
    
}

//- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
//
//  BOOL handled = [[FBSDKApplicationDelegate sharedInstance] application:application openURL:url sourceApplication:options[UIApplicationOpenURLOptionsSourceApplicationKey] annotation:options[UIApplicationOpenURLOptionsAnnotationKey]
//  ];
//  // Add any custom logic here.
//
//  return handled;
//}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{
    NSLog(@"iOS8 远程推送注册完成，token：%@", deviceToken);
    //TODO: 将token上传到自己的推送服务器上
//    [FIRMessaging messaging].APNSToken = deviceToken;
    [Adjust setDeviceToken:deviceToken];//用于统计卸载
}

@end
