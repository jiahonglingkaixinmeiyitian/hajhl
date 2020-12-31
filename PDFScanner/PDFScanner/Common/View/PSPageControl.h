//
//  PSPageControl.h
//  PDFScanner
//
//  Created by Lucy Benson on 2020/5/7.
//  Copyright © 2020 cdants. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^TapPageBlock)(NSInteger tapIndex);

@interface PSPageControl : UIView

@property (nonatomic, assign) NSInteger numberOfPages;
@property (nonatomic, assign) NSInteger currentPage;

@property(nonatomic) BOOL hidesForSinglePage;

@property (nonatomic, strong) UIColor *selectedTintColor;
@property (nonatomic, strong) UIColor *unSelectedTintColor;

@property (nonatomic, copy) TapPageBlock tapPageBlock;


@end

