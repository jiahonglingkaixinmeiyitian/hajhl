//
//  PSPictureModel.h
//  PDFScanner
//
//  Created by Dfsx on 2020/12/28.
//  Copyright © 2020 cdants. All rights reserved.
//

#import <Realm/Realm.h>

/// 图片model
RLM_ARRAY_TYPE(PSPictureModel)
@interface PSPictureModel : RLMObject

/// 创建时间
@property NSDate *createdDate; // created date

/// 图片二进制
@property NSData *imageData;

/// 每个图片应用的滤镜， 默认为setting里设置的滤镜[PSSettingScannerFilter type]
@property NSNumber<RLMInt> *appliedFilter;

@end

