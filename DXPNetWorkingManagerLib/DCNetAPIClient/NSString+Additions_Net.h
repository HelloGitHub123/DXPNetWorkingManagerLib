//
//  NSString+Additions.h
//

#import <UIKit/UIKit.h>

@interface NSString (TTString_Net)

+ (NSString *)documentPath;
+ (NSString *)cachePath;
+ (NSString *)formatCurrentDate;
+ (NSString *)formatCurrentDay;
- (NSString*)removeAllSpace;
- (NSURL *)toURL;
- (BOOL)isEmpty;
- (NSString *)MD5;
- (NSString *)trim;
-(NSString*)jsonStrHandle;
// 时间戳 转日期 （dd/mm/yyyy）
- (NSString *)coverDateDayMonthYear;
- (NSString *)SHA256;
- (NSString *)hmac:(NSString *)plaintext withKey:(NSString *)key;
@end
