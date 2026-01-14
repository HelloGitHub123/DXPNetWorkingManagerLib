//
//  DCReqApiDelegate.h
//  Base
//
//  Created by 胡灿 on 2025/11/19.
//

#import <Foundation/Foundation.h>

@class DCBaseReqParasModel;
@class DCReqApiDataClsBindModel;

NS_ASSUME_NONNULL_BEGIN

/// api请求协议：用于api相关配置
@protocol DCReqApiDelegate <NSObject>

@optional

/// 请求返回数据时 判断是否成功的方法
/// - Parameter res: 请求返回的数据
- (BOOL)requestJudge:(NSDictionary *)res;

/// 返回请求调用的声明周期扩展回调的方法名
/// - Parameter funcName: 默认方法名: `self.storeTag` + (Start｜Success｜Fail｜Cancel)
- (NSString *)extendedLifeCycleFuncNamePrefix:(NSString *)funcNamePrefix;

/// DCReqManager做同步请求时，只使用api和paras会默认调用该方法
/// - Parameter paras: 请求参数model
///
/// > Warning: 该方法必须实现
- (void)request:(DCBaseReqParasModel *)paras;

/// api bind 相关的数据 cls
///
/// > Warning: 该方法必须实现
- (DCReqApiDataClsBindModel *)bindDataCls;

@end

NS_ASSUME_NONNULL_END
