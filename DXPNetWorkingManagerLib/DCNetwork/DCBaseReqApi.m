//
//  DCBaseReqApi.m
//  Base
//
//  Created by 胡灿 on 2025/11/19.
//

#import "DCBaseReqApi.h"
#import "DCNetAPIClient.h"
#import <MJExtension/MJExtension.h>
#import "DCBaseReqResModel.h"
#import "DCNetWorkConstant.h"

/// 请求方法枚举
typedef NS_ENUM(NSUInteger, DCReqMethodType) {
    DCReqGet,
    DCReqPost,
    DCReqPut,
    DCReqDelete,
};

/// 属性校验结果枚举
typedef NS_ENUM(NSUInteger, DCReqPropertyCheckType) {
    DCReqNotHas,
    DCReqWrongClsType,
    DCReqHas
};

/// api 使用状态
///
/// > DCReqApiRunning 状态说明有对象正在使用api，其他对象不准使用
typedef NS_ENUM(NSUInteger, DCReqApiState) {
    DCReqApiUnused,  // 未使用 闲置
    DCReqApiRunning,  // 正在使用
};

static NSString *const kDCBaseReqApiLifeCycleFuncStart = @"Start";
static NSString *const kDCBaseReqApiLifeCycleFuncSuccess = @"Success";
static NSString *const kDCBaseReqApiLifeCycleFuncFail = @"Fail";
static NSString *const kDCBaseReqApiLifeCycleFuncCancel = @"Cancel";

static NSString *const kDCBaseReqApiPropertyRes = @"res";

static NSString *const kDCBaseReqApiResResultCode = @"code";
static NSString *const kDCBaseReqApiResResultCode200 = @"200";

NSString *const DCBaseReqApiResStatusCode = @"statusCode";


#pragma mark - DCReqCoreManager扩展提前声明：DCBaseReqApi会使用DCReqCoreManager私有属性

@interface DCReqCoreManager ()

@property (nonatomic, weak) DCBaseReqApi *firstApi;  // 弱引用 不持有
@property (nonatomic, weak) DCBaseReqApi *lastApi;  // 弱引用 不持有
@property (nonatomic, strong) NSHashTable<DCBaseReqApi *> *apis; // 弱引用 不持有
@property (nonatomic, strong) DCReqApiStore *apiStore; // DCReqManager 非单例时有值
@property (nonatomic, copy) DCReqNextBlock startRequest;
@property (nonatomic, copy) void(^didEndCallback)(void);
@property (nonatomic, assign) BOOL isReqChainCompleted;

@end

#pragma mark - DCBaseReqApi

@interface DCBaseReqApi ()

@property (nonatomic, copy) void(^successThenRequest)(void);
@property (nonatomic, copy) void(^failThenRequest)(void);
@property (nonatomic, weak) DCReqCoreManager *coreManager; // 弱引用 不持有
@property (nonatomic, strong) NSMutableSet<NSURLSessionTask *> *tasks; // 关联的任务集合 一般只会有一个元素
@property (nonatomic, strong) DCReqApiDataClsBindModel *dataClsBindModel;
@property (nonatomic, assign) DCReqApiState state; // 防止一个api同时调用多个请求导致多线程问题

@property (nonatomic, class, readonly) NSMutableSet<NSString *> *validApiClassTable; // 合法apiClass表
@end

@implementation DCBaseReqApi

@synthesize storeTag = _storeTag;

static NSMutableSet<NSString *> *_validApiClassTable = nil;

static DCReqPlaceholderApi *_placeholderApi = nil;

+ (DCReqPlaceholderApi *)placeholderApi {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _placeholderApi = [[DCReqPlaceholderApi alloc] initPlaceholderApi];
    });
    return _placeholderApi;
}

+ (NSMutableSet<NSString *> *)validApiClassTable {
    if (!_validApiClassTable) {
        _validApiClassTable = NSMutableSet.new;
    }
    return _validApiClassTable;
}

- (instancetype)initPlaceholderApi {
    // 没有规则校验
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (NSString *)lowercaseFirstLetter:(NSString *)string {
    if (string.length == 0) {
        return string;
    }
    NSString *firstChar = [string substringToIndex:1];
    NSString *lowercaseFirstChar = [firstChar lowercaseString];
    NSString *restOfString = [string substringFromIndex:1];
    return [lowercaseFirstChar stringByAppendingString:restOfString];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        if (![DCBaseReqApi.validApiClassTable containsObject:NSStringFromClass(self.class)]) {
            // 方法校验
            NSAssert([self respondsToSelector:@selector(request:)], @"[class]%@ instance not responds to [selector]%@.", self.class, NSStringFromSelector(@selector(request:)));
            NSAssert([self respondsToSelector:@selector(bindDataCls)], @"[class]%@ instance not responds to [selector]%@.", self.class, NSStringFromSelector(@selector(bindDataCls)));
        }
        
        self.dataClsBindModel = [self bindDataCls] ?: DCReqApiDataClsBindModelMake(DCBaseReqParasModel.class, DCBaseReqResModel.class);
        
        if (![DCBaseReqApi.validApiClassTable containsObject:NSStringFromClass(self.class)]) {
            // dataClsBindModel 属性校验
            NSAssert(self.dataClsBindModel, @"[method]%@ of [class]%@ returns a nil value.", NSStringFromSelector(@selector(bindDataCls)), self.class);
            NSAssert([self.dataClsBindModel.parasModelCls isKindOfClass:object_getClass(DCBaseReqParasModel.class)], @"[property]%@ of  [DCReqApiDataClsBindModel]%@ is not a kind of [class]%@.", @"parasModelCls", self.dataClsBindModel, @"DCBaseReqParasModel");
            NSAssert([self.dataClsBindModel.resModelCls isKindOfClass:object_getClass(DCBaseReqResModel.class)], @"[property]%@ of [DCReqApiDataClsBindModel]%@ is not a kind of [class]%@.", @"resModelCls", self.dataClsBindModel, @"DCBaseReqResModel");
            // res 属性校验
            DCReqPropertyCheckType checkType;
            NSString *resPropertyType = [self checkPropertyRes:&checkType];
            NSAssert(checkType != DCReqNotHas, @"[class]%@ instance has not [property]%@.", self.dataClsBindModel.resModelCls, kDCBaseReqApiPropertyRes);
            NSAssert(checkType != DCReqWrongClsType, @"[property]%@ of [class]%@ instance is a wrong type: [class]%@, because you have binded the property with [class]%@.", kDCBaseReqApiPropertyRes, self.class, resPropertyType, self.dataClsBindModel.resModelCls);
            // 所有校验通过 加入合法表中
            [DCBaseReqApi.validApiClassTable addObject:NSStringFromClass(self.class)];
        }
    }
    return self;
}

- (NSString *)checkPropertyRes:(DCReqPropertyCheckType *)check {
    // 子类是否有res属性&其类型和传入的self.dataClsBindModel.resModelCls类型一致
    *check = DCReqNotHas;
    objc_property_t property = class_getProperty(self.class, [kDCBaseReqApiPropertyRes UTF8String]);
    if (property) {
        *check = DCReqWrongClsType;
        const char *attrs = property_getAttributes(property);
        NSString *attributes = [NSString stringWithUTF8String:attrs];
        NSArray *components = [attributes componentsSeparatedByString:@","];
        if (components.count > 0) {
            NSString *typeInfo = components[0];
            if ([typeInfo hasPrefix:@"T@"]) {
                // 对象类型，格式类似 T@"NSString"
                NSString *typeName = [typeInfo substringWithRange:NSMakeRange(3, typeInfo.length - 4)];
                // 比较属性类型名和传入类名是否一致
                if ([typeName isEqualToString:NSStringFromClass(self.dataClsBindModel.resModelCls)]) {
                    *check = DCReqHas;
                    return typeName;
                }
            }
        }
    }
    return nil;
}

- (NSString *)extendedLifeCycleFuncNamePrefix:(NSString *)funcNamePrefix {
    return [self lowercaseFirstLetter:funcNamePrefix];
}

- (NSString *)getExtendedLifeCycleFuncNamePrefix:(NSString *)funcNamePrefix {
    if ([self conformsToProtocol:@protocol(DCReqApiDelegate)] && [self respondsToSelector:@selector(extendedLifeCycleFuncNamePrefix:)]) {
        return [self extendedLifeCycleFuncNamePrefix:funcNamePrefix];
    }
    return funcNamePrefix;
}

- (void)callExtendedLifeCycleFunc:(NSString *)lifeCycleFuncNameSuffix {
    SEL extendSel = NSSelectorFromString([NSString stringWithFormat:@"%@%@:", [self getExtendedLifeCycleFuncNamePrefix:self.storeTag], lifeCycleFuncNameSuffix ?: @""]);
    if (self.delegate && [self.delegate isKindOfClass:NSObject.class] && !dcNetWk_isEmptyString(self.storeTag) && [self.delegate respondsToSelector:extendSel]) {
        IMP extendImp = [(NSObject *)self.delegate methodForSelector:extendSel];
        if (extendImp) {
            // 获取方法的 Method 结构体
            Method method = class_getInstanceMethod([self.delegate class], extendSel);
            // 获取方法的类型编码
            const char *typeEncoding = method_getTypeEncoding(method);
            if (typeEncoding && typeEncoding[0] == 'v') {
                // 检查第一个字符是否为 'v'（表示 Void）
                void(*extendFunc)(id, SEL, DCBaseReqApi *) = (void *)extendImp;
                extendFunc(self.delegate, extendSel, self);
            }
        }
    }
}

- (void)doDelegateStartMethod {
    if (self.delegate && [self.delegate respondsToSelector:@selector(start:)]) {
        [self.delegate start:self];
    }
    [self callExtendedLifeCycleFunc:kDCBaseReqApiLifeCycleFuncStart];
}

- (void)doDelegateSuccessMethod{
    if (self.delegate && [self.delegate respondsToSelector:@selector(success:)]) {
        [self.delegate success:self];
    }
    [self callExtendedLifeCycleFunc:kDCBaseReqApiLifeCycleFuncSuccess];
}

- (void)doDelegateFailMethod {
    if (self.delegate && [self.delegate respondsToSelector:@selector(fail:)]) {
        [self.delegate fail:self];
    }
    [self callExtendedLifeCycleFunc:kDCBaseReqApiLifeCycleFuncFail];
}

- (void)doDelegateCancelMethod {
    if (self.delegate && [self.delegate respondsToSelector:@selector(cancel:)]) {
        [self.delegate cancel:self];
    }
    [self callExtendedLifeCycleFunc:kDCBaseReqApiLifeCycleFuncCancel];
}

- (void)callSyncNextBlock:(void(^)(void))next {
    if (self.coreManager && next) {
        next();
    } else {
        if (self.coreManager) self.coreManager.isReqChainCompleted = YES;
    }
}

- (void)responceDetail:(id)res error:(NSError *)error detailResDataBlock:(DCReqDetailResData)detailResDataBlock {
    NSDictionary *resDic = NSDictionary.new;
    if ([res isKindOfClass:NSDictionary.class]) {
        resDic = (NSDictionary *)res;
    }
    if (detailResDataBlock) {
        detailResDataBlock(resDic, error);
    }
    if (!error) {
        NSString *code = [resDic objectForKey:kDCBaseReqApiResResultCode];
        if ((!dcNetWk_isEmptyString(code) && [code isEqualToString:kDCBaseReqApiResResultCode200]) || ([self respondsToSelector:@selector(requestJudge:)] && [self requestJudge:resDic])) {
            [self doDelegateSuccessMethod];
            [self callSyncNextBlock:self.successThenRequest];
        } else {
            [self doDelegateFailMethod];
            [self callSyncNextBlock:self.failThenRequest];
        }
    } else {
        [self doDelegateFailMethod];
        [self callSyncNextBlock:self.failThenRequest];
    }
    
    // 一次性使用
    self.successThenRequest = nil;
    self.failThenRequest = nil;
}

- (void)detailTaskInCompleteBlock:(id)res error:(NSError *)error detailResDataBlock:(DCReqDetailResData)detailResDataBlock task:(NSURLSessionTask *)task {
    if (!(error && error.domain == NSURLErrorDomain && error.code == NSURLErrorCancelled)) {
        // 不是主动取消请求
        id realRes = res;
        if (task && [task.response isKindOfClass:NSHTTPURLResponse.class]) {
            NSMutableDictionary *resTmp = [NSMutableDictionary new];
            if (res && [res isKindOfClass:NSDictionary.class]) {
                resTmp = [NSMutableDictionary dictionaryWithDictionary:res];
            }
            NSHTTPURLResponse *responce = (NSHTTPURLResponse *)task.response;
            [resTmp setObject:@(responce.statusCode) forKey:DCBaseReqApiResStatusCode];
            realRes = resTmp;
        }
        [self responceDetail:realRes error:error detailResDataBlock:detailResDataBlock];
    } else {
        // 请求被主动取消
        [self doDelegateCancelMethod];
        // 串行请求结束
        if (self.coreManager) self.coreManager.isReqChainCompleted = YES;
    }
    
    if (task) {
        [self.tasks removeObject:task];
        task = nil;
    }
    self.state = DCReqApiUnused; // 释放api
}

- (void)request:(DCReqMethodType)method url:(NSString *)url paras:(DCBaseReqParasModel *)paras detailResDataBlock:(DCReqDetailResData)detailResDataBlock {
    if (self.state == DCReqApiUnused && paras && paras.unPacking(self.dataClsBindModel.parasModelCls)) {
        // 修改 api 状态
        if (method == DCReqGet ||
            method == DCReqPost ||
            method == DCReqPut ||
            method == DCReqDelete) {
            self.state = DCReqApiRunning;
            // 开始请求
            [self doDelegateStartMethod];
            NSDictionary *parasDic = [paras mj_keyValues];
            __block NSURLSessionTask *task = nil;
            __weak typeof(self) weakSelf = self;
            switch (method) {
                case DCReqGet:
                {
                    task = [[DCNetAPIClient sharedClient] GET:url paramaters:parasDic CompleteBlock:^(id res, NSError *error) {
                        [weakSelf detailTaskInCompleteBlock:res error:error detailResDataBlock:detailResDataBlock task:task];
                    }];
                    break;
                }
                case DCReqPost:
                {
                    task = [[DCNetAPIClient sharedClient] POST:url paramaters:parasDic CompleteBlock:^(id res, NSError *error) {
                        [weakSelf detailTaskInCompleteBlock:res error:error detailResDataBlock:detailResDataBlock task:task];
                    }];
                    break;
                }
                case DCReqPut:
                {
                    task = [[DCNetAPIClient sharedClient] PUT:url paramaters:parasDic CompleteBlock:^(id res, NSError *error) {
                        [weakSelf detailTaskInCompleteBlock:res error:error detailResDataBlock:detailResDataBlock task:task];
                    }];
                    break;
                }
                case DCReqDelete:
                {
                    task = [[DCNetAPIClient sharedClient] DELETE:url paramaters:parasDic CompleteBlock:^(id res, NSError *error) {
                        [weakSelf detailTaskInCompleteBlock:res error:error detailResDataBlock:detailResDataBlock task:task];
                    }];
                    break;
                }
                default:
                    break;
            }
            if (task) [self.tasks addObject:task];
            return;
        }
    }
    self.state = DCReqApiUnused;
}

- (void)POST:(NSString *)url paras:(DCBaseReqParasModel *)paras detailResDataBlock:(DCReqDetailResData)detailResDataBlock {
    [self request:DCReqPost url:url paras:paras detailResDataBlock:detailResDataBlock];
}

- (void)POST:(NSString *)url paras:(DCBaseReqParasModel *)paras {
    [self request:DCReqPost url:url paras:paras detailResDataBlock:^(NSDictionary * _Nonnull resData, NSError * _Nonnull error) {
        if (resData && self.dataClsBindModel && self.dataClsBindModel.resModelCls) {
            // api 有 res属性且类型与self.dataClsBindModel.resModelCls类型一致
            // 不用担心这里的kvc操作导致崩溃 在init方法中就已经做了属性检测
            [self setValue:[self.dataClsBindModel.resModelCls mj_objectWithKeyValues:resData] forKey:kDCBaseReqApiPropertyRes];
        }
    }];
}

- (void)GET:(NSString *)url paras:(DCBaseReqParasModel *)paras detailResDataBlock:(DCReqDetailResData)detailResDataBlock {
    [self request:DCReqGet url:url paras:paras detailResDataBlock:detailResDataBlock];
}

- (void)GET:(NSString *)url paras:(DCBaseReqParasModel *)paras {
    [self request:DCReqGet url:url paras:paras detailResDataBlock:^(NSDictionary * _Nonnull resData, NSError * _Nonnull error) {
        if (resData && self.dataClsBindModel && self.dataClsBindModel.resModelCls) {
            // api 有 res属性且类型与self.dataClsBindModel.resModelCls类型一致
            // 不用担心这里的kvc操作导致崩溃 在init方法中就已经做了属性检测
            [self setValue:[self.dataClsBindModel.resModelCls mj_objectWithKeyValues:resData] forKey:kDCBaseReqApiPropertyRes];
        }
    }];
}

- (void)PUT:(NSString *)url paras:(DCBaseReqParasModel *)paras detailResDataBlock:(DCReqDetailResData)detailResDataBlock {
    [self request:DCReqPut url:url paras:paras detailResDataBlock:detailResDataBlock];
}

- (void)PUT:(NSString *)url paras:(DCBaseReqParasModel *)paras {
    [self request:DCReqPut url:url paras:paras detailResDataBlock:^(NSDictionary * _Nonnull resData, NSError * _Nonnull error) {
        if (resData && self.dataClsBindModel && self.dataClsBindModel.resModelCls) {
            // api 有 res属性且类型与self.dataClsBindModel.resModelCls类型一致
            // 不用担心这里的kvc操作导致崩溃 在init方法中就已经做了属性检测
            [self setValue:[self.dataClsBindModel.resModelCls mj_objectWithKeyValues:resData] forKey:kDCBaseReqApiPropertyRes];
        }
    }];
}

- (void)DELETE:(NSString *)url paras:(DCBaseReqParasModel *)paras detailResDataBlock:(DCReqDetailResData)detailResDataBlock {
    [self request:DCReqDelete url:url paras:paras detailResDataBlock:detailResDataBlock];
}

- (void)DELETE:(NSString *)url paras:(DCBaseReqParasModel *)paras {
    [self request:DCReqDelete url:url paras:paras detailResDataBlock:^(NSDictionary * _Nonnull resData, NSError * _Nonnull error) {
        if (resData && self.dataClsBindModel && self.dataClsBindModel.resModelCls) {
            // api 有 res属性且类型与self.dataClsBindModel.resModelCls类型一致
            // 不用担心这里的kvc操作导致崩溃 在init方法中就已经做了属性检测
            [self setValue:[self.dataClsBindModel.resModelCls mj_objectWithKeyValues:resData] forKey:kDCBaseReqApiPropertyRes];
        }
    }];
}

- (void)cancelReqs {
    for (NSURLSessionTask *task in self.tasks) {
        if (task) [task cancel];
    }
    [self.tasks removeAllObjects];
    // 以下操作 交给 cancel 回调置空
//    self.successThenRequest = nil;
//    self.failThenRequest = nil;
//    self.coreManager = nil;
}

- (DCReqChainModel *)reqPsChainModel:(DCBaseReqParasModel *)paras {
    return DCReqPsChainModelMake(self, paras);
}

- (DCReqChainModel *)reqPsCnfChainModel:(DCReqParasConfig)config {
    return DCReqPsCnfChainModelMake(self, config);
}

- (DCReqChainModel *)reqBlkChainModel:(DCReqNextBlock)block {
    return DCReqBlkChainModelMake(self, block);
}

- (id)unPacking:(Class)class {
    // 拆箱操作
    if ([self isKindOfClass:self.class] && class && [self isKindOfClass:class]) {
        return self;
    }
    return nil;
}

- (id  _Nonnull (^)(Class  _Nonnull __unsafe_unretained))unPacking {
    return ^id(Class class){
        // 拆箱操作
        return [self unPacking:class];
    };
}

+ (NSString *)className {
    return NSStringFromClass(self);
}

- (NSString *)className {
    return NSStringFromClass(self.class);
}

#pragma mark - KVC

- (id)valueForUndefinedKey:(NSString *)key {
    NSLog(@"[class]%@ has no [property]%@.", self.class, key);
    return nil;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    NSLog(@"[class]%@ has no [property]%@.", self.class, key);
}

- (void)setNilValueForKey:(NSString *)key {
    NSLog(@"[class]%@ can not set a nil value for [property]%@.", self.class, key);
}

#pragma mark - Lazy Load

- (NSMutableSet<NSURLSessionTask *> *)tasks {
    if (!_tasks) {
        _tasks = NSMutableSet.new;
    }
    return _tasks;
}


#pragma mark - dealloc

- (void)dealloc
{
    [self cancelReqs];
}

@end

#pragma mark - DCReqPlaceholderApi

@implementation DCReqPlaceholderApi

@end

#pragma mark - DCReqCoreManager

@implementation DCReqCoreManager

- (instancetype)initCoreManager
{
    self = [super init];
    if (self) {
        _isReqChainCompleted = YES;
    }
    return self;
}

- (instancetype)requestThen:(BOOL)isSuccessRequest reqChainModel:(DCReqChainModel *)reqChainModel {
    void (^requestThen)(void);
    DCBaseReqApi *lastApi = self.lastApi; // 重要 防止后面修改self.lastApi
    if (self.lastApi && reqChainModel.api) {
        if (self.lastApi == DCReqPlhApi) return self; // 上一个是DCReqPlaceholderApi 直接返回
        if (reqChainModel.api != DCReqPlhApi) {
            [self.apis addObject:reqChainModel.api];
            if (reqChainModel.parasConfig && [reqChainModel.api respondsToSelector:@selector(request:)]) {
                requestThen = ^{
                    [reqChainModel.api request:DCBaseReqParasModelMake(reqChainModel.api.dataClsBindModel.parasModelCls, reqChainModel.parasConfig)];
                };
            } else if (reqChainModel.paras && [reqChainModel.api respondsToSelector:@selector(request:)]) {
                requestThen = ^{
                    [reqChainModel.api request:reqChainModel.paras];
                };
            } else {
                if (reqChainModel.block) {
                    requestThen = ^{
                        reqChainModel.block(lastApi);
                    };
                }
            }
            if (requestThen) {
                reqChainModel.api.coreManager = self;
                if (isSuccessRequest) {
                    self.lastApi.successThenRequest = requestThen;
                } else {
                    self.lastApi.failThenRequest = requestThen;
                }
                self.lastApi = reqChainModel.api;
                return self;
            }
        } else {
            // 如果是DCReqPlaceholderApi，只考虑block的参数形式，适用于动态串行调用
            if (reqChainModel.block) {
                requestThen = ^{
                    reqChainModel.block(lastApi);
                };
                reqChainModel.api.coreManager = self;
                if (isSuccessRequest) {
                    self.lastApi.successThenRequest = requestThen;
                } else {
                    self.lastApi.failThenRequest = requestThen;
                }
                self.lastApi = reqChainModel.api;
                return self;
            }
        }
    }
    return self;
}

- (DCReqCoreManager * _Nonnull (^)(DCReqChainModel * _Nonnull))successThen {
    return ^DCReqCoreManager *(DCReqChainModel *reqChainModel) {
        return [self requestThen:YES reqChainModel:reqChainModel];
    };
}

- (void (^)(DCReqNextBlock _Nonnull))dynSuccessThen {
    return ^(DCReqNextBlock next) {
        self.successThen(DCReqBlkChainModelMake(DCReqPlhApi, next));
    };
}

- (DCReqCoreManager * _Nonnull (^)(Class  _Nonnull __unsafe_unretained, DCReqParasConfig _Nonnull))stApiCnf_successThen {
    return ^DCReqCoreManager *(Class apiCls, DCReqParasConfig config) {
        DCBaseReqApi *api = self.apiStore.apiMake(apiCls);
        if (api) {
            return self.successThen(DCReqPsCnfChainModelMake(api, config));
        }
        return self;
    };
}

- (DCReqCoreManager * _Nonnull (^)(Class  _Nonnull __unsafe_unretained, NSDictionary * _Nonnull))stApiDic_successThen {
    return ^DCReqCoreManager *(Class apiCls, NSDictionary *dic) {
        DCBaseReqApi *api = self.apiStore.apiMake(apiCls);
        if (api) {
            DCBaseReqParasModel *paras = [api.dataClsBindModel.parasModelCls mj_objectWithKeyValues:dic];
            if (paras) {
                return self.successThen(DCReqPsChainModelMake(api, paras));
            }
        }
        return self;
    };
}

- (DCReqCoreManager * _Nonnull (^)(DCReqChainModel * _Nonnull))failThen {
    return ^DCReqCoreManager *(DCReqChainModel *reqChainModel) {
        return [self requestThen:NO reqChainModel:reqChainModel];
    };
}

- (void (^)(DCReqNextBlock _Nonnull))dynFailThen {
    return ^(DCReqNextBlock next) {
        self.failThen(DCReqBlkChainModelMake(DCReqPlhApi, next));
    };
}

- (DCReqCoreManager * _Nonnull (^)(Class  _Nonnull __unsafe_unretained, DCReqParasConfig _Nonnull))stApiCnf_failThen {
    return ^DCReqCoreManager *(Class apiCls, DCReqParasConfig config) {
        DCBaseReqApi *api = self.apiStore.apiMake(apiCls);
        if (api) {
            return self.failThen(DCReqPsCnfChainModelMake(api, config));
        }
        return self;
    };
}

- (DCReqCoreManager * _Nonnull (^)(Class  _Nonnull __unsafe_unretained, NSDictionary * _Nonnull))stApiDic_failThen {
    return ^DCReqCoreManager *(Class apiCls, NSDictionary *dic) {
        DCBaseReqApi *api = self.apiStore.apiMake(apiCls);
        if (api) {
            DCBaseReqParasModel *paras = [api.dataClsBindModel.parasModelCls mj_objectWithKeyValues:dic];
            if (paras) {
                return self.failThen(DCReqPsChainModelMake(api, paras));
            }
        }
        return self;
    };
}

- (DCReqCoreManager * _Nonnull (^)(void (^ _Nonnull)(void)))completeThen {
    return ^DCReqCoreManager *(void(^completeThen)(void)) {
        self.didEndCallback = completeThen;
        return self;
    };
}

- (void (^)(void))fire {
    return ^{
        if (self->_isReqChainCompleted) {
            self->_isReqChainCompleted = NO;
            self.startRequest(self.firstApi);
        }
    };
}

#pragma mark - setter

- (void)setIsReqChainCompleted:(BOOL)isReqChainCompleted {
    if (_isReqChainCompleted != isReqChainCompleted) {
        _isReqChainCompleted = isReqChainCompleted;
        if (isReqChainCompleted) {
            for (DCBaseReqApi *api in self.apis) {
                if (api) {
                    api.successThenRequest = nil;
                    api.failThenRequest = nil;
                    api.coreManager = nil;
                }
            }
            [self.apis removeAllObjects];
            if (self.didEndCallback) self.didEndCallback();
        }
    }
}

- (NSHashTable<DCBaseReqApi *> *)apis {
    if (!_apis) {
        // 弱引用
        _apis = [NSHashTable hashTableWithOptions:NSPointerFunctionsWeakMemory];
    }
    return _apis;
}

@end

#pragma mark - DCReqManager：DCReqManager会使用DCReqCoreManager私有属性

@interface DCReqManager ()

@property (nonatomic, strong) DCReqCoreManager *coreManager; // 强引用 持有

@end

@implementation DCReqManager

static DCReqManager *dc_reqManager = nil;

+ (DCReqManager *)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dc_reqManager = self.new;
    });
    return dc_reqManager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.coreManager.apiStore = DCReqApiStore.new;
    }
    return self;
}

- (DCReqCoreManager * _Nonnull (^)(DCReqChainModel * _Nonnull))sync {
    return ^DCReqCoreManager *(DCReqChainModel *reqChainModel) {
        if (reqChainModel.api && self.coreManager.isReqChainCompleted) {
            reqChainModel.api.coreManager = self.coreManager;
            self.coreManager.lastApi = reqChainModel.api;
            self.coreManager.firstApi = reqChainModel.api;
            [self.coreManager.apis addObject:reqChainModel.api];
            void (^startRequest)(DCBaseReqApi *);
            if (reqChainModel.parasConfig && [reqChainModel.api respondsToSelector:@selector(request:)]) {
                startRequest = ^(DCBaseReqApi *api){
                    [reqChainModel.api request:DCBaseReqParasModelMake(reqChainModel.api.dataClsBindModel.parasModelCls, reqChainModel.parasConfig)];
                };
            } else if (reqChainModel.paras && [reqChainModel.api respondsToSelector:@selector(request:)]) {
                startRequest = ^(DCBaseReqApi *api){
                    [reqChainModel.api request:reqChainModel.paras];
                };
            } else {
                if (reqChainModel.block) {
                    startRequest = ^(DCBaseReqApi *api){
                        reqChainModel.block(api);
                    };
                }
            }
            if (startRequest) {
                self.coreManager.startRequest = startRequest;
                return self.coreManager;
            }
        }
        return self.coreManager;
    };
}

- (DCReqCoreManager * _Nonnull (^)(Class  _Nonnull __unsafe_unretained, DCReqParasConfig _Nonnull))stApiCnf_sync {
    return ^DCReqCoreManager *(Class apiCls, DCReqParasConfig config) {
        DCBaseReqApi *api = self.apiStore.apiMake(apiCls);
        if (api) {
            return self.sync(DCReqPsCnfChainModelMake(api, config));
        }
        return self.coreManager;
    };
}

- (DCReqCoreManager * _Nonnull (^)(Class  _Nonnull __unsafe_unretained, NSDictionary * _Nonnull))stApiDic_sync {
    return ^DCReqCoreManager *(Class apiCls, NSDictionary *dic) {
        DCBaseReqApi *api = self.apiStore.apiMake(apiCls);
        if (api) {
            DCBaseReqParasModel *paras = [api.dataClsBindModel.parasModelCls mj_objectWithKeyValues:dic];
            if (paras) {
                return self.sync(DCReqPsChainModelMake(api, paras));
            }
        }
        return self.coreManager;
    };
}

- (DCReqCoreManager * _Nonnull (^)(DCBaseReqApi * _Nonnull))prepare {
    return ^DCReqCoreManager*(DCBaseReqApi *api) {
        if (api && api.coreManager && api.coreManager == self.coreManager) {
            self.coreManager.lastApi = api;
        }
        return self.coreManager;
    };
}

- (DCReqCoreManager * _Nonnull (^)(void (^ _Nonnull)(void)))completeThen {
    return ^DCReqCoreManager *(void(^completeThen)(void)) {
        self.coreManager.didEndCallback = completeThen;
        return self.coreManager;
    };
}

- (DCReqCoreManager * _Nonnull (^)(DCBaseReqApi * _Nonnull))dynPrepare {
    return ^DCReqCoreManager*(DCBaseReqApi *api) {
        if (api) {
            // 动态串行调用之后的设置 此时定位到的api是还未设置好的 需要手动设置
            self.coreManager.lastApi = api;
            api.coreManager = self.coreManager;
            [self.coreManager.apis addObject:api];
        }
        return self.coreManager;
    };
}

- (DCReqCoreManager * _Nonnull (^)(Class  _Nonnull __unsafe_unretained))stApi_prepare {
    return ^DCReqCoreManager*(Class cls) {
        return self.prepare(self.apiStore.apiMake(cls));
    };
}

- (DCReqCoreManager * _Nonnull (^)(Class  _Nonnull __unsafe_unretained))stApi_dynPrepare {
    return ^DCReqCoreManager*(Class cls) {
        return self.dynPrepare(self.apiStore.apiMake(cls));
    };
}

- (void (^)(void))fire {
    return ^{
        self.coreManager.fire();
    };
}

- (BOOL)isReqChainCompleted {
    return self.coreManager.isReqChainCompleted;
}

- (DCReqApiStore *)apiStore {
    return self.coreManager.apiStore;
}

- (BOOL (^)(DCBaseReqApi * _Nonnull, NSString * _Nonnull))checkApiTag {
    return ^BOOL(DCBaseReqApi *api, NSString *tag) {
        return api == self.apiStore.api(tag);
    };
}

- (void (^)(Class  _Nonnull __unsafe_unretained, DCReqParasConfig _Nonnull))stApiCnf_request {
    return ^(Class cls, DCReqParasConfig config) {
        DCBaseReqApi *api = self.apiStore.apiMake(cls);
        if (api) {
            DCBaseReqParasModel *paras = DCBaseReqParasModelMake(api.dataClsBindModel.parasModelCls, config);
            if (paras) {
                [api request:paras];
            }
        }
    };
}

- (void (^)(Class  _Nonnull __unsafe_unretained, NSDictionary * _Nonnull))stApiDic_request {
    return ^(Class cls, NSDictionary *dic) {
        DCBaseReqApi *api = self.apiStore.apiMake(cls);
        if (api) {
            DCBaseReqParasModel *paras = [api.dataClsBindModel.parasModelCls mj_objectWithKeyValues:dic];
            if (paras) {
                [api request:paras];
            }
        }
    };
}

- (void)cancelReqs {
    for (DCBaseReqApi *api in self.coreManager.apis) {
        [api cancelReqs];
    }
}

#pragma mark - lazy load

- (DCReqCoreManager *)coreManager {
    if (!_coreManager) {
        _coreManager = [[DCReqCoreManager alloc] initCoreManager];
    }
    return _coreManager;
}

#pragma mark - dealloc

- (void)dealloc
{
    [self cancelReqs];
}

@end
