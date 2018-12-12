//
//  SourceEditorAutoImpCommand.m
//  ZBSnippet
//
//  Created by xzb on 2018/12/12.
//  Copyright © 2018 xzb. All rights reserved.
//

#import "SourceEditorAutoImpCommand.h"

@implementation SourceEditorAutoImpCommand

- (void)performCommandWithInvocation:(XCSourceEditorCommandInvocation *)invocation completionHandler:(void (^)(NSError *_Nullable nilOrError))completionHandler
{
    self.invocation = invocation;
    
    //1.找到sel name
    
    NSString *selName = [self getSelName];
    
    if (selName.length < 1) {
        return;
    }
    
    //2.找到填写代码位置
    
    NSUInteger insertImpIndex = [self getInsertImpLineIdx];
    
    //3.实现
    NSString *impContent = [self getImpContentWithSelName:selName];
    
    [invocation.buffer.lines insertObject:impContent atIndex:MIN(invocation.buffer.lines.count - 1, insertImpIndex)];
    
    completionHandler(nil);
}

- (NSArray<NSNumber *> *)getLinesWithStr:(NSString *)str
{
    NSMutableArray *array = [NSMutableArray array];
    for (NSInteger idx = 0; idx < self.invocation.buffer.lines.count; idx++) {
        NSString *line = self.invocation.buffer.lines[idx];
        if ([line containsString:str]) {
            [array addObject:@(idx)];
        }
    }
    return array;
}

/**
 如果选择的line,含有EventTouchUpInside,将全局搜索,定位到其他btn事件所在的位置之上;
 
 - 记:林华提的ai需求
 */
- (NSInteger)getInsertImpLineIdxWithEventTouchUpInside
{
    XCSourceTextRange *lastRange = [self.invocation.buffer.selections lastObject];
    if (lastRange.end.line == 0) {
        return 0;
    }
    NSString *lastSelContent =  self.invocation.buffer.lines[lastRange.end.line];
    if (![lastSelContent containsString:@"UIControlEventTouchUpInside"]) {
        return 0;
    }
    NSString *btnEventSelName = @"";
    for (NSNumber *line in [self getLinesWithStr:@"UIControlEventTouchUpInside"]) {
        if (line.integerValue == 0) {
            continue;
        }
        NSString *lineContent = self.invocation.buffer.lines[line.integerValue];
        
        btnEventSelName = [lineContent substringWithRange:NSMakeRange([lineContent rangeOfString:@"("].location + 1, [lineContent rangeOfString:@")"].location - [lineContent rangeOfString:@"("].location - 1)];
        
        if ([btnEventSelName containsString:@"@\""]) {
            btnEventSelName = [btnEventSelName substringWithRange:NSMakeRange(2, btnEventSelName.length - 3)];
        }
        if (btnEventSelName.length == 0) {
            continue;
        }
        
        NSArray *lineArray = [self getLinesWithStr:[NSString stringWithFormat:@")%@", btnEventSelName]];
        if (lineArray.count > 0) {
            return [lineArray.firstObject integerValue] - 1;
        }
    }
    return 0;
}

- (NSUInteger)getInsertImpLineIdx
{
    XCSourceTextRange *lastRange = [self.invocation.buffer.selections lastObject];
    
    NSInteger eventIdx = [self getInsertImpLineIdxWithEventTouchUpInside];
    if (eventIdx > 0) {
        return eventIdx;
    }
    
    for (NSInteger idx = lastRange.end.line; idx < self.invocation.buffer.lines.count; idx++) {
        if ([self.invocation.buffer.lines[idx] hasPrefix:@"}"]) {
            return idx + 1;
        }
    }
    
    return [self getEndLine];
}

- (NSUInteger)getEndLine
{
    __block NSUInteger endIdx = self.invocation.buffer.lines.count;
    __block dispatch_group_t dispatchGroup = dispatch_group_create();
    dispatch_group_enter(dispatchGroup);
    [self.invocation.buffer.lines enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(NSString *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        if ([obj hasPrefix:@"@end"]) {
            endIdx = idx;
            *stop = YES;
            dispatch_group_leave(dispatchGroup);
        } else {
            if (idx == 0) {
                dispatch_group_leave(dispatchGroup);
            }
        }
    }];
    return endIdx;
}

- (NSString *)getSelName
{
    XCSourceTextRange *lastRange = [self.invocation.buffer.selections lastObject];
    NSRange selctedRange = NSMakeRange(lastRange.start.column, lastRange.end.column - lastRange.start.column);
    NSString *selctedLineStr = [self.invocation.buffer.lines objectAtIndex:lastRange.start.line];
    NSString *selctedContent = [selctedLineStr substringWithRange:selctedRange];
    
    if (selctedContent.length < 1) {
        return @"";
    }
    if ([selctedContent containsString:@":"]) {
        NSString *fullStr = @"- (void)";
        NSUInteger argCount = 0;
        for (NSInteger idx = 0; idx < selctedContent.length; idx++) {
            NSString *curStr = [selctedContent substringWithRange:NSMakeRange(idx, 1)];
            if ([curStr isEqualToString:@":"]) {
                argCount++;
                if (argCount == 1) {
                    fullStr = [fullStr stringByAppendingString:@":(id)arg1"];
                } else {
                    fullStr = [fullStr stringByAppendingFormat:@" arg%lu:(id)arg%lu", (unsigned long)argCount, (unsigned long)argCount];
                }
            } else {
                fullStr = [fullStr stringByAppendingString:curStr];
            }
        }
        return fullStr;
    }
    return [NSString stringWithFormat:@"- (void)%@", selctedContent];
}

- (NSString *)getImpContentWithSelName:(NSString *)selName
{
    return [NSString stringWithFormat:@"\n%@ \n{\n\n}", selName];
}

@end
