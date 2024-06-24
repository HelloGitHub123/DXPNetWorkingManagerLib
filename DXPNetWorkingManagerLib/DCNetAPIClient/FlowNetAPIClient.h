//
//  FlowNetAPIClient.h.h
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
    KGet = 0,
    KPost,
    KPostImg,
    KPut,
    KDelete
} KNetworkMethod;

@interface FlowNetAPIClient : NSObject

@property (nonatomic, strong) AFHTTPSessionManager * httpManager;

+ (FlowNetAPIClient *)sharedClient;

@property (nonatomic, copy) NSString * baseUrl;

@property (nonatomic, copy) NSString * token;

@property (nonatomic, copy) NSString * dcMD5SerectStr;

// 返回token
@property (nonatomic, copy) void (^respTokenBlock)(NSString *token);

// HTTP 状态码回调处理 401 304 502 504 593
@property (nonatomic, copy) void (^respHTTPCodeBlock)(NSInteger statusCode);


- (void)requestJsonDataWithPath:(NSString *)aPath
                     withParams:(NSDictionary*)params
                 withMethodType:(KNetworkMethod)method
                        elementPath:(NSString *)elementPath
                       andBlock:(void (^)(id data, NSError *error))block;

- (void)requestJsonDataWithPath:(NSString *)aPath
                     withParams:(NSDictionary*)params
                 withMethodType:(KNetworkMethod)method
                        elementPath:(NSString *)elementPath
                  autoShowError:(BOOL)autoShowError
                       andBlock:(void (^)(id data, NSError *error))block;

+ (void)destroySharedClient;

+ (void)userAddRequestHeader:(NSString *)headerStr forHeadFieldName:(NSString *)headerFieldName;

- (void)GET:(NSString *)url paramaters:(NSDictionary *)paramaters CompleteBlock:(CompleteBlock)completeBlock;

- (void)GET:(NSString *)url CompleteBlock:(CompleteBlock)completeBlock;

- (void)POST:(NSString *)url paramaters:(NSDictionary *)paramaters CompleteBlock:(CompleteBlock)completeBlock;

@end
