//
//  STModuleService+briefMethods.h
//  STModuleService
//
//  Created by stephen.chen on 2021/12/9.
//

#import <STComponentTools/STAnnotationHeader.h>

#import "STModuleServiceDefines.h"
NS_ASSUME_NONNULL_BEGIN

#if defined(__cplusplus)
extern "C" {
#endif

/**
 注册服务
 @param cls 服务类
 @param protocol 服务协议
 @param err 错误信息
 */
BOOL stModuleServiceRegisterExecute(Class cls, Protocol * protocol, NSError *__nullable *__nullable err);

/**
 获取服务
 
 @param protocol 服务协议
 @param err 错误信息
 */
__kindof Class __nullable stModuleServiceWithProtocol(Protocol *protocol, NSError *__nullable *__nullable err);


/**
 组件私有方法， 不可调用
 */
BOOL STModuleServiceRegisterName(Class cls, NSString * proName, NSError *__nullable *__nullable err);
__kindof Class __nullable stModuleServiceWithProtocolName(NSString *proName, NSError *__nullable *__nullable err);

#if defined(__cplusplus)
}
#endif

NS_ASSUME_NONNULL_END
