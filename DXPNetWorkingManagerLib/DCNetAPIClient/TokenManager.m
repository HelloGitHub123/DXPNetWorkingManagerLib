//
//  TokenManager.m
//  react-native-sdk-dxp-base
//
//  Created by 李标 on 2025/5/22.
//

#import "TokenManager.h"
#import "DCNetAPIClient.h"

@interface TokenManager ()<NSURLSessionDelegate>

@property (nonatomic, strong) NSString *token;
//@property (nonatomic, strong) NSDate *expiryDate;
@property (nonatomic, assign) NSInteger expirySeconds; // 记录接口当前时间
@property (nonatomic, strong) dispatch_queue_t serialQueue;

@property (nonatomic, assign) int expiresIn; // 令牌有效期
@property (nonatomic, copy) NSString *resultMsg;
@property (nonatomic, assign) int statusCode;

// 当前请求的任务
@property (nonatomic, strong) NSURLSessionDataTask *currentTask;
// 任务的回调队列
@property (nonatomic, strong) NSMutableArray *callbackBlocks;

@end



@implementation TokenManager


+ (instancetype)sharedInstance {
  static TokenManager *instance;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    instance = [[TokenManager alloc] init];
  });
  return instance;
}

- (instancetype)init {
  self = [super init];
  if (self) {
    _serialQueue = dispatch_queue_create("com.gomo.TokenManagerQueue", DISPATCH_QUEUE_SERIAL);
    _callbackBlocks = [NSMutableArray array];
	  
	  self.statusCode = -1;
	  self.resultMsg = @"";
  }
  return self;
}

- (void)getTokenWithCompletion:(void(^)(NSString * _Nullable token, int code, NSString *resultMsg , NSError * _Nullable error))completion {
  dispatch_async(self.serialQueue, ^{
    // 先判断Token是否有效
//    if (self.token && self.expiryDate && [self.expiryDate compare:[NSDate date]] == NSOrderedDescending) {

    // 获取当前秒
    NSTimeInterval timestamp = [[NSDate date] timeIntervalSince1970];
    NSInteger seconds = (NSInteger)timestamp; // 转换为整数秒
    NSInteger time = self.expirySeconds + self.expiresIn;
    if (self.token && (seconds <= time)) {
      // 有效，直接返回
      dispatch_async(dispatch_get_main_queue(), ^{
        completion(self.token, 200, @"",  nil);
      });
      return;
    }

    // 如果已有请求在进行，加入回调队列
    if (self.currentTask) {
      [self.callbackBlocks addObject:[completion copy]];
      return;
    }

    // 否则发起请求
    [self.callbackBlocks addObject:[completion copy]];
    [self fetchTokenFromServer];
  });
}

// 将参数字典转换为 x-www-form-urlencoded 格式的字符串
- (NSString *)queryStringFromParameters:(NSDictionary *)parameters {
  NSMutableArray *components = [NSMutableArray array];

  [parameters enumerateKeysAndObjectsUsingBlock:^(NSString *key, id obj, BOOL *stop) {
    // 对键和值进行 URL 编码
    NSString *encodedKey = [self urlEncodeString:key];
    NSString *encodedValue = [self urlEncodeString:[self stringFromObject:obj]];

    // 添加到组件数组
    [components addObject:[NSString stringWithFormat:@"%@=%@", encodedKey, encodedValue]];
  }];

  // 用 & 连接所有组件
  return [components componentsJoinedByString:@"&"];
}

// 将对象转换为字符串
- (NSString *)stringFromObject:(id)object {
  if ([object isKindOfClass:[NSString class]]) {
    return (NSString *)object;
  } else if ([object isKindOfClass:[NSNumber class]]) {
    return [object stringValue];
  } else if ([object isKindOfClass:[NSArray class]]) {
    // 处理数组：将数组元素用逗号连接
    NSArray *array = (NSArray *)object;
    NSMutableArray *stringValues = [NSMutableArray array];
    for (id item in array) {
      [stringValues addObject:[self stringFromObject:item]];
    }
    return [stringValues componentsJoinedByString:@","];
  }
  return [object description];
}

// URL 编码字符串
- (NSString *)urlEncodeString:(NSString *)string {
  return [string stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
}

- (void)fetchTokenFromServer {
  NSString *url = [NSString stringWithFormat:@"%@/api/sg/v2/oauth/token",[DCNetAPIClient sharedClient].apigeeHost];

  NSLog(@"url===:%@",url);
  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
  [request setHTTPMethod:@"POST"];
  // 设置单个 Header 字段
//  [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
  [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
  [request setValue:[DCNetAPIClient sharedClient].authorizationStr forHTTPHeaderField:@"Authorization"];

  NSLog(@"authorizationStr====:%@",[DCNetAPIClient sharedClient].authorizationStr);

  // 3. 构造 JSON 数据（示例数据）
  NSDictionary *jsonData = @{
    @"grant_type": @"client_credentials"
  };

  // 2. 将参数字典转换为 x-www-form-urlencoded 格式的字符串
  NSString *queryString = [self queryStringFromParameters:jsonData];

  [request setHTTPBody:[queryString dataUsingEncoding:NSUTF8StringEncoding]];

  // 4. 将 JSON 转换为 Data
//  NSError *error;
//  NSData *jsonDataAsData = [NSJSONSerialization dataWithJSONObject:jsonData
//                                                           options:0
//                                                             error:&error];
//  if (error) {
//    NSLog(@"JSON 转换失败: %@", error);
//    return;
//  }

  // 5. 设置请求体
//  [request setHTTPBody:jsonDataAsData];


	NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
	NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfig delegate:self delegateQueue:nil];
	
	
//  NSURLSession *session = [NSURLSession sharedSession];

  NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                          completionHandler:^(NSData * _Nullable data,
                                                              NSURLResponse * _Nullable response,
                                                              NSError * _Nullable error) {
    dispatch_async(self.serialQueue, ^{
      NSError *err = error;
      NSString *fetchedToken = @"";
      if (!err && data) {
        // 解析你的数据
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&err];

        NSString *access_token = [json valueForKey:@"access_token"];
        NSString *expires_in = [json valueForKey:@"expires_in"];
        if (!err && access_token.length > 0) {
          fetchedToken = access_token;
          self.expiresIn = [expires_in intValue]; // 令牌有效期
          self.token = fetchedToken;
          self.statusCode = 200;
          // 记录时间
          NSTimeInterval timestamp = [[NSDate date] timeIntervalSince1970];
          NSInteger seconds = (NSInteger)timestamp; // 转换为整数秒
          self.expirySeconds = seconds;
          self.resultMsg = @"";
//          self.expiryDate = [NSDate dateWithTimeIntervalSinceNow:[expiresIn doubleValue]];
        } else {
          // 失败
          self.token = @"";
          NSString *status = [json valueForKey:@"status"];
			self.statusCode = [status intValue];
//          if ([status isEqualToString:@"401"]) {
//            [self fetchTokenFromServer];
//          } else {
          NSString *fault = [json valueForKey:@"fault"];
          self.resultMsg = fault;
//          }
        }
      }
      // 请求结束，清空当前任务
      self.currentTask = nil;
      // 调用所有回调
      for (void(^callback)(NSString *,int,NSString *, NSError *) in self.callbackBlocks) {
        dispatch_async(dispatch_get_main_queue(), ^{
          callback(fetchedToken, self.statusCode , self.resultMsg ,err);
        });
      }
      [self.callbackBlocks removeAllObjects];
    });
  }];

  self.currentTask = task;
  [task resume];
}

- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler {
	if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
		NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
		completionHandler(NSURLSessionAuthChallengeUseCredential, credential);
	} else {
		// 其他认证方式处理
		completionHandler(NSURLSessionAuthChallengePerformDefaultHandling, nil);
	}
}

@end
