//
//  SourceEditorEnumToSwitchCommand.h
//  ZBSnippet
//
//  Created by xzb on 2018/12/13.
//  Copyright © 2018 xzb. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XcodeKit/XcodeKit.h>

@interface SourceEditorEnumToSwitchCommand : NSObject <XCSourceEditorCommand>


@property (nonatomic, strong) XCSourceEditorCommandInvocation *invocation;

@end
