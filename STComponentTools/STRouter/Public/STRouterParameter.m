//
//  STRouterParameter.m
//  STRouter
//
//  Created by stephen.chen on 2021/12/2.
//

#import "STRouterParameter.h"

#import <YYModel/YYModel.h>

@implementation STRouterUrlRequest
+ (instancetype)instanceWithBuilder:(void (^)(STRouterUrlRequest *builder))builderAction {
    if (!builderAction) return nil;
    STRouterUrlRequest *result = [[[self class] alloc] init];
    builderAction(result);
    return [result copy];
}

- (id)copyWithZone:(NSZone *)zone {
    return [self yy_modelCopy];
}
@end

@implementation STRouterUrlResponse
+ (instancetype)instanceWithBuilder:(void (^)(STRouterUrlResponse *response))builderAction {
    STRouterUrlResponse *result = [[[self class] alloc] init];
    builderAction(result);
    return [result copy];
}

- (id)copyWithZone:(NSZone *)zone {
    return [self yy_modelCopy];
}

@end
