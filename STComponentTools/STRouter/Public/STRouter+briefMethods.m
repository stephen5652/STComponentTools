//
//  STRouter+briefMethods.m
//  STRouter
//
//  Created by stephen.chen on 2021/12/2.
//

#import "STRouter+briefMethods.h"

@implementation STRouter (briefMethods)
STRouter *STRouterCenter(void) {
    return [STRouter shareInstance];
}

BOOL stRouterRegisterUrlParttern(NSString *urlParttern, NSError **errBack, STRouterUrlExecuteAction executeAction) {
    return [STRouterCenter() stRegisterUrlPartterns:urlParttern error:errBack action:executeAction];
}

void stRouterOpenUrlRequest(STRouterUrlRequest *request, STRouterUrlCompletion complete) {
    [STRouterCenter() stOpenUrl:request complete:complete];
}

void stDeregisterAllUrls(void){
    [STRouterCenter() stDeregisterAllUrls];
}
@end
