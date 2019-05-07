//
//  SourceEditorCommand.m
//  ZBSnippet
//
//  Created by xzb on 2018/12/5.
//  Copyright © 2018 xzb. All rights reserved.
//

#import "SourceEditorCommand.h"

@implementation SourceEditorCommand

- (void)performCommandWithInvocation:(XCSourceEditorCommandInvocation *)invocation completionHandler:(void (^)(NSError *_Nullable nilOrError))completionHandler
{
    __block NSInteger lastImportLine = 0;
    [invocation.buffer.lines enumerateObjectsUsingBlock:^(NSString *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        if ([obj hasPrefix:@"#import"]) {
            lastImportLine = idx;
        }
    }];
    
    XCSourceTextRange *lastRange = [invocation.buffer.selections lastObject];
    
    NSString *selctedLineStr = [invocation.buffer.lines objectAtIndex:lastRange.start.line];
    
    NSRange selctedRange = NSMakeRange(lastRange.start.column, lastRange.end.column - lastRange.start.column);
    
    if (selctedRange.location + selctedRange.length > selctedLineStr.length) {
        NSLog(@"⚠️异常,需要选中文字超出行内容");
        completionHandler(nil);
        return;
    }
    NSString *selctedContent = [selctedLineStr substringWithRange:selctedRange];
    if (selctedContent.length < 1) {
        NSLog(@"⚠️空白,不添加");
        completionHandler(nil);
        return;
    }
    
    //自动实现选中类的extension
    if ([selctedContent containsString:@"@implementation"]) {
        selctedContent = [selctedContent stringByReplacingOccurrencesOfString:@"@implementation" withString:@""];
        NSCharacterSet *set = [NSCharacterSet characterSetWithCharactersInString:[self specialSymbolsAction]];
        selctedContent = [[selctedContent componentsSeparatedByCharactersInSet:set] componentsJoinedByString:@""];
        NSString *importContent = [NSString stringWithFormat:@"\n@interface %@ ()\n\n@end", selctedContent];
         [invocation.buffer.lines insertObject:importContent atIndex:lastRange.start.line - 1];
        completionHandler(nil);
        return;
    }
    
    //自动加import
    if ([selctedContent containsString:@".h"]) {
        selctedContent = [selctedContent stringByReplacingOccurrencesOfString:@".h" withString:@""];
    }
    NSCharacterSet *set = [NSCharacterSet characterSetWithCharactersInString:[self specialSymbolsAction]];
    selctedContent = [[selctedContent componentsSeparatedByCharactersInSet:set] componentsJoinedByString:@""];
    NSString *importContent = [NSString stringWithFormat:@"#import \"%@.h\"", selctedContent];
    [invocation.buffer.lines insertObject:importContent atIndex:lastImportLine + 1];
    completionHandler(nil);
}

/// 特殊符号
- (NSString *)specialSymbolsAction
{
    //数学符号
    NSString *matSym = @" ﹢﹣×÷±/=≌∽≦≧≒﹤﹥≈≡≠=≤≥<>≮≯∷∶∫∮∝∞∧∨∑∏∪∩∈∵∴⊥∥∠⌒⊙√∟⊿㏒㏑%‰⅟½⅓⅕⅙⅛⅔⅖⅚⅜¾⅗⅝⅞⅘≂≃≄≅≆≇≈≉≊≋≌≍≎≏≐≑≒≓≔≕≖≗≘≙≚≛≜≝≞≟≠≡≢≣≤≥≦≧≨≩⊰⊱⋛⋚∫∬∭∮∯∰∱∲∳%℅‰‱øØπ";
    //标点符号
    NSString *punSym = @"。，、＇：∶；?‘’“”〝〞ˆˇ﹕︰﹔﹖﹑·¨….¸;！´？！～—ˉ｜‖＂〃｀@﹫¡¿﹏﹋﹌︴々﹟#﹩$﹠&﹪%*﹡﹢﹦﹤‐￣¯―﹨ˆ˜﹍﹎+=<＿_-ˇ~﹉﹊（）〈〉‹›﹛﹜『』〖〗［］《》〔〕{}「」【】︵︷︿︹︽_﹁﹃︻︶︸﹀︺︾ˉ﹂﹄︼❝❞!():,'[]｛｝^・.·．•＃＾＊＋＝＼＜＞＆§⋯`－–／—|\"\\";
    //单位符号＊·
    NSString *unitSym = @"°′″＄￥〒￠￡％＠℃℉﹩﹪‰﹫㎡㏕㎜㎝㎞㏎m³㎎㎏㏄º○¤%$º¹²³";
    //货币符号
    NSString *curSym = @"₽€£Ұ₴$₰¢₤¥₳₲₪₵元₣₱฿¤₡₮₭₩ރ円₢₥₫₦zł﷼₠₧₯₨Kčर₹ƒ₸￠";
    //制表符
    NSString *tabSym = @"─ ━│┃╌╍╎╏┄ ┅┆┇┈ ┉┊┋┌┍┎┏┐┑┒┓└ ┕┖┗ ┘┙┚┛├┝┞┟┠┡┢┣ ┤┥┦┧┨┩┪┫┬ ┭ ┮ ┯ ┰ ┱ ┲ ┳ ┴ ┵ ┶ ┷ ┸ ┹ ┺ ┻┼ ┽ ┾ ┿ ╀ ╁ ╂ ╃ ╄ ╅ ╆ ╇ ╈ ╉ ╊ ╋ ╪ ╫ ╬═║╒╓╔ ╕╖╗╘╙╚ ╛╜╝╞╟╠ ╡╢╣╤ ╥ ╦ ╧ ╨ ╩ ╳╔ ╗╝╚ ╬ ═ ╓ ╩ ┠ ┨┯ ┷┏ ┓┗ ┛┳ ⊥ ﹃ ﹄┌ ╮ ╭ ╯╰";
    return [NSString stringWithFormat:@"%@%@%@%@%@", matSym, punSym, unitSym, curSym, tabSym];
}

@end
