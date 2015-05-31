//
//  TYAttributedLabel.m
//  TYAttributedLabelDemo
//
//  Created by tanyang on 15/4/8.
//  Copyright (c) 2015年 tanyang. All rights reserved.
//

#import "TYAttributedLabel.h"
#import <CoreText/CoreText.h>

// 文本颜色

#define kTextColor       [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1]
#define kLinkColor       [UIColor colorWithRed:0/255.0 green:91/255.0 blue:255/255.0 alpha:1]
#define kSelectAreaColor [UIColor colorWithRed:204/255.0 green:211/255.0 blue:236/255.0 alpha:1]
#define kHighLightLinkColor [UIColor colorWithRed:28/255.0 green:0/255.0 blue:213/255.0 alpha:1]

static NSString* const kEllipsesCharacter = @"\u2026";
NSString *const kTYTextRunAttributedName = @"TYTextRunAttributedName";

// this code quote M80AttributedLabel
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


@interface TYAttributedLabel ()
{
    struct {
        unsigned int textStorageClickedAtPoint :1;
        unsigned int textStorageLongPressedOnStateAtPoint :1;
    }_delegateFlags;
    
    CTFramesetterRef            _framesetter;
    CTFrameRef                  _frameRef;
    NSInteger                   _replaceStringNum;   // 图片替换字符数
    NSRange                     _clickLinkRange;     // 点击的link的范围
}
@property (nonatomic, strong)   NSMutableAttributedString   *attString;         // 文字属性
@property (nonatomic, strong)   NSMutableArray              *textStorageArray;  // run数组

@property (nonatomic, strong)   NSDictionary                *linkRectDictionary;
@property (nonatomic,strong)    NSDictionary                *runRectDictionary; // runRect字典

@property (nonatomic, strong)   UITapGestureRecognizer      *singleTapGuesture;         // 点击手势
@property (nonatomic, strong)   UILongPressGestureRecognizer *longPressGuesture;// 长按手势

@property (nonatomic, strong)   UIColor                     *saveLinkColor;
@end

@implementation TYAttributedLabel

#pragma mark - init

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setupProperty];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
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
    return _attString;
}

#pragma mark - setter
- (void)setupProperty
{
    if (self.backgroundColor == nil) {
        self.backgroundColor = [UIColor whiteColor];
    }
    self.userInteractionEnabled = YES;
    _font = [UIFont systemFontOfSize:15];
    _characterSpacing = 1;
    _linesSpacing = 5;
    _textAlignment = kCTLeftTextAlignment;
    _lineBreakMode = kCTLineBreakByWordWrapping;
    _textColor = kTextColor;
    _linkColor = kLinkColor;
    _highlightedLinkColor = nil;
    _highlightedLinkBackgroundColor = kSelectAreaColor;
    _replaceStringNum = 0;
}

- (void)setDelegate:(id<TYAttributedLabelDelegate>)delegate
{
    if (delegate == _delegate)  return;
    _delegate = delegate;
    
    _delegateFlags.textStorageClickedAtPoint = [delegate respondsToSelector:@selector(attributedLabel:textStorageClicked:atPoint:)];
    _delegateFlags.textStorageLongPressedOnStateAtPoint = [delegate respondsToSelector:@selector(attributedLabel:textStorageLongPressed:onState:atPoint:)];
}

- (void)setText:(NSString *)text
{
    _attString = [self createTextAttibuteStringWithText:text];
    [self resetAllAttributed];
    [self resetFramesetter];
}

- (void)setAttributedText:(NSAttributedString *)attributedText
{
    _attString = [[NSMutableAttributedString alloc]initWithAttributedString:attributedText];
    [self resetAllAttributed];
    [self resetFramesetter];
}

- (void)setTextColor:(UIColor *)textColor
{
    if (textColor && _textColor != textColor){
        _textColor = textColor;
        
        [_attString addAttributeTextColor:textColor];
        [self resetFramesetter];
    }
}

- (void)setFont:(UIFont *)font
{
    if (font && _font != font){
        _font = font;
        
        [_attString addAttributeFont:font];
        [self resetFramesetter];
    }
}

- (void)setCharacterSpacing:(unichar)characterSpacing
{
    if (characterSpacing && _characterSpacing != characterSpacing) {
        _characterSpacing = characterSpacing;
        
        [_attString addAttributeCharacterSpacing:characterSpacing];
        [self resetFramesetter];
    }
}

- (void)setLinesSpacing:(CGFloat)linesSpacing
{
    if (linesSpacing > 0 && _linesSpacing != linesSpacing) {
        _linesSpacing = linesSpacing;
        
        [_attString addAttributeAlignmentStyle:_textAlignment lineSpaceStyle:linesSpacing lineBreakStyle:_lineBreakMode];
        [self resetFramesetter];
    }
}

- (void)setTextAlignment:(CTTextAlignment)textAlignment
{
    if (_textAlignment != textAlignment) {
        _textAlignment = textAlignment;
        
        [_attString addAttributeAlignmentStyle:textAlignment lineSpaceStyle:_linesSpacing lineBreakStyle:_lineBreakMode];
        [self resetFramesetter];
    }
}

#pragma mark - add textStorage
- (void)addTextStorage:(id<TYTextStorageProtocol>)textStorage
{
    if (textStorage) {
        [self.textStorageArray addObject:textStorage];
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
        [self resetFramesetter];
    }
}

- (void)resetAllAttributed
{
    _runRectDictionary = nil;
    _linkRectDictionary = nil;
    _textStorageArray = nil;
    _replaceStringNum = 0;
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self removeSingleTapGesture];
}

#pragma mark reset framesetter
- (void)resetFramesetter
{
    if (_framesetter){
        CFRelease(_framesetter);
        _framesetter = nil;
    }
    
    if (_frameRef) {
        CFRelease(_frameRef);
        _frameRef = nil;
    }
    
    [self setNeedsDisplay];
}

- (void)updateFramesetterIfNeeded
{
    // 是否更新了内容
    if (_framesetter == nil) {
        
        // 添加文本run属性
        [self addTextStoragesWithAtrributedString:_attString];
        
        _framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)_attString);
        
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
                //[drawStorageArray addObject:textStorage];
                continue;
            }
            
            if ([textStorage conformsToProtocol:@protocol(TYLinkStorageProtocol)]) {
                if (!((id<TYLinkStorageProtocol>)textStorage).textColor) {
                    ((id<TYLinkStorageProtocol>)textStorage).textColor = self.linkColor;
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
                NSInteger currentLenght = _attString.length;
                [drawStorage setTextfontAscent:self.font.ascender descent:self.font.descender];
                [drawStorage currentReplacedStringNum:_replaceStringNum];
                [drawStorage addTextStorageWithAttributedString:attString];
                _replaceStringNum += currentLenght - _attString.length;
            }
        }
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

#pragma mark - drawRect
- (void)drawRect:(CGRect)rect {
    
    if (_attString == nil) {
        return;
    }

    //	跟很多底层 API 一样，Core Text 使用 Y翻转坐标系统，而且内容的呈现也是上下翻转的，所以需要通过转换内容将其翻转
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    CGContextTranslateCTM(context, 0, self.bounds.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    // 这里你需要创建一个用于绘制文本的路径区域,通过 self.bounds 使用整个视图矩形区域创建 CGPath 引用。
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, self.bounds);
    
    // CTFramesetter 是使用 Core Text 绘制时最重要的类。它管理您的字体引用和文本绘制帧。这里在 framesetter 之后通过一个所选的文本范围（这里我们选择整个文本）与需要绘制到的矩形路径创建一个帧。
    
    if (_frameRef == nil) {
        
        [self updateFramesetterIfNeeded];
        
        _frameRef = CTFramesetterCreateFrame(_framesetter, CFRangeMake(0, [_attString length]), path, NULL);
    }
    
    if (_highlightedLinkBackgroundColor) {
        [self drawSelectionAreaInRange:_clickLinkRange bgColor:_highlightedLinkBackgroundColor];
    }
    
    //CTFrameDraw(_frameRef, context);	// CTFrameDraw 将 frame 描述到设备上下文
    [self drawText:_attString frame:_frameRef rect:rect context:context];
    
    // 画其他元素
    [self drawTextStorageWithFrame:_frameRef context:context];
    
    CFRelease(path);
}

// this code quote M80AttributedLabel
- (void)drawText: (NSAttributedString *)attributedString
            frame:(CTFrameRef)frame
            rect: (CGRect)rect
         context: (CGContextRef)context
{
    if (_numberOfLines > 0)
    {
        CFArrayRef lines = CTFrameGetLines(frame);
        NSInteger numberOfLines = _numberOfLines > 0 ? MIN(_numberOfLines, CFArrayGetCount(lines)) : CFArrayGetCount(lines);
        
        CGPoint lineOrigins[numberOfLines];
        CTFrameGetLineOrigins(frame, CFRangeMake(0, numberOfLines), lineOrigins);
        
        BOOL truncateLastLine = (_lineBreakMode == kCTLineBreakByTruncatingHead || _lineBreakMode == kCTLineBreakByTruncatingMiddle || _lineBreakMode == kCTLineBreakByTruncatingTail);
        
        for (CFIndex lineIndex = 0; lineIndex < numberOfLines; lineIndex++)
        {
            CGPoint lineOrigin = lineOrigins[lineIndex];
            CGContextSetTextPosition(context, lineOrigin.x, lineOrigin.y);
            CTLineRef line = CFArrayGetValueAtIndex(lines, lineIndex);
            
            BOOL shouldDrawLine = YES;
            if (lineIndex == numberOfLines - 1 && truncateLastLine)
            {
                // Does the last line need truncation?
                CFRange lastLineRange = CTLineGetStringRange(line);
                if (lastLineRange.location + lastLineRange.length < attributedString.length)
                {
                    CTLineTruncationType truncationType = kCTLineTruncationEnd;
                    NSUInteger truncationAttributePosition = lastLineRange.location + lastLineRange.length - 1;
                    
                    NSDictionary *tokenAttributes = [attributedString attributesAtIndex:truncationAttributePosition effectiveRange:NULL];
                    NSAttributedString *tokenString = [[NSAttributedString alloc] initWithString:kEllipsesCharacter attributes:tokenAttributes];
                    CTLineRef truncationToken = CTLineCreateWithAttributedString((CFAttributedStringRef)tokenString);
                    
                    NSMutableAttributedString *truncationString = [[attributedString attributedSubstringFromRange:NSMakeRange(lastLineRange.location, lastLineRange.length)] mutableCopy];
                    
                    if (lastLineRange.length > 0)
                    {
                        // Remove last token
                        [truncationString deleteCharactersInRange:NSMakeRange(lastLineRange.length - 1, 1)];
                    }
                    [truncationString appendAttributedString:tokenString];
                    
                    
                    CTLineRef truncationLine = CTLineCreateWithAttributedString((CFAttributedStringRef)truncationString);
                    CTLineRef truncatedLine = CTLineCreateTruncatedLine(truncationLine, rect.size.width, truncationType, truncationToken);
                    if (!truncatedLine)
                    {
                        // If the line is not as wide as the truncationToken, truncatedLine is NULL
                        truncatedLine = CFRetain(truncationToken);
                    }
                    CFRelease(truncationLine);
                    CFRelease(truncationToken);
                    CTLineDraw(truncatedLine, context);
                    CFRelease(truncatedLine);
                    
                    shouldDrawLine = NO;
                }
            }
            if(shouldDrawLine)
            {
                CTLineDraw(line, context);
            }
        }
    }
    else
    {
        CTFrameDraw(frame,context);
    }
}

#pragma mark - drawTextStorage
- (void)drawTextStorageWithFrame:(CTFrameRef)frame context:(CGContextRef)context
{
    // 获取每行
    CFArrayRef lines = CTFrameGetLines(frame);
    CGPoint lineOrigins[CFArrayGetCount(lines)];
    CTFrameGetLineOrigins(frame, CFRangeMake(0, 0), lineOrigins);
    CGFloat viewWidth = CGRectGetWidth(self.frame);
    
    NSInteger numberOfLines = _numberOfLines > 0 ? MIN(_numberOfLines, CFArrayGetCount(lines)) : CFArrayGetCount(lines);
    
    NSMutableDictionary *runRectDictionary = [NSMutableDictionary dictionary];
    NSMutableDictionary *linkRectDictionary = [NSMutableDictionary dictionary];
    // 获取每行有多少run
    for (int i = 0; i < numberOfLines; i++) {
        CTLineRef line = CFArrayGetValueAtIndex(lines, i);
        CGFloat lineAscent;
        CGFloat lineDescent;
        CGFloat lineLeading;
        CTLineGetTypographicBounds(line, &lineAscent, &lineDescent, &lineLeading);
        
        CFArrayRef runs = CTLineGetGlyphRuns(line);
        // 获得每行的run
        for (int j = 0; j < CFArrayGetCount(runs); j++) {
            CGFloat runAscent;
            CGFloat runDescent;
            CGPoint lineOrigin = lineOrigins[i];
            CTRunRef run = CFArrayGetValueAtIndex(runs, j);
            // run的属性字典
            NSDictionary* attributes = (NSDictionary*)CTRunGetAttributes(run);
            id<TYTextStorageProtocol> textStorage = [attributes objectForKey:kTYTextRunAttributedName];
            
            if (textStorage) {
                CGFloat runWidth  = CTRunGetTypographicBounds(run, CFRangeMake(0,0), &runAscent, &runDescent, NULL);
                
                if (viewWidth > 0 && runWidth > viewWidth) {
                    runWidth  = viewWidth;
                }
                CGRect runRect = CGRectMake(lineOrigin.x + CTLineGetOffsetForStringIndex(line, CTRunGetStringRange(run).location, NULL), lineOrigin.y - runDescent, runWidth, runAscent + runDescent);
                
                if ([textStorage conformsToProtocol:@protocol(TYDrawStorageProtocol)]) {
                    if ([textStorage conformsToProtocol:@protocol(TYViewStorageProtocol) ]) {
                        [(id<TYViewStorageProtocol>)textStorage setOwnerView:self];
                    }
                    [(id<TYDrawStorageProtocol>)textStorage drawStorageWithRect:runRect];
                } else if ([textStorage conformsToProtocol:@protocol(TYLinkStorageProtocol)]) {
                    [linkRectDictionary setObject:textStorage forKey:[NSValue valueWithCGRect:runRect]];
                }
                
                [runRectDictionary setObject:textStorage forKey:[NSValue valueWithCGRect:runRect]];
            }
        }
    }
    
    if (runRectDictionary.count > 0) {
        // 添加响应点击rect
        [self addRunRectDictionary:[runRectDictionary copy]];
    }
    if (linkRectDictionary.count > 0) {
        _linkRectDictionary = [linkRectDictionary copy];
    }
}

// 添加响应点击rect
- (void)addRunRectDictionary:(NSDictionary *)runRectDictionary
{
    if (runRectDictionary.count < _runRectDictionary.count) {
        NSMutableArray *drawStorageArray = [[_runRectDictionary allValues]mutableCopy];
        // 剔除已经画出来的
        [drawStorageArray removeObjectsInArray:[runRectDictionary allValues]];
        
        // 遍历不会画出来的
        for (id<TYTextStorageProtocol>drawStorage in drawStorageArray) {
            if ([drawStorage conformsToProtocol:@protocol(TYViewStorageProtocol)]) {
                [(id<TYViewStorageProtocol>)drawStorage didNotDrawRun];
            }
        }
    }
    _runRectDictionary = runRectDictionary;
    
    if (_delegateFlags.textStorageClickedAtPoint) {
        [self addSingleTapGesture];
    }
    if (_delegateFlags.textStorageLongPressedOnStateAtPoint) {
        [self addLongPressGesture];
    }
}

#pragma mark - add Gesture
- (void)addSingleTapGesture
{
    if (_singleTapGuesture == nil) {
        // 单指单击
        _singleTapGuesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
        // 增加事件者响应者
        [self addGestureRecognizer:_singleTapGuesture];
    }
}

- (void)removeSingleTapGesture
{
    if (_singleTapGuesture) {
        [self removeGestureRecognizer:_singleTapGuesture];
        _singleTapGuesture = nil;
    }
}

- (void)addLongPressGesture
{
    if (_longPressGuesture == nil) {
        // 长按
        _longPressGuesture = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPress:)];
        [self addGestureRecognizer:_longPressGuesture];
    }
}

- (void)removeLongPressGesture
{
    if (_longPressGuesture) {
        [self removeGestureRecognizer:_longPressGuesture];
        _longPressGuesture = nil;
    }
}

#pragma mark - Gesture action
- (void)singleTap:(UITapGestureRecognizer *)sender
{
    CGPoint point = [sender locationInView:self];
    
    // CoreText context coordinates are the opposite to UIKit so we flip the bounds
    CGAffineTransform transform =  CGAffineTransformScale(CGAffineTransformMakeTranslation(0, self.bounds.size.height), 1.f, -1.f);
    
    __typeof (self) __weak weakSelf = self;
    // 遍历run位置字典
    [_runRectDictionary enumerateKeysAndObjectsUsingBlock:^(NSValue *keyRectValue, id<TYTextStorageProtocol> obj, BOOL *stop) {
        
        CGRect imgRect = [keyRectValue CGRectValue];
        CGRect rect = CGRectApplyAffineTransform(imgRect, transform);
        
        // point 是否在rect里
        if(CGRectContainsPoint(rect, point)){
            //NSLog(@"点击了 textStorage ");
            // 调用代理
            if (_delegateFlags.textStorageClickedAtPoint) {
                [_delegate attributedLabel:weakSelf textStorageClicked:obj atPoint:point];
                *stop = YES;
            }
        }
    }];
}

- (void)longPress:(UILongPressGestureRecognizer *)sender
{
    CGPoint point = [sender locationInView:self];
    
    // CoreText context coordinates are the opposite to UIKit so we flip the bounds
    CGAffineTransform transform =  CGAffineTransformScale(CGAffineTransformMakeTranslation(0, self.bounds.size.height), 1.f, -1.f);
    
    __typeof (self) __weak weakSelf = self;
    
    // 遍历run位置字典
    [_runRectDictionary enumerateKeysAndObjectsUsingBlock:^(NSValue *keyRectValue, id<TYTextStorageProtocol> obj, BOOL *stop) {
        
        CGRect imgRect = [keyRectValue CGRectValue];
        CGRect rect = CGRectApplyAffineTransform(imgRect, transform);
        
        // point 是否在rect里
        if(CGRectContainsPoint(rect, point)){
            //NSLog(@"长按了 textStorage ");
            // 调用代理
            if (_delegateFlags.textStorageLongPressedOnStateAtPoint) {
                [_delegate attributedLabel:weakSelf textStorageLongPressed:obj onState:sender.state atPoint:point];
                *stop = YES;
            }
        }
    }];
}

#pragma mark - touches action

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (_linkRectDictionary.count > 0) {
        UITouch *touch = [touches anyObject];
        CGPoint point = [touch locationInView:self];
        
        // CoreText context coordinates are the opposite to UIKit so we flip the bounds
        CGAffineTransform transform =  CGAffineTransformScale(CGAffineTransformMakeTranslation(0, self.bounds.size.height), 1.f, -1.f);
        
        [_linkRectDictionary enumerateKeysAndObjectsUsingBlock:^(NSValue *keyRectValue, id<TYLinkStorageProtocol> obj, BOOL *stop) {
            CGRect imgRect = [keyRectValue CGRectValue];
            CGRect rect = CGRectApplyAffineTransform(imgRect, transform);
            
            // point 是否在rect里
            if(CGRectContainsPoint(rect, point)){
                NSRange curClickLinkRange = obj.realRange;
            [self setHighlightLinkWithSaveLinkColor:(obj.textColor ? obj.textColor:_linkColor) linkRange:curClickLinkRange];
                return ;
            }
        }];
    }

    [super touchesBegan:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
    if (_linkRectDictionary.count <= 0) {
        return;
    }
    
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    
    // CoreText context coordinates are the opposite to UIKit so we flip the bounds
    CGAffineTransform transform =  CGAffineTransformScale(CGAffineTransformMakeTranslation(0, self.bounds.size.height), 1.f, -1.f);
    
    __block BOOL isUnderClickLink = NO;
    __block NSRange curClickLinkRange;
    __block UIColor *saveLinkColor = nil;
    
    [_linkRectDictionary enumerateKeysAndObjectsUsingBlock:^(NSValue *keyRectValue, id<TYLinkStorageProtocol> obj, BOOL *stop) {
        CGRect imgRect = [keyRectValue CGRectValue];
        CGRect rect = CGRectApplyAffineTransform(imgRect, transform);
        
        // point 是否在rect里
        if(CGRectContainsPoint(rect, point)){
            NSInteger location = obj.range.location - _replaceStringNum;
            if (location < 0) {
                location = 0;
            }
            curClickLinkRange = obj.realRange;;
            isUnderClickLink = YES;
            saveLinkColor = obj.textColor ? obj.textColor:_linkColor;
            *stop = YES;
        }
    }];
    
    if (isUnderClickLink) {
        if (!NSEqualRanges(curClickLinkRange, _clickLinkRange)) {
            if (_saveLinkColor) {
                [_attString addAttributeTextColor:_saveLinkColor range:_clickLinkRange];
            }
            [self setHighlightLinkWithSaveLinkColor:saveLinkColor linkRange:curClickLinkRange];
        }
    } else if(_clickLinkRange.length > 0) {
        [self resetHighLightLink];
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesCancelled:touches withEvent:event];
    if (_linkRectDictionary.count > 0 && _clickLinkRange.length > 0) {
        [self resetHighLightLink];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    if (_linkRectDictionary.count > 0 && _clickLinkRange.length > 0) {
        [self resetHighLightLink];
    }
}

// 设置高亮链接
- (void)setHighlightLinkWithSaveLinkColor:(UIColor *)saveLinkColor linkRange:(NSRange)linkRange
{
    if (NSMaxRange(linkRange) > _attString.length) {
        _clickLinkRange.length = 0;
        return;
    }
    _clickLinkRange = linkRange;
    if (_highlightedLinkColor)
    {
        [_attString addAttributeTextColor:_highlightedLinkColor range:_clickLinkRange];
        _saveLinkColor = saveLinkColor;
        [self resetFramesetter];
    }else{
        [self setNeedsDisplay];
    }
}

// 取消高亮
- (void)resetHighLightLink
{
    if (_highlightedLinkColor) {
        if (_saveLinkColor) {
            [_attString addAttributeTextColor:_saveLinkColor range:_clickLinkRange];
            _saveLinkColor = nil;
        }
        _clickLinkRange.length = 0;
        [self resetFramesetter];
    }else {
        _clickLinkRange.length = 0;
        [self setNeedsDisplay];
    }
}

#pragma mark - draw Rect
// 绘画选择区域
- (void)drawSelectionAreaInRange:(NSRange)selectRange bgColor:(UIColor *)bgColor{
    
    NSInteger selectionStartPosition = selectRange.location;
    NSInteger selectionEndPosition = NSMaxRange(selectRange);
    
    if (selectionStartPosition < 0 || selectRange.length <= 0 || selectionEndPosition > _attString.length) {
        return;
    }
    
    CFArrayRef lines = CTFrameGetLines(_frameRef);
    if (!lines) {
        return;
    }
    CFIndex count = CFArrayGetCount(lines);
    // 获得每一行的origin坐标
    CGPoint origins[count];
    CTFrameGetLineOrigins(_frameRef, CFRangeMake(0,0), origins);
    for (int i = 0; i < count; i++) {
        CGPoint linePoint = origins[i];
        CTLineRef line = CFArrayGetValueAtIndex(lines, i);
        CFRange range = CTLineGetStringRange(line);
        // 1. start和end在一个line,则直接弄完break
        if ([self isPosition:selectionStartPosition inRange:range] && [self isPosition:selectionEndPosition inRange:range]) {
            CGFloat ascent, descent, leading, offset, offset2;
            offset = CTLineGetOffsetForStringIndex(line, selectionStartPosition, NULL);
            offset2 = CTLineGetOffsetForStringIndex(line, selectionEndPosition, NULL);
            CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
            CGRect lineRect = CGRectMake(linePoint.x + offset, linePoint.y - descent, offset2 - offset, ascent + descent);
            [self fillSelectionAreaInRect:lineRect bgColor:bgColor];
            break;
        }
        
        // 2. start和end不在一个line
        // 2.1 如果start在line中，则填充Start后面部分区域
        if ([self isPosition:selectionStartPosition inRange:range]) {
            CGFloat ascent, descent, leading, width, offset;
            offset = CTLineGetOffsetForStringIndex(line, selectionStartPosition, NULL);
            width = CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
            CGRect lineRect = CGRectMake(linePoint.x + offset, linePoint.y - descent, width - offset, ascent + descent);
            [self fillSelectionAreaInRect:lineRect bgColor:bgColor];
        } // 2.2 如果 start在line前，end在line后，则填充整个区域
        else if (selectionStartPosition < range.location && selectionEndPosition >= range.location + range.length) {
            CGFloat ascent, descent, leading, width;
            width = CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
            CGRect lineRect = CGRectMake(linePoint.x, linePoint.y - descent, width, ascent + descent);
            [self fillSelectionAreaInRect:lineRect bgColor:bgColor];
        } // 2.3 如果start在line前，end在line中，则填充end前面的区域,break
        else if (selectionStartPosition < range.location && [self isPosition:selectionEndPosition inRange:range]) {
            CGFloat ascent, descent, leading, width, offset;
            offset = CTLineGetOffsetForStringIndex(line, selectionEndPosition, NULL);
            width = CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
            CGRect lineRect = CGRectMake(linePoint.x, linePoint.y - descent, offset, ascent + descent);
            [self fillSelectionAreaInRect:lineRect bgColor:bgColor];
        }
    }
}

- (BOOL)isPosition:(NSInteger)position inRange:(CFRange)range {
    return (position >= range.location && position < range.location + range.length);
}

- (void)fillSelectionAreaInRect:(CGRect)rect bgColor:(UIColor *)bgColor {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, bgColor.CGColor);
    CGContextFillRect(context, rect);
}

#pragma mark - get Right Height
- (int)getHeightWithWidth:(CGFloat)width
{
    if (_attString == nil) {
        return 0;
    }
    
    // 是否需要更新frame
    [self updateFramesetterIfNeeded];
    
    // 获得建议的size
    CGSize suggestedSize = CTFramesetterSuggestFrameSizeForAttributedStringWithConstraints(_framesetter, _attString, CGSizeMake(width,MAXFLOAT), _numberOfLines);
    //CTFramesetterSuggestFrameSizeWithConstraints(_framesetter, CFRangeMake(0, 0), NULL, CGSizeMake(width,MAXFLOAT), NULL);
    
    return suggestedSize.height+1;
}

- (void)sizeToFit
{
    [super sizeToFit];
}

- (CGSize)sizeThatFits:(CGSize)size
{
    CGFloat width = CGRectGetWidth(self.frame);
    CGFloat height = [self getHeightWithWidth:width];
    return CGSizeMake(width, height);
}

#pragma mark - set right frame
- (void)setFrameWithOrign:(CGPoint)orign Width:(CGFloat)width
{
    // 获得高度
    int height = [self getHeightWithWidth:width];
    
    // 设置frame
    [self setFrame:CGRectMake(orign.x, orign.y, width, height)];
}

- (void)dealloc
{
    if (_framesetter != nil) {
        CFRelease(_framesetter);
    }
    
    if (_frameRef != nil) {
        CFRelease(_frameRef);
    }
    _attString = nil;
    
}

@end


#pragma mark - append attributedString

@implementation TYAttributedLabel (AppendAttributedString)

- (void)appendText:(NSString *)text
{
    NSAttributedString *attributedText = [self createTextAttibuteStringWithText:text];
    [self appendTextAttributedString:attributedText];
}

- (void)appendTextAttributedString:(NSAttributedString *)attributedText
{
    if (_attString == nil) {
        _attString = [[NSMutableAttributedString alloc]init];
    }
    [_attString appendAttributedString:attributedText];
    [self resetFramesetter];
}

- (void)appendTextStorage:(id<TYAppendTextStorageProtocol>)textStorage
{
    if (textStorage) {
        if ([textStorage conformsToProtocol:@protocol(TYDrawStorageProtocol)]) {
            [(id<TYDrawStorageProtocol>)textStorage setTextfontAscent:self.font.ascender descent:self.font.descender];
        } else if ([textStorage conformsToProtocol:@protocol(TYLinkStorageProtocol)]) {
            if (!((id<TYLinkStorageProtocol>)textStorage).textColor) {
                ((id<TYLinkStorageProtocol>)textStorage).textColor = self.linkColor;
            }
        }
        
        NSAttributedString *attAppendString = [textStorage appendTextStorageAttributedString];
        textStorage.realRange = NSMakeRange(_attString.length, attAppendString.length);
        [self appendTextAttributedString:attAppendString];
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
        [self resetFramesetter];
    }
}

@end

