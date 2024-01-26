//
//  STAnnotation.m
//  STAnnotation
//
//  Created by stephen.chen on 2021/11/2.
//

#import "STAnnotation.h"

#include <mach-o/getsect.h>
#include <mach-o/dyld.h>
#include <pthread/pthread.h>

@interface STAnnotationDataFunc : NSObject
@property (nonatomic,readonly) STAnnotationrMach_O_Method stMacho_O_method;  ///< 执行函数
@property (nonatomic,readonly) NSString *stTypeFlag;  ///< 事件类型标识
@end

@interface STAnnotationDataFunc()
@property (nonatomic,assign) struct STAnnotationRegisterStruct funcInfo; ///< 事件
@end

@implementation STAnnotationDataFunc

+ (instancetype)yk_instanceWithFuncInfo:(struct STAnnotationRegisterStruct)info {
    STAnnotationDataFunc *result = [[self alloc]init];
    struct STAnnotationRegisterStruct func = (struct STAnnotationRegisterStruct){NULL, NULL};
    memcpy(&func, &info, sizeof(struct STAnnotationRegisterStruct));
    result.funcInfo = func;
    return result;
}

- (NSString *)stTypeFlag {
    return self.funcInfo.typeFlag ? [[NSString alloc] initWithCString:self.funcInfo.typeFlag encoding:NSUTF8StringEncoding] : nil;
}

- (STAnnotationrMach_O_Method)stMacho_O_method {
    return self.funcInfo.executeMethod;
}

@end



@interface STAnnotation()<NSCopying, NSMutableCopying>
{
    pthread_rwlock_t _lock_stRWLock; ///< 读写锁
}

@property (nonatomic, strong) NSMutableSet<Protocol *> *protocolSet; ///< 注册的协议
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSMutableSet<NSString *> *> *proClsDict; ///< 协议-->类 映射表
@end

@implementation STAnnotation

#define _st_direct_macho_func_flag [NSString stringWithCString:STDirect_flag encoding:NSUTF8StringEncoding]

+ (NSString *)stDirectFlag {
    return _st_direct_macho_func_flag;
}

static STAnnotation *imp;
+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        imp = [[super allocWithZone:zone] init_annotationComponent];
    });
    return imp;
}

- (instancetype)init {return imp;}
- (id)copyWithZone:(NSZone *)zone {return imp;}
- (id)mutableCopyWithZone:(NSZone *)zone {return imp;}

- (instancetype)init_annotationComponent {
    if (self = [super init]) {
        self.protocolSet = [NSMutableSet new];
        self.proClsDict = [NSMutableDictionary new];
        
        pthread_rwlock_t lock = PTHREAD_RWLOCK_INITIALIZER;
        self->_lock_stRWLock = lock;
    }
    return self;
}

+ (void)stRegisterProtocol:(Protocol *)protocol {
    [[self new] stInsRegisterProtocol:protocol];
}

+ (NSArray<Class> *)stClassArrForProtocol:(Protocol *)protocol {
    return [[self new] stInsClassArrForProtocol:protocol];
}

- (NSArray<Class> *)stInsClassArrForProtocol:(Protocol *)pro {
    NSMutableArray<Class> *result = [NSMutableArray new];
    pthread_rwlock_rdlock(&(self->_lock_stRWLock)); /// 读加锁
    NSString *proName = NSStringFromProtocol(pro);
    NSSet<NSString *> *clSet = self.proClsDict[proName];
    if(clSet != nil){
        [clSet enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, BOOL * _Nonnull stop) {
            Class cl = NSClassFromString(obj);
            if(cl != nil){
                [result addObject:cl];
            }
        }];
    }
    
    pthread_rwlock_unlock(&(self->_lock_stRWLock)); /// 读解锁
    return result;
}

- (void)stInsRegisterProtocol:(Protocol *)pro {
    pthread_rwlock_wrlock(&(self->_lock_stRWLock)); /// 写加锁
    NSLog(@"STAnnotation regist protocol:%@", NSStringFromProtocol(pro));
    [self.protocolSet addObject:pro];
    pthread_rwlock_unlock(&(self->_lock_stRWLock)); /// 写解锁
}

- (void)stStoreClass:(Class)cls forProtocol:(Protocol *)pro {
    pthread_rwlock_wrlock(&(self->_lock_stRWLock)); /// 写加锁
    NSString *clName = NSStringFromClass(cls);
    NSString *proName = NSStringFromProtocol(pro);
    NSLog(@"STAnnotation store [class:protocol]: %@ -> %@", clName, proName);
    
    NSMutableSet *clSet = self.proClsDict[proName];
    if(clSet == nil){
        clSet = [NSMutableSet new];
        self.proClsDict[proName] = clSet;
    }
    
    [clSet addObject:clName];
    pthread_rwlock_unlock(&(self->_lock_stRWLock)); /// 写解锁
}

@end

NSArray<NSString *>* YKReadConfiguration(char *sectionName,const struct mach_header *mhp);
NSMutableArray<STAnnotationDataFunc *>* stReadMach_oFunctions(char *sectionName,const struct mach_header *mhp);

static void _st_anotation_dyld_callback(const struct mach_header *mhp, intptr_t vmaddr_slide) {
    //macho_o section SEL
    NSArray<STAnnotationDataFunc *> *funsArr = stReadMach_oFunctions(STAnotationSection_SEL, mhp);
    [funsArr enumerateObjectsUsingBlock:^(STAnnotationDataFunc * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (!obj.stTypeFlag.length) return;
        
        if([obj.stTypeFlag isEqual:STAnnotation.stDirectFlag]){
            obj.stMacho_O_method();
        }
    }];
}

__attribute__((constructor))
void _st_init_anotation_rophet(void) {
    _dyld_register_func_for_add_image(_st_anotation_dyld_callback);
}

NSMutableArray<STAnnotationDataFunc *>* stReadMach_oFunctions(char *sectionName,const struct mach_header *mhp){
    NSMutableArray<STAnnotationDataFunc *> *result = [NSMutableArray new];
    unsigned long size = 0;
#ifndef __LP64__
    uintptr_t *memory = (uintptr_t*)getsectiondata(mhp, SEG_DATA, sectionName, &size);
#else
    const struct mach_header_64 *mhp64 = (const struct mach_header_64 *)mhp;
    unsigned char *memory = (unsigned char *)(uintptr_t*)getsectiondata(mhp64, SEG_DATA, sectionName, &size);
#endif
    
    if (size != 0) {
        NSLog(@"found function section: %s", sectionName);
    }
    
    unsigned long perSize = sizeof(struct STAnnotationRegisterStruct);
    for(int offset = 0; offset < size; ){
        struct STAnnotationRegisterStruct *point = (struct STAnnotationRegisterStruct*)(memory + offset);
        struct STAnnotationRegisterStruct onfInfo;
        memcpy(&onfInfo, point, perSize);
        if (onfInfo.sectionFlag && strcmp(onfInfo.sectionFlag, sectionName) == 0) {
            STAnnotationDataFunc *funcDes = [STAnnotationDataFunc yk_instanceWithFuncInfo:onfInfo];
            NSLog(@"one func:%@", funcDes.stTypeFlag);
            [result addObject:funcDes];
        }
        offset += perSize;
    }
    return result;
}


/**
 以下代码必须在注解器代码之下， 保证注解器优先运行，解析到注册的协议名称
 类分析的时候，根据注解器注册的协议来筛选类
 */

#include <mach-o/getsect.h>
#include <mach-o/dyld.h>
#include <objc/runtime.h>
#include <objc/objc.h>
#include <objc/message.h>

NSDictionary<NSString *, NSArray<NSString *> *> * st_invoksFromProtocol(NSArray<Protocol *> *proArr){
    NSMutableDictionary<NSString *, NSMutableArray<NSString *> *> *result = [NSMutableDictionary new];
    
    for (Protocol *pro in proArr) {
        NSString *name = NSStringFromProtocol(pro);
        NSMutableArray<NSString *> *invArr = result[name];
        if(invArr == nil){
            invArr = [NSMutableArray new];
            result[name] = invArr;
        }
        
        unsigned int method_count = 0;
        struct objc_method_description *me_list = protocol_copyMethodDescriptionList(pro, YES, NO, &method_count);
        for (int i = 0; i < method_count; i ++) {
            struct objc_method_description me = me_list[i];
            SEL name = me.name;
            [invArr addObject:NSStringFromSelector(name)];
        }
    }
    
    return result;
}

NSDictionary<NSString *, NSArray<Class> *> * st_filterClassWithPros(NSArray<Protocol *> *proArr, NSArray<Class> *clsArr) {
    NSMutableDictionary<NSString *, NSMutableArray<Class> *> *result = [NSMutableDictionary new];
    for (int i = 0; i < clsArr.count; i ++) {
        Class one = clsArr[i];
        for (Protocol *pro in proArr) {
            NSString *name = NSStringFromProtocol(pro);
            NSMutableArray<Class> *iteArr = result[name];
            if(iteArr == nil) {
                iteArr = [NSMutableArray new];
                result[name] = iteArr;
            }
            
            if(class_conformsToProtocol(one, pro)){
                NSLog(@"find one class:%s", class_getName(one));
                [iteArr addObject:one];
            }
        }
    }
    
    return result;
}

__attribute__((constructor))
void st_analysisClass(void) {
    NSLog(@"st_analysisClass");
    @autoreleasepool {
        int total =  objc_getClassList(NULL, 0);
        NSArray<Protocol *> *proArr = [[STAnnotation new].protocolSet allObjects];
        
        Class *buf = (__unsafe_unretained Class *) (malloc(total * sizeof(Class)));
        objc_getClassList(buf, total);
        
        NSMutableDictionary <NSString *, NSMutableArray<NSString *> *> *dict = [NSMutableDictionary new];
        
        for (int i = 0; i < total; i ++) {
            Class one = buf[i];
            for (Protocol *onePro in proArr) {
                if(class_conformsToProtocol(one, onePro)){
                    [[STAnnotation new] stStoreClass:one forProtocol:onePro];
                }
            }
        }
        
        free(buf);
    }
}
