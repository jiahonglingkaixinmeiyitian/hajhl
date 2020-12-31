//
//  PSFileModel.m
//  PDFScanner
//
//  Created by Lucy Benson on 2020/4/23.
//  Copyright © 2020 cdants. All rights reserved.
//

#import "PSFileModel.h"

@implementation PSFileModel

+ (NSDictionary *)defaultPropertyValues {
    return @{@"createdDate" : [NSDate date], @"isRoot": @(NO)};
}

+ (NSDictionary *)linkingObjectsProperties {
    return @{
        @"belongedDirs": [RLMPropertyDescriptor descriptorWithClass:PSFileModel.class propertyName:@"fileOrDirs"],
    };
}

- (PSFileModel *)belongedDir {
    return self.belongedDirs.firstObject;
}

- (RLMResults<PSFileModel *>*)dirs {
    return [self.fileOrDirs objectsWhere:@"isDir == true"];
}

- (RLMResults<PSFileModel *>*)files {
    return [self.fileOrDirs objectsWhere:@"isDir == false"];
}

@end
