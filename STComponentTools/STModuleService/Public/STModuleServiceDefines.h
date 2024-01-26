//
//  STModuleServiceDefines.h
//  STModuleService
//
//  Created by stephen.chen on 2021/11/8.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 服务组件中的错误 domain
 */
FOUNDATION_EXPORT NSErrorDomain const YKModuleError_domain;

/**
 服务组件中的错误描述键值
 */
FOUNDATION_EXPORT NSErrorUserInfoKey const YKModuleError_descriptionKey;

/**
 注册器协议
 */
@protocol STModuleServiceRegisterProtocol <NSObject>
/**
 服务注册事件
 @discussion 在此方法体内调用服务注册
 */
+ (void)stModuleServiceRegistAction;

@end
NS_ASSUME_NONNULL_END
