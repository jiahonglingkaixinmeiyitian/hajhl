//
//  PSBottomFilterDrawer.h
//  PDFScanner
//
//  Created by Lucy Benson on 2020/5/15.
//  Copyright © 2020 cdants. All rights reserved.
//

#import "PSBottomDrawer.h"

typedef void(^DidPickListItemBlock)(NSInteger itemIndex);

@interface PSBottomFilterDrawer : PSBottomDrawer

@property (nonatomic, copy) DidPickListItemBlock pickListItemBlock;

@end

