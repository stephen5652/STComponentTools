//
//  STRouterHelper.h
//  STRouter
//
//  Created by stephen.chen on 2021/11/4.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface STRouterHelper : NSObject
+ (NSError *)st_createError:(NSInteger)code info:(NSDictionary * __nullable)info message:(NSString *)msg;
@end

NS_ASSUME_NONNULL_END
