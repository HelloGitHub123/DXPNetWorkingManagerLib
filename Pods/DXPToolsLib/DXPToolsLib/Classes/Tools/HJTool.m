//
//  HJTool.m
//  HJControls
//
//  Created by mac on 2022/9/27.
//

#import "HJTool.h"
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>
#import <CommonCrypto/CommonHMAC.h>
#import <objc/runtime.h>
#import "sys/utsname.h"
#include "sys/stat.h"
#import "DXPHJToolsHeader.h"

@implementation HJTool

+ (BOOL)checkEmail:(NSString *)text {
    NSString *regex =  @"^\\w+([-+.]\\w+)*@\\w+([-.]\\w+)*\\.\\w+([-.]\\w+)*$";
    NSPredicate *test = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [test evaluateWithObject:text];
}

+ (CGFloat)textHeightByWidth:(CGFloat)width withFont:(UIFont*)font string:(NSString *)string {
    NSAssert(font, @"heightForWidth:方法必须传进font参数");
    CGSize labelsize  = [string
                         boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX)
                        options:NSStringDrawingUsesLineFragmentOrigin
                        attributes:@{NSFontAttributeName:font}
                        context:nil].size;
    return ceilf(labelsize.height);
}

+ (CGFloat)textHeightByWidth:(CGFloat)width withFont:(UIFont*)font string:(NSString *)string  lineHeightMultiple:(CGFloat)lineHeightMultiple {
    NSAssert(font, @"textHeightByWidth:withFont:string:lineHeightMultiple 方法必须传进font参数");

    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineHeightMultiple = lineHeightMultiple; // 设置行高倍数

    CGSize labelsize = [string boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX)
                                             options:NSStringDrawingUsesLineFragmentOrigin
                                          attributes:@{NSFontAttributeName: font,
                                                       NSParagraphStyleAttributeName: paragraphStyle}
                                             context:nil].size;

    // 返回向上取整的高度
    return ceilf(labelsize.height);
}

+ (CGFloat)textWidthByMaxWidth:(CGFloat)width withFont:(UIFont*)font string:(NSString *)string {
    NSAssert(font, @"singleWidthWithMaxWidth:方法必须传进font参数");
    CGSize labelsize = [string
                        boundingRectWithSize:CGSizeMake(width, MAXFLOAT)
                              options:NSStringDrawingUsesLineFragmentOrigin
                            attributes:@{NSFontAttributeName: font}
                        context:nil].size;
    return ceilf(labelsize.width);
}

+ (id)dictionaryWithJsonString:(NSString *)jsonString {
    if (jsonString == nil || [jsonString isKindOfClass:[NSNull class]]) {
        return @{};
    }
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    id dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err) {
        return @{};
    }
    return dic;
}

+ (NSDictionary *)dictionaryWithModel:(id)model {
    if (model == nil) {
        return nil;
    }
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    
    // 获取类名/根据类名获取类对象
    NSString *className = NSStringFromClass([model class]);
    id classObject = objc_getClass([className UTF8String]);
    
    // 获取所有属性
    unsigned int count = 0;
    objc_property_t *properties = class_copyPropertyList(classObject, &count);
    
    // 遍历所有属性
    for (int i = 0; i < count; i++) {
        // 取得属性
        objc_property_t property = properties[i];
        // 取得属性名
        NSString *propertyName = [[NSString alloc] initWithCString:property_getName(property)
                                                          encoding:NSUTF8StringEncoding];
        // 取得属性值
        id propertyValue = nil;
        id valueObject = [model valueForKey:propertyName];
        
        if ([valueObject isKindOfClass:[NSDictionary class]]) {
            propertyValue = [NSDictionary dictionaryWithDictionary:valueObject];
        } else if ([valueObject isKindOfClass:[NSArray class]]) {
            propertyValue = [NSArray arrayWithArray:valueObject];
        } else {
            propertyValue = [NSString stringWithFormat:@"%@", [model valueForKey:propertyName]];
        }
        
        [dict setObject:propertyValue forKey:propertyName];
    }
    return [dict copy];
}


/**
 *numberStr 需要断的字符串
 *index 间隔几位断
 */
+ (NSString *)numberFormatWithString:(NSString *)numberStr index:(int)index{
    int yushu = numberStr.length%index;
    long total = numberStr.length/index;
    if (yushu!=0) {
        total += 1;
    }
    NSMutableString *str =[NSMutableString new];
    for (int i =0; i<total; i++) {
        if (i<total-1) {
            [str appendString:[numberStr substringWithRange:NSMakeRange(i*index, index)]];//
            [str appendString:@" "];
        }else{
            int length = index;
            if (yushu!=0) {
                length = MIN(yushu,index);
            }
            [str appendString:[numberStr substringWithRange:NSMakeRange(i*index, length)]];
        }

    }
    
    return str;
}


///< 获取当前时间的: 前一周(day:-7)丶前一个月(month:-30)丶前一年(year:-1)的时间戳
+ (NSString *)ddpGetExpectTimestamp:(NSInteger)year month:(NSUInteger)month day:(NSUInteger)day {
 
    ///< 当前时间
    NSDate *currentdata = [NSDate date];
 
    ///< NSCalendar -- 日历类，它提供了大部分的日期计算接口，并且允许您在NSDate和NSDateComponents之间转换
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    /*
    ///<  NSDateComponents：时间容器，一个包含了详细的年月日时分秒的容器。
    ///< 下例：获取指定日期的年，月，日
    NSDateComponents *comps = nil;
    comps = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:currentdata];
    DebugLog(@"年 year = %ld",comps.year);
    DebugLog(@"月 month = %ld",comps.month);
    DebugLog(@"日 day = %ld",comps.day);*/
 
    
    NSDateComponents *datecomps = [[NSDateComponents alloc] init];
    [datecomps setYear:year?:0];
    [datecomps setMonth:month?:0];
    [datecomps setDay:day?:0];
    
    ///< dateByAddingComponents: 在参数date基础上，增加一个NSDateComponents类型的时间增量
    NSDate *calculatedate = [calendar dateByAddingComponents:datecomps toDate:currentdata options:0];
    
    ///< 打印推算时间
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd/MM/yyyy"];
    NSString *calculateStr = [formatter stringFromDate:calculatedate];
    
 
    ///< 预期的推算时间
//    NSString *result = [NSString stringWithFormat:@"%ld", (long)[calculatedate timeIntervalSince1970]];
    
    return calculateStr;
}

+ (NSString *)getShortCurrentDate:(NSDate *)inputDate{
    //设置时间显示格式
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc]init];
    //[formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setDateFormat:@"yyyy/MM/dd"];
    //[formatter setTimeStyle:NSDateFormatterShortStyle];
    [dateFormat setDateFormat:@"yyyyMMddHHmmss"];
    NSString * cuurentDateStr = [formatter stringFromDate:inputDate];
    NSDate *date = [formatter dateFromString:cuurentDateStr];

    //将NSDate按格式转化为对应的时间格式字符串
    NSString *timeString = [dateFormat stringFromDate:date];
    return timeString;
    
}

+ (NSString *)changeNewDateFormatWithStr:(NSString *)dateStr {
    //设置时间显示格式
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM-dd"];//输入的日期格式
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc]init];
    [dateFormat setDateFormat:@"yyyyMMddHHmmss"];//输出的日期格式
    
    NSDate *date = [formatter dateFromString:dateStr];
    
    //将时间戳(long long 型)转化为NSDate ,注意除以1000(IOS要求是10位的时间戳)
//    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timestamp/1000];
//    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timestamp];

    //将NSDate按格式转化为对应的时间格式字符串
    NSString *timeString = [dateFormat stringFromDate:date];
    return timeString;
}

+ (NSString *)changeDateFormatWithStr:(NSString *)dateStr {
    //设置时间显示格式
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"dd/MM/yyyy"];//输入的日期格式
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc]init];
    [dateFormat setDateFormat:@"yyyyMMddHHmmss"];//输出的日期格式
    
    NSDate *date = [formatter dateFromString:dateStr];
    
    //将时间戳(long long 型)转化为NSDate ,注意除以1000(IOS要求是10位的时间戳)
//    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timestamp/1000];
//    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timestamp];

    //将NSDate按格式转化为对应的时间格式字符串
    NSString *timeString = [dateFormat stringFromDate:date];
    return timeString;
}

+ (NSString *)changeEndDateFormatWithStr:(NSString *)dateStr {
    //设置时间显示格式
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"dd/MM/yyyy"];//输入的日期格式
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc]init];
    [dateFormat setDateFormat:@"yyyyMMdd"];//输出的日期格式
    
    NSDate *date = [formatter dateFromString:dateStr];
    
    //将时间戳(long long 型)转化为NSDate ,注意除以1000(IOS要求是10位的时间戳)
//    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timestamp/1000];
//    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timestamp];

    //将NSDate按格式转化为对应的时间格式字符串
    NSString *timeString = [NSString stringWithFormat:@"%@235959",[dateFormat stringFromDate:date]];
    return timeString;
}

+ (NSString *)getExpDateFromDate:(NSString *)dateStr year:(NSInteger)year month:(NSUInteger)month day:(NSUInteger)day {
 
    ///< 时间转换
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd/MM/yyyy"];
    
    NSDate *fromDate = [formatter dateFromString:dateStr];
 
    ///< NSCalendar -- 日历类，它提供了大部分的日期计算接口，并且允许您在NSDate和NSDateComponents之间转换
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    /*
    ///<  NSDateComponents：时间容器，一个包含了详细的年月日时分秒的容器。
    ///< 下例：获取指定日期的年，月，日
    NSDateComponents *comps = nil;
    comps = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:currentdata];
    DebugLog(@"年 year = %ld",comps.year);
    DebugLog(@"月 month = %ld",comps.month);
    DebugLog(@"日 day = %ld",comps.day);*/
 
    
    NSDateComponents *datecomps = [[NSDateComponents alloc] init];
    [datecomps setYear:year?:0];
    [datecomps setMonth:month?:0];
    [datecomps setDay:day?:0];
    
    ///< dateByAddingComponents: 在参数date基础上，增加一个NSDateComponents类型的时间增量
    NSDate *calculatedate = [calendar dateByAddingComponents:datecomps toDate:fromDate options:0];
    
    ///< 打印推算时间
    
    NSString *calculateStr = [formatter stringFromDate:calculatedate];
     
    ///< 预期的推算时间
//    NSString *result = [NSString stringWithFormat:@"%ld", (long)[calculatedate timeIntervalSince1970]];
    
    return calculateStr;
}

///return : 0（等于）1（大于）-1（小于）
+ (int)compareDate:(NSString*)date01 withDate:(NSString*)date02 toDateFormat:(NSString*)format{
    int num;
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:format];
    NSDate*dt01 = [[NSDate alloc]init];
    NSDate*dt02 = [[NSDate alloc]init];
    dt01 = [df dateFromString:date01];
    dt02 = [df dateFromString:date02];
    NSComparisonResult result = [dt01 compare:dt02];
    switch(result){

    case NSOrderedAscending: num=1;break;

    case NSOrderedDescending: num=-1;break;

    case NSOrderedSame: num=0;break;

    }
    return num;

}

+(NSString *)getMonthFirstDayWithDate:(NSDate *)date{

    NSDate * newDate = date;

    double interval = 0;
    
    NSDate * firstDate = nil;

    NSCalendar *calendar = [NSCalendar currentCalendar];

    BOOL bl = [calendar rangeOfUnit:NSCalendarUnitMonth startDate:&firstDate interval:&interval forDate:newDate];
    if(bl) {
        NSDateFormatter * myDateFormatter = [[NSDateFormatter alloc]init];
        [myDateFormatter setDateFormat:@"dd/MM/yyyy"];
        NSString * firstString = [myDateFormatter stringFromDate: firstDate];
        return firstString;

    }
    return @"";

}

///将yyyyMMddHHmmss 转换成yyyy-MM-dd
+(NSString *)getShortNormalDateFormatWithStr:(NSString *)dateStr{
    //设置时间显示格式
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyyMMddHHmmss"];//输入的日期格式
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc]init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];//输出的日期格式
    
    NSDate *date = [formatter dateFromString:dateStr];
    
    NSString *timeString = [dateFormat stringFromDate:date];
    
    return timeString;
    
}

// 将yyyy-mm-dd HH:mm:ss 转换成 dd/MM/yyyy HH:mm:ss
+ (NSString *)getDateTimeFormat:(NSString *)dateStr {
    if (isEmptyString_tools(dateStr)) {
        return dateStr;
    }
    NSDateFormatter *inputDateFormatter = [[NSDateFormatter alloc] init];
    [inputDateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSDate *inputDate = [inputDateFormatter dateFromString:dateStr];
    NSDateFormatter *outputDateFormatter = [[NSDateFormatter alloc] init];
    [outputDateFormatter setDateFormat:@"dd/MM/yyyy HH:mm:ss"];
    
    NSString *timeString = [outputDateFormatter stringFromDate:inputDate];
    return timeString;
}



//获取plist资源文件数据
+ (NSObject *)getPlistInfoWith:(NSString *)fileName {
	NSString *plistPath = [[NSBundle mainBundle] pathForResource:fileName ofType:@"plist"];
	NSObject *data = nil;
	data = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
	if (!data) {
		data = [[NSMutableArray alloc] initWithContentsOfFile:plistPath];
	}
	return data;
}

//根据字符串跟
+ (CGSize)sizeForContentString:(NSString *)string font:(UIFont*)font {
	CGSize maxSize = CGSizeMake(300, 1000);
	NSStringDrawingOptions opts = NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading;
	NSMutableParagraphStyle * style = [[NSMutableParagraphStyle alloc]init];
	[style setLineBreakMode:NSLineBreakByCharWrapping];
	NSDictionary * attributes = @{NSFontAttributeName:font, NSParagraphStyleAttributeName:style};
	CGRect rect = [string boundingRectWithSize:maxSize options:opts attributes:attributes context:nil];
	return rect.size;
}

+ (CGSize)sizeForTitle:(NSString *)title withFont:(UIFont *)font {
	CGRect titleRect = [title boundingRectWithSize:CGSizeMake(FLT_MAX, FLT_MAX)
										   options:NSStringDrawingUsesLineFragmentOrigin
										attributes:@{NSFontAttributeName : font}
										   context:nil];
	
	return CGSizeMake(titleRect.size.width,
					  titleRect.size.height);
}

//根据字符串跟
+ (CGSize)sizeForContentString:(NSString *)string font:(UIFont*)font width:(NSInteger)width {
	CGSize maxSize = CGSizeMake(width, 1000);
	NSStringDrawingOptions opts = NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading;
	NSMutableParagraphStyle * style = [[NSMutableParagraphStyle alloc]init];
	[style setLineBreakMode:NSLineBreakByCharWrapping];
	NSDictionary * attributes = @{NSFontAttributeName:font, NSParagraphStyleAttributeName:style};
	CGRect rect = [string boundingRectWithSize:maxSize options:opts attributes:attributes context:nil];
	return rect.size;
}

+ (CGFloat)heightForWidth:(CGFloat)width withFont:(UIFont*)font string:(NSString *)string {
	NSAssert(font, @"heightForWidth:方法必须传进font参数");
	return [[self class] heightForWidth:width withFont:font string:string isLineHeight:NO];
}

+ (CGFloat)heightForWidth:(CGFloat)width withFont:(UIFont*)font string:(NSString *)string isLineHeight:(BOOL)isLineHeight {
	NSAssert(font, @"heightForWidth:方法必须传进font参数");
	CGSize size = CGSizeZero;
	NSDictionary *attribute = @{};
	if (isLineHeight) {
		CGFloat lineHeight = (font.pointSize>=26)?font.pointSize:(font.pointSize*1.5);
		NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
		paragraphStyle.maximumLineHeight = lineHeight;
		paragraphStyle.minimumLineHeight = lineHeight;
		attribute = @{NSFontAttributeName: font, NSParagraphStyleAttributeName: paragraphStyle};
	} else {
		attribute = @{NSFontAttributeName: font};
	}
	size = [string boundingRectWithSize:CGSizeMake(width, MAXFLOAT)
							  options: NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:attribute context:nil].size;
	return ceilf(size.height);
}

//获取view的vc
+ (UIViewController *)getViewController:(UIView *)my {
	id responder = my;
	while (responder) {
		if ([responder isKindOfClass:[UIViewController class]]) {
			return responder;
		}
		responder = [responder nextResponder];
	}
	return nil;
}



//计算出时间戳差
+ (NSTimeInterval )getTimeDural:(NSString *)startTime {
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
	NSDate *date1 = [formatter dateFromString:startTime];
	NSDate *date2 = [NSDate date];
	NSTimeInterval aTimer = [date2 timeIntervalSinceDate:date1];
	
	int hour = (int)(aTimer/3600);
	int minute = (int)(aTimer - hour*3600)/60;
	int second = aTimer - hour*3600 - minute*60;
	NSString *dural = [NSString stringWithFormat:@"%d时%d分%d秒", hour, minute,second];
//    DebugLog(@"----时间相差:%@----",dural);
	return aTimer;
}

+ (NSString *)getMonthDay:(NSString *)dateStr {
	if (dateStr) {
		NSDateFormatter *df = [[NSDateFormatter alloc]init];//格式化
		[df setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
		NSDate *date = [df dateFromString:dateStr];
		[df setDateFormat:@"MM-dd"];
		NSString *datestr = [df stringFromDate:date];
		return datestr;
	}
	return @"";
}

+ (NSString *)getTime:(NSString *)dateStr {
	if (dateStr) {
		NSDateFormatter *df = [[NSDateFormatter alloc]init];//格式化
		[df setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
		NSDate *date = [df dateFromString:dateStr];
		[df setDateFormat:@"hh:mm:ss"];
		NSString *datestr = [df stringFromDate:date];
		return datestr;
	}
	return @"";
}

+ (NSString *)getHiStr {
	NSDate *date = [NSDate date];
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"HH"];
	NSInteger hour = [[dateFormatter stringFromDate:date] integerValue];
	return nil;
}




+ (NSString*)TimeformatFromSeconds:(NSInteger)seconds {
	NSString *str_hour = [NSString stringWithFormat:@"%02d",seconds/3600];
	NSString *str_minute = [NSString stringWithFormat:@"%02d",(seconds%3600)/60];
	NSString *str_second = [NSString stringWithFormat:@"%02d",seconds%60];
	NSString *format_time = [NSString stringWithFormat:@"%@:%@:%@",str_hour,str_minute,str_second];
	return format_time;
}

//将时间点转化成日历形式
+ (NSDate *)getCustomDateWithHour:(NSInteger)hour {
	//获取当前时间
	NSDate * destinationDateNow = [NSDate date];
	NSCalendar *currentCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
	NSDateComponents *currentComps = [[NSDateComponents alloc] init];
	NSInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
	
	currentComps = [currentCalendar components:unitFlags fromDate:destinationDateNow];
	//设置当前的时间点
	NSDateComponents *resultComps = [[NSDateComponents alloc] init];
	[resultComps setYear:[currentComps year]];
	[resultComps setMonth:[currentComps month]];
	[resultComps setDay:[currentComps day]];
	[resultComps setHour:hour];
	
	NSCalendar *resultCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
	return [resultCalendar dateFromComponents:resultComps];
}

//考虑时区，获取准备的系统时间方法
+ (NSDate *)getNowDateFromatAnDate:(NSDate *)anyDate {
	//设置源日期时区
	NSTimeZone* sourceTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];//或GMT
	//设置转换后的目标日期时区
	NSTimeZone* destinationTimeZone = [NSTimeZone localTimeZone];
	//得到源日期与世界标准时间的偏移量
	NSInteger sourceGMTOffset = [sourceTimeZone secondsFromGMTForDate:anyDate];
	//目标日期与本地时区的偏移量
	NSInteger destinationGMTOffset = [destinationTimeZone secondsFromGMTForDate:anyDate];
	//得到时间偏移量的差值
	NSTimeInterval interval = destinationGMTOffset - sourceGMTOffset;
	//转为现在时间
	NSDate* destinationDateNow = [[NSDate alloc] initWithTimeInterval:interval sinceDate:anyDate];
	return destinationDateNow;
}

//判断是否为纯数字
+ (BOOL)isPureInt:(NSString*)string {
	NSScanner* scan = [NSScanner scannerWithString:string];
	int val;
	return[scan scanInt:&val] && [scan isAtEnd];
}

+ (BOOL)validateIsNumber:(NSString *)str {
	NSString *regex = @"^[0-9]+$";
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
	return [predicate evaluateWithObject:str];
}

+ (NSString *)formatPhoneNumber:(NSString *)phoneNum {
	NSString *strPhone = @"";
	NSCharacterSet *setToRemove = [[ NSCharacterSet characterSetWithCharactersInString:@"0123456789"] invertedSet];
	strPhone  = [[phoneNum componentsSeparatedByCharactersInSet:setToRemove] componentsJoinedByString:@""];
	return strPhone;
}


+ (NSString *)positiveFormat:(NSString *)text{
	
	if(!text || [text floatValue] == 0){
		return text;
	}else{
		NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
		//        [numberFormatter setPositiveFormat:@",###.00;"];
		numberFormatter.numberStyle =NSNumberFormatterDecimalStyle;
		return [numberFormatter stringFromNumber:[NSNumber numberWithDouble:[text doubleValue]]];
	}
	return @"";
}



+ (BOOL)checkIPAddress:(NSString *)strIP {
	NSArray *IPArr = [strIP componentsSeparatedByString:@":"];
	if (isEmptyString_tools([IPArr objectAtIndex:0])) {
		return NO;
	} else if([IPArr count] == 1){
		return NO;
	} else {
		NSString *regex = @"([1-9]|[1-9]\\d|1\\d{2}|2[0-4]\\d|25[0-5])(\\.(\\d|[1-9]\\d|1\\d{2}|2[0-4]\\d|25[0-5])){3}";
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
		return [predicate evaluateWithObject:[IPArr objectAtIndex:0]];
	}
	return YES;
}

//获取当前日期或者往前第几天日期
+ (NSString *)getNDay:(NSInteger)n {
	NSDate*nowDate = [NSDate date];
	NSDate* theDate;
	if(n!=0) {
		NSTimeInterval oneDay = -24*60*60*1;  //1天的长度
		theDate = [nowDate initWithTimeIntervalSinceNow:oneDay * n ];//initWithTimeIntervalSinceNow是从现在往前后推的秒数
	} else {
		theDate = nowDate;
	}
	NSDateFormatter *date_formatter = [[NSDateFormatter alloc] init];
	//        [date_formatter setDateFormat:@"yyyy-MM-dd"];
	[date_formatter setDateFormat:@"dd/MM/yyyy"];
	NSString *the_date_str = [date_formatter stringFromDate:theDate];
	return the_date_str;
}

//BASE64
+ (NSString *)base64StringFromText:(NSString *)text {
	NSData *data = [text dataUsingEncoding:NSUTF8StringEncoding];
	NSString *base64String = [data base64EncodedStringWithOptions:0];
	return base64String;
}


+ (NSDictionary *)getParamsWithUrlString:(NSString*)urlString {
	if(urlString.length == 0 || ![urlString containsString:@"?"]) {
		NSLog(@"链接为空！");
		return @{};
	}
	//先截取问号
	NSArray* allElements = [urlString componentsSeparatedByString:@"?"];
	NSMutableDictionary* params = [NSMutableDictionary dictionary];//待set的参数字典
	
	if(allElements.count >= 2) {
		//有参数或者?后面为空
		NSString* paramsString = [allElements lastObject];
		//获取参数对
		NSArray*paramsArray = [paramsString componentsSeparatedByString:@"&"];
		if(paramsArray.count>=2) {
			for(NSInteger i =0; i < paramsArray.count; i++) {
				NSString* singleParamString = paramsArray[i];
				NSArray* singleParamSet = [singleParamString componentsSeparatedByString:@"="];
				if(singleParamSet.count==2) {
					NSString* key = singleParamSet[0];
					NSString* value =  [singleParamSet[1] stringByRemovingPercentEncoding];
					if(key.length>0|| value.length>0) {
						[params setObject: value.length>0? value:@"" forKey:key.length>0?key:@""];
					}
				}
			}
		}else if(paramsArray.count == 1) {//无 &。url只有?后一个参数
			NSString* singleParamString = paramsArray[0];
			
			NSArray* singleParamSet = [singleParamString componentsSeparatedByString:@"="];
			if(singleParamSet.count==2) {
				NSString* key = singleParamSet[0];
				NSString* value =  [singleParamSet[1] stringByRemovingPercentEncoding];
				
				if(key.length>0 || value.length>0) {
					[params setObject:value?:@""forKey:key?:@""];
				}
			}else{
				//问号后面啥也没有 xxxx?  无需处理
			}
		}
		//整合url及参数
		return params;
	}else if(allElements.count>2) {
		NSLog(@"链接不合法！链接包含多个\"?\"");
		return @{};
	}else{
		NSLog(@"链接不包含参数！");
		return @{};
	}
}

+ (NSString *)getDeviceName {
	
	struct utsname systemInfo;
	uname(&systemInfo);
	NSString *deviceString = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
	
	//模拟器
	if ([deviceString isEqualToString:@"i386"])         return @"Simulator";
	if ([deviceString isEqualToString:@"x86_64"])       return @"Simulator";
	
	//iPhone
	if ([deviceString isEqualToString:@"iPhone1,1"])    return @"iPhone";
	if ([deviceString isEqualToString:@"iPhone1,2"])    return @"iPhone 3G";
	if ([deviceString isEqualToString:@"iPhone2,1"])    return @"iPhone 3GS";
	if ([deviceString isEqualToString:@"iPhone3,1"])    return @"iPhone 4";
	if ([deviceString isEqualToString:@"iPhone3,2"])    return @"iPhone 4";
	if ([deviceString isEqualToString:@"iPhone3,3"])    return @"iPhone 4";
	if ([deviceString isEqualToString:@"iPhone4,1"])    return @"iPhone 4S";
	if ([deviceString isEqualToString:@"iPhone5,1"])    return @"iPhone 5";
	if ([deviceString isEqualToString:@"iPhone5,2"])    return @"iPhone 5";
	if ([deviceString isEqualToString:@"iPhone5,3"])    return @"iPhone 5c";
	if ([deviceString isEqualToString:@"iPhone5,4"])    return @"iPhone 5c";
	if ([deviceString isEqualToString:@"iPhone6,1"])    return @"iPhone 5s";
	if ([deviceString isEqualToString:@"iPhone6,2"])    return @"iPhone 5s";
	if ([deviceString isEqualToString:@"iPhone7,1"])    return @"iPhone 6 Plus";
	if ([deviceString isEqualToString:@"iPhone7,2"])    return @"iPhone 6";
	if ([deviceString isEqualToString:@"iPhone8,1"])    return @"iPhone 6s";
	if ([deviceString isEqualToString:@"iPhone8,2"])    return @"iPhone 6s Plus";
	if ([deviceString isEqualToString:@"iPhone8,4"])    return @"iPhone SE";
	if ([deviceString isEqualToString:@"iPhone9,1"])    return @"iPhone 7";
	if ([deviceString isEqualToString:@"iPhone9,2"])    return @"iPhone 7 Plus";
	if ([deviceString isEqualToString:@"iPhone9,3"])    return @"iPhone 7";
	if ([deviceString isEqualToString:@"iPhone9,4"])    return @"iPhone 7 Plus";
	if ([deviceString isEqualToString:@"iPhone10,1"])   return @"iPhone 8";
	if ([deviceString isEqualToString:@"iPhone10,2"])   return @"iPhone 8 Plus";
	if ([deviceString isEqualToString:@"iPhone10,3"])   return @"iPhone X";
	if ([deviceString isEqualToString:@"iPhone10,4"])   return @"iPhone 8";
	if ([deviceString isEqualToString:@"iPhone10,5"])   return @"iPhone 8 Plus";
	if ([deviceString isEqualToString:@"iPhone10,6"])   return @"iPhone X";
	if ([deviceString isEqualToString:@"iPhone11,2"])   return @"iPhone XS";
	if ([deviceString isEqualToString:@"iPhone11,4"])   return @"iPhone XS Max";
	if ([deviceString isEqualToString:@"iPhone11,6"])   return @"iPhone XS Max";
	if ([deviceString isEqualToString:@"iPhone11,8"])   return @"iPhone XR";
	if ([deviceString isEqualToString:@"iPhone12,1"])   return @"iPhone 11";
	if ([deviceString isEqualToString:@"iPhone12,3"])   return @"iPhone 11 Pro";
	if ([deviceString isEqualToString:@"iPhone12,5"])   return @"iPhone 11 Pro Max";
	if ([deviceString isEqualToString:@"iPhone12,8"])   return @"iPhone SE2";
	if ([deviceString isEqualToString:@"iPhone13,1"])   return @"iPhone 12 mini";
	if ([deviceString isEqualToString:@"iPhone13,2"])   return @"iPhone 12";
	if ([deviceString isEqualToString:@"iPhone13,3"])   return @"iPhone 12 Pro";
	if ([deviceString isEqualToString:@"iPhone13,4"])   return @"iPhone 12 Pro Max";
	if ([deviceString isEqualToString:@"iPhone14,4"])   return @"iPhone 13 mini";
	if ([deviceString isEqualToString:@"iPhone14,5"])   return @"iPhone 13";
	if ([deviceString isEqualToString:@"iPhone14,2"])   return @"iPhone 13 Pro";
	if ([deviceString isEqualToString:@"iPhone14,3"])   return @"iPhone 13 Pro Max";
	if ([deviceString isEqualToString:@"iPhone14,6"])   return @"iPhone SE3";
	if ([deviceString isEqualToString:@"iPhone14,7"])   return @"iPhone 14";
	if ([deviceString isEqualToString:@"iPhone14,8"])   return @"iPhone 14 Plus";
	if ([deviceString isEqualToString:@"iPhone15,2"])   return @"iPhone 14 Pro";
	if ([deviceString isEqualToString:@"iPhone15,3"])   return @"iPhone 14 Pro Max";
	if ([deviceString isEqualToString:@"iPhone15,4"])   return @"iPhone 15";
	if ([deviceString isEqualToString:@"iPhone15,5"])   return @"iPhone 15 Plus";
	if ([deviceString isEqualToString:@"iPhone16,1"])   return @"iPhone 15 Pro";
	if ([deviceString isEqualToString:@"iPhone16,2"])   return @"iPhone 15 Pro Max";

	return deviceString;
}


///检查是否为URL
+ (BOOL)checkUrlWithString:(NSString *)url {
	if(url.length < 1)
		return NO;
	if (url.length>4 && [[url substringToIndex:4] isEqualToString:@"http"]) {
		return YES;
	}
	return NO;
}

// 获取文件路径
+ (NSString *)getStringWithFilePath:(NSString *)path {
	if (IsNilOrNull_tools(path)) {
		return @"";
	}
	return [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
}

+ (long long)fileSizeAtPath:(NSString*)filePath {
	struct stat st;
	if(lstat([filePath cStringUsingEncoding:NSUTF8StringEncoding], &st) == 0) {
		return st.st_size;
	}
	return 0;
}

+ (NSString *)getDateByNowAndBefor:(int)beforDays {
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"yyyyMMdd"];
	// 得到当前时间（世界标准时间 UTC/GMT）
	NSDate *nowDate = [NSDate date];
	if (beforDays == 0) {
		return stringFormat_tools(@"%@", [dateFormatter stringFromDate:nowDate]);
	} else {
		NSDate *appointDate;// 指定日期声明
		NSTimeInterval oneDay = 24 * 60 * 60;  // 一天一共有多少秒
		appointDate = [nowDate initWithTimeIntervalSinceNow: - (oneDay * beforDays)];
		return stringFormat_tools(@"%@", [dateFormatter stringFromDate:appointDate]);
	}
}




// 转换时分秒。 输出 xx:xxAM 或者 xx:xxPM    dateStr:yyyyMMddHHmmss 时间戳
+ (NSString *)getHHmmss:(NSString *)dateStr {
	if (isNull_tools(dateStr)) return @"";
	if (dateStr.length == 14) {
		NSString *HH = [dateStr substringWithRange:NSMakeRange(8, 2)]; // 小时
		NSString *mm = [dateStr substringWithRange:NSMakeRange(10, 2)]; // 分
		NSString *ss = [dateStr substringWithRange:NSMakeRange(12, 2)]; // 秒
		NSString *outPutTime = [NSString stringWithFormat:@"%@:%@:%@",HH,mm,ss];
		return outPutTime;
	}
	return dateStr;
}

// 转换小时和分。 输出 xx:xxAM 或者 xx:xxPM    dateStr:yyyyMMddHHmmss 时间戳
+ (NSString *)getHHmmAMPM:(NSString *)dateStr {
	if (isNull_tools(dateStr)) return @"";
	if (dateStr.length == 14) {
		NSString *HH = [dateStr substringWithRange:NSMakeRange(8, 2)]; // 小时
		NSString *mm = [dateStr substringWithRange:NSMakeRange(10, 2)]; // 分
		int HH_time = [HH intValue];
		if (HH_time > 12) {
			// 下午
			NSString *outPutTime = [NSString stringWithFormat:@"%d:%dPM",HH_time - 12,[mm intValue]];
			return outPutTime;
		} else {
			// 上午
			NSString *outPutTime = [NSString stringWithFormat:@"%d:%dAM",HH_time,[mm intValue]];
			return outPutTime;
		}
	}
	return dateStr;
}


/// 处理Html
+ (NSString *)divWithHtml:(NSString *)html video:(NSString *)videoUrl {
	if (html.length < 7) return html;
	NSString *first = [html substringWithRange:NSMakeRange(0, 3)];
	NSString *last = [html substringWithRange:NSMakeRange(html.length-4, 4)];
	if ([first isEqualToString:@"<p>"] && [last isEqualToString:@"</p>"]) {
		html = [html stringByReplacingCharactersInRange:NSMakeRange(0, 3) withString:@"<div>"];
		html = [html stringByReplacingCharactersInRange:NSMakeRange(html.length-4, 4) withString:@"</div>"];
	} else if ([last isEqualToString:@"</p>"]) {
		NSString *first1 = [html substringWithRange:NSMakeRange(0, 2)];
		int endIndex = 0;
		for (int i = 0; i<html.length-4; i++) {
			NSString *temp = [html substringWithRange:NSMakeRange(i, 1)];
			if ([temp isEqualToString:@">"]) {
				endIndex = i;
				break;
			}
		}
		if (endIndex>1 && endIndex< html.length-4 && [first1 isEqualToString:@"<p"]) {
			html = [html stringByReplacingCharactersInRange:NSMakeRange(0, endIndex+1) withString:@"<div>"];
			html = [html stringByReplacingCharactersInRange:NSMakeRange(html.length-4, 4) withString:@"</div>"];
		}
	} else {
		html = stringFormat_tools(@"<div>%@</div>", html);
	}
	
	if (!isEmptyString_tools(videoUrl)) {
		html = stringFormat_tools(@"<div>%@%@</div>",videoUrl, html);
	}
	
	NSString *strCssHead = [NSString stringWithFormat:@"<head>"
							"<link rel=\"stylesheet\" type=\"text/css\" href=\"OneHtmlCss.css\">"
							"<meta name=\"viewport\" content=\"initial-scale=1, maximum-scale=1, minimum-scale=1, width=device-width, user-scalable=no\">"
							"<style>img{max-width:320px !important;}</style>"
							"</head>"];
	return [NSString stringWithFormat:@"%@<body>%@</body>", strCssHead, html];
	
}


#pragma mark - 添加阴影效果
+ (UIView *)addShadowToView:(UIView *)theView withColor:(UIColor *)theColor {

	theView.layer.masksToBounds = NO;
	// 阴影颜色
	theView.layer.shadowColor = theColor.CGColor;
	// 阴影偏移，默认(0, -3)
	theView.layer.shadowOffset = CGSizeMake(0,0);
	// 阴影透明度，默认0
	theView.layer.shadowOpacity = 0.5;
	// 阴影半径，默认3
	theView.layer.shadowRadius = 5;
	return theView;
}


+ (NSString *)getDisplayAccNumber:(NSString *)accNumber {
	if (accNumber.length == 9) {
		NSString *first = [accNumber substringWithRange:NSMakeRange(0, 3)];
		NSString *second = [accNumber substringWithRange:NSMakeRange(3, 3)];
		NSString *third = [accNumber substringWithRange:NSMakeRange(6, 3)];
		return  stringFormat_tools(@"%@ %@ %@", first, second, third);
	}
	return accNumber;
}

/// 根据正则表达式校验字符串
+ (BOOL)validateStr:(NSString *)string withRegex:(NSString *)regex{
	if(isEmptyString_tools(regex)){
		return YES;
	}
	NSPredicate *resultStr = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
	return [resultStr evaluateWithObject:string];
}

+ (CGFloat)getWidthWithStr:(NSString *)title font:(UIFont *)font {
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 1000, 0)];
	label.text = title;
	label.font = font;
	[label sizeToFit];
	CGFloat width = label.frame.size.width;
	return ceil(width);
}

+ (NSString *)filterHTMLWithPTagLineFeed:(NSString *)html {
	
	html = [html stringByReplacingOccurrencesOfString:@"</p>" withString:@"\n</p>"];//两个<p>之间上加换行
	NSScanner * scanner = [NSScanner scannerWithString:html];
	NSString * text = nil;
	while(![scanner isAtEnd]) {
		[scanner scanUpToString:@"<" intoString:nil];
		[scanner scanUpToString:@">" intoString:&text];
		html = [html stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@>",text] withString:@""];
	}
	html = [html stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@" "];
	html = [html stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
	return html;
}

+ (NSString *)filterHTML:(NSString *)html {
	
	NSScanner * scanner = [NSScanner scannerWithString:html];
	NSString * text = nil;
	while(![scanner isAtEnd]) {
		[scanner scanUpToString:@"<" intoString:nil];
		[scanner scanUpToString:@">" intoString:&text];
		html = [html stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@>",text] withString:@""];
		html = [html stringByReplacingOccurrencesOfString:@"\n\n" withString:@"\n"];
	}
	html = [html stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@" "];
	html = [html stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
	return html;
}


//@"^(?=.*)(?=.*[a-z])(?=.*[A-Z]).{6,16}$";
+ (BOOL)isNumText:(NSString *)str{
	NSString * regex  = @"^\\d{9,}$";
	NSPredicate * pred  = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
	BOOL isMatch   = [pred evaluateWithObject:str];
	
	return isMatch;
}

+ (UIViewController *)currentVC {
	if ([[UIApplication sharedApplication].delegate.window.rootViewController isKindOfClass:[UINavigationController class]]) {
		return ((UINavigationController *)[UIApplication sharedApplication].delegate.window.rootViewController).topViewController;
	} else if ([[UIApplication sharedApplication].delegate.window.rootViewController isKindOfClass:[UITabBarController class]]) {
		UITabBarController *tab = (UITabBarController *)[UIApplication sharedApplication].delegate.window.rootViewController;
		return ((UINavigationController *)tab.selectedViewController).topViewController;
	}
	return nil;
}


+(NSString *)getMonthEndDayWithDate:(NSDate *)date{
	
	NSDate *newDate=date;
	double interval = 0;
	NSDate *beginDate = nil;
	NSDate *endDate = nil;
	NSCalendar *calendar = [NSCalendar currentCalendar];
		 
	[calendar setFirstWeekday:2];//设定周一为周首日
	BOOL ok = [calendar rangeOfUnit:NSCalendarUnitMonth startDate:&beginDate interval:&interval forDate:newDate];
	//分别修改为 NSDayCalendarUnit NSWeekCalendarUnit NSYearCalendarUnit
	if (ok) {
	   endDate = [beginDate dateByAddingTimeInterval:interval-1];
	}else {
	   return @"";
	}
	NSDateFormatter *myDateFormatter = [[NSDateFormatter alloc] init];
	[myDateFormatter setDateFormat:@"yyyyMMdd"];
	NSString *endString = [myDateFormatter stringFromDate:endDate];
	NSString *s = [NSString stringWithFormat:@"%@235959",endString];
	return s;
}


+ (NSString *)changeNewDateFormatWithStr1:(NSString *)dateStr {
	//设置时间显示格式
	NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
	[formatter setDateFormat:@"yyyy-MM-dd"];//输入的日期格式
	
	NSDateFormatter *dateFormat = [[NSDateFormatter alloc]init];
	[dateFormat setDateFormat:@"yyyyMMddHHmmss"];//输出的日期格式
	
	NSDate *date = [formatter dateFromString:dateStr];
	
	//将时间戳(long long 型)转化为NSDate ,注意除以1000(IOS要求是10位的时间戳)
//    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timestamp/1000];
//    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timestamp];

	//将NSDate按格式转化为对应的时间格式字符串
	NSString *timeString = [dateFormat stringFromDate:date];
	return timeString;
}

+ (NSString *)getCurrentDateStr{
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
	
	// 得到当前时间（世界标准时间 UTC/GMT）
	NSDate *nowDate = [NSDate date];
	NSString *nowDateString = [dateFormatter stringFromDate:nowDate];
	return [NSString stringWithFormat:@"%@",nowDateString];
}

+ (CGFloat)singleWidthWithMaxWidth:(CGFloat)width withFont:(UIFont*)font string:(NSString *)string {
	NSAssert(font, @"singleWidthWithMaxWidth:方法必须传进font参数");
	
	CGSize size = CGSizeZero;
	NSDictionary *attribute = @{NSFontAttributeName: font};
	size = [string boundingRectWithSize:CGSizeMake(width, MAXFLOAT)
							  options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:attribute context:nil].size;
	
	return ceilf(size.width);
}


#pragma mark - 计算高度
+ (CGFloat)configHeightWithContent:(NSString *)content font:(float)font width:(float)width{
	
	CGSize size1 = CGSizeMake(width,MAXFLOAT);
	CGSize lbRect2 = [content boundingRectWithSize:size1 options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:font]} context:nil].size;
	NSNumber *count2 = @((lbRect2.height) / font);
	NSInteger lineNum2 = [count2 integerValue];
//    font+杭高
	return (font+4)*lineNum2+6;
	
}


+ (NSString *)handleImageUrlWithSpace:(NSString *)path {
	if (!path.length) {
		return @"";
	}
	
	if ([path containsString:@" "]) {
		NSString *temp = [path stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
		temp = [temp stringByReplacingOccurrencesOfString:@"\r" withString:@""];
		temp = [temp stringByReplacingOccurrencesOfString:@"\n" withString:@""];
		return temp;
	}
	return path;
}





+ (NSString *)dateStrByMediumStyleDate:(NSDate *)date {
	NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en"];
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    dateFormatter.dateStyle = NSDateFormatterMediumStyle;
	dateFormatter.dateFormat = @"MMM, dd, yyyy";
	[dateFormatter setLocale:locale];
	NSString *dateStr = [dateFormatter stringFromDate:date];
	
	return dateStr;
}

+ (NSString *)getEnShortDateStrByDate:(NSDate *)date {
	
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en"];
	[dateFormatter setDateFormat:@"MMM yyyy"];
	[dateFormatter setLocale:locale];
//    dateFormatter.dateStyle = NSDateFormatterMediumStyle;
	NSString *dateStr = [dateFormatter stringFromDate:date];
	return dateStr;
}

+ (NSDate*)getPriousorLaterDateFromDate:(NSDate*)date withMonth:(NSInteger)month {

	NSDateComponents *comps = [[NSDateComponents alloc] init];
	[comps setMonth:month];
	NSCalendar *calender = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];// 公历NSGregorianCalendar
	NSDate *mDate = [calender dateByAddingComponents:comps toDate:date options:0];
	return mDate;

}

+ (NSDateComponents *)getComponentsFromDate:(NSDate *)date {
	
	NSCalendar *calendar = [NSCalendar currentCalendar];
	NSInteger unitFlag = NSCalendarUnitMonth | NSCalendarUnitYear;
	NSDateComponents *components = [calendar components:unitFlag fromDate:date];
	return components;
//    NSInteger month = [components month];
//    NSInteger year = [components year];
}

+ (NSString *)getYearAndMonthFromDate:(NSDate *)date {
	
	NSCalendar *calendar = [NSCalendar currentCalendar];
	NSInteger unitFlag = NSCalendarUnitMonth | NSCalendarUnitYear;
	NSDateComponents *components = [calendar components:unitFlag fromDate:date];
	NSInteger month = [components month];
	NSInteger year = [components year];
	if (month<10) {
		return [NSString stringWithFormat:@"%ld-0%ld",year,month];
	}
	return [NSString stringWithFormat:@"%ld-%ld",year,month];
}

+ (NSString *)getTimestampToString:(NSString *)dateStr {
	//设置时间显示格式
	NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
	NSDateFormatter *dateFormat = [[NSDateFormatter alloc]init];
	//[formatter setDateStyle:NSDateFormatterMediumStyle];
	[formatter setDateFormat:@"dd/MM/yyyy"];
	//[formatter setTimeStyle:NSDateFormatterShortStyle];
	[dateFormat setDateFormat:@"yyyyMMddHHmmss"];
	NSDate *date = [dateFormat dateFromString:dateStr];
	
	//将时间戳(long long 型)转化为NSDate ,注意除以1000(IOS要求是10位的时间戳)
//    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timestamp/1000];
//    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timestamp];

	//将NSDate按格式转化为对应的时间格式字符串
	NSString *timeString = [formatter stringFromDate:date];
	return timeString;
}

+ (NSString *)getNormalDateToString:(NSString *)dateStr{
	//设置时间显示格式
	NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
	NSDateFormatter *dateFormat = [[NSDateFormatter alloc]init];
	//[formatter setDateStyle:NSDateFormatterMediumStyle];
	[formatter setDateFormat:@"dd/MM/yyyy HH:mm:ss"];
	//[formatter setTimeStyle:NSDateFormatterShortStyle];
	[dateFormat setDateFormat:@"yyyyMMddHHmmss"];
	NSDate *date = [dateFormat dateFromString:dateStr];
	
	//将时间戳(long long 型)转化为NSDate ,注意除以1000(IOS要求是10位的时间戳)
//    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timestamp/1000];
//    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timestamp];

	//将NSDate按格式转化为对应的时间格式字符串
	NSString *timeString = [formatter stringFromDate:date];
	return timeString;
}


+ (NSString *)getDateFromString:(NSString *)dateStr {
	//设置时间显示格式
	NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
	NSDateFormatter *dateFormat = [[NSDateFormatter alloc]init];
	[formatter setDateFormat:@"dd/MM/yyyy"];
	[dateFormat setDateFormat:@"yyyyMMdd"];
	NSDate *date = [dateFormat dateFromString:dateStr];
	NSString *timeString = [formatter stringFromDate:date];
	return timeString;
}


+ (NSString *)getShortDateFromString:(NSString *)dateStr {
	//设置时间显示格式
	NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
	NSDateFormatter *dateFormat = [[NSDateFormatter alloc]init];
	[formatter setDateFormat:@"dd/MM/yyyy"];
	[dateFormat setDateFormat:@"yyyyMMddHHmmss"];
	NSDate *date = [dateFormat dateFromString:dateStr];
	NSString *timeString = [formatter stringFromDate:date];
	return timeString;
}


+ (NSString *)getNowTimeTimestamp {
	
	NSDate *datenow = [NSDate date];//现在时间,你可以输出来看下是什么格式
	NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)[datenow timeIntervalSince1970]];
	return timeSp;
}

+ (NSString *)getFormatterMoney:(NSString *)str {
	if (!str.length) {
		return @"0";
	}
	CGFloat num = [str floatValue];
	NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
	formatter.numberStyle = NSNumberFormatterDecimalStyle;
	NSString *string = [formatter stringFromNumber:[NSNumber numberWithDouble:num]];
	return string;
}

//MD5
+ (NSString *)md5:(NSString *)str {
	const char *cStr = [str UTF8String];
	unsigned char result[16];
	CC_MD5(cStr, strlen(cStr), result); // This is the md5 call
	return [NSString stringWithFormat:
			@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
			result[0], result[1], result[2], result[3],
			result[4], result[5], result[6], result[7],
			result[8], result[9], result[10], result[11],
			result[12], result[13], result[14], result[15]
			];
}

+ (NSString *)md5String:(NSString *)str {
	const char *myPasswd = [str UTF8String ];
	unsigned char mdc[ 16 ];
	CC_MD5 (myPasswd, ( CC_LONG ) strlen (myPasswd), mdc);
	NSMutableString *md5String = [ NSMutableString string ];
	for ( int i = 0 ; i< 16 ; i++) {
		[md5String appendFormat : @"%02x" ,mdc[i]];
	}
	return md5String;
}

//+ (KFileType)getFileTypeByFileName:(NSString *)fileName {
//	fileName = [fileName lowercaseString];
//	if ([fileName rangeOfString:@".jpeg"].location != NSNotFound || [fileName rangeOfString:@".jpg"].location != NSNotFound || [fileName rangeOfString:@".png"].location != NSNotFound) {
//		return KFileType_image;
//	} else if ([fileName rangeOfString:@".pdf"].location != NSNotFound) {
//		return KFileType_pdf;
//	} else if ([fileName rangeOfString:@".doc"].location != NSNotFound) {
//		return KFileType_doc;
//	} else if ([fileName rangeOfString:@".docx"].location != NSNotFound) {
//		return KFileType_docx;
//	} else if ([fileName rangeOfString:@".txt"].location != NSNotFound) {
//		return KFileType_txt;
//	}
//	return KFileType_none;
//}

@end
