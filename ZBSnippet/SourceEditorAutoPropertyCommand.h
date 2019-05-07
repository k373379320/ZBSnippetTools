//
//  SourceEditorAutoPropertyCommand.h
//  ZBSnippet
//
//  Created by xzb on 2019/5/7.
//  Copyright © 2019 xzb. All rights reserved.
//

#import <XcodeKit/XcodeKit.h>


@interface SourceEditorAutoPropertyCommand : NSObject <XCSourceEditorCommand>

@property (nonatomic, strong) XCSourceEditorCommandInvocation *invocation;

@end

