//
//  DCBaseReqApi+Extension.m
//  Base
//
//  Created by 胡灿 on 2025/12/2.
//

#import "DCBaseReqApi+Extension.h"

@implementation DCBaseReqApi (Extension)

- (DCReqApiDataClsBindModel *)dataClsBindModelProperty {
    return [self valueForKey:@"dataClsBindModel"];
}

@end

@implementation DCReqCoreManager (Extension)

- (DCReqApiStore *)apiStoreProperty {
    return [self valueForKey:@"apiStore"];
}

- (DCReqCoreManager * _Nonnull (^)(DCBaseReqApi * _Nonnull, DCReqNextBlock _Nonnull))apiBlk_successThen {
    return ^DCReqCoreManager*(DCBaseReqApi *api, DCReqNextBlock next) {
        return self.successThen(DCReqBlkChainModelMake(api, next));
    };
}

- (DCReqCoreManager * _Nonnull (^)(DCBaseReqApi * _Nonnull, DCReqParasConfig _Nonnull))apiCnf_successThen {
    return ^DCReqCoreManager*(DCBaseReqApi *api, DCReqParasConfig config) {
        return self.successThen(DCReqPsCnfChainModelMake(api, config));
    };
}

- (DCReqCoreManager * _Nonnull (^)(Class  _Nonnull __unsafe_unretained, NSString * _Nonnull, DCReqParasConfig _Nonnull))stApiTgCnf_successThen {
    return ^DCReqCoreManager *(Class apiCls, NSString *tag, DCReqParasConfig config) {
        DCBaseReqApi *api = [self.apiStoreProperty apiMake:apiCls tag:tag delegate:self.apiStoreProperty.delegate];
        if (api) {
            return self.successThen(DCReqPsCnfChainModelMake(api, config));
        }
        return self;
    };
}

- (DCReqCoreManager * _Nonnull (^)(Class  _Nonnull __unsafe_unretained, DCReqNextBlock _Nonnull))stApiBlk_successThen {
    return ^DCReqCoreManager *(Class apiCls, DCReqNextBlock next) {
        return self.successThen(DCReqBlkChainModelMake(apiCls == DCReqPlhApiCls ? DCBaseReqApi.placeholderApi : self.apiStoreProperty.apiMake(apiCls), next));
    };
}

- (DCReqCoreManager * _Nonnull (^)(Class  _Nonnull __unsafe_unretained, NSString * _Nonnull, DCReqNextBlock _Nonnull))stApiTgBlk_successThen {
    return ^DCReqCoreManager *(Class apiCls, NSString *tag, DCReqNextBlock next) {
        return self.successThen(DCReqBlkChainModelMake(apiCls == DCReqPlhApiCls ? DCBaseReqApi.placeholderApi : [self.apiStoreProperty apiMake:apiCls tag:tag delegate:self.apiStoreProperty.delegate], next));
    };
}

- (DCReqCoreManager * _Nonnull (^)(Class  _Nonnull __unsafe_unretained))stApi_successThen {
    return ^DCReqCoreManager *(Class apiCls) {
        return self.stApiCnf_successThen(apiCls, DCBaseReqEmptyParasModelConfig);
    };
}

- (DCReqCoreManager * _Nonnull (^)(DCBaseReqApi * _Nonnull, DCReqNextBlock _Nonnull))apiBlk_failThen {
    return ^DCReqCoreManager*(DCBaseReqApi *api, DCReqNextBlock next) {
        return self.failThen(DCReqBlkChainModelMake(api, next));
    };
}

- (DCReqCoreManager * _Nonnull (^)(DCBaseReqApi * _Nonnull, DCReqParasConfig _Nonnull))apiCnf_failThen {
    return ^DCReqCoreManager*(DCBaseReqApi *api, DCReqParasConfig config) {
        return self.failThen(DCReqPsCnfChainModelMake(api, config));
    };
}

- (DCReqCoreManager * _Nonnull (^)(Class  _Nonnull __unsafe_unretained, NSString * _Nonnull, DCReqParasConfig _Nonnull))stApiTgCnf_failThen {
    return ^DCReqCoreManager *(Class apiCls, NSString *tag, DCReqParasConfig config) {
        DCBaseReqApi *api = [self.apiStoreProperty apiMake:apiCls tag:tag delegate:self.apiStoreProperty.delegate];
        if (api) {
            return self.failThen(DCReqPsCnfChainModelMake(api, config));
        }
        return self;
    };
}

- (DCReqCoreManager * _Nonnull (^)(Class  _Nonnull __unsafe_unretained, DCReqNextBlock _Nonnull))stApiBlk_failThen {
    return ^DCReqCoreManager *(Class apiCls, DCReqNextBlock next) {
        return self.failThen(DCReqBlkChainModelMake(apiCls == DCReqPlhApiCls ? DCBaseReqApi.placeholderApi : self.apiStoreProperty.apiMake(apiCls), next));
    };
}

- (DCReqCoreManager * _Nonnull (^)(Class  _Nonnull __unsafe_unretained, NSString * _Nonnull, DCReqNextBlock _Nonnull))stApiTgBlk_failThen {
    return ^DCReqCoreManager *(Class apiCls, NSString *tag, DCReqNextBlock next) {
        return self.failThen(DCReqBlkChainModelMake(apiCls == DCReqPlhApiCls ? DCBaseReqApi.placeholderApi : [self.apiStoreProperty apiMake:apiCls tag:tag delegate:self.apiStoreProperty.delegate], next));
    };
}

- (DCReqCoreManager * _Nonnull (^)(Class  _Nonnull __unsafe_unretained))stApi_failThen {
    return ^DCReqCoreManager *(Class apiCls) {
        return self.stApiCnf_failThen(apiCls, DCBaseReqEmptyParasModelConfig);
    };
}

- (id)valueForUndefinedKey:(NSString *)key {
    NSLog(@"[class]%@ has no [property]%@.", self.class, key);
    return nil;
}

@end

@implementation DCReqManager (Extension)

- (DCReqCoreManager *)coreManagerProperty {
    return [self valueForKey:@"coreManager"];
}

- (DCReqCoreManager * _Nonnull (^)(DCBaseReqApi * _Nonnull, DCReqNextBlock _Nonnull))apiBlk_sync {
    return ^DCReqCoreManager*(DCBaseReqApi *api, DCReqNextBlock next) {
        return self.sync(DCReqBlkChainModelMake(api, next));
    };
}

- (DCReqCoreManager * _Nonnull (^)(DCBaseReqApi * _Nonnull, DCBaseReqParasModel * _Nonnull))apiParas_sync {
    return ^DCReqCoreManager*(DCBaseReqApi *api, DCBaseReqParasModel *paras) {
        return self.sync(DCReqPsChainModelMake(api, paras));
    };
}

- (DCReqCoreManager * _Nonnull (^)(Class  _Nonnull __unsafe_unretained, DCReqNextBlock _Nonnull))stApiBlk_sync {
    return ^DCReqCoreManager *(Class apiCls, DCReqNextBlock next) {
        return self.sync(DCReqBlkChainModelMake(apiCls == DCReqPlhApiCls ? DCBaseReqApi.placeholderApi : self.apiStore.apiMake(apiCls), next));
    };
}

- (DCReqCoreManager * _Nonnull (^)(Class  _Nonnull __unsafe_unretained, NSString * _Nonnull, DCReqParasConfig _Nonnull))stApiTgCnf_sync {
    return ^DCReqCoreManager *(Class apiCls, NSString *tag, DCReqParasConfig config) {
        DCBaseReqApi *api = [self.apiStore apiMake:apiCls tag:tag delegate:self.apiStore.delegate];
        if (api) {
            return self.sync(DCReqPsCnfChainModelMake(api, config));
        }
        return self.coreManagerProperty;
    };
}

- (DCReqCoreManager * _Nonnull (^)(Class  _Nonnull __unsafe_unretained, NSString * _Nonnull, DCReqNextBlock next))stApiTgBlk_sync {
    return ^DCReqCoreManager *(Class apiCls, NSString *tag, DCReqNextBlock next) {
        return self.sync(DCReqBlkChainModelMake(apiCls == DCReqPlhApiCls ? DCBaseReqApi.placeholderApi : [self.apiStore apiMake:apiCls tag:tag delegate:self.apiStore.delegate], next));
    };
}

- (DCReqCoreManager * _Nonnull (^)(Class  _Nonnull __unsafe_unretained))stApi_sync {
    return ^DCReqCoreManager *(Class apiCls) {
        return self.stApiCnf_sync(apiCls, DCBaseReqEmptyParasModelConfig);
    };
}

- (DCReqCoreManager * _Nonnull (^)(NSString * _Nonnull))stApiTg_prepare {
    return ^DCReqCoreManager*(NSString *tag) {
        return self.prepare(self.apiStore.api(tag));
    };
}

- (DCReqCoreManager * _Nonnull (^)(NSString * _Nonnull))stApiTg_dynPrepare {
    return ^DCReqCoreManager*(NSString *tag) {
        return self.dynPrepare(self.apiStore.api(tag));
    };
}

- (void (^)(Class  _Nonnull __unsafe_unretained, NSString * _Nonnull, DCReqParasConfig _Nonnull))stApiTgCnf_request {
    return ^(Class cls, NSString *tag, DCReqParasConfig config) {
        DCBaseReqApi *api = [self.apiStore apiMake:cls tag:tag delegate:self.apiStore.delegate];
        if (api) {
            DCBaseReqParasModel *paras = DCBaseReqParasModelMake(api.dataClsBindModelProperty.parasModelCls, config);
            if (paras) {
                [api request:paras];
            }
        }
    };
}

- (void (^)(Class  _Nonnull __unsafe_unretained))stApi_request {
    return ^(Class cls) {
        self.stApiCnf_request(cls, DCBaseReqEmptyParasModelConfig);
    };
}

- (id)valueForUndefinedKey:(NSString *)key {
    NSLog(@"[class]%@ has no [property]%@.", self.class, key);
    return nil;
}

@end
