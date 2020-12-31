//
//  PSBottomFilterDrawerCell.m
//  PDFScanner
//
//  Created by Lucy Benson on 2020/5/15.
//  Copyright © 2020 cdants. All rights reserved.
//

#import "PSBottomFilterDrawerCell.h"
#import <PDFScanner-Swift.h>

@interface PSBottomFilterDrawerCell ()

@property (strong, nonatomic) IBOutlet UIImageView *backImageView;
@property (strong, nonatomic) IBOutlet UILabel *filterNameLabel;

@end

@implementation PSBottomFilterDrawerCell

- (void)configWithFilterType:(PSSettingScannerFilter)filter {
    UIImage *originalImage = [UIImage imageNamed:@"Original"];
    switch (filter) {
        case PSSettingScannerFilterOriginal: {
            self.filterNameLabel.text = @"Original";
            self.backImageView.image = originalImage;
        }
            break;
        case PSSettingScannerFilterScans: {
            self.filterNameLabel.text = @"Scans";
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                UIImage *filteredImage = [GPUFilterHander getFilterImageWithOriginImage:originalImage filter:[GPUFilterHander sharedInstance].scansFilter];
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.backImageView.image = filteredImage;
                });
            });
        }
            break;
        case PSSettingScannerFilterMagic: {
            self.filterNameLabel.text = @"Magic";
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                UIImage *filteredImage = [GPUFilterHander getFilterImageWithOriginImage:originalImage filter:[GPUFilterHander sharedInstance].magicFilter];
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.backImageView.image = filteredImage;
                });
            });
        }
            break;
        case PSSettingScannerFilterBlackWhite: {
            self.filterNameLabel.text = @"B&W";
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                UIImage *filteredImage = [GPUFilterHander getFilterImageWithOriginImage:originalImage filter:[GPUFilterHander sharedInstance].bwFilter];
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.backImageView.image = filteredImage;
                });
            });
        }
            break;
        case PSSettingScannerFilterGrayScale: {
            self.filterNameLabel.text = @"Grayscale";
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                UIImage *filteredImage = [GPUFilterHander getFilterImageWithOriginImage:originalImage filter:[GPUFilterHander sharedInstance].grayscaleFilter];
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.backImageView.image = filteredImage;
                });
            });
        }
            break;
        case PSSettingScannerFilterThreshold: {
            self.filterNameLabel.text = @"Threshold";
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                UIImage *filteredImage = [GPUFilterHander getFilterImageWithOriginImage:originalImage filter:[GPUFilterHander sharedInstance].thresholdFilter];
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.backImageView.image = filteredImage;
                });
            });
        }
            break;
            
        default:
            break;
    }
    
    PSScannerSettingModel *model = [PSScannerSettingModel allObjects].firstObject;
    if (model.scannerFilter == filter) {
        self.contentView.layer.borderColor = UIColorFromRGB(0xD13D1E).CGColor;
        self.contentView.layer.borderWidth = 3.f;
    } else {
        self.contentView.layer.borderColor = [UIColor clearColor].CGColor;
        self.contentView.layer.borderWidth = 0.f;
    }
    
}


- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

@end
