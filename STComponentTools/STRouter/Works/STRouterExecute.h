//
//  STRouterExecute.h
//  STRouter
//
//  Created by stephen.chen on 2021/11/4.
//

#import <Foundation/Foundation.h>

#import "STRouterDefines.h"
#import "STRouterParameter.h"
NS_ASSUME_NONNULL_BEGIN

@interface STRouterExecute : NSObject

/**
 清除注册过的路由
 */
- (void)stDeregisterAllUrls;

/**
 注册URL
 
 @param urlParttern url字符串
 @param urlExecuteAction url执行事件
 */
- (BOOL)stRegisterUrlPartterns:(NSString *)urlParttern error:(NSError **)err action:(STRouterUrlExecuteAction)urlExecuteAction;

/**
 取消注册URL
 
 @param url url字符串
 */
- (BOOL)stDeregisterUrl:(NSString *)url;

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
