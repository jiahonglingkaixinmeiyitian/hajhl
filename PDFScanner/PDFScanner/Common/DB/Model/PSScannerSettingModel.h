//
//  PSScannerSettingModel.h
//  PDFScanner
//
//  Created by Lucy Benson on 2020/5/11.
//  Copyright © 2020 cdants. All rights reserved.
//

#import <Realm/Realm.h>

/// 图片质量枚举
typedef NS_ENUM(NSInteger, PSSettingPictureQuality) {
    PSSettingPictureQualityLow = 0,
    PSSettingPictureQualityMedium = 1,
    PSSettingPictureQualityHigh = 2,
    PSSettingPictureQualityOriginal = 3,
};

/// 滤镜枚举
typedef NS_ENUM(NSInteger, PSSettingScannerFilter) {
    PSSettingScannerFilterOriginal = 0,
    PSSettingScannerFilterScans = 1,
    PSSettingScannerFilterMagic = 2,
    PSSettingScannerFilterBlackWhite = 3,
    PSSettingScannerFilterGrayScale = 4,
    PSSettingScannerFilterThreshold = 5,
};

@interface PSScannerSettingModel : RLMObject

@property PSSettingPictureQuality pictureQuality; // default High
@property PSSettingScannerFilter scannerFilter; // default B&W

-(CGFloat)cameraCompressionRatio;
-(int)phoneCompressionByte;

- (NSString *)pictureQualityValue;
- (NSString *)scannerFilterValue;
+ (NSString *)scannerFilterValue:(PSSettingScannerFilter)filter;


@end
