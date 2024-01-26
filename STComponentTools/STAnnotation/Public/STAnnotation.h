//
//  STAnnotation.h
//  STAnnotation
//
//  Created by stephen.chen on 2021/11/2.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#if defined(__cplusplus)
extern "C" {
#endif

#ifndef STAnotationSection_SEL
#define STAnotationSection_SEL "STAn_SEL"
#endif

#define merge_body(a, b) a ## b //合并用的主体
#define merge(a, b) merge_body(a, b) //中间层
#define _STA_UNIQUE_ID(func)  merge(func, merge(_unused, __COUNTER__))

typedef void(*STAnnotationrMach_O_Method)(void);
struct STAnnotationRegisterStruct{
    char *sectionFlag; ///< 字符, 用以存放mach_o字段标识,用于在读取的时候判定是否是合法的struct.
    char *typeFlag; ///<  字符,用以存放SEL功能标识,长度不限制,用于标识SEL的功能类型.
    char *externStr; ///< 扩展信息, 为了便于以后扩展, 注意是字符串类型
    STAnnotationrMach_O_Method executeMethod; ///< 注册的SEL
};

/**
 注册事件
 */
#define _ST_C_STRING_(str) ""#str""
#define _ST_ANNOTATION_REGISTER_FUNC_(funcType, externStr, funcName) \
\
static void funcName (void); \
\
/**使用 used字段，即使没有任何引用，在Release下也不会被优化 __attribute__((used, section("__DATA," "STRouter_func")))*/  \
__attribute__((used, section("__DATA," STAnotationSection_SEL))) static const struct STAnnotationRegisterStruct merge(STAnStruct_, funcName) = (struct STAnnotationRegisterStruct){ \
(char *) STAnotationSection_SEL, \
(char *) funcType, \
(char *) externStr, \
(STAnnotationrMach_O_Method) funcName, \
};\
\
static void funcName(void)

/**
 向mach_o 注册方法
 */
#define STAnnotationRegisterSEL(funcType, externStr) \
class STAnnotationDataFunc; \
 _ST_ANNOTATION_REGISTER_FUNC_(funcType, externStr, _STA_UNIQUE_ID(STAn_regist_func_))


#define STDirect_flag "STMachoSel_executeDirect"
/**
 注册立即运行的方法
 
 code example:
 
 //@implementation YourClass
 @STDirect_flag(){
 NSLog(@"execute direct");
 // Your code.
 }
 //@end
 
 */
#define STDirectRegist() STAnnotationRegisterSEL(STDirect_flag, "direct_future")


#if defined(__cplusplus)
}
#endif

@interface STAnnotation : NSObject
@property (nonatomic, class, readonly) NSString *stDirectFlag; ///< 直接执行事件的标识

+ (void)stRegisterProtocol:(Protocol *)protocol;

+ (NSArray<Class> *)stClassArrForProtocol:(Protocol *)protocol;
@end

NS_ASSUME_NONNULL_END
