//
//  DCReqApiClsBindModel.m
//  Base
//
//  Created by 胡灿 on 2025/11/20.
//

#import "DCReqApiDataClsBindModel.h"
#import <objc/runtime.h>
#import "DCBaseReqResModel.h"
#import "DCBaseReqParasModel.h"

@implementation DCReqApiDataClsBindModel

- (void)setResModelCls:(Class)resModelCls {
    if (_resModelCls != resModelCls && [resModelCls isKindOfClass:object_getClass(DCBaseReqResModel.class)]) {
        // 只有DCBaseReqResModel及其子类才可以设置该值
        _resModelCls = resModelCls;
    }
}

- (void)setParasModelCls:(Class)parasModelCls {
    if (_parasModelCls != parasModelCls && [parasModelCls isKindOfClass:object_getClass(DCBaseReqParasModel.class)]) {
        // 只有DCBaseReqParasModel及其子类才可以设置该值
        _parasModelCls = parasModelCls;
    }
}

@end
