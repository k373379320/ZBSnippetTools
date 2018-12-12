//
//  SourceEditorAutoImpCommand.h
//  ZBSnippet
//
//  Created by xzb on 2018/12/12.
//  Copyright © 2018 xzb. All rights reserved.
//

#import <XcodeKit/XcodeKit.h>

@interface SourceEditorAutoImpCommand : NSObject <XCSourceEditorCommand>

@property (nonatomic, strong) XCSourceEditorCommandInvocation *invocation;

@end

