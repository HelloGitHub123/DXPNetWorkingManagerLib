//
//  DCBaseReqParasModel.h
//  Base
//
//  Created by 胡灿 on 2025/11/19.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

@class DCBaseReqParasModel;
@class DCBaseReqApi;

typedef void(^DCReqParasConfig)(DCBaseReqParasModel * _Nonnull model);

/// 空参数
#define DCBaseReqEmptyParasModel [DCBaseReqParasModel modelMake:^(DCBaseReqParasModel * _Nonnull model){}]
/// 空参数config
#define DCBaseReqEmptyParasModelConfig ^(DCBaseReqParasModel * _Nonnull model){}

/// 构建DCBaseReqParasModel的block回调前缀
#define DCBaseReqParasCnfPrefix(model) ^(DCBaseReqParasModel * _Nonnull model)

NS_ASSUME_NONNULL_BEGIN

/// 用于api网络请求的参数model
@interface DCBaseReqParasModel : NSObject

/// 初始化 常用于创建临时对象 代码更聚合
@property (nonatomic, class, readonly, copy) DCBaseReqParasModel *(^modelMake)(DCReqParasConfig config);

/// 初始化 常用于创建临时对象 代码更聚合
@property (nonatomic, class, readonly, copy) DCBaseReqParasModel *(^withDic)(NSDictionary *dic);

/// 拆箱操作 动态类型转换 做了类型检查
/// > 类型不对会返回nil，用于转为对应的子类对象
@property (nonatomic, readonly, copy) id (^unPacking)(Class class);\

/// 初始化 常用于创建临时对象 代码更聚合
+ (instancetype)modelMake:(DCReqParasConfig)config;

/// 初始化 常用于创建临时对象 代码更聚合 不会做类型检查 不会有提示 内部使用MJExtension
+ (instancetype)modelWithDic:(NSDictionary *)dic;

/// 拆箱操作 动态类型转换 做了类型检查
/// > 类型不对会返回nil，用于转为对应的子类对象
- (id)unPacking:(Class)class;

@end

#pragma mark - Quick Maker Method

CG_INLINE DCBaseReqParasModel*
DCBaseReqParasModelMake(Class subClass, DCReqParasConfig config)
{
    if ([subClass isKindOfClass:object_getClass(DCBaseReqParasModel.class)]) {
        DCBaseReqParasModel *model = [subClass new];
        if (config) config(model);
        return model;
    }
    return DCBaseReqParasModel.new;
}

/// 为了xcode代码补全
/// - Parameter config: 传入的config，直接传出
CG_INLINE DCReqParasConfig
DCParasConfigMake(DCReqParasConfig config)
{
    return config;
}

NS_ASSUME_NONNULL_END
