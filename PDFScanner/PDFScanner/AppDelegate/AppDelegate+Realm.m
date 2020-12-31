//
//  AppDelegate+Realm.m
//  PDFScanner
//
//  Created by Dfsx on 2020/12/28.
//  Copyright © 2020 cdants. All rights reserved.
//

#import "AppDelegate+Realm.h"
#import "PSFileModel.h"

typedef NS_ENUM(NSInteger, PSSchemaVersion) {
    PSSchemaVersionInitial = 0,
    PSSchemaVersion1 = 1, // PSFileModel删除imageDatas,引进PSPictureModel数组pictures
    PSSchemaVersion2 = 2, // Future usage.
};

@implementation AppDelegate (Realm)


- (void)configRealm {
    
    RLMRealmConfiguration *config = [RLMRealmConfiguration defaultConfiguration];
    // Set the new schema version. This must be greater than the previously used
    // version (if you've never set a schema version before, the version is 0).
    config.schemaVersion = PSSchemaVersion1;

    // Set the block which will be called automatically when opening a Realm with a
    // schema version lower than the one set above
    config.migrationBlock = ^(RLMMigration *migration, uint64_t oldSchemaVersion) {
        // We haven’t migrated anything yet, so oldSchemaVersion == 0
        if (oldSchemaVersion < PSSchemaVersion1) {
            
            [migration enumerateObjects:PSFileModel.className
                                  block:^(RLMObject *oldObject, RLMObject *newObject) {

                // add new `pictures` property
                RLMArray<NSData *><RLMData> *imageDatas = oldObject[@"imageDatas"];
                
                NSMutableArray *pictures = @[].mutableCopy;
                for (NSData *data in imageDatas) {
                    PSPictureModel *model = [[PSPictureModel alloc] init];
                    model.imageData = data;
                    model.appliedFilter = @(PSSettingScannerFilterBlackWhite); // 第一版默认滤镜为B&W
                    [pictures addObject:model];
                }
                
                newObject[@"pictures"] = pictures;
                
            }];
            
            [migration enumerateObjects:PSScannerSettingModel.className block:^(RLMObject * _Nullable oldObject, RLMObject * _Nullable newObject) {
                // 更改老用户的设置滤镜为GrayScale
                newObject[@"scannerFilter"] = @(PSSettingScannerFilterGrayScale);
            }];
        }
        
        if (oldSchemaVersion < PSSchemaVersion2) {
            /// ... Future usage.
        }

    };

    // Tell Realm to use this new configuration object for the default Realm
    [RLMRealmConfiguration setDefaultConfiguration:config];

    // Now that we've told Realm how to handle the schema change, opening the file
    // will automatically perform the migration
    [RLMRealm defaultRealm];
}

@end
