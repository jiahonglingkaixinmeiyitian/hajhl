//
//  PSPDFUtil.h
//  PDFScanner
//
//  Created by Lucy Benson on 2020/4/24.
//  Copyright © 2020 cdants. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PSPDFUtil : NSObject

+ (NSData *)generatePDFDataWithImageDatas:(NSArray *)imageDatas;

@end

