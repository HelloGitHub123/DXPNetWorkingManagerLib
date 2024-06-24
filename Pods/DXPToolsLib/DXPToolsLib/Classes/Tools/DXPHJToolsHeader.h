//
//  DXPHJToolsHeader.h
//  Pods
//
//  Created by 李标 on 2024/6/8.
//

#ifndef DXPHJToolsHeader_h
#define DXPHJToolsHeader_h


#define isNull_tools(x)                (!x || [x isKindOfClass:[NSNull class]])
#define isEmptyString_tools(x)         (isNull_tools(x) || [x isEqual:@""] || [x isEqual:@"(null)"] || [x isEqual:@"null"])
#define IsArrEmpty_tools(_ref)    (((_ref) == nil) || ([(_ref) isEqual:[NSNull null]]) ||([(_ref) count] == 0))
#define IsNilOrNull_tools(_ref)        (((_ref) == nil) || ([(_ref) isEqual:[NSNull null]]))

//将数据保存在本地
#define NSUSER_DEF_SET_tools(a,b) [[NSUserDefaults standardUserDefaults] setValue:a forKey:b]
//从本地读取数据
#define NSUSER_DEF_tools(a)  [[NSUserDefaults standardUserDefaults] valueForKey:a]

#define stringFormat_tools(s, ...)     [NSString stringWithFormat:(s),##__VA_ARGS__]


#endif /* DXPToolsHeader_h */
