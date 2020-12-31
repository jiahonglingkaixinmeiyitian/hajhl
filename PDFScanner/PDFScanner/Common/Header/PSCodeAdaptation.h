//
//  PSCodeAdaptation.h
//  PDFScanner
//
//  Created by heartjhl on 2020/5/29.
//  Copyright © 2020 cdants. All rights reserved.
//

#ifndef PSCodeAdaptation_h
#define PSCodeAdaptation_h

#import "AppDelegate.h"
#import "PSCurrentViewController.h"

CG_INLINE CGRect
CGRectMakeAdapter(CGFloat x, CGFloat y, CGFloat width, CGFloat height)
{
    AppDelegate *myDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    CGRect rect;
    rect.origin.x = x * myDelegate.autoSizeScaleX;
    rect.origin.y = y * myDelegate.autoSizeScaleY;
    rect.size.width = width * myDelegate.autoSizeScaleX;
    rect.size.height = height * myDelegate.autoSizeScaleY;
    return rect;
}
CG_INLINE float
FLoatChange(CGFloat size)
{
    CGFloat newS;
    AppDelegate *myDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    newS = (size *myDelegate.autoSizeScaleX)*(isHandlePad?padScale:1);
    return newS;
}

CG_INLINE float
YFLoatChange(CGFloat size)
{
    CGFloat newS;
    AppDelegate *myDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    newS = size *myDelegate.autoSizeScaleY;
    return newS;
}

CG_INLINE float
YNFLoatChange(CGFloat size)
{
    CGFloat newS;
    AppDelegate *myDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    newS = size *myDelegate.autoSizeScaleYN;
    return newS;
}

CG_INLINE float
YTFLoatChange(CGFloat size)
{
    CGFloat newS;
    AppDelegate *myDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    newS = size *myDelegate.autoSizeScaleYT;
    return newS;
}


/**
 没有nav、没有tabBar
 */
CG_INLINE float
YNONTFLoatChange(CGFloat size)
{
    CGFloat newS;
    AppDelegate *myDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    newS = (size *myDelegate.autoSizeScaleYNONT)*(isHandlePad?padScale:1);
    return newS;
}

#endif /* PSCodeAdaptation_h */
