//
//  STRouterParameter.h
//  STRouter
//
//  Created by stephen.chen on 2021/12/2.
//

#import <Foundation/Foundation.h>

#import "STRouterDefines.h"

NS_ASSUME_NONNULL_BEGIN
@class UIViewController;
@interface STRouterUrlRequest : NSObject<NSCopying>
@property(nonatomic, copy) NSString * url; ///< url
@property (nonatomic,assign) BOOL absolute; ///< 绝对匹配URL
@property(nonatomic, copy) NSString * urlParttern; ///< urlParttern
@property(nonatomic, weak) UIViewController * fromVC; ///< 跳转的来源页面
@property(nonatomic, assign) STRouterAnimationType animateTyepe; ///< 界面切换类型
@property(nonatomic, copy) NSDictionary * parameter; ///< 序列化后的参数
@property(nonatomic, copy) NSDictionary * paraOrignal; ///< 原始参数

+ (instancetype)instanceWithBuilder:(void(^)(STRouterUrlRequest *builder))builderAction;
@end

@interface STRouterUrlResponse : NSObject<NSCopying>
@property (nonatomic,assign) NSInteger status; ///< 业务码
@property (nonatomic, strong) NSDictionary * __nullable responseObj; ///< 应答数据
@property(nonatomic, copy) NSString * msg; ///< 业务应当信息
@property (nonatomic, strong) NSError * __nullable err; ///< 业务错误对象

+ (instancetype)instanceWithBuilder:(void(^)(STRouterUrlResponse *response))builderAction;
@end

NS_ASSUME_NONNULL_END
