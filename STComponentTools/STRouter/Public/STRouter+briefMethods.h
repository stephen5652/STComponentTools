//
//  STRouter+briefMethods.h
//  STRouter
//
//  Created by stephen.chen on 2021/12/2.
//

#import <STComponentTools/STRouter.h>

#import <STComponentTools/STAnnotation.h>

NS_ASSUME_NONNULL_BEGIN

#if defined(__cplusplus)
extern "C" {
#endif

@interface STRouter (briefMethods)

/**
 注册URL
 @param urlParttern url parttern
 @param errBack 错误回调
 @param executeAction 响应事件
 */
BOOL stRouterRegisterUrlParttern(NSString * urlParttern, NSError **errBack, STRouterUrlExecuteAction executeAction);

/**
 打开URL
 
 @param request 请求
 @param complete 回调
 */
void stRouterOpenUrlRequest(STRouterUrlRequest *request, STRouterUrlCompletion complete);

/**
 取消所有注册
 */
void stDeregisterAllUrls(void);

@end

#if defined(__cplusplus)
}
#endif

NS_ASSUME_NONNULL_END
