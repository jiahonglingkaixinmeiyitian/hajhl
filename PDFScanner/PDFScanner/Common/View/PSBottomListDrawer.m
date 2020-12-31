//
//  PSBottomListDrawer.m
//  PDFScanner
//
//  Created by Lucy Benson on 2020/5/9.
//  Copyright © 2020 cdants. All rights reserved.
//

#import "PSBottomListDrawer.h"

@interface PSBottomListDrawerCell : UITableViewCell

@property (nonatomic, strong) UIImageView *leftImageView;
@property (nonatomic, strong) UILabel *rightLabel;

- (void)configWithDictionary:(NSDictionary *)dictionary;

@end

@interface PSBottomListDrawer ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSArray<NSDictionary *> *items;

@end

@implementation PSBottomListDrawer

- (instancetype)initWithItems:(NSArray<NSDictionary *> *)items {
    if (self = [super init]) {
        self.items = items;
        [self setContentView:self.tableView margin:UIEdgeInsetsMake(30, 0, 30, 0)];
    }
    return self;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    !self.pickListItemBlock?:self.pickListItemBlock(indexPath.row);
    [self dismissDrawer];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dict = self.items[indexPath.row];
    PSBottomListDrawerCell *cell = [tableView dequeueReusableCellWithIdentifier:[PSBottomListDrawerCell ps_reuseIdentifier]];
    [cell configWithDictionary:dict];
    return cell;
}

#pragma mark - Property Getters

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.estimatedRowHeight = 60;
        _tableView.rowHeight = 60;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_tableView registerClass:[PSBottomListDrawerCell class] forCellReuseIdentifier:[PSBottomListDrawerCell ps_reuseIdentifier]];
        
        [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(self.items.count * 60);
        }];
    }
    return _tableView;
}

@end

@implementation PSBottomListDrawerCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        UIStackView *stackView = [[UIStackView alloc] initWithArrangedSubviews:@[self.leftImageView, self.rightLabel]];
        stackView.spacing = 12;
        stackView.axis = UILayoutConstraintAxisHorizontal;
        [self.contentView addSubview:stackView];
        [stackView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.contentView);
        }];
    }
    return self;
}

- (void)configWithDictionary:(NSDictionary *)dict {
    self.leftImageView.image = [UIImage imageNamed:dict[@"leftName"]];
    self.rightLabel.text = dict[@"rightText"];
}

#pragma mark - Property Getters

- (UIImageView *)leftImageView {
    if (!_leftImageView) {
        _leftImageView = [[UIImageView alloc] init];
    }
    return _leftImageView;
}

- (UILabel *)rightLabel {
    if (!_rightLabel) {
        _rightLabel = [[UILabel alloc] init];
        _rightLabel.font = [UIFont appBoldFontSize:18.f];
        _rightLabel.textColor = [UIColor themeColor];
    }
    return _rightLabel;
}

@end
