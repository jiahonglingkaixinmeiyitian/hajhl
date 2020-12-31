//
//  PSLanguageModel.m
//  PDFScanner
//
//  Created by Lucy Benson on 2020/5/12.
//  Copyright © 2020 cdants. All rights reserved.
//

#import "PSLanguageModel.h"

@implementation PSLanguageModel

+ (NSArray<NSString *> *)selectedLanguageCodes {
    NSMutableArray *codes = @[].mutableCopy;
    RLMResults<PSLanguageModel *> *selectedLanguages = [PSLanguageModel objectsWhere:@"isSelected == true"];
    for (PSLanguageModel *model in selectedLanguages) {
        [codes addObject:model.languageCode];
    }
    return codes.copy;
}

@end
