//
//  PSBaseVC.m
//  PDFScanner
//
//  Created by Lcyu on 2020/5/7.
//  Copyright © 2020 cdants. All rights reserved.
//

#import "PSBaseVC.h"

@interface PSBaseVC ()
@property (nonatomic, strong) UIView *titleView;
@property (nonatomic, strong) UILabel *titleLabel;
@end

@implementation PSBaseVC

-(instancetype)init{
    if (self = [super init]){
        self.needTitleView = false;
    }
    return self;
}

- (void)viewDidLoad {
    self.safeBottomViewHeight = 0;
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupViews];
}

-(void)setupViews{
    self.view.backgroundColor = [UIColor mainBackgroundColor];
    self.safeBottomView.backgroundColor = self.view.backgroundColor;
    self.safeBottomViewHeight = SAFE_BOTTOM_HEIGHT;
    [self.view addSubview:self.safeBottomView];
    [self.safeBottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        make.height.equalTo(@(self.safeBottomViewHeight));
    }];
    
    if (self.needTitleView) {
        self.titleLabel.text = self.titleStr;
    }
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}

-(void)dealloc{
    
}

- (BOOL)hidesBottomBarWhenPushed{
    return true;
}

-(void)titleViewClick:(UITapGestureRecognizer *)gr{
    !self.titleViewClickBlock?:self.titleViewClickBlock();
}

-(UIView *)safeBottomView
{
    if (!_safeBottomView) {
        self.safeBottomView = [[UIView alloc] init];
    }
    return _safeBottomView;
}

-(UIView *)titleView
{
    if (!_titleView) {
        self.titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 220, self.navigationController.navigationBar.height)];
        self.navigationItem.titleView = self.titleView;
        [self.titleView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(titleViewClick:)]];
    }
    return _titleView;
}

-(UILabel *)titleLabel
{
    if (!_titleLabel) {
        self.titleLabel = [[UILabel alloc] init];
        [self.titleView addSubview:self.titleLabel];
        self.titleLabel.font = [UIFont appBoldFontSize:18];
        self.titleLabel.textColor = [UIColor themeColor];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.titleView);
        }];
    }
    return _titleLabel;
}

-(void)setTitleStr:(NSString *)titleStr{
    _titleStr = titleStr;
    if (self.needTitleView)
    {
        self.titleLabel.text = _titleStr;
    }
}


@end
