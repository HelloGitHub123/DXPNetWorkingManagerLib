//
//  DCReqChainModel.h
//  Base
//
//  Created by 胡灿 on 2025/11/19.
//

#import <Foundation/Foundation.h>
#import "DCBaseReqParasModel.h"

@class DCBaseReqApi;

typedef void(^DCReqNextBlock)(DCBaseReqApi * _Nonnull lastApi);

/// 构建DCReqNextBlock的block回调前缀
#define DCReqNextBlockMakePrefix(lastApi) ^(DCBaseReqApi *_Nonnull lastApi)

NS_ASSUME_NONNULL_BEGIN

/// 接口同步调用的model
@interface DCReqChainModel : NSObject

/// 同步接口调用的api
@property (nonatomic, strong) DCBaseReqApi *api;

/// 同步接口调用的具体操作block，带有上一次接口调用的api
@property (nonatomic, copy) DCReqNextBlock block;

/// 同步接口调用的具体参数config，无需写具体的调用代码，默认调用api的request方法（前提是要实现request方法）
@property (nonatomic, copy) DCReqParasConfig parasConfig;

/// 同步接口调用的具体参数，无需写具体的调用代码，默认调用api的request方法（前提是要实现request方法）
@property (nonatomic, strong) DCBaseReqParasModel *paras;

@end

#pragma mark - Quick Maker Method

CG_INLINE DCReqChainModel*
DCReqPsCnfChainModelMake(DCBaseReqApi *api, DCReqParasConfig config)
{
    DCReqChainModel *reqChainModel = DCReqChainModel.new;
    reqChainModel.api = api;
    reqChainModel.parasConfig = config;
    return reqChainModel;
}

CG_INLINE DCReqChainModel*
DCReqPsChainModelMake(DCBaseReqApi *api, DCBaseReqParasModel *paras)
{
    DCReqChainModel *reqChainModel = DCReqChainModel.new;
    reqChainModel.api = api;
    reqChainModel.paras = paras;
    return reqChainModel;
}

CG_INLINE DCReqChainModel*
DCReqBlkChainModelMake(DCBaseReqApi *api, DCReqNextBlock block)
{
    DCReqChainModel *reqChainModel = DCReqChainModel.new;
    reqChainModel.api = api;
    reqChainModel.block = block;
    return reqChainModel;
}

/// 为了xcode代码补全
/// - Parameter next: 传入的next，直接传出
CG_INLINE DCReqNextBlock
DCReqNextBlockMake(DCReqNextBlock next)
{
    return next;
}

NS_ASSUME_NONNULL_END
