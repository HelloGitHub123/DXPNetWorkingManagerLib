//
//  HJSecurityUtil.h
//  aes256test
//
//  Created by mac on 2021/11/4.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HJSecurityUtil : NSObject

+ (NSData *)encryptAES:(NSString *)content key:(NSString *)key iv:(NSString *)iv;

+ (NSData *)decryptAESWithData:(NSData *)data key:(NSString *)key iv:(NSString *)iv;

+ (NSString *)encrypt:(NSString *)content;

@end

NS_ASSUME_NONNULL_END
