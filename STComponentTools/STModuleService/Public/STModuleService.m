//
//  STModuleService.m
//  STModuleService
//
//  Created by stephen.chen on 2021/11/8.
//

#import "STModuleService.h"

#import "STModuleServiceExect.h"

@implementation STModuleService
- (BOOL)stRegisterModuleService:(Class)cls protocol:(Protocol *)protocol err:(NSError *__nullable *__nullable)err {
    return [[STModuleServiceExect new] stRegisterModuleService:cls protocol:protocol err:err];
}

- (__kindof Class  __nullable)stModuleWithProtocol:(Protocol *)protocol error:(NSError *__nullable *__nullable)err {
    return [[STModuleServiceExect new] stModuleWithProtocol:protocol error:err];
}
@end
