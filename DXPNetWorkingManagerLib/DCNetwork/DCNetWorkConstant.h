//
//  DCNetWorkConstant.h
//  Base
//
//  Created by 胡灿 on 2026/1/14.
//

#ifndef DCNetWorkConstant_h
#define DCNetWorkConstant_h

#define dcNetWk_isNull(x)                (!x || [x isKindOfClass:[NSNull class]])
#define dcNetWk_isEmptyString(x)         (dcNetWk_isNull(x) || [x isEqual:@""] || [x isEqual:@"(null)"] || [x isEqual:@"null"] || [x isEqual:@"<null>"])

#endif /* DCNetWorkConstant_h */
