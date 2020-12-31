//
//  PSSignatureModel.h
//  PDFScanner
//
//  Created by Lucy Benson on 2020/4/23.
//  Copyright © 2020 cdants. All rights reserved.
//

#import <Realm/Realm.h>

/*
 * 签名model
 *
 */
@interface PSSignatureModel : RLMObject

@property NSData *imageData;
@property NSDate *createdDate; // created date

+(NSArray *)allModels;
@end

