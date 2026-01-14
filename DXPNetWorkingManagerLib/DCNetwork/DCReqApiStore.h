//
//  DCReqApiStore.h
//  Base
//
//  Created by 胡灿 on 2025/11/19.
//

#import <Foundation/Foundation.h>
#import "DCReqLifeCycleDelegate.h"

@class DCBaseReqApi;

NS_ASSUME_NONNULL_BEGIN

/// api仓库
@interface DCReqApiStore : NSObject

/// 仓库内所有api的请求生命周期代理
/// > 单独设置时会被取代
@property (nonatomic, weak) id<DCReqLifeCycleDelegate> delegate;

/// 生成api并存入 已存在api，不会创建新对象
/// - Parameters:
///   - cls: 要生成的api的class
///   - tag: 与要生成的api绑定的tag，用于取api
///   - delegate: 要生成的api的请求生命周期代理，可代替`DCReqApiStore`的delegate
- (DCBaseReqApi *)apiMake:(Class)cls tag:(NSString * _Nullable)tag delegate:(id<DCReqLifeCycleDelegate>)delegate;

/// 生成api并存入 tag默认采取api的class字符串
/// - Parameters:
///   - cls: 要生成的api的class
///   - delegate: 要生成的api的请求生命周期代理，可代替`DCReqApiStore`的delegate
- (DCBaseReqApi *)apiMake:(Class)cls delegate:(id<DCReqLifeCycleDelegate>)delegate;

/// 生成api并存入 tag默认采取api的class字符串 delegate采取`DCReqApiStore`的delegate
/// - Parameter cls: 要生成的api的class
- (DCBaseReqApi *)apiMake:(Class)cls;

/// 取api
/// - Parameter tag: 与api绑定的tag
- (DCBaseReqApi *)api:(NSString *)tag;

/// 取api：api的tag是api的className 做了拆包
/// - Parameter cls: api的class
- (id)apiWithCls:(Class)cls;

/// 移除api
/// - Parameter tag: api对应的tag
- (void)rmApi:(NSString *)tag;

/// 生成api并存入 tag默认采取api的class字符串 `delegate`采取`DCReqApiStore`的`delegate`
@property (nonatomic, copy, readonly) DCBaseReqApi *(^apiMake)(Class cls);

/// 取api tag：与api绑定的tag
@property (nonatomic, copy, readonly) DCBaseReqApi *(^api)(NSString *tag);

/// 取api：api的tag是api的className 做了拆包
@property (nonatomic, copy, readonly) id(^apiWithCls)(Class cls);

@property (nonatomic, copy, readonly) void(^rmApi)(NSString *tag);

+ (void)checkApi:(DCBaseReqApi *)api judgeDic:(NSDictionary<NSString *, void(^)(void)> *)judgeDic;

@end

#pragma mark - Quick Maker Method

CG_INLINE DCBaseReqApi *
DCApiStoreTagDelegateApiMake(DCReqApiStore *store, Class cls, NSString *tag, id<DCReqLifeCycleDelegate> delegate)
{
    return [store apiMake:cls tag:tag delegate:delegate];
}

CG_INLINE DCBaseReqApi *
DCApiStoreClsDelegateApiMake(DCReqApiStore *store, Class cls, id<DCReqLifeCycleDelegate> delegate)
{
    return [store apiMake:cls delegate:delegate];
}

CG_INLINE DCBaseReqApi *
DCApiStoreClsApiMake(DCReqApiStore *store, Class cls)
{
    return [store apiMake:cls];
}

CG_INLINE DCBaseReqApi *
DCApiStoreGet(DCReqApiStore *store, NSString *tag)
{
    return [store api:tag];
}

NS_ASSUME_NONNULL_END
