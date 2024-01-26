//
//  STRouterDefines.h
//  Pods
//
//  Created by stephen.chen on 2021/11/4.
//

#ifndef STRouterDefines_h
#define STRouterDefines_h

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class STRouterUrlResponse;
typedef void(^STRouterUrlCompletion)(STRouterUrlResponse *urlResponse);

@class STRouterUrlRequest;
typedef void(^STRouterUrlExecuteAction)(STRouterUrlRequest *urlRequest, STRouterUrlCompletion __nullable completetion);

/**
 路由拦截器协议
 */
@protocol STRouterInterceptorProtocol <NSObject>

/**
 是否可以打开URL
 
 @discussion URL 默认是可以打开的.
 
 @param urlParttern 注册的URL
 @param parameter URL 参数
 @param msgBack 回调
 */
- (BOOL)stRouterShouldOpenUrlParttern:(NSString *)urlParttern parameter:(NSDictionary<NSString *, NSString *> *)parameter msessageBack:(NSString * __nonnull *__nullable)msgBack;

- (BOOL)stRouterWhetheExchangeUrlParttern:(NSString *)url parameter:(NSDictionary<NSString *, NSString *> *)parameter urlPartternBack:(NSString *__nonnull *__nullable)urlBack parameterBack:(NSDictionary * __nonnull *__nullable)paraBack messageBack:(NSString *__nonnull *__nullable)msgBack;

@end

/**
 路由辅助信息格式定义
 */
@protocol STRouterMessageBodyProtocol <NSObject>
@property(nonatomic, readonly) NSString * eventName; ///< 事件名称
@property (nonatomic,readonly) NSUInteger eventIdentifier; ///< 事件数字表示
@property(nonatomic, readonly) NSString * eventMessage; ///< 事件信息
@end

/**
 路由辅助信息输出协议
 */
@protocol STRouterMessageExportProtocol <NSObject>
@optional
- (void)stRouterExcuteEvent:(__kindof NSObject<STRouterMessageBodyProtocol> *)messageBody;
@end

FOUNDATION_EXPORT NSErrorDomain const STRouterError_domain;
FOUNDATION_EXPORT NSErrorUserInfoKey const STRouterError_descriptionKey;

FOUNDATION_EXPORT NSString const *STRouterWildcard_domain;

typedef NS_ENUM(NSInteger, STRouterErrorCode) {
    STRouterErrorCode_success = 0, /// < 业务成功
    STRouterErrorCode_noUrl = -1, /// < URL未注册
    STRouterErrorCode_urlClosed = -2, /// < URL关闭
    STRouterErrorCode_urlDuplicate = -3, /// < 重复注册URL
};

typedef NS_ENUM(NSInteger, STRouterAnimationType) {
    STRouterAnimationType_push = 0, /// < 压栈切换界面
    STRouterAnimationType_present, /// < 模态切换界面
};

NS_ASSUME_NONNULL_END

#endif /* STRouterDefines_h */
