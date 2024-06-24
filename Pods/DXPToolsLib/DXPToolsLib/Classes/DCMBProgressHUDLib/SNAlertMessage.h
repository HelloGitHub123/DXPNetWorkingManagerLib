//
//  SNAlertMessage.h
//
//
//  Created by libiao on 6/9/14.
//  Copyright (c) 2014 libiao. All rights reserved.
//  tost以及加载框的封装

#import <Foundation/Foundation.h>
#import "HJMBProgressHUD.h"

@interface SNAlertMessage : NSObject<HJMBProgressHUDDelegate>
@property (nonatomic, retain) HJMBProgressHUD *hud;
@property (nonatomic, retain) UIView *snView;
//提示框队列
@property (nonatomic, assign) BOOL isShowMessage;
@property (nonatomic, retain) NSMutableArray *messageStack;

+ (SNAlertMessage *)sharedInstance;

+ (void)displayMessageInView:(UIView *)tmpView Message:(NSString *)message;

/**菊花加载框*/
+ (void)displayLoadingInViewInView:(UIView *)tmpView Message:(NSString *)message;

/**Toast 固定时间后消失**/
+ (void)displayMessageInView:(UIView *)tmpView Message:(NSString *)message afterDelay:(CGFloat)time;

/**隐藏加载框*/
+ (void)hideLoading;

@end
