//
//  DCNetworkHeader.h
//  Pods
//
//  Created by Lee on 22.12.22.
//

#ifndef DCNetworkHeader_h
#define DCNetworkHeader_h

#define DDLog(s, ...)         NSLog(@"%s(%d): %@", __FUNCTION__, __LINE__, [NSString stringWithFormat:(s), ##__VA_ARGS__])
#define kDCNetworkMethodName @[@"Get", @"Post", @"Put", @"Delete"]
#define HJStringFormat(s, ...)     [NSString stringWithFormat:(s),##__VA_ARGS__]

#define DCIsNull(x)                (!x || [x isKindOfClass:[NSNull class]])

#define dcIsEmptyString(x)         (DCIsNull(x) || [x isEqual:@""] || [x isEqual:@"(null)"] || [x isEqual:@"null"])
#define dcObjectOrEmptyStr(obj)    ((obj) ? (obj) : @"")
#endif /* DCNetworkHeader_h */
