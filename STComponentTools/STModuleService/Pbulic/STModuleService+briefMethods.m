//
//  STModuleService+briefMethods.m
//  STModuleService
//
//  Created by stephen.chen on 2021/12/9.
//

#import "STModuleService+briefMethods.h"

#import <STComponentTools/STModuleService.h>
#import "STModuleServiceExect.h"

@interface STModuleService(priExtension)
@end
@implementation STModuleService(priExtension)

- (BOOL)stRegisterModuleService:(Class)cls protocolName:(NSString *)proName err:(NSError *__nullable *__nullable)err {
    return [[STModuleServiceExect new] stRegisterModuleService:cls protocolName:proName err:err];
}

- (__kindof Class)stModuleWithProtocolName:(NSString *)proName error:(NSError *__nullable *__nullable)err {
    return  [[STModuleServiceExect new] stModuleWithProtocolName:proName error:err];
}

@end

@implementation STModuleService (briefMethods)

@STDirectRegist(){
    [STAnnotation stRegisterProtocol:@protocol(STModuleServiceRegisterProtocol)];
}

BOOL stModuleServiceRegisterExecute(Class cls, Protocol * protocol, NSError *__nullable *__nullable err) {
    return [[STModuleService new] stRegisterModuleService:cls protocol:protocol err:err];
}

__kindof Class __nullable stModuleServiceWithProtocol(Protocol *protocol, NSError *__nullable *__nullable err) {
    return [[STModuleService new] stModuleWithProtocol:protocol error:err];
}

BOOL STModuleServiceRegisterName(Class cls, NSString * proName, NSError *__nullable *__nullable err) {
    return [[STModuleService new] stRegisterModuleService:cls protocolName:proName err:err];
}

__kindof Class __nullable stModuleServiceWithProtocolName(NSString *proName, NSError *__nullable *__nullable err) {
    return [[STModuleService new] stModuleWithProtocolName:proName error:err];
}
@end
