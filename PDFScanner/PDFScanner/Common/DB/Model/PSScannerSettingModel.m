//
//  PSScannerSettingModel.m
//  PDFScanner
//
//  Created by Lucy Benson on 2020/5/11.
//  Copyright © 2020 cdants. All rights reserved.
//

#import "PSScannerSettingModel.h"

@implementation PSScannerSettingModel

+ (NSDictionary *)defaultPropertyValues {
    return @{@"pictureQuality" : @(PSSettingPictureQualityHigh), @"scannerFilter": @(PSSettingScannerFilterBlackWhite)};
}

- (NSString *)pictureQualityValue {
    switch (self.pictureQuality) {
        case PSSettingPictureQualityLow:
            return @"Low";
        case PSSettingPictureQualityHigh:
            return @"High";
        case PSSettingPictureQualityMedium:
            return @"Medium";
        case PSSettingPictureQualityOriginal:
            return @"Original";
        default:
            break;
    }
}

-(CGFloat)cameraCompressionRatio{
    switch (self.pictureQuality) {
        case PSSettingPictureQualityLow:
            return 0.2;
        case PSSettingPictureQualityMedium:
            return 0.5;
        case PSSettingPictureQualityHigh:
            return 0.6;
        case PSSettingPictureQualityOriginal:
            return 0.8;
        default:
            return 0.8;
    }
}

-(int)phoneCompressionByte{
    switch (self.pictureQuality) {
        case PSSettingPictureQualityLow:
            return 465330;
        case PSSettingPictureQualityMedium:
            return 702736;
        case PSSettingPictureQualityHigh:
            return 2285373;
        case PSSettingPictureQualityOriginal:
            return 3670016;
        default:
            return 3670016;
    }
}

- (NSString *)scannerFilterValue {
    return [[self class] scannerFilterValue:self.scannerFilter];
}

+ (NSString *)scannerFilterValue:(PSSettingScannerFilter)filter{
    switch (filter) {
        case PSSettingScannerFilterMagic:
            return @"Magic";
        case PSSettingScannerFilterScans:
            return @"Scans";
        case PSSettingScannerFilterOriginal:
            return @"Original";
        case PSSettingScannerFilterGrayScale:
            return @"Grayscale";
        case PSSettingScannerFilterBlackWhite:
            return @"B&W";
        case PSSettingScannerFilterThreshold:
            return @"Threshold";
        default:
            break;
    }
}

@end
