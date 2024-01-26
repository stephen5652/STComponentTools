//
//  STRouter.m
//  Pods-STRouter_Example
//
//  Created by stephen.chen on 2021/11/3.
//

#import "STRouter.h"

#import "STRouterExecute.h"
#import "STRouterHelper.h"

@interface STRouter ()
@end

@implementation STRouter

+ (instancetype)shareInstance {
    return [STRouter new];
}

- (BOOL)stRegisterUrlPartterns:(NSString *)urlParttern error:(NSError **)err action:(STRouterUrlExecuteAction)urlExecuteAction {
    return [[STRouterExecute new] stRegisterUrlPartterns:urlParttern error:err action:urlExecuteAction];
}

- (BOOL)stDeregisterUrl:(NSString *)url {
    return [[STRouterExecute new] stDeregisterUrl:url];
}

- (void)stDeregisterAllUrls {
    [[STRouterExecute new] stDeregisterAllUrls];
}

/// 全局拦截器
- (void)stSetRouterGlobalInterceptor:(NSObject <STRouterInterceptorProtocol> *)globalInterceptor {
    [[STRouterExecute new] stSetRouterGlobalInterceptor:globalInterceptor];
}

- (void)stSetRouterMessageExporter:(NSObject<STRouterMessageExportProtocol> *)exporter {
    [[STRouterExecute new] stSetRouterMessageExporter:exporter];
}

- (void)stOpenUrl:(STRouterUrlRequest *)request complete:(STRouterUrlCompletion __nullable)complete {
    [[STRouterExecute new] stOpenUrl:request complete:complete];
}

- (void)stOpenUrlInstance:(NSString *)urlInstance fromVC:(UIViewController * __nullable)fromVC complete:(STRouterUrlCompletion __nullable) complete {
    [[STRouterExecute new] stOpenUrlInstance:urlInstance fromVC:fromVC complete:complete];
}

- (BOOL)stCanOpenUrl:(NSString *)url parameter:(NSDictionary *__nullable)parameters absolute:(BOOL)absolute error:(NSError *__nullable *__nullable)err {
    return [[STRouterExecute new] stCanOpenUrl:url parameter:parameters absolute:absolute error:err];
}

- (NSDictionary *)stRouterMapperDict {
    return [[STRouterExecute new] stRouterMapperDict];
}

- (NSString *)stRouterMapperJsonString {
    return [[STRouterExecute new] stRouterMapperJsonString];
}

@end
