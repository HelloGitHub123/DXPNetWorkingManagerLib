//
//  DCNetAPITools.m
//  DXPNetWorkingManagerLib
//
//  Created by 李标 on 2025/5/29.
//

#import "DCNetAPITools.h"
#import "DCNetworkHeader.h"

#define prefix  @"/api/sg/v1/fusioncore"

@implementation DCNetAPITools

// 返回处理好后的url eg:/api/sg/v1/fusioncore/subscirber-management/dxp/subscriber-management/v1/subscribers/detail
// aPath: /dxp/subscriber-management/v1/subscribers/detail
+ (NSString *)getProxyPathURLString:(NSString *)aPath {
	if (dcIsEmptyString(aPath)) {
		return aPath;
	}
	NSString *strPath = aPath;
	// 取出对应映射的val
	NSString *pathVal = [DCNetAPITools getAPathValue:aPath];
	// 拼接
	strPath = [NSString stringWithFormat:@"%@%@%@",prefix,pathVal,aPath];
	return strPath;
}

// 获取对应aPath的dxp key
+ (NSString *)getAPathValue:(NSString *)keyPath {
	
	NSDictionary *dic = @{
		@"/dxp/customer-bill": @"/customer-bill-management",
		@"/dxp/trouble-ticket": @"/trouble-ticket-management",
		@"/dxp/promotion-management": @"/promotion-management",
		@"/dxp/menu-management": @"/menu-management",
		@"/dxp/dashboard": @"/dashboard",
		@"/dxp/content-management": @"/content-management",
		@"/dxp/loyalty-management": @"/loyalty-management",
		@"/dxp/message-management": @"/message-management",
		@"/dxp/advertisement": @"/message-management",
		@"/dxp/usage-consumption": @"/usage-consumption-management",
		@"/dxp/proj/package-advantage": @"/package-advantage",
		@"/dxp/page-builder": @"/page-builder",
		@"/dxp/user-management": @"/user-management",
		@"/dxp/resource-inventory": @"/resource-inventory-management",
		@"/dxp/proj/resource-inventory": @"/resource-inventory-management",
		@"/dxp/subscriber-management": @"/subscirber-management",
		@"/dxp/proj/subscriber-management": @"/subscirber-management",
		@"/dxp/app-launch-management": @"/app-launch-management",
		@"/dxp/agreement-management": @"/agreement-management",
		@"/dxp/customer-balance": @"/customer-balance-management",
		@"/dxp/account-management": @"/account-management",
		@"/dxp/theme-management": @"/theme-management",
		@"/dxp/app-version-management": @"/app-version-management",
		@"/dxp/common-management": @"/common-management",
		@"/dxp/proj/common-management": @"/common-management",
		@"/dxp/game-management": @"/game-management",
		@"/dxp/payment-management": @"/payment-management",
		@"/dxp/customer-management": @"/customer-management",
		@"/dxp/product-catalog": @"/product-catalog-management",
		@"/dxp/proj/marketing-management": @"/marketing-campaign-management",
		@"/dxp/journey-builder": @"/journey-builder",
		@"/dxp/proj/product-ordering": @"/product-ordering",
		@"/dxp/product-ordering": @"/product-ordering",
		@"/dxp/proj/order-management": @"/product-ordering",
	};
	
	NSArray *keyList = [dic allKeys];
	NSString __block *pathVal = keyPath;
	[keyList enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL * _Nonnull stop) {
		// 查找
		if ([keyPath containsString:obj]) {
			// 取出value
			pathVal = [dic valueForKey:obj];
			*stop = YES;
		}
	}];
	
	return pathVal;
}

@end
