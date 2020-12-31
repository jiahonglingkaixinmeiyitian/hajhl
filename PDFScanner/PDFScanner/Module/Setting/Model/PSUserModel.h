//
//  PSUserModel.h
//  PDFScanner
//
//  Created by heartjhl on 2020/5/27.
//  Copyright © 2020 cdants. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PSUserModel : NSObject<NSSecureCoding>
@property (nonatomic, assign) BOOL is_vip;
/** 本地语言是否为英语 */
@property (nonatomic,assign,readonly) BOOL languageEn;
/** App 版本 */
@property (nonatomic,copy) NSString *appVersion;
/** 是否在巴西 */
@property (nonatomic,assign) BOOL isInBr;
/** 是否在美国 */
@property (nonatomic,assign) BOOL isInUs;
/**  */
@property (nonatomic,copy) NSString *productId;
@end

NS_ASSUME_NONNULL_END
