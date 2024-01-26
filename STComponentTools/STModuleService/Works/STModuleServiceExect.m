//
//  STModuleServiceExect.m
//  STModuleService
//
//  Created by stephen.chen on 2021/11/8.
//

#import "STModuleServiceExect.h"

#import "STModuleServiceDefines.h"
#import "STModuleServiceHelper.h"
#import "STModuleService+briefMethods.h"

#import <pthread/pthread.h>

#import <STComponentTools/STAnnotationHeader.h>

@interface STModuleServiceExect()
{
    pthread_rwlock_t _lock_stRWLock; ///< 读写锁
}
@property (nonatomic, strong) NSMapTable<NSString *, Class> *modulesMap; ///< 模块表
@end

@implementation STModuleServiceExect
static STModuleServiceExect *imp;
+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        imp = [[super allocWithZone:zone] init_STModuleServiceExect];
    });
    return imp;
}

- (instancetype)init {return imp;}
- (id)copyWithZone:(NSZone *)zone {return imp;}
- (id)mutableCopyWithZone:(NSZone *)zone {return imp;}

- (instancetype)init_STModuleServiceExect {
    if (self = [super init]) {
        self.modulesMap = [NSMapTable strongToStrongObjectsMapTable];
        pthread_rwlock_t lock = PTHREAD_RWLOCK_INITIALIZER;
        self->_lock_stRWLock = lock;
    }
    return self;
}

- (BOOL)stRegisterModuleService:(Class)cls protocol:(Protocol *)protocol err:(NSError *__nullable *__nullable)err {
    if (!cls || !protocol) { //没有类或协议
        NSString *msg = [NSString stringWithFormat:@"No module class or module protocol, while registing module."];
        NSError *errBack = [STModuleServiceHelper st_createError:1 info:nil message:msg];
        if (err) *err = errBack;
        NSAssert(0, msg);
        return NO;
    }
    
    NSString *proName = NSStringFromProtocol(protocol);
    return [self stRegisterModuleService:cls protocolName:proName err:err];
}

- (BOOL)stRegisterModuleService:(Class)cls protocolName:(NSString *)proName err:(NSError *__nullable *__nullable)err {
    pthread_rwlock_rdlock(&(self->_lock_stRWLock)); ////读加锁
    NSString *key = [proName componentsSeparatedByString:@"."].lastObject;
    Class existCls = [self.modulesMap objectForKey:key];
    pthread_rwlock_unlock(&(self->_lock_stRWLock)); /// 读解锁

    if ([existCls isEqual:cls]) { //已经注册过
        NSString *msg = [NSString stringWithFormat:@"Class[%@] has been regist with protocol:[%@]", existCls, proName];
        NSError *errBack = [STModuleServiceHelper st_createError:1 info:nil message:msg];
        if (err) *err = errBack;
        NSAssert(0, msg);
        return NO;
    }
    
    pthread_rwlock_wrlock(&(self->_lock_stRWLock)); /// 写加锁
    [self.modulesMap setObject:cls forKey:key];
    pthread_rwlock_unlock(&(self->_lock_stRWLock)); /// 写解锁
    
    return YES;
}

- (__kindof Class)stModuleWithProtocol:(Protocol *)protocol error:(NSError *__nullable *__nullable)err {
    return [self stModuleWithProtocolName:NSStringFromProtocol(protocol) error:err];
}

- (__kindof Class)stModuleWithProtocolName:(NSString *)proName error:(NSError *__nullable *__nullable)err {
    [self initModuleConfig];
    pthread_rwlock_rdlock(&(self->_lock_stRWLock)); ////读加锁
    NSString *key = [proName componentsSeparatedByString:@"."].lastObject;
    Class cls = [self.modulesMap objectForKey:key];
    pthread_rwlock_unlock(&(self->_lock_stRWLock)); /// 读解锁
    if (!cls) {
        NSString *msg = [NSString stringWithFormat:@"No class for protocol[%@], while get module.", proName];
        NSError *errBack = [STModuleServiceHelper st_createError:1 info:nil message:msg];
        if (err) *err = errBack;
    }
    return cls;
}

# pragma mark - work methods
- (void)initModuleConfig {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSArray<Class<STModuleServiceRegisterProtocol>> *clsArr = [STAnnotation stClassArrForProtocol:@protocol(STModuleServiceRegisterProtocol)];
        [clsArr enumerateObjectsUsingBlock:^(Class<STModuleServiceRegisterProtocol>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if([obj respondsToSelector:@selector(stModuleServiceRegistAction)]){
                [obj stModuleServiceRegistAction];
            }
        }];
    });
}
@end
