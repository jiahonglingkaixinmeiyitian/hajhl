//
//  UIView+RoundedCorner.h
//  PDFScanner
//
//  Created by Lucy Benson on 2020/5/7.
//  Copyright © 2020 cdants. All rights reserved.
//

#import <UIKit/UIKit.h>

///动画效果
typedef  enum{
    TransitonAnimationCameraIrisOpen,//摄像机打开
    TransitonAnimationCameraIrisClose,//摄像机关闭
    TransitonAnimationCube,//立方体
    TransitonAnimationPageCurl,//从左下角开始卷页
    TransitonAnimationPageUnCurl,//与TransitonAnimationPageCurl相反
    TransitonAnimationRippleEffect,//波纹效应
    TransitonAnimationSuckEffect,//吸吮效应，像一块布被抽走
    TransitonAnimationOglFlip,//前后翻转
    TransitonAnimationFade,//颜色由浅入深，淡淡出现
    TransitonAnimationMoveIn,//新view由浅入深，淡入
    TransitonAnimationPush,//新view推入旧view推出
    TransitonAnimationReveal,//旧View颜色由深入浅，淡出
    
}TransitonAnimation;

///动画的方向
typedef enum {
    TansitionAnimationTowardTypeFromLeft,
    TansitionAnimationTowardTypeFromRight,
    TansitionAnimationTowardTypeFromTop,
    TansitionAnimationTowardTypeFromBottom
    
}TansitionAnimationTowardType;

///动画的速度变化
typedef NS_ENUM(NSUInteger, TransitonAnimTimingFunc) {
    TransitonAnimTimingFuncLinear,//线性
    TransitonAnimTimingFuncEaseIn,//慢入
    TransitonAnimTimingFuncEaseOut,//慢出
    TransitonAnimTimingFuncEaseInEaseOut//慢入慢出
};
@interface UIView (RoundedCorner)

- (void)ps_roundCorners:(UIRectCorner)corners radius:(CGFloat)radius;

- (void)ps_applyGradientColors:(NSArray *)colors;

///设置转场动画
-(void)setTrasitonAnimation:(TransitonAnimation)type duration:(NSTimeInterval)duration towardType:(TansitionAnimationTowardType)towardType timingFunc:(TransitonAnimTimingFunc)timingFunc;

@end

