//
//  PSMainPurchseViewModel.m
//  PDFScanner
//
//  Created by heartjhl on 2020/6/2.
//  Copyright © 2020 cdants. All rights reserved.
//

#import "PSMainPurchseViewModel.h"
#import "PSMainPurchseModel.h"

@implementation PSMainPurchseViewModel
-(NSArray *)fetchDataSource{
    NSArray *titleArr = @[@"Weekly",@"Annually"];
    PSPurchaseModel *model = [PSPurchaseModel sharedInstance];
    NSString *weekPrice = [model.priceDic[subscribe1wTrialProductId] stringByAppendingFormat:@"/week"];
    NSString *yearPrice = [model.priceDic[subscribe1yTrialProductId] stringByAppendingFormat:@"/year"];
    NSArray *priceArr = @[weekPrice,yearPrice];
    NSMutableArray *arr = [[NSMutableArray alloc]init];
    for (int i = 0; i<titleArr.count; i++) {
        PSMainPurchseModel *model = [[PSMainPurchseModel alloc]init];
        model.title = titleArr[i];
        model.price = priceArr[i];
        if (i==0) {
            model.selected = NO;
        }else{
            model.selected = YES;
        }
        [arr addObject:model];
    }
    
    return arr;
}
@end
