//
//  STModuleService.h
//  STModuleService
//
//  Created by stephen.chen on 2021/11/8.
//

#import <Foundation/Foundation.h>

#import "STModuleServiceDefines.h"

NS_ASSUME_NONNULL_BEGIN

@interface STModuleService : NSObject
/**
 注册服务
 @param cls 服务类
 @param protocol 服务协议
 @param err 错误信息
 */
- (BOOL)stRegisterModuleService:(Class)cls protocol:(Protocol *)protocol err:(NSError *__nullable *__nullable)err;

/**
 获取服务
 
 @param protocol 服务协议
 @param err 错误信息
 */
- (__kindof Class __nullable)stModuleWithProtocol:(Protocol *)protocol error:(NSError *__nullable *__nullable)err;
@end

NS_ASSUME_NONNULL_END
