//
//  PSMoveDirectoryDrawer.h
//  PDFScanner
//
//  Created by Lucy Benson on 2020/5/12.
//  Copyright © 2020 cdants. All rights reserved.
//

#import "PSBottomDrawer.h"
#import "PSFileModel.h"

typedef void(^MoveDirectorySuccessBlock)(void);

@interface PSMoveDirectoryDrawer : PSBottomDrawer

@property (nonatomic, copy) MoveDirectorySuccessBlock moveDirSuccessBlock;

- (instancetype)initWithCurrentDirectory:(PSFileModel *)directory movingFiles:(RLMResults<PSFileModel *> *)movingFiles;

@end

