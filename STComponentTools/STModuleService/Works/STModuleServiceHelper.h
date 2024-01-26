//
//  STModuleServiceHelper.h
//  STModuleService
//
//  Created by stephen.chen on 2021/11/8.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface STModuleServiceHelper : NSObject
+ (NSError *)st_createError:(NSInteger)code info:(NSDictionary * __nullable)info message:(NSString *)msg;
@end

NS_ASSUME_NONNULL_END
