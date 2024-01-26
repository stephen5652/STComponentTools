//
//  STRouterMessageBody.h
//  STRouter
//
//  Created by stephen.chen on 2022/1/25.
//

#import <Foundation/Foundation.h>

#import "STRouterDefines.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, STRouterEventId) {
    STRouterEventId_unknown,
    STRouterEventId_registerUrl,
    STRouterEventId_deregisterUrl,
    STRouterEventId_openUrl,
    STRouterEventId_checkUrl,
};

@interface STRouterMessageBody : NSObject <STRouterMessageBodyProtocol>
@property (nonatomic,assign) STRouterEventId eventIdentifier; ///< 事件数字表示
- (void)setEventMessage:(NSString *)eventMessage;
@end

NS_ASSUME_NONNULL_END
