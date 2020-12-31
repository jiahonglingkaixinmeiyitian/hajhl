//
//  PSDocHeaderView.h
//  PDFScanner
//
//  Created by Lucy Benson on 2020/5/9.
//  Copyright © 2020 cdants. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^ChangeDocNameBlock)(void);

@interface PSDocHeaderView : UICollectionReusableView

@property (nonatomic, copy) ChangeDocNameBlock changeNameBlock;

- (void)updateDocName:(NSString *)name count:(NSInteger)count;

@end

