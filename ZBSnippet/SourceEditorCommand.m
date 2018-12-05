//
//  SourceEditorCommand.m
//  ZBSnippet
//
//  Created by xzb on 2018/12/5.
//  Copyright © 2018 xzb. All rights reserved.
//

#import "SourceEditorCommand.h"

@implementation SourceEditorCommand

- (void)performCommandWithInvocation:(XCSourceEditorCommandInvocation *)invocation completionHandler:(void (^)(NSError * _Nullable nilOrError))completionHandler
{
    __block NSInteger lastImportLine = 0;
    [invocation.buffer.lines enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj hasPrefix:@"#import"]) {
            lastImportLine = idx;
        }
    }];
 
    XCSourceTextRange *lastRange = [invocation.buffer.selections lastObject];

    NSString *selctedLineStr = [invocation.buffer.lines objectAtIndex:lastRange.start.line];
    
    NSRange selctedRange = NSMakeRange(lastRange.start.column, lastRange.end.column - lastRange.start.column);
    
    if (selctedRange.location + selctedRange.length > selctedLineStr.length ) {
        NSLog(@"⚠️异常,需要选中文字超出行内容");
        return;
    }
    NSString *selctedContent = [selctedLineStr substringWithRange:selctedRange];
    if (selctedContent.length < 1) {
        NSLog(@"⚠️空白,不添加");
        return;
    }
    NSString *importContent = [NSString stringWithFormat:@"#import \"%@.h\"",selctedContent];
    
    [invocation.buffer.lines insertObject:importContent atIndex:lastImportLine + 1];
    
    completionHandler(nil);
}

@end
