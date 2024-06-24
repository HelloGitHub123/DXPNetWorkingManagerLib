//
//  HJSecurityUtil.m
//  aes256test
//
//  Created by mac on 2021/11/4.
//

#import "HJSecurityUtil.h"
#import <CommonCrypto/CommonCrypto.h>
#import <CommonCrypto/CommonDigest.h>

static NSString *const PSW_AES_KEY = @"3965346538613263323139636464396163396261623961626339616237393332";
//static NSString *const AES_IV_PARAMETER = @"11111111111111111111111111111111";
//随机生成长度为32的16进制字符串。IV称为初始向量，不同的IV加密后的字符串是不同的，加密和解密需要相同的IV。

@implementation HJSecurityUtil
//加密
+ (NSData *)encryptAES:(NSString *)content key:(NSString *)key iv:(NSString *)iv {
    NSData *contentData = [content dataUsingEncoding:NSUTF8StringEncoding];
    NSUInteger dataLength = contentData.length;
    size_t encryptSize = dataLength + kCCBlockSizeAES128;
    void *encryptedBytes = malloc(encryptSize);
    size_t actualOutSize = 0;
    NSData *initVector = convertHexStrToData(iv); //16位偏移，CBC模式才有
    NSData *keyData = convertHexStrToData(key);
    CCCryptorStatus cryptStatus = CCCrypt(
    kCCEncrypt,//kCCEncrypt 代表加密 kCCDecrypt代表解密
    kCCAlgorithmAES,//加密算法
    kCCOptionPKCS7Padding,  // PKCS7Padding
    keyData.bytes,//公钥
    kCCKeySizeAES256,//密钥长度256
    initVector.bytes,//偏移字符串
    contentData.bytes,//编码内容
    dataLength,//数据长度
    encryptedBytes,//加密输出缓冲区
    encryptSize,//加密输出缓冲区大小
    &actualOutSize);//实际输出大小
    if (cryptStatus == kCCSuccess) {
        // 返回编码后的数据
        return [NSData dataWithBytesNoCopy:encryptedBytes length:actualOutSize];
    }
    free(encryptedBytes);
    return nil;
}

// 解密
+ (NSData *)decryptAESWithData:(NSData *)data key:(NSString *)key iv:(NSString *)iv {
    NSUInteger dataLength = [data length];
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    size_t numBytesDecrypted = 0;
    NSData *initVector =  convertHexStrToData(iv);  //16位偏移，CBC模式才有
    NSData *keyData = convertHexStrToData(key);
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt, kCCAlgorithmAES, kCCOptionPKCS7Padding, keyData.bytes, kCCKeySizeAES256, initVector.bytes, [data bytes], dataLength, buffer, bufferSize, &numBytesDecrypted);

    if(cryptStatus == kCCSuccess) {
        return [NSData dataWithBytesNoCopy:buffer length:numBytesDecrypted];
    }

    free(buffer);
    return nil;
}

NSData *convertHexStrToData(NSString *str) {
    if (!str || [str length] == 0) {
        return nil;
    }
    
    NSMutableData *hexData = [[NSMutableData alloc] initWithCapacity:20];
    NSRange range;
    if ([str length] % 2 == 0) {
        range = NSMakeRange(0, 2);
    } else {
        range = NSMakeRange(0, 1);
    }
    for (NSInteger i = range.location; i < [str length]; i += 2) {
        unsigned int anInt;
        NSString *hexCharStr = [str substringWithRange:range];
        NSScanner *scanner = [[NSScanner alloc] initWithString:hexCharStr];
        
        [scanner scanHexInt:&anInt];
        NSData *entity = [[NSData alloc] initWithBytes:&anInt length:1];
        [hexData appendData:entity];
        
        range.location += range.length;
        range.length = 2;
    }
    return hexData;
}

+ (NSString *)encrypt:(NSString *)content {
    if ([content isKindOfClass:[NSString class]]&&content.length>0) {
        NSString *hexStr = [self ret32bitString];
        NSData *initVector =  convertHexStrToData(hexStr);  //16位偏移，CBC模式才有
        NSString *stringBase64 = [initVector base64EncodedStringWithOptions:0]; // base64格式的字符串
        return [NSString stringWithFormat:@"%@&&&&%@",[[self encryptAES:content key:PSW_AES_KEY iv:hexStr] base64EncodedStringWithOptions:0],stringBase64];
    }
    return @"";
}


+ (NSString *)ret32bitString {
    NSString *hexString = @"0123456789ABCDEF";
    NSString *string = @"";
    for (int i = 0; i < 32; i++) {
        NSString *tempString = [hexString substringWithRange:NSMakeRange(arc4random() % 16, 1)];
        string = [string stringByAppendingString:tempString];
    }
    return string;
}

//+ (NSString *)decrypt:(NSString *)content
//{
//    NSData *data = [[NSData alloc]initWithBase64EncodedString:content options:NSDataBase64DecodingIgnoreUnknownCharacters];
//    return [[self decryptAESWithData:data key:PSW_AES_KEY iv:AES_IV_PARAMETER] base64EncodedStringWithOptions:0];
//}
@end
