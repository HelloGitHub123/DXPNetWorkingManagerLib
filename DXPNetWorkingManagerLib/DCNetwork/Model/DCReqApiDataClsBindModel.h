//
//  DCReqApiDataClsBindModel.h
//  Base
//
//  Created by 胡灿 on 2025/11/20.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// api 绑定的数据类型 model
///
/// 保存相关的数据模型映射
@interface DCReqApiDataClsBindModel : NSObject

/// 绑定的参数 model class
///
/// > 只有`DCBaseReqResModel`及其子类才可以设置该值
@property (nonatomic, strong) Class parasModelCls;

/// 绑定的返回数据 model class
///
/// > 只有`DCBaseReqResModel`及其子类才可以设置该值
@property (nonatomic, strong) Class resModelCls;

@end

#pragma mark - Quick Maker Method

CG_INLINE DCReqApiDataClsBindModel*
DCReqApiDataClsBindModelMake(Class parasModelCls, Class resModelCls)
{
    DCReqApiDataClsBindModel *dataClsBindModel = DCReqApiDataClsBindModel.new;
    dataClsBindModel.parasModelCls = parasModelCls;
    dataClsBindModel.resModelCls = resModelCls;
    return dataClsBindModel;
}

NS_ASSUME_NONNULL_END
