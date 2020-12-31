//
//  PSMoveToRootDirectoryDrawer.m
//  PDFScanner
//
//  Created by Lucy Benson on 2020/5/12.
//  Copyright © 2020 cdants. All rights reserved.
//

#import "PSMoveToRootDirectoryDrawer.h"
#import "PSDocListCell.h"
#import "AppDelegate.h"


static CGFloat kLayoutMargin = 24.f;
static CGFloat kInterItemSpacing = 16.f;

@interface PSMoveToRootDirectoryDrawer ()<UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) PSFileModel *rootDir;
@property (nonatomic, strong) RLMResults<PSFileModel *> *movingFiles;

@end

@implementation PSMoveToRootDirectoryDrawer

- (instancetype)initWithMovingFiles:(RLMResults<PSFileModel *> *)movingFiles {
    if (self = [super init]) {
        self.rootDir = [PSFileModel objectsWhere:@"isRoot == true"].firstObject;
        self.movingFiles = movingFiles;
        [self setContentView:self.contentView margin:UIEdgeInsetsMake(20, 0, 32, 0)];
    }
    return self;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 1;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    PSDocListCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[PSDocListCell ps_reuseIdentifier] forIndexPath:indexPath];
    [cell configWithModel:self.rootDir isEditMode:NO];
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm transactionWithBlock:^{
        // step1: 先copy
        NSArray *copiedFiles = [self _copySelectedFiles];
        // step2: 再删除
        [realm deleteObjects:self.movingFiles];
        // step3: 再添加(添加到前面)
        [copiedFiles enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [self.rootDir.fileOrDirs insertObject:obj atIndex:0];
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
        for (id picture in model.pictures) {
            [file.pictures addObject:picture];
        }
        [array addObject:file];
    }
    return array;
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
    }
    return _collectionView;
}

- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc] init];
        [_contentView addSubview:self.collectionView];
        [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.right.bottom.equalTo(_contentView);
            make.height.mas_equalTo(120.f);
        }];
    }
    return _contentView;
}

@end
