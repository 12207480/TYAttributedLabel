//
//  TYTextContainer.m
//  TYAttributedLabelDemo
//
//  Created by SunYong on 15/6/4.
//  Copyright (c) 2015年 tanyang. All rights reserved.
//

#import "TYTextContainer.h"

#define kTextColor       [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1]
#define kLinkColor       [UIColor colorWithRed:0/255.0 green:91/255.0 blue:255/255.0 alpha:1]

// this code quote TTTAttributedLabel
static inline CGSize CTFramesetterSuggestFrameSizeForAttributedStringWithConstraints(CTFramesetterRef framesetter, NSAttributedString *attributedString, CGSize size, NSUInteger numberOfLines) {
    CFRange rangeToSize = CFRangeMake(0, (CFIndex)[attributedString length]);
    CGSize constraints = CGSizeMake(size.width, MAXFLOAT);
    
    if (numberOfLines > 0) {
        // If the line count of the label more than 1, limit the range to size to the number of lines that have been set
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathAddRect(path, NULL, CGRectMake(0.0f, 0.0f, constraints.width, MAXFLOAT));
        CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, NULL);
        CFArrayRef lines = CTFrameGetLines(frame);
        
        if (CFArrayGetCount(lines) > 0) {
            NSInteger lastVisibleLineIndex = MIN((CFIndex)numberOfLines, CFArrayGetCount(lines)) - 1;
            CTLineRef lastVisibleLine = CFArrayGetValueAtIndex(lines, lastVisibleLineIndex);
            
            CFRange rangeToLayout = CTLineGetStringRange(lastVisibleLine);
            rangeToSize = CFRangeMake(0, rangeToLayout.location + rangeToLayout.length);
        }
        
        CFRelease(frame);
        CFRelease(path);
    }
    
    CGSize suggestedSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, rangeToSize, NULL, constraints, NULL);
    
    return CGSizeMake(ceil(suggestedSize.width), ceil(suggestedSize.height));
}

@interface TYTextContainer()
@property (nonatomic, strong) NSMutableArray    *textStorageArray;  // run数组
@property (nonatomic, assign) NSInteger         replaceStringNum;   // 图片替换字符数
@property (nonatomic, strong) NSMutableAttributedString *attString;
@property (nonatomic, assign) CTFrameRef  frameRef;
@property (nonatomic, assign) CGFloat     textHeight;
@property (nonatomic, assign) CGFloat     textWidth;

@end

@implementation TYTextContainer

- (instancetype)init
{
    if (self = [super init]) {
        [self setupProperty];
    }
    return self;
}

#pragma mark - getter

- (NSMutableArray *)textStorageArray
{
    if (_textStorageArray == nil) {
        _textStorageArray = [NSMutableArray array];
    }
    return _textStorageArray;
}

- (NSString *)text{
    return _attString.string;
}

- (NSAttributedString *)attributedText
{
    return [_attString copy];
}

- (NSMutableAttributedString *)createAttributedString
{
    [self addTextStoragesWithAtrributedString:_attString];
    return _attString;
}

#pragma mark - setter
- (void)setupProperty
{
    _font = [UIFont systemFontOfSize:15];
    _characterSpacing = 1;
    _linesSpacing = 5;
    _textAlignment = kCTLeftTextAlignment;
    _lineBreakMode = kCTLineBreakByWordWrapping;
    _textColor = kTextColor;
    _linkColor = kLinkColor;
    _replaceStringNum = 0;
}

- (void)resetAllAttributed
{
    _textStorageArray = nil;
    _replaceStringNum = 0;
}

- (void)resetFrameRef
{
    if (_frameRef) {
        CFRelease(_frameRef);
        _frameRef = nil;
    }
    _textHeight = 0;
}

- (void)setText:(NSString *)text
{
    _attString = [self createTextAttibuteStringWithText:text];
    [self resetAllAttributed];
    [self resetFrameRef];
}

- (void)setAttributedText:(NSAttributedString *)attributedText
{
    if ([attributedText isKindOfClass:[NSMutableAttributedString class]]) {
        _attString = (NSMutableAttributedString *)attributedText;
    }else {
        _attString = [[NSMutableAttributedString alloc]initWithAttributedString:attributedText];
    }
    [self resetAllAttributed];
    [self resetFrameRef];
}

- (void)setTextColor:(UIColor *)textColor
{
    if (textColor && _textColor != textColor){
        _textColor = textColor;
        
        [_attString addAttributeTextColor:textColor];
        [self resetFrameRef];
    }
}

- (void)setFont:(UIFont *)font
{
    if (font && _font != font){
        _font = font;
        
        [_attString addAttributeFont:font];
        [self resetFrameRef];
    }
}

- (void)setCharacterSpacing:(unichar)characterSpacing
{
    if (characterSpacing && _characterSpacing != characterSpacing) {
        _characterSpacing = characterSpacing;
        
        [_attString addAttributeCharacterSpacing:characterSpacing];
        [self resetFrameRef];
    }
}

- (void)setLinesSpacing:(CGFloat)linesSpacing
{
    if (linesSpacing > 0 && _linesSpacing != linesSpacing) {
        _linesSpacing = linesSpacing;
        
        [_attString addAttributeAlignmentStyle:_textAlignment lineSpaceStyle:linesSpacing lineBreakStyle:_lineBreakMode];
        [self resetFrameRef];
    }
}

- (void)setTextAlignment:(CTTextAlignment)textAlignment
{
    if (_textAlignment != textAlignment) {
        _textAlignment = textAlignment;
        
        [_attString addAttributeAlignmentStyle:textAlignment lineSpaceStyle:_linesSpacing lineBreakStyle:_lineBreakMode];
        [self resetFrameRef];
    }
}

#pragma mark - create text attibuteString
- (NSMutableAttributedString *)createTextAttibuteStringWithText:(NSString *)text
{
    if (text.length <= 0) {
        return [[NSMutableAttributedString alloc]init];
    }
    // 创建属性文本
    NSMutableAttributedString *attString = [[NSMutableAttributedString alloc]initWithString:text];
    
    // 添加文本颜色 字体属性
    [self addTextColorAndFontWithAtrributedString:attString];
    
    // 添加文本段落样式
    [self addTextParaphStyleWithAtrributedString:attString];
    
    return attString;
}

// 添加文本颜色 字体属性
- (void)addTextColorAndFontWithAtrributedString:(NSMutableAttributedString *)attString
{
    // 添加文本字体
    [attString addAttributeFont:_font];
    
    // 添加文本颜色
    [attString addAttributeTextColor:_textColor];
    
}

// 添加文本段落样式
- (void)addTextParaphStyleWithAtrributedString:(NSMutableAttributedString *)attString
{
    // 字体间距
    if (_characterSpacing)
    {
        [attString addAttributeCharacterSpacing:_characterSpacing];
    }
    
    // 添加文本段落样式
    [attString addAttributeAlignmentStyle:_textAlignment lineSpaceStyle:_linesSpacing lineBreakStyle:_lineBreakMode];
}

#pragma mark -  add text storage atrributed
- (void)addTextStoragesWithAtrributedString:(NSMutableAttributedString *)attString
{
    if (attString && _textStorageArray.count > 0) {
        
        // 排序range
        [self sortTextStorageArray:_textStorageArray];
        
        for (id<TYTextStorageProtocol> textStorage in _textStorageArray) {
            
            // 修正图片替换字符来的误差
            if ([textStorage conformsToProtocol:@protocol(TYDrawStorageProtocol) ]) {
                continue;
            }
            
            if ([textStorage conformsToProtocol:@protocol(TYLinkStorageProtocol)]) {
                if (!((id<TYLinkStorageProtocol>)textStorage).textColor) {
                    ((id<TYLinkStorageProtocol>)textStorage).textColor = _linkColor;
                }
            }
            
            // 验证范围
            if (NSMaxRange(textStorage.range) <= attString.length) {
                [textStorage addTextStorageWithAttributedString:attString];
            }
            
        }
        
        for (id<TYTextStorageProtocol> textStorage in _textStorageArray) {
            textStorage.realRange = NSMakeRange(textStorage.range.location-_replaceStringNum, textStorage.range.length);
            if ([textStorage conformsToProtocol:@protocol(TYDrawStorageProtocol)]) {
                id<TYDrawStorageProtocol> drawStorage = (id<TYDrawStorageProtocol>)textStorage;
                NSInteger currentLenght = attString.length;
                [drawStorage setTextfontAscent:_font.ascender descent:_font.descender];
                [drawStorage currentReplacedStringNum:_replaceStringNum];
                [drawStorage addTextStorageWithAttributedString:attString];
                _replaceStringNum += currentLenght - attString.length;
            }
        }
        [_textStorageArray removeAllObjects];
    }
}

- (void)sortTextStorageArray:(NSMutableArray *)textStorageArray
{
    [textStorageArray sortUsingComparator:^NSComparisonResult(id<TYTextStorageProtocol> obj1, id<TYTextStorageProtocol> obj2) {
        if (obj1.range.location < obj2.range.location) {
            return NSOrderedAscending;
        } else if (obj1.range.location > obj2.range.location){
            return NSOrderedDescending;
        }else {
            return obj1.range.length > obj2.range.length ? NSOrderedAscending:NSOrderedDescending;
        }
    }];
}

- (int)getHeightWithFramesetter:(CTFramesetterRef)framesetter Width:(CGFloat)width
{
    if (_attString == nil || width <= 0) {
        return 0;
    }
    if (_textHeight > 0) {
        return _textHeight;
    }
    
    // 是否需要更新frame
    if (framesetter == nil) {
        
        framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)[self createAttributedString]);
    }else {
        CFRetain(framesetter);
    }
    
    // 获得建议的size
    CGSize suggestedSize = CTFramesetterSuggestFrameSizeForAttributedStringWithConstraints(framesetter, _attString, CGSizeMake(width,MAXFLOAT), _numberOfLines);
    
    //CTFramesetterSuggestFrameSizeWithConstraints(_framesetter, CFRangeMake(0, 0), NULL, CGSizeMake(width,MAXFLOAT), NULL);
    
    CFRelease(framesetter);
    
    return suggestedSize.height+1;
}

-  (CTFrameRef)createFrameRefWithFramesetter:(CTFramesetterRef)framesetter textHeight:(CGFloat)textHeight
{
    // 这里你需要创建一个用于绘制文本的路径区域,通过 self.bounds 使用整个视图矩形区域创建 CGPath 引用。
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, CGRectMake(0, 0, _textWidth, textHeight));
    
    CTFrameRef frameRef = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, [_attString length]), path, NULL);
    CFRelease(path);
    return frameRef;
}

- (instancetype)createTextContainerWithTextWidth:(CGFloat)textWidth
{
    if (_frameRef) {
        return self;
    }
    _textWidth = textWidth;
    
    // 创建CTFramesetter
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)[self createAttributedString]);
    
    // 获得建议的size
    CGFloat textHeight = [self getHeightWithFramesetter:framesetter Width:_textWidth];
    
    // 创建CTFrameRef
    _frameRef = [self createFrameRefWithFramesetter:framesetter textHeight:textHeight];
    _textHeight = textHeight;
    // 释放内存
    CFRelease(framesetter);
    return self;
}

- (void)dealloc{
    [self resetFrameRef];
}

@end

#pragma mark - add textStorage
@implementation TYTextContainer (Add)

- (void)addTextStorage:(id<TYTextStorageProtocol>)textStorage
{
    if (textStorage) {
        [self.textStorageArray addObject:textStorage];
        [self resetFrameRef];
    }
}

- (void)addTextStorageArray:(NSArray *)textStorageArray
{
    if (textStorageArray) {
        for (id<TYTextStorageProtocol> textStorage in textStorageArray) {
            if ([textStorage conformsToProtocol:@protocol(TYTextStorageProtocol)]) {
                [self addTextStorage:textStorage];
            }
        }
    }
}
@end

#pragma mark - append textStorage
@implementation TYTextContainer (Append)

- (void)appendText:(NSString *)text
{
    NSAttributedString *attributedText = [self createTextAttibuteStringWithText:text];
    [self appendTextAttributedString:attributedText];
    [self resetFrameRef];
}

- (void)appendTextAttributedString:(NSAttributedString *)attributedText
{
    if (_attString == nil) {
        _attString = [[NSMutableAttributedString alloc]init];
    }
    [_attString appendAttributedString:attributedText];
    [self resetFrameRef];
}

- (void)appendTextStorage:(id<TYAppendTextStorageProtocol>)textStorage
{
    if (textStorage) {
        if ([textStorage conformsToProtocol:@protocol(TYDrawStorageProtocol)]) {
            [(id<TYDrawStorageProtocol>)textStorage setTextfontAscent:_font.ascender descent:_font.descender];
        } else if ([textStorage conformsToProtocol:@protocol(TYLinkStorageProtocol)]) {
            if (!((id<TYLinkStorageProtocol>)textStorage).textColor) {
                ((id<TYLinkStorageProtocol>)textStorage).textColor = _linkColor;
            }
        }
        
        NSAttributedString *attAppendString = [textStorage appendTextStorageAttributedString];
        textStorage.realRange = NSMakeRange(_attString.length, attAppendString.length);
        [self appendTextAttributedString:attAppendString];
        [self resetFrameRef];
    }
}

- (void)appendTextStorageArray:(NSArray *)textStorageArray
{
    if (textStorageArray) {
        for (id<TYAppendTextStorageProtocol> textStorage in textStorageArray) {
            if ([textStorage conformsToProtocol:@protocol(TYAppendTextStorageProtocol)]) {
                [self appendTextStorage:textStorage];
            }
        }
    }
}


@end
