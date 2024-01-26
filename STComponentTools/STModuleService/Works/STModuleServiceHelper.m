//
//  STModuleServiceHelper.m
//  STModuleService
//
//  Created by stephen.chen on 2021/11/8.
//

#import "STModuleServiceHelper.h"

#import "STModuleServiceDefines.h"

@implementation STModuleServiceHelper
+ (NSError *)st_createError:(NSInteger)code info:(NSDictionary *)info message:(NSString *)msg {
    NSMutableDictionary *errInfo =
    [NSMutableDictionary dictionaryWithDictionary:
     @{
        NSLocalizedDescriptionKey: msg.length ? msg : @"YKModuleError unknow",
        NSLocalizedFailureReasonErrorKey : msg.length ? msg : @"YKModuleError unknow",
        YKModuleError_descriptionKey : msg.length ? msg : @"YKModulrError unknow",
    }];
    
    [errInfo addEntriesFromDictionary:info];
    NSError *error = [NSError errorWithDomain:YKModuleError_domain code:code userInfo:errInfo];
    return error;
}
@end
