//
//  TYDrawRun.m
//  TYAttributedLabelDemo
//
//  Created by tanyang on 15/4/8.
//  Copyright (c) 2015年 tanyang. All rights reserved.
//

#import "TYDrawRun.h"
#import <CoreText/CoreText.h>

@interface TYDrawRun (){
    CGFloat         _fontAscent;
    CGFloat         _fontDescent;
}
@end

@implementation TYDrawRun

- (void)setTextFontAscent:(CGFloat)ascent descent:(CGFloat)descent
{
    _fontAscent = ascent;
    _fontDescent = -descent;
}

- (void)addTextRunWithAttributedString:(NSMutableAttributedString *)attributedString
{
    // 判断是不是追加
    NSRange range = self.range;
    
    if (NSEqualRanges(range, NSMakeRange(0, 0))) {
        [attributedString appendAttributedString:[[NSAttributedString alloc]initWithString:[self spaceReplaceString]]];
        range = NSMakeRange(0, 1);
    }else {
        // 用空白替换
        [attributedString replaceCharactersInRange:range withString:[self spaceReplaceString]];
        // 修正range
        range = NSMakeRange(range.location, 1);
    }
    
    // 判断size 大小 小于 _fontAscent 把对齐设为中心 更美观
    if (_size.height <= _fontAscent + _fontDescent) {
        _drawAlignment = TYDrawAlignmentCenter;
    }
    
    // 添加文本属性和runDelegate
    [self addRunDelegateWithAttributedString:attributedString range:range];
}

- (NSAttributedString *)appendTextRunAttributedString
{
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]init];
    self.range = NSMakeRange(0, 0);
    [self addTextRunWithAttributedString:attributedString];
    return [attributedString copy];
}

- (NSString *)spaceReplaceString
{
    // 替换字符
    unichar objectReplacementChar           = 0xFFFC;
    NSString *objectReplacementString       = [NSString stringWithCharacters:&objectReplacementChar length:1];
    return objectReplacementString;
}

// 添加文本属性和runDelegate
- (void)addRunDelegateWithAttributedString:(NSMutableAttributedString *)attributedString range:(NSRange)range
{
    // 添加文本属性和runDelegate
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
    CGFloat ascent = 0;
    CGFloat height = self.size.height;
    switch (_drawAlignment)
    {
        case TYDrawAlignmentTop:
            ascent = height - _fontDescent;
            break;
        case TYDrawAlignmentCenter:
        {
            CGFloat baseLine = (_fontAscent + _fontDescent) / 2 - _fontDescent;
            ascent = height / 2 + baseLine;
            break;
        }
        case TYDrawAlignmentButtom:
            ascent = _fontAscent;
            break;
        default:
            break;
    }
    return ascent;
}

- (CGFloat)getDrawRunWidth
{
    return self.size.width;
}

- (CGFloat)getDrawRunDescentHeight
{
    CGFloat descent = 0;
    CGFloat height = self.size.height;
    switch (_drawAlignment)
    {
        case TYDrawAlignmentTop:
            descent = _fontDescent;
            break;
        case TYDrawAlignmentCenter:
        {
            CGFloat baseLine = (_fontAscent + _fontDescent) / 2 - _fontDescent;
            descent = height / 2 - baseLine;
            break;
        }
        case TYDrawAlignmentButtom:
            descent = height - _fontAscent;
            break;
        default:
            break;
    }
    
    return descent;
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
