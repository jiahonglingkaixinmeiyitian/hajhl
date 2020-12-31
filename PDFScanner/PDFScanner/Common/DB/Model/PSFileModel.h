//
//  PSFileModel.h
//  PDFScanner
//
//  Created by Lucy Benson on 2020/4/23.
//  Copyright © 2020 cdants. All rights reserved.
//

#import <Realm/Realm.h>
#import "PSScannerSettingModel.h"
#import "PSPictureModel.h"

/**
 * 文件或者目录model
 * 目录包含文件，文件包含图片
 *
 */
NS_ASSUME_NONNULL_BEGIN

RLM_ARRAY_TYPE(PSFileModel)
@interface PSFileModel : RLMObject

@property NSString *name; // file name or directory name
@property NSDate *createdDate; // created date

@property (readonly) RLMLinkingObjects *belongedDirs;
@property (readonly) PSFileModel *belongedDir; // file or dir belongs to this directory, nil means at root level.

/// 目录相关属性
@property BOOL isDir;   // 是否为目录
@property BOOL isRoot;   // 是否为根目录- default NO
@property RLMArray<PSFileModel *><PSFileModel> *fileOrDirs;

@property RLMArray<PSPictureModel *><PSPictureModel> *pictures;

@property BOOL isSelected; // 是否选中

@property (readonly) RLMResults<PSFileModel *> *dirs;
@property (readonly) RLMResults<PSFileModel *> *files;



@end

NS_ASSUME_NONNULL_END
