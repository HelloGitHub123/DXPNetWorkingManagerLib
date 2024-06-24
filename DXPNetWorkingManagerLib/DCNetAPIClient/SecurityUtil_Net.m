//
//  SecurityUtil.m
//  Test
//
//  Created by 刘伯洋 on 16/2/20.
//  Copyright © 2016年 刘伯洋. All rights reserved.
//

#import "SecurityUtil_Net.h"

@implementation SecurityUtil_Net

+ (NSString *)dESEncrypt:(NSString *)str {
    //iv
    NSMutableData * dIv = [[NSMutableData alloc] initWithBase64EncodedString:@"uK1EBgjPTr0=" options:NSDataBase64DecodingIgnoreUnknownCharacters];
    //key
    NSMutableData * dKey = [[NSMutableData alloc] initWithBase64EncodedString:@"SivnBF2z0IY=" options:NSDataBase64DecodingIgnoreUnknownCharacters];
    [dKey setLength:kCCBlockSizeDES];

    return [SecurityUtil_Net doCipher:str key:dKey iv:dIv context:kCCEncrypt];
}

+ (NSString *)doCipher:(NSString *)sTextIn key:(NSMutableData *)dKey iv:dIv context:(CCOperation)encryptOrDecrypt {
    NSStringEncoding EnC = NSUTF8StringEncoding;
    NSMutableData * dTextIn;
    if (encryptOrDecrypt == kCCDecrypt) {
        NSData* data = [sTextIn dataUsingEncoding:NSUTF8StringEncoding];
        dTextIn =  [[data base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed] mutableCopy];
    }
    else{
        dTextIn = [[sTextIn dataUsingEncoding: EnC] mutableCopy];
    }
    uint8_t *bufferPtr1 = NULL;
    size_t bufferPtrSize1 = 0;
    size_t movedBytes1 = 0;
    bufferPtrSize1 = ([sTextIn length] + kCCKeySizeDES) & ~(kCCKeySizeDES -1);
    bufferPtr1 = malloc(bufferPtrSize1 * sizeof(uint8_t));
    memset((void *)bufferPtr1, 0x00, bufferPtrSize1);
    CCCrypt(encryptOrDecrypt, // CCOperation op
            kCCAlgorithmDES, // CCAlgorithm alg
            kCCOptionPKCS7Padding, // CCOptions options
            [dKey bytes], // const void *key
            [dKey length], // size_t keyLength
            [dIv bytes], // const void *iv
            [dTextIn bytes], // const void *dataIn
            [dTextIn length],  // size_t dataInLength
            (void *)bufferPtr1, // void *dataOut
            bufferPtrSize1,     // size_t dataOutAvailable
            &movedBytes1);      // size_t *dataOutMoved
    NSString * sResult;
    if (encryptOrDecrypt == kCCDecrypt){
        sResult = [[NSString alloc] initWithData:[NSData dataWithBytes:bufferPtr1
                                                                length:movedBytes1] encoding:EnC];
    }
    else {
        NSData *dResult = [NSData dataWithBytes:bufferPtr1 length:movedBytes1];
        sResult =  [dResult base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    }
    return sResult;
}

+ (NSString *) generateHmacSHA256Signature:(NSString *)sTextIn key:(NSString *)key {
    NSData *keyData = [key dataUsingEncoding:NSUTF8StringEncoding];
    NSData *textInData = [sTextIn dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableData* hash = [NSMutableData dataWithLength:CC_SHA256_DIGEST_LENGTH ];
    CCHmac(kCCHmacAlgSHA256, keyData.bytes, keyData.length, textInData.bytes, textInData.length, hash.mutableBytes);
    NSString *base64Hash = [hash base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    return base64Hash;
}
@end

