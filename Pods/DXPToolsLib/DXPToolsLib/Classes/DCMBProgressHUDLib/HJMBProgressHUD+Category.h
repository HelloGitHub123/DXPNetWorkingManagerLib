//
//  HJMBProgressHUD+Category.h
//  MPTCLPMall
//
//  Created by 张威 on 2020/9/23.
//  Copyright © 2020 OO. All rights reserved.
//

#import "HJMBProgressHUD.h"

NS_ASSUME_NONNULL_BEGIN

@interface HJMBProgressHUD (Category)

/// 展示菊花在window上
+ (instancetype)showLoading;
/// 隐藏window上的菊花
+ (void)hideLoading;
/// 展示菊花和文字在window上
/// @param text text
+ (instancetype)showLoadingWithText:(NSString *)text;
/// 只展示文字在window上
/// @param text text
+ (instancetype)showText:(NSString *)text;

@end

NS_ASSUME_NONNULL_END
