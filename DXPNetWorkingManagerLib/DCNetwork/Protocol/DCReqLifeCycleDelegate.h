//
//  DCReqLifeCycleDelegate.h
//  Base
//
//  Created by 胡灿 on 2025/11/19.
//

#import <Foundation/Foundation.h>

@class DCBaseReqApi;

NS_ASSUME_NONNULL_BEGIN

/// 请求回调协议：开始请求、请求成功、请求失败会调用
@protocol DCReqLifeCycleDelegate <NSObject>

@optional

/// 请求开始
/// - Parameter api: 发起请求的api
- (void)start:(DCBaseReqApi *)api;

@required

/// 请求成功
/// - Parameter api: 发起请求的api
- (void)success:(DCBaseReqApi *)api;

/// 请求失败
/// - Parameter api: 发起请求的api
- (void)fail:(DCBaseReqApi *)api;

@optional

/// 请求取消
/// - Parameter api: 发起请求的api
- (void)cancel:(DCBaseReqApi *)api;

@end

NS_ASSUME_NONNULL_END
