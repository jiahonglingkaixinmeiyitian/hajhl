//
//  PSBottomFilterDrawer.m
//  PDFScanner
//
//  Created by Lucy Benson on 2020/5/15.
//  Copyright © 2020 cdants. All rights reserved.
//

#import "PSBottomFilterDrawer.h"
#import "PSBottomFilterDrawerCell.h"

static CGFloat kItemSizeWidth = 75.f;
static CGFloat kItemSizeHeight = 75.f;

@interface PSBottomFilterDrawer ()<UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) NSArray *filterArray;

@end

@implementation PSBottomFilterDrawer

- (instancetype)init {
    if (self = [super init]) {
        [self setContentView:self.collectionView margin:UIEdgeInsetsMake(20, 0, 32, 0)];
    }
    return self;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.filterArray.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PSBottomFilterDrawerCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[PSBottomFilterDrawerCell ps_reuseIdentifier] forIndexPath:indexPath];
    [cell configWithFilterType:[self.filterArray[indexPath.item] integerValue]];
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    !self.pickListItemBlock?:self.pickListItemBlock(indexPath.item);
    [self dismissDrawer];
}

#pragma mark - Property Getters

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
        flowLayout.minimumLineSpacing = 34.f;
        flowLayout.sectionInset = UIEdgeInsetsMake(65.f, 45.f, 0, 45.f);
        flowLayout.minimumInteritemSpacing = (SCREEN_WIDTH - 45.f * 2 - kItemSizeWidth * 3) / 2.f;
        flowLayout.itemSize = CGSizeMake(kItemSizeWidth, kItemSizeHeight);
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
//        _collectionView.contentInset = UIEdgeInsetsMake(65.f, 45.f, 0, 45.f);
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        [_collectionView registerNib:[PSBottomFilterDrawerCell ps_nib] forCellWithReuseIdentifier:[PSBottomFilterDrawerCell ps_reuseIdentifier]];
        [_collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(322.f);
        }];
    }
    return _collectionView;
}

- (NSArray *)filterArray {
    if (!_filterArray) {
        NSMutableArray *filterArray = @[].mutableCopy;
        for (NSInteger i = 0; i < 6; i++) {
            [filterArray addObject:@(i)];
        }
        _filterArray = filterArray.copy;
    }
    return _filterArray;
}

@end
