//
//  DCReqApiStore.m
//  Base
//
//  Created by 胡灿 on 2025/11/19.
//

#import "DCReqApiStore.h"
#import "DCBaseReqApi.h"
#import "DCNetWorkConstant.h"

@interface DCReqApiStore ()

@property (nonatomic, strong) NSMutableDictionary<NSString *, DCBaseReqApi *> *apis; // 强引用 持有

@end

@implementation DCReqApiStore

- (DCBaseReqApi *)apiMake:(Class)cls tag:(NSString *)tag delegate:(nonnull id<DCReqLifeCycleDelegate>)delegate {
    if (cls && [cls isKindOfClass:object_getClass(DCBaseReqApi.class)] && delegate && [delegate conformsToProtocol:@protocol(DCReqLifeCycleDelegate)]) {
        NSString *realTag = tag;
        if (dcNetWk_isEmptyString(realTag)) {
            realTag = NSStringFromClass(cls);
        }
        DCBaseReqApi *api = [self.apis objectForKey:realTag];
        if (!api) {
            api = cls.new;
            [api setValue:realTag forKey:@"storeTag"];
            [self.apis setObject:api forKey:realTag];
        }
        id realDelegate = delegate;
        if (!delegate) {
            realDelegate = self.delegate;
        }
        api.delegate = realDelegate;
        return api;
    }
    return nil;
}

- (DCBaseReqApi *)apiMake:(Class)cls delegate:(nonnull id<DCReqLifeCycleDelegate>)delegate {
    return [self apiMake:cls tag:nil delegate:delegate];
}

- (DCBaseReqApi *)apiMake:(Class)cls {
    return [self apiMake:cls tag:nil delegate:self.delegate];
}

- (DCBaseReqApi * _Nonnull (^)(Class  _Nonnull __unsafe_unretained))apiMake {
    return ^DCBaseReqApi*(Class cls) {
        return [self apiMake:cls];
    };
}

- (DCBaseReqApi *)api:(NSString *)tag {
    return [self.apis objectForKey:tag];
}

- (DCBaseReqApi * _Nonnull (^)(NSString * _Nonnull))api {
    return ^DCBaseReqApi*(NSString *tag) {
        return [self api:tag];
    };
}

- (void)rmApi:(NSString *)tag {
    if (!dcNetWk_isEmptyString(tag)) {
        [self.apis removeObjectForKey:tag];
    }
}

- (void (^)(NSString * _Nonnull))rmApi {
    return ^(NSString *tag) {
        [self rmApi:tag];
    };
}

- (id)apiWithCls:(Class)cls {
    if (cls && [cls isKindOfClass:object_getClass(DCBaseReqApi.class)]) {
        return [self api:NSStringFromClass(cls)].unPacking(cls);
    }
    return nil;
}

- (id (^)(Class  _Nonnull __unsafe_unretained))apiWithCls {
    return ^id(Class cls) {
        return [self apiWithCls:cls];
    };
}

+ (void)checkApi:(DCBaseReqApi *)api judgeDic:(NSDictionary<NSString *,void (^)(void)> *)judgeDic {
    if (api && api.storeTag) {
        void(^apiBlock)(void) = [judgeDic objectForKey:api.storeTag];
        if (apiBlock) {
            apiBlock();
        }
    }
}

#pragma mark - lazy load

- (NSMutableDictionary<NSString *,DCBaseReqApi *> *)apis {
    if (!_apis) {
        _apis = NSMutableDictionary.new;
    }
    return _apis;
}

@end
