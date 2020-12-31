//
//  PSSignatureModel.m
//  PDFScanner
//
//  Created by Lucy Benson on 2020/4/23.
//  Copyright © 2020 cdants. All rights reserved.
//

#import "PSSignatureModel.h"

@implementation PSSignatureModel

+ (NSDictionary *)defaultPropertyValues {
    return @{@"createdDate" : [NSDate date]};
}

+(NSArray *)allModels{
    NSMutableArray *arr = [NSMutableArray array];
    for (PSSignatureModel *model in [[[self class] allObjects] sortedResultsUsingKeyPath:@"createdDate" ascending:false]){
        [arr addObject:model];
    }
    return [arr copy];
}
@end
