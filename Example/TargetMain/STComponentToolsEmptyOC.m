//
//  STComponentToolsEmptyOC.m
//  STComponentTools_Example
//
//  Created by stephenchen on 2024/01/26.
//

#import "STComponentToolsEmptyOC.h"

@implementation STComponentToolsEmptyOC
+ (void)load {
#ifdef kENTERPRISE
    NSLog(@"has kEnterprise:%d", kENTERPRISE);
#else
    NSLog(@"no kEnterprise");
#endif
}
@end
