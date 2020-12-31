//
//  UIView+RoundedCorner.m
//  PDFScanner
//
//  Created by Lucy Benson on 2020/5/7.
//  Copyright © 2020 cdants. All rights reserved.
//

#import "UIView+RoundedCorner.h"

@implementation UIView (RoundedCorner)

- (void)ps_roundCorners:(UIRectCorner)corners radius:(CGFloat)radius {

    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:corners cornerRadii:CGSizeMake(radius, radius)];
    CAShapeLayer *mask = [[CAShapeLayer alloc] init];
    mask.path = path.CGPath;
    self.layer.mask = mask;
}

- (void)ps_applyGradientColors:(NSArray *)colors {
    
    CAGradientLayer *gradientLayer = [[CAGradientLayer alloc] init];
    gradientLayer.colors = colors;
    gradientLayer.startPoint = CGPointMake(0, 0.5);
    gradientLayer.endPoint = CGPointMake(1, 0.5);
    gradientLayer.frame = self.bounds;
    [self.layer insertSublayer:gradientLayer atIndex:0];
}

-(void)setTrasitonAnimation:(TransitonAnimation)type duration:(NSTimeInterval)duration towardType:(TansitionAnimationTowardType)towardType timingFunc:(TransitonAnimTimingFunc)timingFunc
{
    NSArray *typeArray = @[@"cameraIrisHollowOpen",@"cameraIrisHollowClose",@"cube",@"pageCurl",@"pageUnCurl",@"rippleEffect",@"suckEffect",@"oglFlip",@"fade",@"moveIn",@"push",@"reveal"];
    NSArray *towardArray = @[@"fromLeft",@"fromRight",@"fromTop",@"fromBottom"];
    NSArray *timingdArray = @[@"linear",@"easeIn",@"easeOut",@"easeInEaseOut"];
    
    CATransition *transitin = [[CATransition alloc]init];
    //动画时间
    transitin.duration = duration;
    //设置动画类型
    transitin.type = typeArray[type];
    //动画方向
    transitin.subtype = towardArray[towardType];
    //速度变化
    transitin.timingFunction =  [CAMediaTimingFunction functionWithName:timingdArray[timingFunc]];
    
    [self.layer addAnimation:transitin forKey:nil];
    
}
/**
 UIModalTransitionStylePartialCurl//卷页
 UIModalTransitionStyleCoverVertical //垂直覆盖（从下往上）
 UIModalTransitionStyleFlipHorizontal//前后翻转
 UIModalTransitionStyleCrossDissolve//交叉溶解（没有过度动画）
 svc:UIViewController
 svc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
 */

@end
