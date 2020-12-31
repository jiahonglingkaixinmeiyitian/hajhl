//
//  PSLanguageDrawerCell.m
//  PDFScanner
//
//  Created by Lucy Benson on 2020/5/12.
//  Copyright © 2020 cdants. All rights reserved.
//

#import "PSLanguageDrawerCell.h"
#import "PSTrainedDataDownloader.h"
#import "PSScannerSettingModel.h"
#import <CircleProgressBar/CircleProgressBar.h>
#import <SVGKit/SVGKit.h>

@interface PSLanguageDrawerCell ()

@property (strong, nonatomic) IBOutlet UIView *selectedBackView;
@property (strong, nonatomic) IBOutlet UIButton *downloadButton;
@property (strong, nonatomic) IBOutlet SVGKFastImageView *flagImageView;
@property (strong, nonatomic) IBOutlet UILabel *countryNameLabel;
@property (strong, nonatomic) IBOutlet UIImageView *selectedImageView;
@property (strong, nonatomic) IBOutlet CircleProgressBar *progressBar;

@property (nonatomic, strong) PSLanguageModel *language;

@end

@implementation PSLanguageDrawerCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)configWithLanguage:(PSLanguageModel *)language downloadInfo:(NSDictionary *)downloadInfo {
    self.language = language;
    self.flagImageView.image = [SVGKImage imageNamed:language.languageCode];
    self.countryNameLabel.text = language.languageName;
    
    self.downloadButton.selected = [[PSTrainedDataDownloader sharedDownloader] trainedDataDownloadedForLanguage:language.languageCode];
    
    self.selectedImageView.image = language.isSelected ? [UIImage imageNamed:@"home_directory_selected_state"] : [UIImage imageNamed:@"home_directory_unselected_state"];
    
    /// 没有下载的语言包没有uncheck box
    self.selectedImageView.hidden = !self.downloadButton.selected;
    
    self.selectedBackView.hidden = !language.isSelected;
    
    NSString *downloadLanguageCode = downloadInfo[@"languageCode"];
    if ([downloadLanguageCode isEqualToString:language.languageCode]) {
        self.downloadButton.hidden = YES;
        self.progressBar.hidden = NO;
        NSProgress *progress = downloadInfo[@"progress"];
        [self.progressBar setProgress:progress.fractionCompleted animated:NO];
        if (progress.fractionCompleted == 1.0) {
            self.downloadButton.hidden = NO;
            self.downloadButton.selected = YES;
            self.progressBar.hidden = YES;
        }
    } else {
        self.downloadButton.hidden = NO;
        self.progressBar.hidden = YES;
    }

}

@end
