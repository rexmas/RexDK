//
//  UITextField+RXCursorless.m
//  RexDK
//
//  Created by Rex Fenley on 5/18/14.
//
//  The MIT License (MIT)
//
//  Copyright (c) 2014 Rex Fenley
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

#import "UITextField+RXCursorless.h"

#import <objc/runtime.h>
#import "NSObject+RXRuntimeAdditions.h"

static void * const kTextFieldCursorlessStorage = (void *)&kTextFieldCursorlessStorage;

@implementation UITextField (RXCursorless)

- (void)setCursorless:(BOOL)cursorless
{
    NSNumber *boolObject = [NSNumber numberWithBool:cursorless];
    
    objc_setAssociatedObject(self, kTextFieldCursorlessStorage, boolObject, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (BOOL)cursorless
{
    NSNumber *boolObject = objc_getAssociatedObject(self, kTextFieldCursorlessStorage);
    if (boolObject)
    {
        return [boolObject boolValue];
    }
    else
    {
        return 0;
    }
}

#pragma mark - Swizzling

static CGRect rxCaretRectForPosition(id self, SEL _cmd, UITextPosition *position);
static CGRect (*rxCaretRectForPositionIMP)(id self, SEL _cmd, UITextPosition *position);

static CGRect rxCaretRectForPosition(id self, SEL _cmd, UITextPosition *position)
{
    UITextField *textField = (UITextField *)self;
    
    if (textField.cursorless)
    {
        // Do our version.
        return CGRectZero;
    }
    else
    {
        CGRect val = rxCaretRectForPositionIMP(self, _cmd, position);
        return val;
    }
}

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        @autoreleasepool
        {
            [self swizzle:@selector(caretRectForPosition:) with:(IMP)rxCaretRectForPosition store:(IMPPointer)&rxCaretRectForPositionIMP];
        }
    });
}

@end
