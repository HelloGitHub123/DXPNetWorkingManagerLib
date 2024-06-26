//
//  DMNetAPIClint.m
//  DataMall
//
//  Created by 刘伯洋 on 16/1/4.
//  Copyright © 2016年 刘伯洋. All rights reserved.
//

#import "DCNetAPIClient.h"
#import "NSObject+ObjectMap_Net.h"
#import "NSString+Additions_Net.h"
#import "DCNetworkHeader.h"
#import <DXPToolsLib/SNAlertMessage.h>
#import <DXPToolsLib/HJMBProgressHUD.h>
#import <DXPToolsLib/HJMBProgressHUD+Category.h>

@implementation DCNetAPIClient

static DCNetAPIClient *_sharedClient = nil;
static dispatch_once_t onceToken;

static DCNetAPIClient *_sharedMockClient = nil;
static dispatch_once_t onceTokenForMock;

static DCNetAPIClient *_sharedUcClient = nil;
static dispatch_once_t onceTokenForUC;

+ (void)destroySharedClient {
    _sharedClient = nil;
    _sharedMockClient = nil;
    _sharedUcClient = nil;
    onceToken = 0l;
    onceTokenForMock = 0l;
    onceTokenForUC = 0l;
}

+ (DCNetAPIClient *)sharedClient {
    dispatch_once(&onceToken, ^{
        _sharedClient = [[DCNetAPIClient alloc] init];
    });
    return _sharedClient;
}

+ (DCNetAPIClient *)sharedMockClient {
    dispatch_once(&onceTokenForMock, ^{
        _sharedMockClient = [[DCNetAPIClient alloc] init];
    });
    return _sharedMockClient;
}

+ (DCNetAPIClient *)sharedUcClient {
    dispatch_once(&onceTokenForUC, ^{
        _sharedUcClient = [[DCNetAPIClient alloc] init];
    });
    return _sharedUcClient;
}

- (void)setToken:(NSString *)token {
	_token = token;
}

- (void)setBaseUrl:(NSString *)baseUrl{
    _baseUrl = baseUrl;
    [self initWithBaseURL:[NSURL URLWithString:baseUrl]];
}

- (void)setDcMD5SerectStr:(NSString *)dcMD5SerectStr{
    _dcMD5SerectStr = dcMD5SerectStr;
}

- (void)initWithBaseURL:(NSURL *)url {
    if (!self) {
        return ;
    }

    _httpManager = [[AFHTTPSessionManager alloc] initWithBaseURL:url];
    self.httpManager.responseSerializer = [AFJSONResponseSerializer serializer];//[AFHTTPResponseSerializer serializer];
//    ((AFJSONResponseSerializer *)self.httpManager.responseSerializer).removesKeysWithNullValues= YES;
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
                 withMethodType:(DCNetworkMethod)method
                        elementPath:(NSString *)elementPath
                       andBlock:(void (^)(id data, NSError *error))block {
    [self requestJsonDataWithPath:aPath withParams:params withMethodType:method elementPath:elementPath autoShowError:YES andBlock:block];
}

- (void)requestJsonDataWithPath:(NSString *)aPath
                     withParams:(NSDictionary*)params
                 withMethodType:(DCNetworkMethod)method
                        elementPath:(NSString *)elementPath
                  autoShowError:(BOOL)autoShowError
                       andBlock:(void (^)(id data, NSError *error))block {
    if (!aPath || aPath.length <= 0) {
        return;
    }
    //log请求数据
//    aPath = [aPath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    aPath = [aPath stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [DCNetAPIClient addHttpHeader:aPath];
    
    if ([aPath containsString:@"/online/zoloz/realId/initialize"] || [aPath containsString:@"/online/zoloz/realId/checkresult"]) {
        self.httpManager.requestSerializer.timeoutInterval = 30;
    } else {
        self.httpManager.requestSerializer.timeoutInterval = 60;
    }

    //添加权限管理头部信息
    [self.httpManager.requestSerializer setValue:elementPath forHTTPHeaderField:@"element"];
    [self.httpManager.requestSerializer setValue:@"USER" forHTTPHeaderField:@"user-role"];
    [self.httpManager.requestSerializer setValue:@"2" forHTTPHeaderField:@"terminal-Type"];
    [self.httpManager.requestSerializer setValue:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"] forHTTPHeaderField:@"appVersion"];
    if (!dcIsEmptyString([[NSUserDefaults standardUserDefaults] valueForKey:@"LastModified"])) {
        [self.httpManager.requestSerializer setValue:[[NSUserDefaults standardUserDefaults] valueForKey:@"LastModified"] forHTTPHeaderField:@"If-Modified-Since"];
    }
    if ([aPath containsString:@"/property/cx/property.json"] || ([aPath containsString:@"/i18n/app"] && [aPath containsString:@"/local.json"])) {
        self.httpManager.requestSerializer.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
    } else {
        self.httpManager.requestSerializer.cachePolicy = NSURLRequestUseProtocolCachePolicy;
    }
    switch (method) {
        case Get:{
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
            NSString * token = dcIsEmptyString(self.token)?@"":self.token;
            
            NSString * apathNew = [aPathStr stringByReplacingOccurrencesOfString:@"/ecare/" withString:@"/"];
            if ([apathNew containsString:@"mccm-outerfront/dmc/"]) {
                NSTimeInterval interval = [[NSDate date] timeIntervalSince1970];
                long long totalMilliseconds = interval*1000 ;
                NSString *curTime = [[NSString alloc] initWithFormat:@"%lld", totalMilliseconds];
                token = [NSString stringWithFormat:@"%@%@",curTime,token];
            }
            
            apathNew = [apathNew stringByReplacingOccurrencesOfString:@"/mccm-outerfront/dmc/" withString:@"/"];
            apathNew = [apathNew stringByReplacingOccurrencesOfString:@"mccm-outerfront/dmc/" withString:@"/"];
            
            apathNew = [apathNew stringByReplacingOccurrencesOfString:@"ecare/" withString:@"/"];
            _dcMD5SerectStr = dcIsEmptyString(_dcMD5SerectStr)?@"32BytesString":_dcMD5SerectStr;
           
            DDLog(@"=========aPathStr========%@",apathNew);
            
            if ([aPath containsString:@"promotion-rest-boot"]) {
                NSArray *pathList = [apathNew componentsSeparatedByString:@"/promotion-rest-boot"];
                apathNew = pathList[1];
            }
            
            NSString * md5str = [NSString stringWithFormat:@"%@%@%@",[NSString stringWithFormat:@"%@",apathNew],token,_dcMD5SerectStr];//登录成功后获取token
            NSString *authToken  = [md5str SHA256];
            
            [self.httpManager.requestSerializer setValue:authToken forHTTPHeaderField:@"signcode"];
            
            DDLog(@"\n===========request===========\n%@\n%@\n%@:\n%@", kDCNetworkMethodName[method], aPath, params,self.httpManager.requestSerializer.HTTPRequestHeaders);
            [self.httpManager GET:aPathStr parameters:nil headers:nil progress:^(NSProgress * _Nonnull downloadProgress) {
                
            } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                
                if (![aPathStr containsString:@"common/file/acquire"]) {
                    DDLog(@"\n===========response===========\n%@ \n%@", aPath, responseObject);

                }
                id error = [self handleResponse:responseObject autoShowError:autoShowError];
                if (error) {
                    block(responseObject, error);
                } else {
//                    block(responseObject, nil);
                    [self successRequestWithTask:task res:responseObject block:block];
                }
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                DDLog(@"\n===========response===========\n%@:", aPath);
                
                NSData * data = error.userInfo[@"com.alamofire.serialization.response.error.data"];
//                if (data) {
                    [self failRequestWithTask:task error:error block:block];
//                }
            }];
            break;
        }
        case Post:{
            NSString * token = dcIsEmptyString(self.token)?@"":self.token;
            // 参数处理
            NSString * codeSign = [self dictionaryToJson:params];
            NSRegularExpression *regular = [NSRegularExpression regularExpressionWithPattern:@"[^a-zA-Z0-9]" options:0 error:NULL];
            codeSign = [regular stringByReplacingMatchesInString:codeSign options:0 range:NSMakeRange(0, [codeSign length]) withTemplate:@""];
            codeSign = [codeSign stringByReplacingOccurrencesOfString:@"null" withString:@""];
            // URL处理
            NSString * apathNew = [aPath stringByReplacingOccurrencesOfString:@"/ecare/" withString:@"/"];
            if ([apathNew containsString:@"mccm-outerfront/dmc/"]) {
                NSTimeInterval interval = [[NSDate date] timeIntervalSince1970];
                long long totalMilliseconds = interval*1000 ;
                NSString *curTime = [[NSString alloc] initWithFormat:@"%lld", totalMilliseconds];
                token = [NSString stringWithFormat:@"%@%@",curTime,token];
            }
            apathNew = [apathNew stringByReplacingOccurrencesOfString:@"/mccm-outerfront/dmc/" withString:@"/"];
            apathNew = [apathNew stringByReplacingOccurrencesOfString:@"mccm-outerfront/dmc/" withString:@"/"];
            apathNew = [apathNew stringByReplacingOccurrencesOfString:@"ecare/" withString:@"/"];
            
            NSString * authToken = @"";
            if ([aPath containsString:@"promotion-rest-boot"]) {
                NSArray *pathList = [apathNew componentsSeparatedByString:@"/promotion-rest-boot"];
                apathNew = pathList[1];
                NSString *md5str = [NSString stringWithFormat:@"%@%@%@%@",apathNew,codeSign,token,@"32BytesString"];//GCP接口签名
                authToken = [md5str SHA256];
            } else {
                NSString *md5str = [NSString stringWithFormat:@"%@%@%@%@",apathNew,codeSign,token,@"32BytesString"];//登录成功后获取token
                authToken = [md5str SHA256];
            }
            
            [self.httpManager.requestSerializer setValue:authToken forHTTPHeaderField:@"signcode"];
            
            DDLog(@"\n===========request===========\n%@\n%@\n%@:\n%@", kDCNetworkMethodName[method], aPath, params,self.httpManager.requestSerializer.HTTPRequestHeaders);

            [self.httpManager POST:aPath parameters:params headers:nil progress:^(NSProgress * _Nonnull uploadProgress) {
                
            } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                DDLog(@"\n===========response===========\n%@:\n%@", aPath, responseObject);
                
                id error = [self handleResponse:responseObject autoShowError:autoShowError];
                if (error) {
//                    block(nil, error);
                    [self failRequestWithTask:task error:error block:block];
                } else {
                    [self successRequestWithTask:task res:responseObject block:block];
                }
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                [self failRequestWithTask:task error:error block:block];
            }];
            break;
        }
       
        default:
            break;
    }
}

- (void)uploadImgWithPath:(NSString *)aPath
                     withImg:(UIImage*)uploadImage
                 withMethodType:(DCNetworkMethod)method
                        elementPath:(NSString *)elementPath
                  autoShowError:(BOOL)autoShowError
                 andBlock:(void (^)(id data, NSError *error))block{
    
    if (!aPath || aPath.length <= 0) {
        return;
    }
    //log请求数据
    aPath = [aPath stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [DCNetAPIClient addHttpHeader:aPath];
    //添加权限管理头部信息
    [self.httpManager.requestSerializer setValue:elementPath forHTTPHeaderField:@"element"];
    [self.httpManager.requestSerializer setValue:@"USER" forHTTPHeaderField:@"user-role"];
    [self.httpManager.requestSerializer setValue:@"2" forHTTPHeaderField:@"terminal-Type"];
    [self.httpManager.requestSerializer setValue:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"] forHTTPHeaderField:@"appVersion"];
        
    switch (method) {
        case PostImg:{
            [self.httpManager POST:aPath parameters:nil headers:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
                NSData *imageData =UIImageJPEGRepresentation(uploadImage,0.1);
                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];

                formatter.dateFormat = @"yyyyMMddHHmmss";

                NSString *str = [formatter stringFromDate:[NSDate date]];

                NSString *fileName = [NSString stringWithFormat:@"%@.jpg", str];
                [formData appendPartWithFileData:imageData name:@"files" fileName:fileName mimeType:@"image/jpeg"];
                
            } progress:^(NSProgress * _Nonnull uploadProgress) {
                
            } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                DDLog(@"\n===========response===========\n%@:\n%@", aPath,responseObject);
                id error = [self handleResponse:responseObject autoShowError:autoShowError];
                if (error) {
                    block(nil, error);
                } else {
                    [self successRequestWithTask:task res:responseObject block:block];
                }
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                [self failRequestWithTask:task error:error block:block];
            }];
            break;
        }
        default:
            break;
    }
    
}

- (void)GET:(NSString *)url paramaters:(NSDictionary *)paramaters CompleteBlock:(CompleteBlock)completeBlock {
    [self requestJsonDataWithPath:url withParams:paramaters withMethodType:Get elementPath:@"" andBlock:completeBlock];
}

- (void)GET:(NSString *)url CompleteBlock:(CompleteBlock)completeBlock {
    
    [self requestJsonDataWithPath:url withParams:nil withMethodType:Get elementPath:@"" andBlock:completeBlock];
}

- (void)POST:(NSString *)url paramaters:(NSDictionary *)paramaters CompleteBlock:(CompleteBlock)completeBlock {
    
    [self requestJsonDataWithPath:url withParams:paramaters withMethodType:Post elementPath:@"" andBlock:completeBlock];
}

- (void)POST:(NSString *)url image:(UIImage *)img CompleteBlock:(CompleteBlock)completeBlock {
    [self uploadImgWithPath:url withImg:img withMethodType:PostImg elementPath:@"" autoShowError:YES andBlock:completeBlock];
}
//上传
- (void)upload:(NSString *)url data:(NSData *)data name:(NSString *)name fileName:(NSString *)fileName CompleteBlock:(CompleteBlock)completeBlock {
    NSTimeInterval interval = [[NSDate date] timeIntervalSince1970];
    long long totalMilliseconds = interval*1000 ;
    NSString *curTime = [[NSString alloc] initWithFormat:@"%lld", totalMilliseconds];
    [self.httpManager.requestSerializer setValue:curTime forHTTPHeaderField:@"timestamp"];
    [self.httpManager.requestSerializer setValue:@"2" forHTTPHeaderField:@"terminal-Type"];
    [self.httpManager.requestSerializer setValue:@"ios" forHTTPHeaderField:@"Device-Type"];
//    [self.requestSerializer setValue:Single_deviceId forHTTPHeaderField:@"Device-Id"];
//    [self.requestSerializer setValue:kVersion_Coding forHTTPHeaderField:@"Terminal-Version"];
//    [self.requestSerializer setValue:Single_Token forHTTPHeaderField:@"Token"];
    [self.httpManager.requestSerializer setValue:[[NSUserDefaults standardUserDefaults] valueForKey:@"cx_language"] forHTTPHeaderField:@"locale"];
//
    NSString *mimeType = @"image/jpeg";
    if ([fileName rangeOfString:@".pdf"].location != NSNotFound)  mimeType = @"application/pdf";
    if ([fileName rangeOfString:@".docx"].location != NSNotFound)  mimeType = @"application/vnd.openxmlformats-officedocument.wordprocessingml.document";
    if ([fileName rangeOfString:@".doc"].location != NSNotFound)  mimeType = @"application/msword";
    if ([fileName rangeOfString:@".txt"].location != NSNotFound)  mimeType = @"text/plain";

    [self.httpManager POST:url parameters:nil headers:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        [formData appendPartWithFileData:data name:name fileName:fileName mimeType:mimeType];
    } progress:^(NSProgress * _Nonnull uploadProgress) {

    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        DDLog(@"\n===========response===========\n%@:\n%@", url, responseObject);
        [self successRequestWithTask:task res:responseObject block:completeBlock];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//        [self failRequestWithTask:task error:error path:url block:completeBlock];
        [self failRequestWithTask:task error:error block:completeBlock];
    }];
}
/**
 * method  取 POST或GET
 */
- (void)downloadFile:(NSString *)urlStr method:(NSString *)method paramaters:(NSDictionary *)paramaters CompleteBlock:(CompleteBlock)completeBlock{
///    1、创建网络下载对象

    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
///    2、 设置下载地址

    NSMutableURLRequest *request = [self.httpManager.requestSerializer requestWithMethod:method URLString:[NSString stringWithFormat:@"%@%@",_baseUrl,urlStr] parameters:paramaters error:nil];

    
    UIDevice *device = [UIDevice currentDevice];
    if([[device model] hasSuffix:@"Simulator"]){ //在模拟器不保存到文件中
        return;
    }
    
    //获取Document目录下的Log文件夹，若没有则新建
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *logDirectory = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"Download"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL fileExists = [fileManager fileExistsAtPath:logDirectory];
    if (!fileExists) {
        [fileManager createDirectoryAtPath:logDirectory  withIntermediateDirectories:YES attributes:nil error:nil];
    }
//    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//    [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"]];
//    [formatter setDateFormat:@"yyyyMMddHHmmss"]; //每次启动后都保存一个新的日志文件中
//    NSString *dateStr = [formatter stringFromDate:[NSDate date]];
    
    NSString *savePath = [NSHomeDirectory() stringByAppendingString:[NSString stringWithFormat:@"/Documents/Download/"]];

///    3、开始请求下载

    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {

        /* 设定下载到的位置 */

        NSString *fileStr = [savePath stringByAppendingPathComponent:response.suggestedFilename];
//        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//        [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"]];
//        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"]; //每次启动后都保存一个新的日志文件中
//        NSString *dateStr = [formatter stringFromDate:[NSDate date]];
//        NSString *path = [NSHomeDirectory() stringByAppendingString:[NSString stringWithFormat:@"/Documents/Download/%@",[NSString stringWithFormat:@"%@.pdf",dateStr]]];
        
        DDLog(@"===fileStr===%@",fileStr);

        return [NSURL fileURLWithPath:fileStr];

    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {

      //下载完成之后的操作
        if (error) {
            [self failRequestWithTask:nil error:error block:completeBlock];
            
            DDLog(@"error:%@",error);
        }else{

//            NSFileManager* fm=[NSFileManager defaultManager];
//            NSData *data;
//            if(![fm fileExistsAtPath:filePath.absoluteString]){
//                //读取某个文件
////                data = [fm contentsAtPath:filePath.absoluteString];
//                data = [NSData dataWithContentsOfURL:filePath.absoluteURL];
//            }
//
//            UIImage *image = [UIImage imageWithData: data];
//
//            NSDictionary * dataDict = @{@"data":@{@"image":image},@"code":@"200"};
            [self successRequestWithTask:nil res:nil block:completeBlock];
            
            
            DDLog(@"success");
            
        }
//        [self downloadSuccessWithFilePath:filePath];

    }];

    [downloadTask resume];

    
}

#pragma mark - 成功回调
- (void)successRequestWithTask:(NSURLSessionDataTask *)task res:(id)res block:(void (^)(id data, NSError *error))block {
    NSHTTPURLResponse *responses = (NSHTTPURLResponse *)task.response;
    NSDictionary* headFilesDic = responses.allHeaderFields;
    
    DDLog(@"--------服务器返回的调用链:-------\n%@",[headFilesDic objectForKey:@"ITRACING_TRACE_ID"]);
    
    //所有请求接口的地方增加通用的逻辑：如果接口返回的请求头中有 token，则在后续请求的请求头中需要使用最新的token覆盖原本登录返回的token值
    NSString *token = [responses.allHeaderFields objectForKey:@"Token"];
    if (!dcIsEmptyString(token)) {
//        [HJGlobalDataManager shareInstance].signInResponseModel.token = token;
		self.token = token;
		if (self.respTokenBlock) {
			self.respTokenBlock(token);
		}
	
        [DCNetAPIClient userAddRequestHeader:token forHeadFieldName:@"Token"];
        [DCNetAPIClient userAddRequestHeader:token forHeadFieldName:@"authtoken"];
        [[NSUserDefaults standardUserDefaults] setValue:token forKey:@"DCLoginToken"];
    }
    NSString *urlString = [responses.URL absoluteString];
    if ([urlString containsString:@"/property/cx/property.json"] || ([urlString containsString:@"/i18n/app"] && [urlString containsString:@"/local.json"])) {
        //说明国际化有要更新的内容
        NSString *strLastModified = [responses.allHeaderFields objectForKey:@"Last-Modified"];
        [[NSUserDefaults standardUserDefaults] setValue:dcObjectOrEmptyStr(strLastModified) forKey:@"LastModified"];
        block(res, nil);
    } else {
//        if ([DCIsNull([res objectForKey:@"code"])?@"":[res objectForKey:@"code"] isEqualToString:@"500"]) {
//            [HJMBProgressHUD showText:HTTP_ResultMsg];
//            block(res, nil);
//        }else{
            block(res, nil);
//        }
    
    }
}

#pragma mark - 失败回调
- (void)failRequestWithTask:(NSURLSessionDataTask *)task error:(NSError *)error block:(void (^)(id data, NSError *error))block{
    NSHTTPURLResponse * responses = (NSHTTPURLResponse *)task.response;
    
    NSDictionary* headFilesDic = responses.allHeaderFields;
    
    NSError *err;
    NSData *data = [error.userInfo valueForKey:@"com.alamofire.serialization.response.error.data"];
    DDLog(@"服务器的错误原因:%@",error);
    DDLog(@"--------服务器返回的调用链:-------\n%@",[headFilesDic objectForKey:@"ITRACING_TRACE_ID"]);
    NSDictionary *dic ;
    if (data) {
        NSString *errorString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&err];
        
    }
    [HJMBProgressHUD hideLoading];
    
	if (responses.statusCode == 401 || responses.statusCode == 304 || responses.statusCode == 502 || responses.statusCode == 593 || responses.statusCode == 504) {
		
		if (responses.statusCode == 401) {
			block(dic, error);
			NSMutableDictionary * userInfo = [NSMutableDictionary new];
			[userInfo setValue:@"" forKey:@"loginType"];
		}
		
		if (self.respHTTPCodeBlock) {
			self.respHTTPCodeBlock(responses.statusCode);
		}
		
	}
//    if (responses.statusCode == 401) {
//        [HJMBProgressHUD showText:dcObjectOrEmptyStr([dic objectForKey:@"message"])];
//        
//        block(dic, error);
//        NSMutableDictionary * userInfo = [NSMutableDictionary new];
//        [userInfo setValue:@"" forKey:@"loginType"];
//        
//        [[NSNotificationCenter defaultCenter]postNotificationName:@"GotoLoginVCNotification" object:nil userInfo:userInfo];
//        [[HJGlobalDataManager shareInstance] resetUserInfo];
//        
//    } 
//	else if (responses.statusCode == 304) {
//        //说明国际化没有要更新
//    } else if (responses.statusCode == 502) {
//        [SNAlertMessage displayMessageInView:[UIApplication sharedApplication].keyWindow Message:[[HJLanguageManager shareInstance] getTextByKey:@"tips_service_is_unavailable"]];
//    } else if (responses.statusCode == 504) {
//        [SNAlertMessage displayMessageInView:[UIApplication sharedApplication].keyWindow Message:[[HJLanguageManager shareInstance] getTextByKey:@"tip_something_wrong"]];
//    } else if (responses.statusCode == 593) {
//        [HJMBProgressHUD hideLoading];
//        [[NSNotificationCenter defaultCenter]postNotificationName:@"GotoMaintenceVCNotification" object:nil userInfo:dic];
//        
//    }
	else {
//        [HJMBProgressHUD showText:dcObjectOrEmptyStr([dic objectForKey:@"message"])];
        block(dic, error);
    }
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
    [[self sharedMockClient].httpManager.requestSerializer setValue:curTime forHTTPHeaderField:@"timestamp"];
    [[self sharedUcClient].httpManager.requestSerializer setValue:curTime forHTTPHeaderField:@"timestamp"];
    
    NSString *accesstoken = @"";
    
    if (accesstoken.length) {
//        [[self sharedClient].httpManager.requestSerializer setValue:accesstoken forHTTPHeaderField:@"authtoken"];
//        [[self sharedMockClient].httpManager.requestSerializer setValue:accesstoken forHTTPHeaderField:@"authtoken"];
//        [[self sharedUcClient].httpManager.requestSerializer setValue:accesstoken forHTTPHeaderField:@"authtoken"];
        NSString *securityKey = @"";//[HJAppDataManager sharedInstance].userInfo.securityKey;
        if (securityKey.length) {
            //accesstoken + timestamp + url
            NSString *temp = [NSString stringWithFormat:@"%@%@%@", accesstoken, curTime, url] ;
            NSString *sign = [SecurityUtil_Net generateHmacSHA256Signature:temp key:securityKey];
            [[self sharedClient].httpManager.requestSerializer setValue:sign forHTTPHeaderField:@"sign"];
            [[self sharedMockClient].httpManager.requestSerializer setValue:sign forHTTPHeaderField:@"sign"];
            [[self sharedUcClient].httpManager.requestSerializer setValue:sign forHTTPHeaderField:@"sign"];
        }
    }else{
//        [[self sharedClient].httpManager.requestSerializer setValue:@"" forHTTPHeaderField:@"authtoken"];
//        [[self sharedMockClient].httpManager.requestSerializer setValue:@"" forHTTPHeaderField:@"authtoken"];
//        [[self sharedUcClient].httpManager.requestSerializer setValue:@"" forHTTPHeaderField:@"authtoken"];
    }

    [[self sharedClient].httpManager.requestSerializer setValue:@"ios" forHTTPHeaderField:@"Device-Type"];
    [[self sharedMockClient].httpManager.requestSerializer setValue:@"ios" forHTTPHeaderField:@"Device-Type"];
    [[self sharedUcClient].httpManager.requestSerializer setValue:@"ios" forHTTPHeaderField:@"Device-Type"];

    [[self sharedClient].httpManager.requestSerializer setValue:@"2" forHTTPHeaderField:@"terminal-Type"];
    [[self sharedUcClient].httpManager.requestSerializer setValue:@"2" forHTTPHeaderField:@"terminal-Type"];
    [[self sharedMockClient].httpManager.requestSerializer setValue:@"2" forHTTPHeaderField:@"terminal-Type"];
//    [self.requestSerializer setValue:Single_deviceId forHTTPHeaderField:@"Device-Id"];
//    [self.requestSerializer setValue:kVersion_Coding forHTTPHeaderField:@"Terminal-Version"];
//    [self.requestSerializer setValue:Single_Token forHTTPHeaderField:@"Token"];
    [[self sharedClient].httpManager.requestSerializer setValue:[[NSUserDefaults standardUserDefaults] valueForKey:@"cx_language"] forHTTPHeaderField:@"locale"];
    
}

+ (void)userAddRequestHeader:(NSString *)headerStr forHeadFieldName:(NSString *)headerFieldName{
    [[self sharedClient].httpManager.requestSerializer setValue:headerStr forHTTPHeaderField:headerFieldName];
    [[self sharedMockClient].httpManager.requestSerializer setValue:headerStr forHTTPHeaderField:headerFieldName];
    [[self sharedUcClient].httpManager.requestSerializer setValue:headerStr forHTTPHeaderField:headerFieldName];
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
    if (![responseJSON isKindOfClass:[NSDictionary class]]) return nil;
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
