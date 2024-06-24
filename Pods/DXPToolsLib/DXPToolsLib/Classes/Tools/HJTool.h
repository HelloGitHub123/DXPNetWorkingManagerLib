//
//  HJTool.h
//  HJControls
//
//  Created by mac on 2022/9/27.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

//typedef NS_ENUM(NSInteger, KFileType) {
//	KFileType_none,
//	KFileType_image,
//	KFileType_pdf,
//	KFileType_doc,
//	KFileType_docx,
//	KFileType_txt
//};

NS_ASSUME_NONNULL_BEGIN

@interface HJTool : NSObject

+ (BOOL)checkEmail:(NSString *)text;

+ (CGFloat)textHeightByWidth:(CGFloat)width withFont:(UIFont*)font string:(NSString *)string;

+ (CGFloat)textHeightByWidth:(CGFloat)width withFont:(UIFont*)font string:(NSString *)string  lineHeightMultiple:(CGFloat)lineHeightMultiple;

+ (CGFloat)textWidthByMaxWidth:(CGFloat)width withFont:(UIFont*)font string:(NSString *)string;

+ (id)dictionaryWithJsonString:(NSString *)jsonString;

+ (NSDictionary *)dictionaryWithModel:(id)model;
/**
 *numberStr 需要断的字符串
 *index 间隔几位断
 */
+ (NSString *)numberFormatWithString:(NSString *)numberStr index:(int)index;

+ (NSString *)ddpGetExpectTimestamp:(NSInteger)year month:(NSUInteger)month day:(NSUInteger)day;
///dd/MM/yyyy to yyyyMMddHHmmss,全部补0
+ (NSString *)changeDateFormatWithStr:(NSString *)dateStr;
///yyyy/MM/dd to yyyyMMddHHmmss,全部补0
+ (NSString *)changeNewDateFormatWithStr:(NSString *)dateStr;
///dd/MM/yyyy to yyyyMMddHHmmss,HHmmss补235959
+ (NSString *)changeEndDateFormatWithStr:(NSString *)dateStr;
///计算某个时间点的距离
+ (NSString *)getExpDateFromDate:(NSString *)dateStr year:(NSInteger)year month:(NSUInteger)month day:(NSUInteger)day;
///比较2个日期的先后 return : 0（等于）1（大于）-1（小于）
+ (int)compareDate:(NSString*)date01 withDate:(NSString*)date02 toDateFormat:(NSString*)format;
///获取当前月的第一天
+(NSString *)getMonthFirstDayWithDate:(NSDate *)date;

///将yyyyMMddHHmmss 转换成yyyy-MM-dd
+(NSString *)getShortNormalDateFormatWithStr:(NSString *)dateStr;

// 将yyyy-mm-dd HH:mm:ss 转换成 dd/MM/yyyy HH:mm:ss
+ (NSString *)getDateTimeFormat:(NSString *)dateStr;

+ (NSObject *)getPlistInfoWith:(NSString *)fileName;

+ (CGSize)sizeForContentString:(NSString *)string font:(UIFont*)font;

+ (CGSize)sizeForContentString:(NSString *)string font:(UIFont*)font width:(NSInteger)width;

+ (CGSize)sizeForTitle:(NSString *)title withFont:(UIFont *)font;


// string 的size
+ (CGFloat)heightForWidth:(CGFloat)width withFont:(UIFont*)font string:(NSString *)string;

+ (CGFloat)heightForWidth:(CGFloat)width withFont:(UIFont*)font string:(NSString *)string isLineHeight:(BOOL)isLineHeight;

+ (UIViewController *)getViewController:(UIView *)my;

//计算出时间戳差
+ (NSTimeInterval )getTimeDural:(NSString *)startTime;

+ (NSString *)getMonthDay:(NSString *)dateStr;

+ (NSString *)getTime:(NSString *)dateStr;

+ (NSString *)getHiStr;

+ (NSString*)TimeformatFromSeconds:(NSInteger)second;

+ (BOOL)isPureInt:(NSString*)string;

+ (BOOL)validateIsNumber:(NSString *)str;

//去掉电话号码中非数字的字符
+ (NSString *)formatPhoneNumber:(NSString *)phoneNum;

+ (NSString *)positiveFormat:(NSString *)text;

+ (BOOL)checkIPAddress:(NSString *)strIP;

//获取当前日期的前第几天日期
+ (NSString *)getNDay:(NSInteger)n;

//add/modify by libiao
//BASE64
+ (NSString *)base64StringFromText:(NSString *)text;

+ (NSDictionary *)getParamsWithUrlString:(NSString*)urlString;

+ (NSString *)getDeviceName;

///检查是否为URL
+ (BOOL)checkUrlWithString:(NSString *)url;

// 获取文件路径
+ (NSString *)getStringWithFilePath:(NSString *)path;

+ (long long)fileSizeAtPath:(NSString*)filePath;

+ (NSString *)getDateByNowAndBefor:(int)beforDays;

// 转换时分秒。 输出 xx:xxAM 或者 xx:xxPM    dateStr:yyyyMMddHHmmss 时间戳
+ (NSString *)getHHmmss:(NSString *)dateStr;

// 转换小时和分。 输出 xx:xxAM 或者 xx:xxPM    dateStr:yyyyMMddHHmmss 时间戳
+ (NSString *)getHHmmAMPM:(NSString *)dateStr;

+ (NSString *)divWithHtml:(NSString *)html video:(NSString *)videoUrl;

#pragma mark - 添加阴影效果
+ (UIView *)addShadowToView:(UIView *)theView withColor:(UIColor *)theColor;

+ (NSString *)getDisplayAccNumber:(NSString *)accNumber;

/// 根据正则表达式校验字符串
+ (BOOL)validateStr:(NSString *)string withRegex:(NSString *)regex;

///根据字符串和字体大小计算label宽度
+ (CGFloat)getWidthWithStr:(NSString *)title font:(UIFont *)font;

+ (NSString *)filterHTMLWithPTagLineFeed:(NSString *)html;

+ (NSString *)filterHTML:(NSString *)html;

//判断纯数字
+ (BOOL)isNumText:(NSString *)str;

+ (UIViewController *)currentVC;

///获取某月的最后一天
+(NSString *)getMonthEndDayWithDate:(NSDate *)date;

+ (NSString *)changeNewDateFormatWithStr1:(NSString *)dateStr;

/// 获取当前时间的时间字符串
+ (NSString *)getCurrentDateStr;

+ (CGFloat)singleWidthWithMaxWidth:(CGFloat)width withFont:(UIFont*)font string:(NSString *)string;

//计算高度
+ (CGFloat)configHeightWithContent:(NSString *)content font:(float)font width:(float)width;

/// 格式化图片路径中的空格
/// @param path 图片路径
+ (NSString *)handleImageUrlWithSpace:(NSString *)path;

/// 根据日期获取MediumStyle的日期字符串
/// @param date 日期
+ (NSString *)dateStrByMediumStyleDate:(NSDate *)date;

/// 获取英文的月份年份
/// @param date 日期
+ (NSString *)getEnShortDateStrByDate:(NSDate *)date;

/// 获取当前月份的前/后月份
/// @param date 当前日期
/// @param month 第几个月
+ (NSDate*)getPriousorLaterDateFromDate:(NSDate*)date withMonth:(NSInteger)month ;

/// 根据日期获取对应的组件（年月）
/// @param date 日期
+ (NSDateComponents *)getComponentsFromDate:(NSDate *)date;

+ (NSString *)getYearAndMonthFromDate:(NSDate *)date;

+ (NSString *)getTimestampToString:(NSString *)dateStr;

+ (NSString *)getNormalDateToString:(NSString *)dateStr;

+ (NSString *)getDateFromString:(NSString *)dateStr;

+ (NSString *)getShortDateFromString:(NSString *)dateStr;

/// 获取当前时间的时间戳字符串
+ (NSString *)getNowTimeTimestamp;

+ (NSString *)getFormatterMoney:(NSString *)str;

//MD5
+ (NSString *)md5:(NSString *)str;
+ (NSString *)md5String:(NSString *)str;

//+ (KFileType)getFileTypeByFileName:(NSString *)fileName ;

@end

NS_ASSUME_NONNULL_END
