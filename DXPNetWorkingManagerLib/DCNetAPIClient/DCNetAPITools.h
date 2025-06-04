//
//  DCNetAPITools.h
//  DXPNetWorkingManagerLib
//
//  Created by 李标 on 2025/5/29.
//  三层架构请求path 映射

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DCNetAPITools : NSObject

+ (NSString *)getProxyPathURLString:(NSString *)aPath;

@end

NS_ASSUME_NONNULL_END
