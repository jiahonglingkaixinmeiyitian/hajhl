//
//  PSPageControl.m
//  PDFScanner
//
//  Created by Lucy Benson on 2020/5/7.
//  Copyright © 2020 cdants. All rights reserved.
//

#import "PSPageControl.h"

static NSInteger kPageControlHeight = 8.f;
static NSInteger kPagePadding = 8.f;
static NSInteger kSelectedPageWidth = 27.f;
static NSInteger kUnselectedPageWidth = 8.f;

@implementation PSPageControl

- (instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [super initWithCoder:coder]) {
        [self setUpView];
    }
    return self;
}

- (void)setUpView {
    self.backgroundColor = [UIColor clearColor];
    self.selectedTintColor = UIColorFromRGB(0xD13D1E);
    self.unSelectedTintColor = [UIColor themeColor];
    self.hidesForSinglePage = YES;

    [self mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(kPageControlHeight);
    }];
    
}

- (void)setNumberOfPages:(NSInteger)numberOfPages {
    if (_numberOfPages == numberOfPages) {
        return;
    }
    _numberOfPages = numberOfPages;
    
    for (UIView *subView in self.subviews) {
        [subView removeFromSuperview];
    }
    
    if (numberOfPages == 1 && self.hidesForSinglePage) {
        return;
    }
    
    UIView *previousPage = nil;
    for (NSInteger i = 0; i < numberOfPages; i++) {
        UIControl *page = [[UIControl alloc] init];
        page.layer.cornerRadius = kPageControlHeight / 2;
        page.layer.masksToBounds = YES;
        page.tag = i;
        [page addTarget:self action:@selector(tapPage:) forControlEvents:UIControlEventTouchUpInside];
        page.backgroundColor = self.unSelectedTintColor;
        [self addSubview:page];
        [page mas_makeConstraints:^(MASConstraintMaker *make) {
            if (i == 0) {
                make.left.equalTo(self);
            } else {
                make.left.equalTo(previousPage.mas_right).offset(kPagePadding);
            }
            if (i == numberOfPages - 1) {
                make.right.equalTo(self);
            }
            make.height.equalTo(self);
            make.width.mas_equalTo(kUnselectedPageWidth);
            make.top.bottom.equalTo(self);
        }];
        previousPage = page;
    }
}

- (void)setCurrentPage:(NSInteger)currentPage {

    if (_currentPage >= self.numberOfPages) {
        return;
    }
    _currentPage = currentPage;

    for (NSInteger i = 0; i < self.subviews.count; i++) {
        UIView *page = self.subviews[i];
        if (i == currentPage) {
            page.backgroundColor = self.selectedTintColor;
            [page mas_updateConstraints:^(MASConstraintMaker *make) {
                make.width.mas_equalTo(kSelectedPageWidth);
            }];
        } else {
            page.backgroundColor = self.unSelectedTintColor;
            [page mas_updateConstraints:^(MASConstraintMaker *make) {
                make.width.mas_equalTo(kUnselectedPageWidth);
            }];
        }
    }
}

- (void)tapPage:(UIControl *)control {
    !self.tapPageBlock?:self.tapPageBlock(control.tag);
}

@end
