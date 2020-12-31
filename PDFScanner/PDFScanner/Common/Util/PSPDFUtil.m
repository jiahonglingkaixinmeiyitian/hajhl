//
//  PSPDFUtil.m
//  PDFScanner
//
//  Created by Lucy Benson on 2020/4/24.
//  Copyright © 2020 cdants. All rights reserved.
//

#import "PSPDFUtil.h"
#import "AppDelegate.h"

@implementation PSPDFUtil

+ (NSData *)generatePDFDataWithImageDatas:(NSArray *)imageDatas {
    
    // CGRectZero 表示默认尺寸，参数可修改，设置自己需要的尺寸
    NSMutableData *data = [NSMutableData data];
    UIGraphicsBeginPDFContextToData(data, CGRectZero, NULL);

    CGRect  pdfBounds = UIGraphicsGetPDFContextBounds();
    CGFloat pdfWidth  = pdfBounds.size.width;
    CGFloat pdfHeight = pdfBounds.size.height;
    
    NSMutableArray *images = @[].mutableCopy;
    for (NSData *data in imageDatas) {
        [images addObject:[UIImage imageWithData:data]];
    }

    [images enumerateObjectsUsingBlock:^(UIImage * _Nonnull image, NSUInteger idx, BOOL * _Nonnull stop) {
       // 绘制PDF
       UIGraphicsBeginPDFPage();
       
       CGFloat imageW = image.size.width;
       CGFloat imageH = image.size.height;
       
       if (imageW <= pdfWidth && imageH <= pdfHeight)
       {
           CGFloat originX = (pdfWidth - imageW) / 2;
           CGFloat originY = (pdfHeight - imageH) / 2;
           [image drawInRect:CGRectMake(originX, originY, imageW, imageH)];
       }
       else
       {
           CGFloat width,height;

           if ((imageW / imageH) > (pdfWidth / pdfHeight))
           {
               width  = pdfWidth;
               height = width * imageH / imageW;
           }
           else
           {
               height = pdfHeight;
               width = height * imageW / imageH;
           }
           [image drawInRect:CGRectMake((pdfWidth - width) / 2, (pdfHeight - height) / 2, width, height)];
       }
    }];

    UIGraphicsEndPDFContext();

    return data;
}

@end
