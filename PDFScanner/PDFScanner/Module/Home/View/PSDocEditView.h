//
//  PSDocEditView.h
//  PDFScanner
//
//  Created by Lucy Benson on 2020/5/9.
//  Copyright © 2020 cdants. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PSDocEditView;

@protocol PSDocEditViewDelegate <NSObject>

- (void)clickShareButtonWithEditView:(PSDocEditView *)editView;
- (void)clickMoveButtonWithEditView:(PSDocEditView *)editView;
- (void)clickDeleteButtonWithEditView:(PSDocEditView *)editView;

@end

@interface PSDocEditView : UIView

@property (nonatomic, weak) id<PSDocEditViewDelegate> delegate;

- (void)operationSelection:(BOOL)selectable;

@end

