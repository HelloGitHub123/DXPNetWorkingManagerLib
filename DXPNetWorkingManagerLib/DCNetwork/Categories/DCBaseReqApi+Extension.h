//
//  DCBaseReqApi+Extension.h
//  Base
//
//  Created by 胡灿 on 2025/12/2.
//

#import "DCBaseReqApi.h"

NS_ASSUME_NONNULL_BEGIN

@interface DCBaseReqApi (Extension)

@end

@interface DCReqCoreManager (Extension)

#pragma mark - 接口调用成功之后的操作 不带`apiStore`的简洁用法

/// 接口调用成功之后的操作 朴素用法 不依赖api的`request:`和`bindDataCls:`以及`reqManager`的`apiStore`
@property (nonatomic, copy, readonly) DCReqCoreManager *(^apiBlk_successThen)(DCBaseReqApi *api, DCReqNextBlock next);

/// 接口调用成功之后的操作 较朴素用法 不依赖`reqManager`的`apiStore` 但依赖api的`request:`
@property (nonatomic, copy, readonly) DCReqCoreManager *(^apiCnf_successThen)(DCBaseReqApi *api, DCReqParasConfig config);

#pragma mark - 接口调用成功之后的操作 带`apiStore`的简洁用法

@property (nonatomic, copy, readonly) DCReqCoreManager *(^stApiTgCnf_successThen)(Class apiCls, NSString *tag, DCReqParasConfig config);

@property (nonatomic, copy, readonly) DCReqCoreManager *(^stApiBlk_successThen)(Class apiCls, DCReqNextBlock next);

@property (nonatomic, copy, readonly) DCReqCoreManager *(^stApiTgBlk_successThen)(Class apiCls, NSString *tag, DCReqNextBlock next);

/// 接口调用成功之后的操作 无参调用
@property (nonatomic, copy, readonly) DCReqCoreManager *(^stApi_successThen)(Class apiCls);

#pragma mark - 接口调用失败之后的操作 不带`apiStore`的简洁用法

/// 接口调用失败之后的操作 朴素用法 不依赖api的`request:`和`bindDataCls:`以及`reqManager`的`apiStore`
@property (nonatomic, copy, readonly) DCReqCoreManager *(^apiBlk_failThen)(DCBaseReqApi *api, DCReqNextBlock next);

/// 接口调用失败之后的操作 较朴素用法 不依赖`reqManager`的`apiStore` 但依赖api的`request:`
@property (nonatomic, copy, readonly) DCReqCoreManager *(^apiCnf_failThen)(DCBaseReqApi *api, DCReqParasConfig config);

#pragma mark - 接口调用失败之后的操作 带`apiStore`的简洁用法

@property (nonatomic, copy, readonly) DCReqCoreManager *(^stApiTgCnf_failThen)(Class apiCls, NSString *tag, DCReqParasConfig config);

/// 接口调用失败之后的操作 带`apiStore`的简洁用法
@property (nonatomic, copy, readonly) DCReqCoreManager *(^stApiBlk_failThen)(Class apiCls, DCReqNextBlock next);

@property (nonatomic, copy, readonly) DCReqCoreManager *(^stApiTgBlk_failThen)(Class apiCls, NSString *tag, DCReqNextBlock next);

/// 接口调用失败之后的操作 无参调用
@property (nonatomic, copy, readonly) DCReqCoreManager *(^stApi_failThen)(Class apiCls);

@end

@interface DCReqManager (Extension)

/// 请求链起始 朴素用法 不依赖api的`request:`和`bindDataCls:`以及`reqManager`的`apiStore`
@property (nonatomic, copy, readonly) DCReqCoreManager *(^apiBlk_sync)(DCBaseReqApi *api, DCReqNextBlock next);

/// 请求链起始 较朴素用法 不依赖api的`bindDataCls:`以及`reqManager`的`apiStore` 但依赖api的`request:`
@property (nonatomic, copy, readonly) DCReqCoreManager *(^apiParas_sync)(DCBaseReqApi *api, DCBaseReqParasModel *paras);

/// 请求链起始 带`apiStore`的简洁用法
@property (nonatomic, copy, readonly) DCReqCoreManager *(^stApiBlk_sync)(Class apiCls, DCReqNextBlock next);

@property (nonatomic, copy, readonly) DCReqCoreManager *(^stApiTgCnf_sync)(Class apiCls, NSString *tag, DCReqParasConfig config);

@property (nonatomic, copy, readonly) DCReqCoreManager *(^stApiTgBlk_sync)(Class apiCls, NSString *tag, DCReqNextBlock next);

/// 请求链起始 无参调用
@property (nonatomic, copy, readonly) DCReqCoreManager *(^stApi_sync)(Class apiCls);

/// 重定位到某个节点 继续设置请求链 带apiStore的简洁用法  不会创建api 会判断api是否在串行调用链中
@property (nonatomic, copy, readonly) DCReqCoreManager *(^stApiTg_prepare)(NSString *tag);

@property (nonatomic, copy, readonly) DCReqCoreManager *(^stApiTg_dynPrepare)(NSString *tag);

/// 简化api直接调用
@property (nonatomic, copy, readonly) void(^stApiTgCnf_request)(Class apiCls, NSString *tag, DCReqParasConfig config);

/// 无参调用
@property (nonatomic, copy, readonly) void(^stApi_request)(Class apiCls);

@end

NS_ASSUME_NONNULL_END
