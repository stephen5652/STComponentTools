//
//  STRouterMessageBody.m
//  STRouter
//
//  Created by stephen.chen on 2022/1/25.
//

#import "STRouterMessageBody.h"

@interface STRouterMessageBody()
@property(nonatomic, copy) NSString * eventName; ///< 事件名称
@property(nonatomic, copy) NSString * eventMessage; ///< 事件信息
@end

NSString * yk_RouterEventNameWithID(STRouterEventId enentID);
@implementation STRouterMessageBody

- (void)setEventIdentifier:(STRouterEventId)eventIdentifier {
    _eventIdentifier = eventIdentifier;
    _eventName = yk_RouterEventNameWithID(eventIdentifier);
}

NSString * yk_RouterEventNameWithID(STRouterEventId enentID) {
    NSString *result = nil;
    switch (enentID) {
        case STRouterEventId_registerUrl:
            result = @"STRouterEventId_registerUrl";
            break;
        case STRouterEventId_deregisterUrl:
            result = @"STRouterEventId_deregisterUrl";
            break;
        case STRouterEventId_openUrl:
            result = @"STRouterEventId_openUrl";
            break;
        case STRouterEventId_checkUrl:
            result = @"STRouterEventId_checkUrl";
            break;
        default:
            result = @"STRouterEventId_unknown";
            break;
    }
    return result;
}

@end
