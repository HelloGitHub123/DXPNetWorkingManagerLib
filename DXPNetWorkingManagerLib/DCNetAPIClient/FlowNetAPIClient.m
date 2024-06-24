//
//  DMNetAPIClint.m
//  DataMall
//
//  Created by 刘伯洋 on 16/1/4.
//  Copyright © 2016年 刘伯洋. All rights reserved.
//

#import "FlowNetAPIClient.h"
#import "NSObject+ObjectMap_Net.h"
#import "NSString+Additions_Net.h"
#import "DCNetworkHeader.h"
#import <DXPToolsLib/SNAlertMessage.h>
#import <DXPToolsLib/HJMBProgressHUD.h>
#import <DXPToolsLib/HJMBProgressHUD+Category.h>

@implementation FlowNetAPIClient

static FlowNetAPIClient *_sharedClient = nil;
static dispatch_once_t onceToken;

+ (void)destroySharedClient {
    _sharedClient = nil;
    onceToken = 0l;
}

+ (FlowNetAPIClient *)sharedClient {
    dispatch_once(&onceToken, ^{
        _sharedClient = [[FlowNetAPIClient alloc] init];
    });
    return _sharedClient;
}

- (void)setBaseUrl:(NSString *)baseUrl{
    _baseUrl = baseUrl;
    [self initWithBaseURL:[NSURL URLWithString:baseUrl]];
}

- (void)setDcMD5SerectStr:(NSString *)dcMD5SerectStr{
    _dcMD5SerectStr = dcMD5SerectStr;
}

- (void)setToken:(NSString *)token {
	_token = token;
}

- (void)initWithBaseURL:(NSURL *)url {
    if (!self) {
        return ;
    }
    _httpManager = [[AFHTTPSessionManager alloc] initWithBaseURL:url];
    self.httpManager.responseSerializer = [AFHTTPResponseSerializer serializer];
    self.httpManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/plain", @"text/javascript", @"text/json", @"text/html",@"image/jpeg", @"image/png",@"image/jpg",@"application/octet-stream",@"application/pdf", nil];
    self.httpManager.requestSerializer = [AFJSONRequestSerializer serializer];
    [self.httpManager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [self.httpManager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [self.httpManager.requestSerializer setValue:url.absoluteString forHTTPHeaderField:@"Referer"];
    self.httpManager.securityPolicy.allowInvalidCertificates = YES;
    self.httpManager.securityPolicy.validatesDomainName = NO;
}

- (void)requestJsonDataWithPath:(NSString *)aPath
                     withParams:(NSDictionary*)params
                 withMethodType:(KNetworkMethod)method
                        elementPath:(NSString *)elementPath
                       andBlock:(void (^)(id data, NSError *error))block {
    [self requestJsonDataWithPath:aPath withParams:params withMethodType:method elementPath:elementPath autoShowError:YES andBlock:block];
}

- (void)requestJsonDataWithPath:(NSString *)aPath
                     withParams:(NSDictionary*)params
                 withMethodType:(KNetworkMethod)method
                        elementPath:(NSString *)elementPath
                  autoShowError:(BOOL)autoShowError
                       andBlock:(void (^)(id data, NSError *error))block {
    if (!aPath || aPath.length <= 0) {
        return;
    }
    //log请求数据
//    aPath = [aPath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    aPath = [aPath stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [FlowNetAPIClient addHttpHeader:aPath];

    //添加权限管理头部信息
    [self.httpManager.requestSerializer setValue:elementPath forHTTPHeaderField:@"element"];
    [self.httpManager.requestSerializer setValue:@"USER" forHTTPHeaderField:@"user-role"];
    [self.httpManager.requestSerializer setValue:@"2" forHTTPHeaderField:@"terminal-Type"];
    [self.httpManager.requestSerializer setValue:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"] forHTTPHeaderField:@"appVersion"];
        
    switch (method) {
        case KGet:{
            DDLog(@"\n===========request===========\n%@ %@:%@", @"GET", aPath, params);
            //所有 Get 请求，增加缓存机制
            NSMutableString *localPath = [aPath mutableCopy];
            __block NSMutableString * aPathStr = [aPath mutableCopy];
            if (params) {
                [localPath appendString:params.description];
                aPathStr = [[aPath stringByAppendingString:@"?"] mutableCopy];
                [params enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                    aPathStr = [[aPathStr stringByAppendingString:[NSString stringWithFormat:@"%@=%@&",key,obj]] mutableCopy];
                    
                }];
                
                aPathStr = [[aPathStr substringToIndex:aPathStr.length-1] mutableCopy];
            }
            
            NSString * apathNew = [aPathStr stringByReplacingOccurrencesOfString:@"/ecare/" withString:@"/"];
            apathNew = [apathNew stringByReplacingOccurrencesOfString:@"ecare/" withString:@"/"];
            _dcMD5SerectStr = dcIsEmptyString(_dcMD5SerectStr)?@"32BytesString":_dcMD5SerectStr;
            NSString * token = dcIsEmptyString(self.token)?@"":self.token;
            DDLog(@"=========aPathStr========%@",apathNew);
            
            NSString * md5str = [NSString stringWithFormat:@"%@%@%@",[NSString stringWithFormat:@"%@",apathNew],token,_dcMD5SerectStr];//登录成功后获取token
            NSString * authToken  = [md5str SHA256];
            [self.httpManager.requestSerializer setValue:authToken forHTTPHeaderField:@"signcode"];
            
            [self.httpManager GET:aPathStr parameters:nil headers:nil progress:^(NSProgress * _Nonnull downloadProgress) {
                
            } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                DDLog(@"\n===========response===========\n%@ \n%@", aPath, responseObject);
                block(responseObject, nil);

            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                DDLog(@"\n===========response===========\n%@:\n%@", aPath, error);
                block(nil, error);
            }];
            break;
        }
        case KPost:{
            NSString * codeSign = [self dictionaryToJson:params];
            NSRegularExpression *regular = [NSRegularExpression regularExpressionWithPattern:@"[^a-zA-Z0-9]" options:0 error:NULL];
            codeSign = [regular stringByReplacingMatchesInString:codeSign options:0 range:NSMakeRange(0, [codeSign length]) withTemplate:@""];
            codeSign = [codeSign stringByReplacingOccurrencesOfString:@"null" withString:@""];
            NSString * apathNew = [aPath stringByReplacingOccurrencesOfString:@"/ecare/" withString:@"/"];
            apathNew = [apathNew stringByReplacingOccurrencesOfString:@"ecare/" withString:@"/"];
            NSString * token = dcIsEmptyString(self.token)?@"":self.token;
            
            NSString * md5str = [NSString stringWithFormat:@"%@%@%@%@",apathNew,codeSign,token,@"32BytesString"];//登录成功后获取token
            NSString * authToken  = [md5str SHA256];
            [self.httpManager.requestSerializer setValue:authToken forHTTPHeaderField:@"signcode"];
            
            DDLog(@"\n===========request===========\n%@\n%@\n%@:\n%@", @"POST", aPath, params,self.httpManager.requestSerializer.HTTPRequestHeaders);

            [self.httpManager POST:aPath parameters:params headers:nil progress:^(NSProgress * _Nonnull uploadProgress) {
                
            } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                DDLog(@"\n===========response===========\n%@ \n%@", aPath, responseObject);
                block(responseObject, nil);
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                DDLog(@"\n===========response===========\n%@:\n%@", aPath, error);
                block(nil, error);
            }];
            break;
        }
       
        default:
            break;
    }
}

- (void)GET:(NSString *)url paramaters:(NSDictionary *)paramaters CompleteBlock:(CompleteBlock)completeBlock {
    [self requestJsonDataWithPath:url withParams:paramaters withMethodType:KGet elementPath:@"" andBlock:completeBlock];
}

- (void)GET:(NSString *)url CompleteBlock:(CompleteBlock)completeBlock {
    
    [self requestJsonDataWithPath:url withParams:nil withMethodType:KGet elementPath:@"" andBlock:completeBlock];
}

- (void)POST:(NSString *)url paramaters:(NSDictionary *)paramaters CompleteBlock:(CompleteBlock)completeBlock {
    
    [self requestJsonDataWithPath:url withParams:paramaters withMethodType:KPost elementPath:@"" andBlock:completeBlock];
}

#pragma mark -- fuction
-(NSString*)stringWithDict:(NSDictionary*)dict{
    NSArray*keys = [dict allKeys];
    NSArray*sortedArray = [keys sortedArrayUsingComparator:^NSComparisonResult(id obj1,id obj2) {
        return[obj1 compare:obj2 options:NSNumericSearch];
        
    }];
    NSString*str =@"";
    for(NSString*categoryId in sortedArray) {
        id value = [dict objectForKey:categoryId];
        if([value isKindOfClass:[NSDictionary class]]) {
            value = [self stringWithDict:value];}//
        DDLog(@"[dict objectForKey:categoryId] === %@",[dict objectForKey:categoryId]);
        if([str length] !=0) {
            str = [str stringByAppendingString:@";"];
            
        }
        str = [str stringByAppendingFormat:@"%@:%@",categoryId,value];
        
    }
    return str;
    
}
    

#pragma mark - 字典转字符串
-(NSString*)dictionaryToJson:(NSDictionary *)dic
{
    NSError *parseError = nil;
    if (!dic) {
        return @"";
    }
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:0 error:&parseError];
    
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}
                  
#pragma mark - 字符串转字典
- (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString
{
    if (jsonString == nil) {
        return nil;
    }
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
    if(err) {
        DDLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}
//添加头部，生成签名
+ (void)addHttpHeader:(NSString *)url {
    
    if ([url containsString:@"?"]) {
        NSArray *list = [url componentsSeparatedByString:@"?"];
        url = [list objectAtIndex:0];
    }
    
    long long time = [self getDateTimeTOMilliSeconds:[NSDate date]];
    
    NSString *curTime = [[NSString alloc] initWithFormat:@"%lld", time];

    [[self sharedClient].httpManager.requestSerializer setValue:curTime forHTTPHeaderField:@"timestamp"];
    
    NSString *accesstoken = @"";
    
    if (accesstoken.length) {
        [[self sharedClient].httpManager.requestSerializer setValue:accesstoken forHTTPHeaderField:@"authtoken"];
        NSString *securityKey = @"";//[HJAppDataManager sharedInstance].userInfo.securityKey;
        if (securityKey.length) {
            //accesstoken + timestamp + url
            NSString *temp = [NSString stringWithFormat:@"%@%@%@", accesstoken, curTime, url] ;
            NSString *sign = [SecurityUtil_Net generateHmacSHA256Signature:temp key:securityKey];
            [[self sharedClient].httpManager.requestSerializer setValue:sign forHTTPHeaderField:@"sign"];
        }
    }else{
        [[self sharedClient].httpManager.requestSerializer setValue:@"" forHTTPHeaderField:@"authtoken"];
    }
//    [[self sharedClient].httpManager.requestSerializer setValue:[Tools getSSKeyUUID] forHTTPHeaderField:@"Meid"];
    [[self sharedClient].httpManager.requestSerializer setValue:@"ios" forHTTPHeaderField:@"Device-Type"];
}

+ (void)userAddRequestHeader:(NSString *)headerStr forHeadFieldName:(NSString *)headerFieldName{
    [[self sharedClient].httpManager.requestSerializer setValue:headerStr forHTTPHeaderField:headerFieldName];
}

+(NSDate *)getDateTimeFromMilliSeconds:(long long) miliSeconds{
    NSTimeInterval tempMilli = miliSeconds;
    NSTimeInterval seconds = tempMilli/1000.0;//这里的.0一定要加上，不然除下来的数据会被截断导致时间不一致
    return [NSDate dateWithTimeIntervalSince1970:seconds];
    
}

//将NSDate类型的时间转换为时间戳,从1970/1/1开始
+(long long)getDateTimeTOMilliSeconds:(NSDate *)datetime{
    NSTimeInterval interval = [datetime timeIntervalSince1970];
    long long totalMilliseconds = interval*1000 ;
    return totalMilliseconds;
    
}

- (NSString *)uploadingData: (NSString *)absoluteFilePath {

//    NSArray *directoryPathsArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *documentsDirectory = [directoryPathsArray objectAtIndex:0];
//
//    NSString *absoluteFilePath = [NSString stringWithFormat:@"%@/%@/%@", documentsDirectory, baseDirName, fileName];

    NSInputStream *inputStream = [NSInputStream inputStreamWithFileAtPath:absoluteFilePath];
    [inputStream open];

    uint8_t buffer[1024];

    int len;

    NSMutableString *total = [[NSMutableString alloc] init];

    while ([inputStream hasBytesAvailable]) {
        len = [inputStream read:buffer maxLength:sizeof(buffer)];

        if (len > 0) {
             [total appendString: [[NSString alloc] initWithBytes:buffer length:len encoding:NSASCIIStringEncoding]];
        }
    }


    NSData *plainData = [total dataUsingEncoding:NSUTF8StringEncoding];
    NSString *base64String = [plainData base64EncodedStringWithOptions:0];

    return base64String;
// Adding to JSON and upload goes here.
}

- (AFHTTPSessionManager *)httpManager{
    if (!_httpManager) {
        _httpManager = [[AFHTTPSessionManager alloc] init];
    }
    return _httpManager;
}

- (id)handleResponse:(id)responseJSON autoShowError:(BOOL)autoShowError {
    NSError *error = nil;
    //code为非0值时，表示有错
    int resultCode=0;
    @try {
        if (!DCIsNull([responseJSON valueForKeyPath:@"code"])) {
            resultCode = ((NSNumber *)[responseJSON valueForKeyPath:@"code"]).intValue;
        }
    }@catch (NSException *exception) {}
    
    if (resultCode != 0) {
        if (resultCode == 1000) {
            //用户未登录
//            if ([Login isLogin]) {
//                //已登录的状态要抹掉
//                [Login doLogout];
//                [((AppDelegate *)[UIApplication sharedApplication].delegate) setupLoginViewController];
//            }
        } else {
            //显示错误
        }
    }
    return error;
}
@end
