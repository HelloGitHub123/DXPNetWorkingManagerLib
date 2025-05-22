//
//  TokenManager.h
//  react-native-sdk-dxp-base
//
//  Created by 李标 on 2025/5/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TokenManager : NSObject

+ (instancetype)sharedInstance;

- (void)getTokenWithCompletion:(void(^)(NSString * _Nullable token, NSString *code, NSString *resultMsg , NSError * _Nullable error))completion;
@end

NS_ASSUME_NONNULL_END
