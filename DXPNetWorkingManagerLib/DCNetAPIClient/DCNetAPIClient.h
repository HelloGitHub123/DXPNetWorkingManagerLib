//
//  DMNetAPIClint.h
//  DataMall
//
//  Created by 刘伯洋 on 16/1/4.
//  Copyright © 2016年 刘伯洋. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>
#import "SecurityUtil_Net.h"

typedef void(^SuccessBlock)(id res);
typedef void(^FailureBlock)(NSError *error);
typedef void(^CompleteBlock)(id res, NSError *error);

typedef enum {
    Get = 0,
    Post,
    PostImg,
    Put,
    Delete
} DCNetworkMethod;

@interface DCNetAPIClient : NSObject
@property (nonatomic, strong) AFHTTPSessionManager * httpManager;

@property (nonatomic, copy) NSString * baseUrl;

@property (nonatomic, copy) NSString * token;

@property (nonatomic, copy) NSString * dcMD5SerectStr;

// 返回token
@property (nonatomic, copy) void (^respTokenBlock)(NSString *token);

// HTTP 状态码回调处理 401 304 502 504 593
@property (nonatomic, copy) void (^respHTTPCodeBlock)(NSInteger statusCode);

+ (DCNetAPIClient *)sharedClient;
+ (DCNetAPIClient *)sharedMockClient;
+ (DCNetAPIClient *)sharedUcClient;

- (void)requestJsonDataWithPath:(NSString *)aPath
                     withParams:(NSDictionary*)params
                 withMethodType:(DCNetworkMethod)method
                        elementPath:(NSString *)elementPath
                       andBlock:(void (^)(id data, NSError *error))block;
- (void)requestJsonDataWithPath:(NSString *)aPath
                     withParams:(NSDictionary*)params
                 withMethodType:(DCNetworkMethod)method
                        elementPath:(NSString *)elementPath
                  autoShowError:(BOOL)autoShowError
                       andBlock:(void (^)(id data, NSError *error))block;

- (void)uploadImgWithPath:(NSString *)aPath
                     withImg:(UIImage*)image
                 withMethodType:(DCNetworkMethod)method
                        elementPath:(NSString *)elementPath
                  autoShowError:(BOOL)autoShowError
                       andBlock:(void (^)(id data, NSError *error))block;
+ (void)destroySharedClient;

+ (void)userAddRequestHeader:(NSString *)headerStr forHeadFieldName:(NSString *)headerFieldName;

- (void)GET:(NSString *)url paramaters:(NSDictionary *)paramaters CompleteBlock:(CompleteBlock)completeBlock;

- (void)GET:(NSString *)url CompleteBlock:(CompleteBlock)completeBlock;

- (void)POST:(NSString *)url paramaters:(NSDictionary *)paramaters CompleteBlock:(CompleteBlock)completeBlock;

- (void)POST:(NSString *)url image:(UIImage *)img CompleteBlock:(CompleteBlock)completeBlock;
///上传文件
- (void)upload:(NSString *)url data:(NSData *)data name:(NSString *)name fileName:(NSString *)fileName CompleteBlock:(CompleteBlock)completeBlock;
///下载文件
/**
 * method  取 POST或GET
 */
- (void)downloadFile:(NSString *)urlStr method:(NSString *)method paramaters:(NSDictionary *)paramaters CompleteBlock:(CompleteBlock)completeBlock;


@end
