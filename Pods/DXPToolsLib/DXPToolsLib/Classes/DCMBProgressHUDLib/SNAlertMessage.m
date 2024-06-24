//
//  SNAlertMessage.m
//
//
//  Created by libiao on 6/9/14.
//  Copyright (c) 2014 libiao. All rights reserved.
//

#import "SNAlertMessage.h"
#import "HJMBProgressHUD.h"
#import <SDWebImage/SDWebImage.h>
#import "HJLoadingView.h"

@interface SNAlertMessage ()

@property (nonatomic, assign) CGFloat afterDelayTime;
@end

@implementation SNAlertMessage
@synthesize messageStack = _messageStack;

+ (SNAlertMessage *)sharedInstance {
    static SNAlertMessage *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(& onceToken,^{
        sharedInstance = [[self alloc]init];
    });
    return sharedInstance;
}

- (id)init {
    self = [super init];
    if (self) {
        _messageStack=[[NSMutableArray alloc] init];
        _isShowMessage=NO;
    }
    return self;
}

+ (void)displayMessageInView:(UIView *)tmpView Message:(NSString *)message afterDelay:(CGFloat)time {
    
    [SNAlertMessage sharedInstance].afterDelayTime = time;
    
    [self displayMessageInView:(UIView *)tmpView Message:message];
}

//弹出框
+ (void)displayMessageInView:(UIView *)tmpView Message:(NSString *)message {
    [SNAlertMessage sharedInstance].snView = tmpView;
    if ([SNAlertMessage sharedInstance].isShowMessage) {
        [[SNAlertMessage sharedInstance] hideAlertMessage];
    }
    if(message==nil||[message isEqualToString:@""]) {
        return;
    }
    if ([[SNAlertMessage sharedInstance].messageStack count]>0) {
        [[SNAlertMessage sharedInstance].messageStack removeAllObjects];
    }
    [[SNAlertMessage sharedInstance].messageStack addObject:message];
    
    if(![SNAlertMessage sharedInstance].isShowMessage) {
        [[SNAlertMessage sharedInstance] showAlertMessage];
    }
}

- (void)showAlertMessage {
    if([_messageStack count]<=0) {
        return;
    }
    _isShowMessage=YES;
    //自定义view
    self.hud = [HJMBProgressHUD showHUDAddedTo:[SNAlertMessage sharedInstance].snView animated:YES];
    // Set custom view mode
    self.hud.mode = HJMBProgressHUDModeCustomView;
    self.hud.delegate = self;
//    self.hud.labelText = [_messageStack firstObject];
    self.hud.label.text = [_messageStack firstObject];
    self.hud.label.numberOfLines = 0;
    self.hud.label.textColor = [UIColor whiteColor];
    
//    [self.hud show:YES];
    [self.hud showAnimated:YES];
//    [self.hud hide:YES afterDelay:1.5];
    if ([SNAlertMessage sharedInstance].afterDelayTime > 0) {
        [self.hud hideAnimated:YES afterDelay: [SNAlertMessage sharedInstance].afterDelayTime];
        [SNAlertMessage sharedInstance].afterDelayTime = 0;
    } else {
        [self.hud hideAnimated:YES afterDelay:3];
    }
}

- (void)hideAlertMessage {
    [self.hud hideAnimated:YES];
    _isShowMessage=NO;
    [self performSelector:@selector(showAlertMessage) withObject:nil afterDelay:0.2f];
}

//加载效果
+ (void)displayLoadingInViewInView:(UIView *)tmpView Message:(NSString *)message {
    
    [SNAlertMessage sharedInstance].snView = tmpView;
    
    NSString *appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
    if ([appName isEqualToString:@"POST"]) {
        // TM
        NSString *path = [[NSBundle mainBundle] pathForResource:@"CLP_Loading" ofType:@"gif"];
        NSData *gifData = [NSData dataWithContentsOfFile:path];
        HJLoadingView *sdImageView = [[HJLoadingView alloc] init];
        sdImageView.image = [UIImage sd_imageWithGIFData:gifData];

        HJMBProgressHUD *hud = [HJMBProgressHUD showHUDAddedTo:[SNAlertMessage sharedInstance].snView animated:YES];
        if (message && ![message isEqualToString:@""]) {
            hud.label.text = message;
            hud.label.textAlignment = NSTextAlignmentLeft;
        }
        [[SNAlertMessage sharedInstance].snView bringSubviewToFront:hud];
        hud.mode = HJMBProgressHUDModeCustomView; // 自定义
        hud.removeFromSuperViewOnHide = YES;
        hud.margin = 7.0;
        hud.minSize = CGSizeMake(50, 50);
        hud.customView = sdImageView;
        hud.backgroundView.style = HJMBProgressHUDBackgroundStyleSolidColor;
        hud.bezelView.style = HJMBProgressHUDBackgroundStyleSolidColor;
        hud.bezelView.backgroundColor = [UIColor whiteColor];
        hud.backgroundView.backgroundColor = [UIColor clearColor];
        
    } else {
        
        [SNAlertMessage sharedInstance].snView = tmpView;
        [[SNAlertMessage sharedInstance].hud hideAnimated:YES];
        [SNAlertMessage sharedInstance].hud = [[HJMBProgressHUD alloc] initWithView:[SNAlertMessage sharedInstance].snView];
        HJMBProgressHUD *hud=[SNAlertMessage sharedInstance].hud;
        [[SNAlertMessage sharedInstance].snView addSubview:hud];
        
        hud.removeFromSuperViewOnHide=YES;
        hud.mode=HJMBProgressHUDModeIndeterminate;
        hud.delegate = [SNAlertMessage sharedInstance];
        hud.margin = 30.f;
        //    hud. = 0.0f;
        hud.removeFromSuperViewOnHide = YES;
        hud.label.text = message;
        [[SNAlertMessage sharedInstance].snView bringSubviewToFront:hud];
        [hud showAnimated:YES];
    }
}

+ (void)hideLoading {
    NSString *appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
    if ([appName isEqualToString:@"POST"]) {
        [HJMBProgressHUD hideHUDForView:[SNAlertMessage sharedInstance].snView animated:YES];
    } else {
        [[SNAlertMessage sharedInstance].hud hideAnimated:YES];
    }
}

@end
