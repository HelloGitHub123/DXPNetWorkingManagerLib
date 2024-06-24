//
//  HJMBProgressHUD+Category.m
//  MPTCLPMall
//
//  Created by OO on 2020/9/23.
//  Copyright © 2020 OO. All rights reserved.
//

#import "HJMBProgressHUD+Category.h"
#import <SDWebImage/SDWebImage.h>
#import "HJLoadingView.h"

@implementation HJMBProgressHUD (Category)

+ (instancetype)showLoading {
    
    NSString *appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
    if ([appName isEqualToString:@"POST"]) {
        // TM
        NSString *path = [[NSBundle mainBundle] pathForResource:@"CLP_Loading" ofType:@"gif"];
        NSData *gifData = [NSData dataWithContentsOfFile:path];
        HJLoadingView *sdImageView = [[HJLoadingView alloc] init];
        sdImageView.image = [UIImage sd_imageWithGIFData:gifData];
        
        HJMBProgressHUD *hud = [HJMBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].delegate.window animated:YES];
        [[UIApplication sharedApplication].delegate.window bringSubviewToFront:hud];
        hud.mode = HJMBProgressHUDModeCustomView; // 自定义
        hud.removeFromSuperViewOnHide = YES;
        hud.margin = 7.0;
        hud.minSize = CGSizeMake(50, 50);
        hud.customView = sdImageView;
        hud.backgroundView.style = HJMBProgressHUDBackgroundStyleSolidColor;
        hud.bezelView.style = HJMBProgressHUDBackgroundStyleSolidColor;
        hud.bezelView.backgroundColor = [UIColor whiteColor];
        hud.backgroundView.backgroundColor = [UIColor clearColor];
        return hud;
    }
    
    HJMBProgressHUD *hud = [HJMBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].delegate.window animated:YES];
    return hud;
}

+ (BOOL)hideLoading {
    
    NSString *appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
    if ([appName isEqualToString:@"POST"]) {
        BOOL res = [HJMBProgressHUD hideHUDForView:[UIApplication sharedApplication].delegate.window animated:YES];
        return res;
    }
    
    BOOL res = [HJMBProgressHUD hideHUDForView:[UIApplication sharedApplication].delegate.window animated:YES];
    return res;
}

+ (instancetype)showLoadingWithText:(NSString *)text {
    HJMBProgressHUD *hud = [HJMBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].delegate.window animated:YES];
    hud.label.text = text;
    return hud;
}

+ (instancetype)showText:(NSString *)text {
    
    HJMBProgressHUD *hud = [HJMBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].delegate.window animated:YES];

    // Set the text mode to show only text.
    hud.mode = HJMBProgressHUDModeText;
    hud.label.text = text;//NSLocalizedString(@"Message here!", @"HUD message title");
    hud.label.numberOfLines = 0;
    // Move to bottm center.
    hud.offset = CGPointMake(0.f, HJMBProgressMaxOffset);
    hud.label.textColor = [UIColor whiteColor];
    [hud hideAnimated:YES afterDelay:2.f];
    return hud;
}

@end
