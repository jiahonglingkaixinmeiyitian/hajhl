//
//  PSUserModel.m
//  PDFScanner
//
//  Created by heartjhl on 2020/5/27.
//  Copyright © 2020 cdants. All rights reserved.
//

#import "PSUserModel.h"

@implementation PSUserModel
- (BOOL)languageEn{
    return [[NSLocale preferredLanguages].firstObject hasPrefix:@"en"];
}
//重写以下几个方法
- (void)encodeWithCoder:(NSCoder*)aCoder {
    [self yy_modelEncodeWithCoder:aCoder];
}

- (id)initWithCoder:(NSCoder*)aDecoder
{
    self = [super init];
    return [self yy_modelInitWithCoder:aDecoder];
}

- (id)copyWithZone:(NSZone*)zone {
    return [self yy_modelCopy];
}

- (NSUInteger)hash {
    return [self yy_modelHash];
}

- (BOOL)isEqual:(id)object {
    return [self yy_modelIsEqual:object];
}

+ (BOOL)supportsSecureCoding{
    return YES;
}
@end
