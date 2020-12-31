//
//  PSMoveDirectoryDrawer.m
//  PDFScanner
//
//  Created by Lucy Benson on 2020/5/12.
//  Copyright © 2020 cdants. All rights reserved.
//

#import "PSMoveDirectoryDrawer.h"
#import "PSDocListCell.h"
#import "AppDelegate.h"


static CGFloat kLayoutMargin = 24.f;
static CGFloat kInterItemSpacing = 16.f;

@interface PSMoveDirectoryDrawer ()<UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UIButton *createDirectoryButton;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UILabel *emptyLabel;

@property (nonatomic, strong) PSFileModel *currentDirectory;
@property (nonatomic, strong) RLMResults<PSFileModel *> *movingFiles;

@end

@implementation PSMoveDirectoryDrawer

- (instancetype)initWithCurrentDirectory:(PSFileModel *)directory movingFiles:(RLMResults<PSFileModel *> *)movingFiles {
    if (self = [super init]) {
        self.currentDirectory = directory;
        self.movingFiles = movingFiles;
        [self setContentView:self.contentView margin:UIEdgeInsetsMake(20, 0, 32, 0)];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    // add dot.
    CAShapeLayer *dashedBorder = [CAShapeLayer layer];
    dashedBorder.strokeColor = [[UIColor themeColor] colorWithAlphaComponent:0.5].CGColor;
    dashedBorder.fillColor = nil;
    dashedBorder.lineDashPattern = @[@4, @4];
    dashedBorder.frame = self.createDirectoryButton.bounds;
    dashedBorder.path = [UIBezierPath bezierPathWithRoundedRect:self.createDirectoryButton.bounds cornerRadius:12.f].CGPath;
    [self.createDirectoryButton.layer addSublayer:dashedBorder];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.currentDirectory.dirs.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    PSDocListCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[PSDocListCell ps_reuseIdentifier] forIndexPath:indexPath];
    if (indexPath.item < self.currentDirectory.dirs.count) {
        [cell configWithModel:self.currentDirectory.dirs[indexPath.item] isEditMode:NO];
    }
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    PSFileModel *selectedDir = self.currentDirectory.dirs[indexPath.item];
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm transactionWithBlock:^{
        // step1: 先copy
        NSArray *copiedFiles = [self _copySelectedFiles];
        // step2: 再删除
        [realm deleteObjects:self.movingFiles];
        // step3: 再添加(添加到前面)
        [copiedFiles enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [selectedDir.fileOrDirs insertObject:obj atIndex:0];
        }];
    }];
    !self.moveDirSuccessBlock?:self.moveDirSuccessBlock();
    [self dismissDrawer];
    
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat itemWidth = SCREEN_WIDTH - kLayoutMargin * 2;
    CGFloat itemHeight = itemWidth / (366.f / 88.f);
    return CGSizeMake(itemWidth, itemHeight);
}

#pragma mark - Private Methods

- (NSArray<PSFileModel *> *)_copySelectedFiles {
    NSMutableArray *array = @[].mutableCopy;
    for (PSFileModel *model in self.movingFiles) {
        PSFileModel *file = [[PSFileModel alloc] init];
        file.isDir = model.isDir;
        file.name = model.name;
        file.createdDate = model.createdDate;
        for (id data in model.imageDatas) {
            [file.imageDatas addObject:data];
        }
        [array addObject:file];
    }
    return array;
}

- (void)createDir:(id)sender {
    UIAlertController *addDirDialog = [UIAlertController alertControllerWithTitle:@"Create new folder" message:@"Type new folder name below" preferredStyle:UIAlertControllerStyleAlert];
    [addDirDialog addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"folder name";
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *createAction = [UIAlertAction actionWithTitle:@"Create" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self _createDirectory:addDirDialog.textFields.firstObject.text];
    }];
    [addDirDialog addAction:cancelAction];
    [addDirDialog addAction:createAction];
    UIViewController *vc = [UIApplication sharedApplication].delegate.window.rootViewController;
    [vc presentViewController:addDirDialog animated:YES completion:nil];
}

- (void)_createDirectory:(NSString *)directoryName {
    NSString *trimmedDirName = [directoryName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (trimmedDirName.length == 0) {
        [self ps_showHint:@"Directory name can't be empty"];
        return;
    }
    RLMRealm *realm = [RLMRealm defaultRealm];

    PSFileModel *dir = [[PSFileModel alloc] init];
    dir.name = trimmedDirName;
    dir.isDir = YES;
    
    [realm transactionWithBlock:^{
        [self.currentDirectory.fileOrDirs insertObject:dir atIndex:0]; // 放到最前面
        [realm addObject:dir];
    }];
    
    self.collectionView.backgroundView = self.currentDirectory.dirs.count > 0 ? nil : self.emptyLabel;
    
    [self.collectionView performBatchUpdates:^{
        //
        [self.collectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:0 inSection:0]]];
    } completion:nil];
    [self.collectionView reloadData];
}

#pragma mark - Property Getters

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        layout.minimumInteritemSpacing = kInterItemSpacing;
        layout.minimumLineSpacing = kInterItemSpacing;
        layout.sectionInset = UIEdgeInsetsMake(12, kLayoutMargin, 0, kLayoutMargin);
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView.alwaysBounceVertical = YES;
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        [_collectionView registerNib:[PSDocListCell ps_nib] forCellWithReuseIdentifier:[PSDocListCell ps_reuseIdentifier]];
        _collectionView.backgroundView = self.currentDirectory.dirs.count > 0 ? nil : self.emptyLabel;
    }
    return _collectionView;
}

- (UIButton *)createDirectoryButton {
    if (!_createDirectoryButton) {
        _createDirectoryButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [_createDirectoryButton setTitle:@"Create Folder" forState:UIControlStateNormal];
        [_createDirectoryButton setImage:[UIImage imageNamed:@"home_create_directory_button"] forState:UIControlStateNormal];
        _createDirectoryButton.titleEdgeInsets = UIEdgeInsetsMake(0, 15, 0, 0);
        _createDirectoryButton.titleLabel.font = [UIFont appBoldFontSize:18.f];
        [_createDirectoryButton setTitleColor:[UIColor themeColor] forState:UIControlStateNormal];
        [_createDirectoryButton addTarget:self action:@selector(createDir:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _createDirectoryButton;
}

- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc] init];
        [_contentView addSubview:self.collectionView];
        [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.right.equalTo(_contentView);
            make.height.mas_equalTo(SCREEN_HEIGHT * (622.f / 896.f));
        }];
        [_contentView addSubview:self.createDirectoryButton];
        [self.createDirectoryButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.collectionView.mas_bottom).offset(20);
            make.bottom.equalTo(_contentView);
            make.left.equalTo(_contentView).offset(24);
            make.right.equalTo(_contentView).offset(-24);
            make.height.mas_equalTo(60);
        }];
    }
    return _contentView;
}

- (UILabel *)emptyLabel {
    if (!_emptyLabel) {
        _emptyLabel = [[UILabel alloc] init];
        _emptyLabel.text = @"Create your first folder ↓";
        _emptyLabel.textAlignment = NSTextAlignmentCenter;
        _emptyLabel.font = [UIFont appRegularFontSize:15.];
        _emptyLabel.textColor = [UIColor themeColor];
    }
    return _emptyLabel;
}

@end
