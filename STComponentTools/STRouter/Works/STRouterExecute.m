//
//  STRouterExecute.m
//  STRouter
//
//  Created by stephen.chen on 2021/11/4.
//

#import "STRouterExecute.h"

#import "STRouter+briefMethods.h"
#import "STRouterHelper.h"
#import "STRouterUrlParser.h"
#import "STRouterMapperNode.h"
#import "STRouterMessageBody.h"

#import <pthread/pthread.h>

#import <STComponentTools/STAnnotationHeader.h>
#import <YYModel/YYModel.h>

@interface STRouterExecute ()
@property(nonatomic, strong) STRouterMapperNode *routerNodesMap; ///< 路由表--事件
@property(nonatomic, strong) NSObject <STRouterInterceptorProtocol> *globalInterceptor; ///< 全局拦截器
@property (nonatomic, strong) NSObject<STRouterMessageExportProtocol> * messageExporter; ///< 消息输出器

- (instancetype)init_routerExecute;
@end

@implementation STRouterExecute

@STDirectRegist(){
    [STAnnotation stRegisterProtocol:@protocol(STRouterRegisterProtocol)];
}

static STRouterExecute *imp;

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        imp = [(STRouterExecute *) [super allocWithZone:zone] init_routerExecute];
    });
    return imp;
}

- (instancetype)init {  return imp;}

- (id)copyWithZone:(NSZone *)zone { return imp;}

- (id)mutableCopyWithZone:(NSZone *)zone { return imp;}

- (instancetype)init_routerExecute {
    if (self = [super init]) {
        self.routerNodesMap = [STRouterMapperNode new];
    }
    return self;
}

- (void)initRouterConfig {
    if (self.routerNodesMap.isNodesEmpty) { //没有节点
        @synchronized (self) {
            if (self.routerNodesMap.isNodesEmpty) { //没有节点
                NSArray<Class> *routerProtocolClsArr = [STAnnotation stClassArrForProtocol:@protocol(STRouterRegisterProtocol)];
                /**
                 1. 此处一次性执行所有路由的注册函数.
                 2. 后期可以考虑做优化, 每个路由第一次被调用的时候,才执行它的注册函数, 提升时间效率.[借助STAnnotationRegisterSEL宏的externStr 字段, 实现url 与 执行函数的映射]
                 */
                [routerProtocolClsArr enumerateObjectsUsingBlock:^(Class  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    if([obj conformsToProtocol:@protocol(STRouterRegisterProtocol)] && [obj respondsToSelector:@selector(stRouterRegisterExecute)]){
                        [((Class<STRouterRegisterProtocol>)obj) stRouterRegisterExecute];
                    }
                }];
            }
        }
    }
}

# pragma mark - public methods
- (void)stDeregisterAllUrls {
    [self.routerNodesMap stCleanNodes];
}

- (BOOL)stRegisterUrlPartterns:(NSString *)urlParttern error:(NSError **)err action:(STRouterUrlExecuteAction)urlExecuteAction {
    [self yk_exportEventMessageWithId:STRouterEventId_registerUrl message:urlParttern];
    BOOL result = NO;
    result = [self.routerNodesMap stInsertOneNodeWithUrl:urlParttern executeAction:urlExecuteAction error:err];
    return result;
}

- (BOOL)stDeregisterUrl:(NSString *)url {
    NSError *err;
    STRouterMapperNode *node = [self.routerNodesMap stSearchNodeWithUrl:url absoluteFlag:YES error:&err];
    [node stDeregisteNode];
    return YES;
}

/// 全局拦截器
- (void)stSetRouterGlobalInterceptor:(NSObject <STRouterInterceptorProtocol> *)globalInterceptor {
    self.globalInterceptor = globalInterceptor;
}

- (void)stSetRouterMessageExporter:(NSObject<STRouterMessageExportProtocol> *)exporter {
    self.messageExporter = exporter;
}

- (void)stOpenUrl:(STRouterUrlRequest *)request complete:(STRouterUrlCompletion __nullable) complete {
    [self yk_exportEventMessageWithId:STRouterEventId_openUrl message:request.url];
    NSError *err = nil;
    STRouterUrlRequest *requestUsing = nil;
    
    STRouterMapperNode *node = [self yk_filterUrNodeWithRequest:[request copy] requestBack:&requestUsing error:&err];
    
    if (err) { //失败
        STRouterUrlResponse *response = [STRouterUrlResponse instanceWithBuilder:^(STRouterUrlResponse * _Nonnull response) {
            response.err = err;
            response.msg =  err.localizedDescription;
            response.status = err.code;
        }];
        
        if (complete) complete(response);
        return;
    }
    
    STRouterUrlExecuteAction action = node.executeAction;
    if (action){
        STRouterUrlCompletion com = ^(STRouterUrlResponse *urlResponse){ //此处只是为了方便调试.
            if (complete) complete(urlResponse);
        };
        action(requestUsing, com);
        
    }else{
        [STRouterHelper st_createError:STRouterErrorCode_noUrl info:nil message:@"路由失败,注册的路由没有设置响应事件"];
    }
}

- (void)stOpenUrlInstance:(NSString *)urlInstance fromVC:(UIViewController * __nullable)fromVC complete:(STRouterUrlCompletion __nullable) complete {
    STRouterUrlRequest *request = [STRouterUrlRequest instanceWithBuilder:^(STRouterUrlRequest * _Nonnull builder) {
        builder.url = urlInstance;
        builder.fromVC = fromVC;
    }];
    [self stOpenUrl:request complete:complete];
}

- (BOOL)stCanOpenUrl:(NSString *)url parameter:(NSDictionary *__nullable)paramaters absolute:(BOOL)absolute error:(NSError *__nullable *__nullable)err {
    NSError *errBack = nil;
    
    STRouterUrlRequest *request = [STRouterUrlRequest instanceWithBuilder:^(STRouterUrlRequest * _Nonnull builder) {
        builder.url = url; builder.parameter = paramaters;
    }];
    
    [self yk_filterUrNodeWithRequest:request requestBack:nil error:&errBack];
    
    if (errBack) {
        if (err) {
            *err = errBack;
        } else { //业务失败,发送方未判断错误, 此处在终端和日志系统中反馈一下
            [STRouterHelper st_createError:STRouterErrorCode_noUrl info:nil message:@"路由检查能否开启失败,发起方未接受异常信息"];
        }
        return NO;
    }
    return YES;
}

- (NSString *)stRouterMapperJsonString {
    return [self.routerNodesMap stRouterMapperJsonString];
}

- (NSDictionary *)stRouterMapperDict {
    return [self.routerNodesMap stRouterMapperDict];
}

# pragma mark - work methods
//STRouterUrlRequest
- (STRouterMapperNode *)yk_filterUrNodeWithRequest:(STRouterUrlRequest*)request requestBack:(STRouterUrlRequest **)requestBack error:(NSError **)err {
    [self initRouterConfig];
    
    NSString *url = request.url;
    NSDictionary *paramaters = request.parameter;
    BOOL absolute = request.absolute;
    
    STRouterUrlParser *parser = [STRouterUrlParser stParserUrl:request.url parameter:request.parameter];
    NSMutableDictionary *para = [NSMutableDictionary new];
    [para addEntriesFromDictionary:[parser queryparamaters]];
    [request.parameter enumerateKeysAndObjectsUsingBlock:^(id _Nonnull key, id _Nonnull obj, BOOL *_Nonnull stop) {
        NSString *value = [[NSString stringWithFormat:@"%@", obj] stringByRemovingPercentEncoding];
        [para setObject:value forKey:key];
    }];
    
    NSString *interceptorMes = nil;
    /** 此处需要进入全局拦截流程 */
    if ([self.globalInterceptor respondsToSelector:@selector(stRouterShouldOpenUrlParttern:parameter:msessageBack:)]) {
        // 全局判断是否可打开URL
        BOOL result = [self.globalInterceptor stRouterShouldOpenUrlParttern:parser.urlParttern parameter:para msessageBack:&interceptorMes];
        if (!result) { //url 不能被打开
            NSString *errMsg = interceptorMes.length ? interceptorMes : [NSString stringWithFormat:@"Url was closed by server:[%@]", [parser.url stringByRemovingPercentEncoding]];
            NSError *errBack = [STRouterHelper st_createError:STRouterErrorCode_urlClosed info:nil message:errMsg];
            
            if (err) *err = errBack;
            return nil;
        }
    }
    
    if ([self.globalInterceptor respondsToSelector:@selector(stRouterWhetheExchangeUrlParttern:parameter: urlPartternBack: parameterBack:messageBack:)]) {
        // 全局拦截去, URL是否被切换
        NSDictionary *paraUsed = nil;
        NSString *urlUsed = nil;
        BOOL exchangeFlag = [self.globalInterceptor stRouterWhetheExchangeUrlParttern:parser.urlParttern parameter:para urlPartternBack:&urlUsed parameterBack:&paraUsed messageBack:&interceptorMes];
        if (exchangeFlag) { //URL 或者 参数 被交换了
            url = urlUsed;
            para = [paraUsed mutableCopy];
        }
    }
    
    NSError *errBack;
    STRouterMapperNode *node = [self.routerNodesMap stSearchNodeWithUrl:parser.urlPartternFull absoluteFlag:absolute error:&errBack];
    
    if (errBack) { //没有找到节点
        if (err) *err = errBack;
        return nil;
    }
    
    paramaters = para;
    NSURLComponents *componentSource = [NSURLComponents componentsWithString:parser.urlPartternFull];
    
    //重组URL, 将paramaters参数变为 query
    NSMutableArray<NSURLQueryItem *> *queryArr = [NSMutableArray new];
    [queryArr addObjectsFromArray:componentSource.queryItems];
    [paramaters enumerateKeysAndObjectsUsingBlock:^(id _Nonnull key, id _Nonnull obj, BOOL *_Nonnull stop) {
        NSString *value = [[NSString stringWithFormat:@"%@", obj] stringByRemovingPercentEncoding];
        NSURLQueryItem *item = [[NSURLQueryItem alloc] initWithName:key value:value];
        [queryArr addObject:item];
    }];
    queryArr.count ? componentSource.queryItems = queryArr : 0;
    NSString *urlBack = componentSource.URL.absoluteString;
    
//    STRouterUrlParser *parserUsed = [STRouterUrlParser stParserUrl:urlBack parameter:paramaters];
    NSString *urlPartternBack = parser.urlParttern;
    
    
    if (requestBack) {
        STRouterUrlRequest *request_used = [request copy];
        request_used.url = urlBack;
        request_used.urlParttern = urlPartternBack;
        request_used.parameter = paramaters;
        request_used.paraOrignal = request.parameter;
        *requestBack = request_used;
    }
    
    return node;
}

- (void)yk_exportEventMessageWithId:(NSInteger)eventId message:(NSString *)msg {
    STRouterMessageBody *body = [STRouterMessageBody new];
    body.eventIdentifier = eventId; body.eventMessage = msg;
    if ([self.messageExporter respondsToSelector:@selector(stRouterExcuteEvent:)]) {
        [self.messageExporter stRouterExcuteEvent:body];
    }
}

@end
