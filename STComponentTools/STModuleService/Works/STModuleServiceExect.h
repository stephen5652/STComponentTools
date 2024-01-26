//
//  STModuleServiceExect.h
//  STModuleService
//
//  Created by stephen.chen on 2021/11/8.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface STModuleServiceExect : NSObject<NSCopying, NSMutableCopying>
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
- (__kindof Class)stModuleWithProtocol:(Protocol *)protocol error:(NSError *__nullable *__nullable)err;

- (BOOL)stRegisterModuleService:(Class)cls protocolName:(NSString *)proName err:(NSError *__nullable *__nullable)err;
- (__kindof Class)stModuleWithProtocolName:(NSString *)protocol error:(NSError *__nullable *__nullable)err;
@end

NS_ASSUME_NONNULL_END
