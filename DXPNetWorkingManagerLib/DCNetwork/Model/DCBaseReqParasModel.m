//
//  DCBaseReqParasModel.m
//  Base
//
//  Created by 胡灿 on 2025/11/19.
//

#import "DCBaseReqParasModel.h"
#import <MJExtension/MJExtension.h>

@implementation DCBaseReqParasModel

+ (DCBaseReqParasModel * _Nonnull (^)(DCReqParasConfig _Nonnull))modelMake {
    return ^DCBaseReqParasModel*(DCReqParasConfig config){
        DCBaseReqParasModel *model = [self new]; // 重要 使用self new创建对象 创建的是具体的实例 有可能是子类对象
        if (config) config(model);
        return model;
    };
}

- (id  _Nonnull (^)(Class  _Nonnull __unsafe_unretained))unPacking {
    return ^id(Class class){
        // 拆箱操作
        return [self unPacking:class];
    };
}

+ (DCBaseReqParasModel * _Nonnull (^)(NSDictionary * _Nonnull))withDic {
    return ^DCBaseReqParasModel*(NSDictionary *dic){
        return [self modelWithDic:dic];
    };
}

+ (instancetype)modelMake:(DCReqParasConfig)config {
    DCBaseReqParasModel *model = [self new]; // 重要 使用self new创建对象 创建的是具体的实例 有可能是子类对象
    if (config) config(model);
    return model;
}

- (id)unPacking:(Class)class {
    // 拆箱操作
    if ([self isKindOfClass:self.class] && class && [self isKindOfClass:class]) {
        return self;
    }
    return nil;
}

+ (instancetype)modelWithDic:(NSDictionary *)dic {
    if (dic) {
        DCBaseReqParasModel *model = [self.class mj_objectWithKeyValues:dic];
        return model;
    }
    return [self new];
}

+ (NSArray *)mj_ignoredPropertyNames {
    return @[@"unPacking"]; // 属性当方法使用 子类转字典时忽略
}

@end
