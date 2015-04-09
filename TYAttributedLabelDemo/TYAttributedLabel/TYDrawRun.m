//
//  TYDrawRun.m
//  TYAttributedLabelDemo
//
//  Created by tanyang on 15/4/8.
//  Copyright (c) 2015年 tanyang. All rights reserved.
//

#import "TYDrawRun.h"
#import <CoreText/CoreText.h>

@implementation TYDrawRun

- (void)addTextRunWithAttributedString:(NSMutableAttributedString *)attributedString
{
    NSRange range = self.range;
    if (NSEqualRanges(self.range, NSMakeRange(0, 0))) {
        range = NSMakeRange(0, 1);
    }else {
        // 用空白替换
        unichar objectReplacementChar           = 0xFFFC;
        NSString *objectReplacementString       = [NSString stringWithCharacters:&objectReplacementChar length:1];
        [attributedString replaceCharactersInRange:range withString:objectReplacementString];
        // 修正range
        range = NSMakeRange(range.location, 1);
    }
    [attributedString addAttribute:kTYTextRunAttributedName value:self range:range];
    
    //为图片设置CTRunDelegate,delegate决定留给显示内容的空间大小
    CTRunDelegateCallbacks runCallbacks;
    runCallbacks.version = kCTRunDelegateVersion1;
    runCallbacks.dealloc = TYTextRunDelegateDeallocCallback;
    runCallbacks.getAscent = TYTextRunDelegateGetAscentCallback;
    runCallbacks.getDescent = TYTextRunDelegateGetDescentCallback;
    runCallbacks.getWidth = TYTextRunDelegateGetWidthCallback;
    
    CTRunDelegateRef runDelegate = CTRunDelegateCreate(&runCallbacks, (__bridge void *)(self));
    [attributedString addAttribute:(__bridge_transfer NSString *)kCTRunDelegateAttributeName value:(__bridge id)runDelegate range:range];
    CFRelease(runDelegate);
}

- (CGFloat)getDrawRunAscentHeight
{
    //return self.size.height;
    CGFloat baseLine = (_fontAscent + _fontDescent) / 2 - _fontDescent;
    return self.size.height / 2 + baseLine;
}

- (CGFloat)getDrawRunWidth
{
    return self.size.width;
}

- (CGFloat)getDrawRunDescentHeight
{
    CGFloat baseLine = (_fontAscent + _fontDescent) / 2 - _fontDescent;
    return self.size.height / 2 - baseLine;
    //return 0;
}

- (void)DrawRunDealloc
{
    
}

//CTRun的回调，销毁内存的回调
void TYTextRunDelegateDeallocCallback( void* refCon ){
    //TYDrawRun *textRun = (__bridge TYDrawRun *)refCon;
    //[textRun DrawRunDealloc];
}

//CTRun的回调，获取高度
CGFloat TYTextRunDelegateGetAscentCallback( void *refCon ){
    
    TYDrawRun *textRun = (__bridge TYDrawRun *)refCon;
    return [textRun getDrawRunAscentHeight];
}

CGFloat TYTextRunDelegateGetDescentCallback(void *refCon){
    TYDrawRun *textRun = (__bridge TYDrawRun *)refCon;
    return [textRun getDrawRunDescentHeight];
}

//CTRun的回调，获取宽度
CGFloat TYTextRunDelegateGetWidthCallback(void *refCon){
    
    TYDrawRun *textRun = (__bridge TYDrawRun *)refCon;
    return [textRun getDrawRunWidth];
}

@end
