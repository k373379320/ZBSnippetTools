//
//  SourceEditorEnumToSwitchCommand.m
//  ZBSnippet
//
//  Created by xzb on 2018/12/13.
//  Copyright © 2018 xzb. All rights reserved.
//


#import "SourceEditorEnumToSwitchCommand.h"


#ifdef DEBUG

#define Log(format, ...)        NSLog((@"💧💧💧%s [Line %d] 💧💧💧\n" format), __PRETTY_FUNCTION__, __LINE__, ## __VA_ARGS__)
#define tLog(format, ...)       NSLog((@"⭕️⭕️⭕️%s [Line %d] ⭕️⭕️⭕️\n" format), __PRETTY_FUNCTION__, __LINE__, ## __VA_ARGS__)
#define wLog(format, ...)       NSLog((@"❗️❗️❗️%s [Line %d] ❗️❗️❗️\n" format), __PRETTY_FUNCTION__, __LINE__, ## __VA_ARGS__)
#define eLog(format, ...)       NSLog((@"❌❌❌%s [Line %d] ❌❌❌\n" format), __PRETTY_FUNCTION__, __LINE__, ## __VA_ARGS__)
#else
#define Log(format, ...)        ;
#define tLog(format, ...)       ;
#define wLog(format, ...)       ;
#define eLog(format, ...)       ;
#endif

@implementation SourceEditorEnumToSwitchCommand
- (void)performCommandWithInvocation:(XCSourceEditorCommandInvocation *)invocation completionHandler:(void (^)(NSError *_Nullable nilOrError))completionHandler
{
    
    self.invocation = invocation;
    
    NSArray *enumDatas = [self enumDatas];
    if (enumDatas.count == 0 ) {
        return;
    }
    //生成switch代码
    NSString *switchContent = [self switchContentWithEnumDatas:[self enumDatas]];
    
    //选择插入位置
    NSInteger insertIdx = [invocation.buffer.selections lastObject].end.line + 1;
    
    if (insertIdx == 0) {
        insertIdx = invocation.buffer.lines.count;
    }
    [invocation.buffer.lines insertObject:switchContent atIndex:insertIdx];
    
    completionHandler(nil);
}

- (NSArray *)enumDatas
{
    NSRange selctedRange = NSMakeRange(self.invocation.buffer.selections.firstObject.start.line, self.invocation.buffer.selections.lastObject.end.line - self.invocation.buffer.selections.firstObject.start.line);
    
    NSMutableArray *enumDatas = [[NSMutableArray alloc] initWithCapacity:selctedRange.length];
    BOOL(^isEnumFirstLine)(NSString *line) = ^(NSString *line){
        if ([line containsString:@"//"]) {
            line = [[line componentsSeparatedByString:@"//"] firstObject];
        }
        if ([line containsString:@"NS_ENUM"]) {
            return YES;
        }
        if ([line containsString:@"NS_OPTIONS"]) {
            return YES;
        }
        return NO;
    };
    BOOL(^isEnumLastLine)(NSString *line) = ^(NSString *line){
        if ([line containsString:@"//"]) {
            line = [[line componentsSeparatedByString:@"//"] firstObject];
        }
        if ([line containsString:@"};"]) {
            return YES;
        }
        return NO;
    };
    NSString *(^enumPrefix)(NSString *line) = ^(NSString *line){
        if ([line containsString:@"//"]) {
            line = [[line componentsSeparatedByString:@"//"] firstObject];
        }
        NSRange prefixRange = [line rangeOfString:@","];
        NSRange suffixRange = [line rangeOfString:@")"];
        NSString *prefix = [line substringWithRange:NSMakeRange(prefixRange.location + 1, suffixRange.location - prefixRange.location - 1)];
        prefix = [prefix stringByReplacingOccurrencesOfString:@" " withString:@""];
        return prefix;
    };
    NSString *enumPrefixStr = @"";
    
    NSString *(^filterContentLine)(NSString *prefix, NSString *line) = ^(NSString *prefix, NSString *line){
        if (prefix.length < 1) {
            return @"";
        }
        if ([line containsString:@"//"]) {
            line = [[line componentsSeparatedByString:@"//"] firstObject];
        }
        if (![line containsString:prefix]) {
            return @"";
        }
        if ([line containsString:@","]) {
            line = [line stringByReplacingOccurrencesOfString:@"," withString:@""];
        }
        if ([line containsString:@"="]) {
            line = [[line componentsSeparatedByString:@"="] firstObject];
        }
        if ([line containsString:@" "]) {
            line = [line stringByReplacingOccurrencesOfString:@" " withString:@""];
        }
        return line;
    };
    
    for (NSInteger idx = selctedRange.location; idx < selctedRange.location + selctedRange.length; idx ++) {
        NSString *selctedLineContent =  self.invocation.buffer.lines[idx];
        
        if (enumPrefixStr.length < 1) {
            Log(@"-->正在搜索前缀");
            if (isEnumFirstLine(selctedLineContent)) {
                enumPrefixStr = enumPrefix(selctedLineContent);
                NSLog(@"-->前缀: %@",enumPrefixStr);
            }
            continue;
        }
        if (isEnumLastLine(selctedLineContent)) {
            Log(@"-->已经是最后一行,结束");
            break;
        }
        NSString *content = filterContentLine(enumPrefixStr,selctedLineContent);
        if (content.length > 0) {
            Log(@"-->准备添加: %@",content);
            [enumDatas addObject:content];
        }
    }
    return enumDatas;
}
- (NSString *)switchContentWithEnumDatas:(NSArray<NSString *> *)datas
{
    
    NSString *content = @"    switch (<#expression#>) {\n";
    
    for (NSString *caseStr in datas) {
        content = [content stringByAppendingFormat:@"        case %@:\n",caseStr];
        content = [content stringByAppendingString:@"            <#statements#>\n"];
        content = [content stringByAppendingString:@"            break;\n"];
    }
    content = [content stringByAppendingString:@"        default:\n"];
    content = [content stringByAppendingString:@"            break;\n"];
    content = [content stringByAppendingString:@"    }\n"];
    return content;
}
@end
