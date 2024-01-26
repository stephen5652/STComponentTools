//
//  STRouterMapperNode.h
//  STRouter
//
//  Created by stephen.chen on 2021/11/5.
//

#import <Foundation/Foundation.h>

#import "STRouterUrlParser.h"
#import "STRouterDefines.h"
#import "STRouterParameter.h"

NS_ASSUME_NONNULL_BEGIN

@interface STRouterMapperNode : NSObject
@property (nonatomic, readonly) NSString *nodeFlag; ///< 节点标识
@property (nonatomic, readonly) NSString *url; ///< url
@property (nonatomic, readonly) NSString *urlParttern; ///< urlParttern
@property (nonatomic, readonly)BOOL urlDeregistedFlag; ///< 节点取消注册的标识
@property(nonatomic, readonly) STRouterUrlExecuteAction executeAction; ///< url执行事件
@property (nonatomic, readonly) BOOL isNodesEmpty; ///< 路由是否为空
- (BOOL)stInsertOneNodeWithUrl:(NSString *)url executeAction:(STRouterUrlExecuteAction)executeAction error:(NSError **)err;
- (STRouterMapperNode *)stSearchNodeWithUrl:(NSString *)url absoluteFlag:(BOOL)absolute error:(NSError **)err;
- (void)stDeregisteNode;
- (void)stCleanNodes;

# pragma mark - debug methods
- (NSString *)stRouterMapperJsonString;
- (NSDictionary *)stRouterMapperDict;
@end

NS_ASSUME_NONNULL_END
