//
//  DCBaseReqResModel.h
//  Base
//
//  Created by 胡灿 on 2025/11/19.
//

#import <Foundation/Foundation.h>
#import <MJExtension/MJExtension.h>

NS_ASSUME_NONNULL_BEGIN

/// api回调的数据model：主要是一些公共的字段，核心数据返回交给具体的子类
///
/// > 所有resModel相关属性请使用readonly，防止外面修改
@interface DCBaseReqResModel : NSObject

/// 接口状态码
@property (nonatomic, assign, readonly) NSInteger statusCode;

/// 接口返回的code
@property (nonatomic, copy, readonly) NSString *code;
/// 错误码
@property (nonatomic, copy, readonly) NSString *resultCode;
/// 错误信息
@property (nonatomic, copy, readonly) NSString *resultMsg;

@end

NS_ASSUME_NONNULL_END
