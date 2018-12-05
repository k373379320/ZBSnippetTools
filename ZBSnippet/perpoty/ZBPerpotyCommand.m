//
//  ZBPerpotyCommand.m
//  ZBSnippet
//
//  Created by xzb on 2018/12/5.
//  Copyright © 2018 xzb. All rights reserved.
//

#import "ZBPerpotyCommand.h"

@implementation ZBPerpotyCommand

- (void)performCommandWithInvocation:(XCSourceEditorCommandInvocation *)invocation completionHandler:(void (^)(NSError * _Nullable nilOrError))completionHandler
{
    XCSourceTextRange *range = [invocation.buffer.selections lastObject];
    NSInteger endLine = range.end.line;
    

    completionHandler(nil);completionHandler(nil);
}


@end
