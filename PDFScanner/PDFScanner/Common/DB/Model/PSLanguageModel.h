//
//  PSLanguageModel.h
//  PDFScanner
//
//  Created by Lucy Benson on 2020/5/12.
//  Copyright © 2020 cdants. All rights reserved.
//

#import <Realm/Realm.h>

@interface PSLanguageModel : RLMObject

@property NSString *languageName; // english
@property NSString *languageCode;   // eng
@property BOOL isSelected;  // 是否选中 default NO

+ (NSArray<NSString *> *)selectedLanguageCodes;

@end

