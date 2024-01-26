//
//  STRouterHelper.m
//  STRouter
//
//  Created by stephen.chen on 2021/11/4.
//

#import "STRouterHelper.h"

#import "STRouterDefines.h"

@implementation STRouterHelper
+ (NSError *)st_createError:(NSInteger)code info:(NSDictionary *)info message:(NSString *)msg {
    NSMutableDictionary *errInfo =
    [NSMutableDictionary dictionaryWithDictionary:
     @{
        NSLocalizedDescriptionKey: msg.length ? msg : @"STRouterError unknow",
        NSLocalizedFailureReasonErrorKey : msg.length ? msg : @"STRouterError unknow",
        STRouterError_descriptionKey : msg.length ? msg : @"STRouterError unknow",
    }];
    
    [errInfo addEntriesFromDictionary:info];
    NSError *error = [NSError errorWithDomain:STRouterError_domain code:code userInfo:errInfo];
    NSLog(@"STRouter work unnormal:%@", msg);
    return error;
}
@end
