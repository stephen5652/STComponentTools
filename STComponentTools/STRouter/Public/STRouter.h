//
//  STRouter.h
//  Pods-STRouter_Example
//
//  Created by stephen.chen on 2021/11/3.
//

#import <Foundation/Foundation.h>

#import "STRouterDefines.h"
#import "STRouterParameter.h"

#import <STComponentTools/STAnnotation.h>

NS_ASSUME_NONNULL_BEGIN

@class UIViewController;

@protocol STRouterRegisterProtocol <NSObject>

/**
 路由注册执行事件
 
 @discussion 用以在此事件中注册业务模块的多个路由事件
 
 */
+ (void)stRouterRegisterExecute;

@end

@interface STRouter : NSObject

+ (instancetype)shareInstance;

/**
 注册URL
 
 @param urlParttern url字符串
 @param urlExecuteAction url执行事件
 @param err 错误回调
 */
- (BOOL)stRegisterUrlPartterns:(NSString *)urlParttern error:(NSError **)err action:(STRouterUrlExecuteAction)urlExecuteAction;

/**
 取消注册URL
 
 @param url url字符串
 */
- (BOOL)stDeregisterUrl:(NSString *)url;

/**
 清除注册过的路由
 */
- (void)stDeregisterAllUrls;

/**
 设置全局拦截器
 
 @discussion URL 在打开的过程中, 提供了全局拦截的机会, 用以支持通过拦截表来开启或关闭某些URL.
 
 @param globalInterceptor 全局拦截器
 */
- (void)stSetRouterGlobalInterceptor:(NSObject<STRouterInterceptorProtocol> *)globalInterceptor;

/**
 设置消息输出器
 @param exporter 消息输出器
 */
- (void)stSetRouterMessageExporter:(NSObject<STRouterMessageExportProtocol> *)exporter;

/**
 打开URL
 
 @param request 请求
 @param complete 回调
 */
- (void)stOpenUrl:(STRouterUrlRequest *)request complete:(STRouterUrlCompletion __nullable) complete;

/**
 打开URL
 
 @param urlInstance url
 @param fromVC 上级界面
 @param complete 回调
 */
- (void)stOpenUrlInstance:(NSString *)urlInstance fromVC:(UIViewController * __nullable)fromVC complete:(STRouterUrlCompletion __nullable) complete;

/**
 检查是否可以开启URL
 
 @discussion 检查路由能否开启的时候,有3个要素:
 1. urlparttern 被取消了
 2. 精准匹配, 没有匹配到完整urlparttern的路由节点
 3. 模糊匹配, 没有匹配到任何可以用的路由节点.
 
 @param url URL
 @param parameters 参数
 @param absolute 绝对匹配/模糊匹配
 @param err 错误信息
 */
- (BOOL)stCanOpenUrl:(NSString *)url parameter:(NSDictionary * __nullable)parameters absolute:(BOOL)absolute error:(NSError *__nullable *__nullable)err;

# pragma mark - debug methods
- (NSString *)stRouterMapperJsonString;
- (NSDictionary *)stRouterMapperDict;
@end

NS_ASSUME_NONNULL_END
