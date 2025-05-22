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

@property (nonatomic, assign) BOOL useMptSignCode;

@property (nonatomic, copy) NSString * clientKey;

@property (nonatomic, copy) NSString * curTime;

@property (nonatomic, assign) BOOL isAddNewDXPHeader; // 是否支持新的DXP接口请求头

@property (nonatomic, copy) NSString *authorizationStr; // 3层架构authorization
@property (nonatomic, assign) BOOL openOauthToken; // 3层架构开关。YES:开  NO:关 默认关

// 返回token
@property (nonatomic, copy) void (^respTokenBlock)(NSString *token);

// HTTP 状态码回调处理 401 304 502 504 593
@property (nonatomic, copy) void (^respHTTPCodeBlock)(NSInteger statusCode,NSError *error);

/// eg: 埋点
/// @return trackName: 埋点名称
/// @return responses：响应报文
/// @return inputParamDic  输入参数
/// @return event_duration  接口响应时长
/// @return isSuccess  业务是否成功
/// @return errorCode  失败错误码
/// @return failReason  失败原因
@property (nonatomic, copy) void (^respTrackBlock)(NSString *trackName, NSHTTPURLResponse *responses, NSMutableDictionary *inputParamDic, NSString *event_duration, NSNumber *isSuccess ,NSString *errorCode, NSString *failReason);

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


/// eg: 文件下载
/// @param downLoadURL  下载链接
/// @param method  方式 Post 、Get
/// @param paramaters  参数
/// @param downloadName  下载目标目录名称
/// @param fileName 文件名称
/// @param completeBlock  回调
- (void)downloadFile:(NSString *)downLoadURL method:(NSString *)method paramaters:(NSDictionary *)paramaters downloadName:(NSString *)downloadName fileName:(NSString *)fileName CompleteBlock:(CompleteBlock)completeBlock;

@end
