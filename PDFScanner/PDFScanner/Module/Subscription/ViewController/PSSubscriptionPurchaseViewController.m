//
//  PSSubscriptionPurchaseViewController.m
//  PDFScanner
//
//  Created by Lucy Benson on 2020/5/11.
//  Copyright © 2020 cdants. All rights reserved.
//

#import "PSSubscriptionPurchaseViewController.h"
#import "UIView+RoundedCorner.h"
#import "PSSubscriptionPurchaseCell.h"

@interface PSSubscriptionPurchaseViewController ()<UICollectionViewDelegate, UICollectionViewDataSource>

@property (strong, nonatomic) IBOutlet UIButton *freeTrialButton;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) IBOutlet UICollectionViewFlowLayout *collectionFlowLayout;

@property (nonatomic, strong) NSArray *products;

@end

@implementation PSSubscriptionPurchaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpCollectionView];
}

- (void)setUpCollectionView {
    [self.collectionView registerNib:[PSSubscriptionPurchaseCell ps_nib] forCellWithReuseIdentifier:[PSSubscriptionPurchaseCell ps_reuseIdentifier]];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self.freeTrialButton ps_applyGradientColors:@[(id)UIColorFromRGB(0xF35533).CGColor, (id)UIColorFromRGB(0xFF7F49).CGColor]];
    
    CGFloat padding = (SCREEN_WIDTH - self.collectionFlowLayout.minimumInteritemSpacing - self.collectionFlowLayout.itemSize.width * 2) / 2;
    self.collectionFlowLayout.sectionInset = UIEdgeInsetsMake(0, padding, 0, padding);
}

#pragma mark - Actions

- (IBAction)clickFreeTrialButton:(id)sender {
    // TODO:
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.products.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PSSubscriptionPurchaseCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[PSSubscriptionPurchaseCell ps_reuseIdentifier] forIndexPath:indexPath];
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    // TODO:
}


#pragma mark - Property Getters

- (NSArray *)products {
    if (!_products) {
        _products = @[@(1), @(2)]; // replace with SKProduct
    }
    return _products;
}

@end
