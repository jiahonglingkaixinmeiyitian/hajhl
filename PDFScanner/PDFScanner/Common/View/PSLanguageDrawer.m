//
//  PSLanguageDrawer.m
//  PDFScanner
//
//  Created by Lucy Benson on 2020/5/12.
//  Copyright © 2020 cdants. All rights reserved.
//

#import "PSLanguageDrawer.h"
#import "PSLanguageDrawerCell.h"
#import "PSTrainedDataDownloader.h"
#import "PSScannerSettingModel.h"
#import "PSLanguageModel.h"

static NSInteger kMaxSelectLanguageCount = 3;

@interface PSLanguageDrawer ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSDictionary *downloadInfo;

@end

@implementation PSLanguageDrawer

- (instancetype)init {
    if (self = [super init]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateProgress:) name:PSTrainedDataDownloaderProgressNotification object:nil];
        [self setContentView:self.tableView margin:UIEdgeInsetsMake(30, 0, 0, 0)];
    }
    return self;
}

- (void)updateProgress:(NSNotification *)sender {
    self.downloadInfo = sender.object;
    dispatch_async(dispatch_get_main_queue(), ^{
        //
        [self.tableView reloadData];
    });
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [PSLanguageModel allObjects].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PSLanguageDrawerCell *cell = [tableView dequeueReusableCellWithIdentifier:[PSLanguageDrawerCell ps_reuseIdentifier]];
    [cell configWithLanguage:[PSLanguageModel allObjects][indexPath.row] downloadInfo:self.downloadInfo];
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    PSLanguageModel *model = [[PSLanguageModel allObjects] objectAtIndex:indexPath.row];
    BOOL isDownloaded = [[PSTrainedDataDownloader sharedDownloader] trainedDataDownloadedForLanguage:model.languageCode];
    if (isDownloaded) {
        // 选择语言包
        if (!model.isSelected) {
            if ([PSLanguageModel objectsWhere:@"isSelected == true"].count >= kMaxSelectLanguageCount) {
                [self ps_showHint:[NSString stringWithFormat:@"At most pick %ld languages", kMaxSelectLanguageCount]];
                return;
            }
        }
        
        RLMRealm *realm = [RLMRealm defaultRealm];
        [realm transactionWithBlock:^{
            model.isSelected = !model.isSelected;
        }];
        [tableView reloadData];
        return;
    }

    [[PSTrainedDataDownloader sharedDownloader] downloadTraindDataWithLanguage:model.languageCode completionHandler:^(NSURL *filePath, NSError *error) {
        [self.tableView reloadData];
    }];
}

#pragma mark - Property Getters

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.estimatedRowHeight = 60;
        _tableView.rowHeight = 60;
        _tableView.contentInset = UIEdgeInsetsMake(0, 0, 20, 0);
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_tableView registerNib:[PSLanguageDrawerCell ps_nib] forCellReuseIdentifier:[PSLanguageDrawerCell ps_reuseIdentifier]];
        
        [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(SCREEN_HEIGHT * 0.8);
        }];
    }
    return _tableView;
}

@end
