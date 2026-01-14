//
//  DCBaseReqApi.h
//  Base
//
//  Created by 胡灿 on 2025/11/19.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import "DCBaseReqParasModel.h"
#import "DCReqApiDataClsBindModel.h"
#import "DCReqChainModel.h"
#import "DCReqApiStore.h"
#import "DCReqApiDelegate.h"
#import "DCReqLifeCycleDelegate.h"

@class DCReqPlaceholderApi;

typedef void(^DCReqDetailResData)(NSDictionary * _Nonnull resData, NSError * _Nonnull error);
typedef void(^DCReqVoidBlock)(void);

#define DCReqPlhApi DCBaseReqApi.placeholderApi
#define DCReqPlhApiCls DCReqPlaceholderApi.class

FOUNDATION_EXPORT NSString * _Nonnull const DCBaseReqApiResStatusCode;

NS_ASSUME_NONNULL_BEGIN

/// 发起网络请求的api
///
/// > Warning:
/// > **必须实现**
/// > 1. `res` 属性：与`bindDataCls:`方法中返回的`model.resModelCls`类型相同
/// > 2. `bindDataCls:` 方法：返回一个参数类型映射`model`
/// > 3. `request:` 方法：具体的请求调用
///
/// > Note:
/// > 1. 内部模型转字典、字典转模型采用`MJExtension`
/// > 2. 不准一个api同时多个请求，一个请求结束才可以下一个请求
/// > 3. 参数为空，请传一个`parasModel`，但是属性不要设置值
/// > 4. 一个接口一个api。主要是为了防止一个api多接口会出现同一个api同时多个接口调用产生的多线程问题，多接口修改api需要用锁，不好维护，占更多资源且不好调试
/// > 5. 请求周期的回调会有一个扩展回调方法，需要自己实现：`-(void)方法名(DCBaseReqApi *)api`，方法名取的是：`[self extendedLifeCycleFuncName:(self.storeTag)]+Start|Success|Fail|Cancel`，默认是self.storeTag（首字母小写）
@interface DCBaseReqApi : NSObject <DCReqApiDelegate>

/// 占位api 用于动态串行调用
@property (nonatomic, class, readonly) DCReqPlaceholderApi *placeholderApi;

/// 存储在`DCReqApiStore`中的tag
@property (nonatomic, copy, readonly) NSString *storeTag;

/// 请求周期代理
@property (nonatomic, weak) id<DCReqLifeCycleDelegate> delegate;

/// 字符串类名 可作为`DCReqApiStore`取api的key使用
@property (nonatomic, copy, class, readonly) NSString *className;

@property (nonatomic, copy, readonly) NSString *className;

/// POST 请求
/// - Parameters:
///   - url: 用于请求的url
///   - paras: 用于请求的参数
///   - detailResDataBlock: 用于处理请求到的数据的回调
- (void)POST:(NSString *)url paras:(DCBaseReqParasModel *)paras detailResDataBlock:(DCReqDetailResData)detailResDataBlock;

/// POST 请求
///
/// > 内部会根据`bindDataCls`方法返回的`model.resModelCls`来实现字典转模型
///
/// - Parameters:
///   - url: 用于请求的url
///   - paras: 用于请求的参数
- (void)POST:(NSString *)url paras:(DCBaseReqParasModel *)paras;

/// GET 请求
/// - Parameters:
///   - url: 用于请求的url
///   - paras: 用于请求的参数
///   - detailResDataBlock: 用于处理请求到的数据的回调
- (void)GET:(NSString *)url paras:(DCBaseReqParasModel *)paras detailResDataBlock:(DCReqDetailResData)detailResDataBlock;

/// GET 请求
///
/// > 内部会根据`bindDataCls`方法返回的`model.resModelCls`来实现字典转模型
///
/// - Parameters:
///   - url: 用于请求的url
///   - paras: 用于请求的参数
- (void)GET:(NSString *)url paras:(DCBaseReqParasModel *)paras;

/// PUT 请求
/// - Parameters:
///   - url: 用于请求的url
///   - paras: 用于请求的参数
///   - detailResDataBlock: 用于处理请求到的数据的回调
- (void)PUT:(NSString *)url paras:(DCBaseReqParasModel *)paras detailResDataBlock:(DCReqDetailResData)detailResDataBlock;

/// PUT 请求
///
/// > 内部会根据`bindDataCls`方法返回的`model.resModelCls`来实现字典转模型
///
/// - Parameters:
///   - url: 用于请求的url
///   - paras: 用于请求的参数
- (void)PUT:(NSString *)url paras:(DCBaseReqParasModel *)paras;

/// DELETE 请求
/// - Parameters:
///   - url: 用于请求的url
///   - paras: 用于请求的参数
///   - detailResDataBlock: 用于处理请求到的数据的回调
- (void)DELETE:(NSString *)url paras:(DCBaseReqParasModel *)paras detailResDataBlock:(DCReqDetailResData)detailResDataBlock;

/// DELETE 请求
///
/// > 内部会根据bindDataCls方法返回的model.resModelCls来实现字典转模型
///
/// - Parameters:
///   - url: 用于请求的url
///   - paras: 用于请求的参数
- (void)DELETE:(NSString *)url paras:(DCBaseReqParasModel *)paras;

/// 生成主参数的同步接口调用model
/// - Parameter paras: 参数
- (DCReqChainModel*)reqPsChainModel:(DCBaseReqParasModel *)paras;

/// 生成主参数的同步接口调用model
/// - Parameter config: 参数config
- (DCReqChainModel*)reqPsCnfChainModel:(DCReqParasConfig)config;

/// 生成主回调的同步接口调用model
/// - Parameter next: 回调，会带有上一次接口调用的api参数
- (DCReqChainModel*)reqBlkChainModel:(DCReqNextBlock)next;

/// 拆箱操作 动态类型转换 做了类型检查
/// > 类型不对会返回nil，用于转为对应的子类对象
- (id)unPacking:(Class)class;

/// 拆箱操作 动态类型转换 做了类型检查
/// > 类型不对会返回nil，用于转为对应的子类对象
@property (nonatomic, readonly, copy) id (^unPacking)(Class class);

/// 终止相关联的所有请求
- (void)cancelReqs;

@end

/// 空占位api 用于动态串行调用 不让手动创建
@interface DCReqPlaceholderApi : DCBaseReqApi

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

/// 同步请求的具体功能实现
/// 1. 成功之后的接口调用
/// 2. 失败之后的接口调用
/// 3. 整个接口调用链调用完成之后的回调和接口调用链的启动
/// > Note:
/// > 1. 不支持创建实例操作，交给`DCReqManager`使用
/// > 2. 使用`DCReqParasConfig` 和 `DCReqNextBlock`可以在串行调用中拿到上文的api的res
/// > 3. 如果想要请求的参数是空，请传一个没配置的`DCBaseReqParasModel`对象或者传入一个空实现的`DCReqParasConfig`
/// > 4. 后面设置的调用关系（`successThen`、`failThen`）会覆盖前面的调用关系
@interface DCReqCoreManager : NSObject

#pragma mark - successThen

/// 接口调用成功之后的操作
@property (nonatomic, copy, readonly) DCReqCoreManager *(^successThen)(DCReqChainModel *reqChainModel);

/// 动态接口调用成功之后的操作 api使用的是DCReqPlhApi 具体调用的时候才知道调用的是那个接口
@property (nonatomic, copy, readonly) void(^dynSuccessThen)(DCReqNextBlock next);

/// 接口调用成功之后的操作 带`apiStore`+`request:`+`bindDataCls:`的简洁用法
@property (nonatomic, copy, readonly) DCReqCoreManager *(^stApiCnf_successThen)(Class apiCls, DCReqParasConfig config);

/// 接口调用成功之后的操作 带`apiStore`+`request:`+`bindDataCls:`的超级简洁用法
@property (nonatomic, copy, readonly) DCReqCoreManager *(^stApiDic_successThen)(Class apiCls, NSDictionary *dic);

#pragma mark - failThen

/// 接口调用失败之后的操作
@property (nonatomic, copy, readonly) DCReqCoreManager *(^failThen)(DCReqChainModel *reqChainModel);

/// 动态接口调用失败之后的操作 api使用的是DCReqPlhApi 具体调用的时候才知道调用的是那个接口
@property (nonatomic, copy, readonly) void(^dynFailThen)(DCReqNextBlock next);

/// 接口调用失败之后的操作 带`apiStore`+`request:`+`bindDataCls:`的简洁用法
@property (nonatomic, copy, readonly) DCReqCoreManager *(^stApiCnf_failThen)(Class apiCls, DCReqParasConfig config);

/// 接口调用失败之后的操作 带`apiStore`+`request:`+`bindDataCls:`的超级简洁用法
@property (nonatomic, copy, readonly) DCReqCoreManager *(^stApiDic_failThen)(Class apiCls, NSDictionary *dic);

/// 整个接口调用链调用完成之后操作
@property (nonatomic, copy, readonly) DCReqCoreManager *(^completeThen)(void(^)(void));

/// 整个接口调用链开始调用
@property (nonatomic, readonly, copy) void(^fire)(void);

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

/// 同步请求调用器
///
/// 内部使用`DCReqCoreManager`
///
/// > ## 内部不会强引用api
/// >
/// > **api需要依赖使用者强引用（或`DCReqApiStore`实例，间接使用者也要强引用）**。
/// > 不然调用链会中断，且`DCReqLifeCycleDelegate`协议里面的方法传入的api会是一个nil。
/// >
/// > ## 生命周期
/// >
/// > 1. `detailResDataBlock(res, error)` 或 `DCReqLifeCycleDelegate`协议方法(cancel)直接结束
/// > 2. `requestJudge(res)`
/// > 3. `DCReqLifeCycleDelegate`协议方法(`start`, `success`, `fail`)
/// > 4. (`start`, `success`, `fail`)对应的扩展回调方法
/// > 5. `successThen or failThen`
/// >   - 使用参数生成的`DCReqChainModel`时，会调用api的request方法
/// >   - 调用其他接口，转1；所有接口调用结束，转6
/// > 6. `completeThen`
/// >
/// > ## 一次性同步调用关系
/// > 一次完整的调用链结束，设置的调用链关系会被移除
///
/// > Note: 建议使用
/// > - **`DCReqManager.sharedInstance` + 自定义`DCReqApiStore`属性**
/// > - **自定义`DCReqManager`属性**
@interface DCReqManager : NSObject

/// 请求链起始 参数是一个`DCReqChainModel`
@property (nonatomic, copy, readonly) DCReqCoreManager *(^sync)(DCReqChainModel *reqChainModel);

/// 请求链起始 带`apiStore`+`request:`的简洁用法
@property (nonatomic, copy, readonly) DCReqCoreManager *(^stApiCnf_sync)(Class apiCls, DCReqParasConfig config);

/// 请求链起始 带`apiStore`+`request:`的超级简洁用法
@property (nonatomic, copy, readonly) DCReqCoreManager *(^stApiDic_sync)(Class apiCls, NSDictionary *dic);

/// 整个接口调用链调用完成之后操作
@property (nonatomic, copy, readonly) DCReqCoreManager *(^completeThen)(void(^)(void));

/// 重定位到某个节点 继续设置请求链 不会创建api
///
/// > Note: 参数是一个api，前提是该api已经在同步调用链中了
@property (nonatomic, copy, readonly) DCReqCoreManager *(^prepare)(DCBaseReqApi *api);

/// 使用`DCBaseReqApi.placeholderApi`之后的重新定位 不会判断api是否在串行调用链中
@property (nonatomic, copy, readonly) DCReqCoreManager *(^dynPrepare)(DCBaseReqApi *api);

@property (nonatomic, copy, readonly) DCReqCoreManager *(^stApi_prepare)(Class cls);
@property (nonatomic, copy, readonly) DCReqCoreManager *(^stApi_dynPrepare)(Class cls);

/// 开始执行整个请求链
@property (nonatomic, readonly, copy) void(^fire)(void);

/// 整个调用链是否完成调用
@property (nonatomic, readonly, assign) BOOL isReqChainCompleted;

/// api store
///
/// > 1. 使用`sharedInstance`时，`apiStore`为nil
/// > 2. 手动创建时，apiStore不空，但需要自己设置具体属性
@property (nonatomic, strong, readonly) DCReqApiStore *apiStore;

/// 校验api是否带有tag
///
/// > 前提是`self.apiStore`不空
@property (nonatomic, copy, readonly) BOOL(^checkApiTag)(DCBaseReqApi *api, NSString *tag);

/// 简化api直接调用
@property (nonatomic, copy, readonly) void(^stApiCnf_request)(Class apiCls, DCReqParasConfig config);

@property (nonatomic, copy, readonly) void(^stApiDic_request)(Class apiCls, NSDictionary *dic);

/// 全局单例 简化调用
///
/// > 不带apiStore，防止一直强引用，不释放，不要使用带api store的用法
@property (nonatomic, class, readonly) DCReqManager *sharedInstance;

/// 终止相关联的所有请求
- (void)cancelReqs;

@end

#pragma mark - Quick Maker Method

/// 为了xcode代码补全
/// - Parameter voidBlock: 传入的block，直接传出
CG_INLINE DCReqVoidBlock
DCReqVoidBlockMake(DCReqVoidBlock voidBlock)
{
    return voidBlock;
}

NS_ASSUME_NONNULL_END
