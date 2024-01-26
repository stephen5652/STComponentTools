//
//  STRouterMapperNode.m
//  STRouter
//
//  Created by stephen.chen on 2021/11/5.
//

#import "STRouterMapperNode.h"

#import "STRouterUrlParser.h"
#import "STRouterHelper.h"

#import <pthread/pthread.h>
#import <YYModel/YYModel.h>

@interface STRouterMapperNode()
{
    pthread_rwlock_t _lock_STRWLock; ///< 读写锁
}
@property (nonatomic, copy) NSString *nodeFlag; ///< 节点标识
@property (nonatomic, copy) NSString *url; ///< url
@property (nonatomic, copy) NSString *urlParttern; ///< urlParttern
@property (nonatomic, strong) NSMutableDictionary<NSString *, STRouterMapperNode *> *subNodeMap; ///< 下级节点
@property (nonatomic, assign) BOOL urlDeregistedFlag; ///< 节点取消注册的标识

@property(nonatomic, copy) STRouterUrlExecuteAction executeAction; ///< url执行事件

@end

@implementation STRouterMapperNode
- (instancetype)init {
    if (self = [super init]) {
        pthread_rwlock_t lock = PTHREAD_RWLOCK_INITIALIZER;
        self->_lock_STRWLock = lock;
    }
    return self;
}

- (BOOL)stInsertOneNodeWithUrl:(NSString *)url executeAction:(STRouterUrlExecuteAction)executeAction error:(NSError **)err{
    STRouterUrlParser *parser = [STRouterUrlParser stParserUrl:url parameter:nil];
    NSArray<NSString *> *url_parts = [parser stUrlSeperateResult];
    
    pthread_rwlock_wrlock(&(self->_lock_STRWLock)); /// 写加锁
    __block STRouterMapperNode *lastNode = self;
    [url_parts enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (![lastNode.subNodeMap objectForKey:obj]) {
            STRouterMapperNode *new = [STRouterMapperNode new];
            new.nodeFlag = obj;
            [lastNode.subNodeMap setObject:new forKey:obj];
        }
        lastNode = [lastNode.subNodeMap objectForKey:obj];
    }];
    pthread_rwlock_unlock(&(self->_lock_STRWLock)); /// 写解锁
    
    if (lastNode.executeAction) { //此节点已经注册
        if (lastNode.urlDeregistedFlag == NO) { //此节点已经被注册,且未被取消注册
            NSString *msg = [NSString stringWithFormat:@""
                             "重复注册URL sorce:%@\n"
                             "new:%@"
                             "", lastNode.url, url];
            NSAssert(0, msg);
            NSError *errBack = [STRouterHelper st_createError:STRouterErrorCode_urlDuplicate info:nil message:msg];
            if (err) *err = errBack;
            return NO;
        }else{
            //此节点已经被取消注册,此处覆盖原来的响应
            lastNode.urlDeregistedFlag = YES;
        }
    }
    
    lastNode.urlParttern = parser.urlParttern;
    lastNode.url = url;
    lastNode.executeAction = executeAction;
    return YES;
}

- (STRouterMapperNode *)ykFuzzySearchNodeWithUrl:(NSString *)url error:(NSError **)err {
    return [self stSearchNodeWithUrl:url absoluteFlag:NO error:err];
}

- (STRouterMapperNode *)ykAbsoluteSearchNodeWithUrl:(NSString *)url error:(NSError **)err {
    return [self stSearchNodeWithUrl:url absoluteFlag:YES error:err];
}

- (void)stDeregisteNode{
    pthread_rwlock_wrlock(&(self->_lock_STRWLock)); /// 写加锁
    self.urlDeregistedFlag = YES;
    pthread_rwlock_unlock(&(self->_lock_STRWLock)); /// 写解锁
}

- (void)stCleanNodes {
    pthread_rwlock_wrlock(&(self->_lock_STRWLock)); /// 写加锁
    [self.subNodeMap removeAllObjects];
    self.urlParttern = nil;
    self.executeAction = nil;
    self.nodeFlag = nil;
    self.urlDeregistedFlag = NO;
    pthread_rwlock_unlock(&(self->_lock_STRWLock)); /// 写解锁
}

- (BOOL)isNodesEmpty {
    BOOL result = NO;
    
    pthread_rwlock_rdlock(&(self->_lock_STRWLock)); ////读加锁
    if (self.nodeFlag.length == 0) {
        if (self.subNodeMap.count == 0) {
            result = YES;
        }else{
            result = NO;
        }
    }else{
        result = NO;
    }
    pthread_rwlock_unlock(&(self->_lock_STRWLock)); /// 读解锁
    return result;
}

- (NSString *)stRouterMapperJsonString {return [self yy_modelToJSONString];}
- (NSDictionary *)stRouterMapperDict {return  [self yy_modelToJSONObject];}

# pragma mark - work methods
- (STRouterMapperNode *)stSearchNodeWithUrl:(NSString *)url absoluteFlag:(BOOL)absolute error:(NSError **)err {
    pthread_rwlock_rdlock(&(self->_lock_STRWLock)); ////读加锁
    
    STRouterUrlParser *parser = [STRouterUrlParser stParserUrl:url parameter:nil];
    NSArray<NSString *> *url_parts = [parser stUrlSeperateResult];
    
    __block STRouterMapperNode *lastNode = self;
    __block STRouterMapperNode *lastEnableNode = self; //模糊匹配只需要找到一个可用的节点就行
    NSString *obj = nil;
    int idx = 0;
    for (; idx < url_parts.count; idx ++) {
        obj = url_parts[idx];
        if ([lastNode.subNodeMap objectForKey:obj]) { //存在下一个节点
            lastNode = [lastNode.subNodeMap objectForKey:obj];
            if (lastNode.urlDeregistedFlag == NO) {
                lastEnableNode = lastNode;
            }
        } else {
            break;
        }
    }
    pthread_rwlock_unlock(&(self->_lock_STRWLock)); /// 读解锁
    
    if (absolute == NO){ //模糊匹配
        if(lastEnableNode.executeAction == nil){ //模糊匹配, 也不能完全打开所有url
            NSString *msg = [NSString stringWithFormat:@"can note find register url:%@", url];
            NSError *errBack = [STRouterHelper st_createError:STRouterErrorCode_noUrl info:nil message:msg];
            if (err) *err = errBack;
            return nil;
        }else if (lastEnableNode.urlDeregistedFlag){ //节点被关闭
            NSString *msg = [NSString stringWithFormat:@"url parttern is closed:%@", lastNode.urlParttern];
            NSError *errBack = [STRouterHelper st_createError:STRouterErrorCode_urlClosed info:nil message:msg];
            if (err) *err = errBack;
        }
        return lastEnableNode;
    }
    
    if (idx < url_parts.count || lastNode.executeAction == nil){ //精准匹配, 需要匹配到所有节点
        NSString *msg = [NSString stringWithFormat:@"can note find register url:%@", url];
        NSError *errBack = [STRouterHelper st_createError:STRouterErrorCode_noUrl info:nil message:msg];
        if (err) *err = errBack;
        return nil;
    } else if (lastNode.urlDeregistedFlag){
        NSString *msg = [NSString stringWithFormat:@"url is closed:%@", lastNode.urlParttern];
        NSError *errBack = [STRouterHelper st_createError:STRouterErrorCode_urlClosed info:nil message:msg];
        if (err) *err = errBack;
        return nil;
    }
    
    return lastNode;
}

#pragma mark - setter & getter methos
- (NSMutableDictionary<NSString *,STRouterMapperNode *> *)subNodeMap {
    pthread_rwlock_rdlock(&(self->_lock_STRWLock)); ////读加锁
    if (!_subNodeMap) _subNodeMap = [NSMutableDictionary new];
    pthread_rwlock_unlock(&(self->_lock_STRWLock)); /// 读解锁
    return _subNodeMap;
}
@end
