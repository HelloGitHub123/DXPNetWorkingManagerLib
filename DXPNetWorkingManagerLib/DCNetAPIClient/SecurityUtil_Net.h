//
//  SecurityUtil.h
//  Test
//
//  Created by 刘伯洋 on 16/2/20.
//  Copyright © 2016年 刘伯洋. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>
#import <CommonCrypto/CommonHMAC.h>

@interface SecurityUtil_Net : NSObject

+ (NSString *)dESEncrypt:(NSString *)str ;
+ (NSString *)doCipher:(NSString *)sTextIn key:(NSMutableData *)dKey iv:dIv context:(CCOperation)encryptOrDecrypt;
+ (NSString *) generateHmacSHA256Signature:(NSString *)sTextIn key:(NSString *)key;
@end
