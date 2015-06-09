//
//  TYAttributedLabel.m
//  TYAttributedLabelDemo
//
//  Created by tanyang on 15/4/8.
//  Copyright (c) 2015年 tanyang. All rights reserved.
//

#import "TYAttributedLabel.h"
#import <CoreText/CoreText.h>

#define kSelectAreaColor [UIColor colorWithRed:204/255.0 green:211/255.0 blue:236/255.0 alpha:1]
#define kHighLightLinkColor [UIColor colorWithRed:28/255.0 green:0/255.0 blue:213/255.0 alpha:1]

static NSString* const kEllipsesCharacter = @"\u2026";
NSString *const kTYTextRunAttributedName = @"TYTextRunAttributedName";

@interface TYTextContainer ()
@property (nonatomic, strong) NSMutableAttributedString *attString;
@property (nonatomic, assign,readonly) CTFrameRef  frameRef;
@property (nonatomic, assign,readonly) CGFloat     textHeight;
@property (nonatomic, assign,readonly) CGFloat     textWidth;

- (void)resetFrameRef;
@end

@interface TYAttributedLabel ()
{
    struct {
        unsigned int textStorageClickedAtPoint :1;
        unsigned int textStorageLongPressedOnStateAtPoint :1;
    }_delegateFlags;
    
    NSRange                     _clickLinkRange;     // 点击的link的范围
}

@property (nonatomic, strong)   NSDictionary                *runRectDictionary; // runRect字典
@property (nonatomic, strong)   NSDictionary                *linkRectDictionary;

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
        _textContainer = [[TYTextContainer alloc]init];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self setupProperty];
        _textContainer = [[TYTextContainer alloc]init];
    }
    return self;
}

- (instancetype)initWithTextContainer:(TYTextContainer *)textContainer
{
    if (self = [super init]) {
        [self setupProperty];
        _textContainer = textContainer;
    }
    return self;
}

- (void)setupProperty
{
    if (self.backgroundColor == nil) {
        self.backgroundColor = [UIColor whiteColor];
    }
    self.userInteractionEnabled = YES;
    _highlightedLinkColor = nil;
    _highlightedLinkBackgroundColor = kSelectAreaColor;
}

- (void)setTextContainer:(TYTextContainer *)attStringCreater
{
    _textContainer = attStringCreater;
    [self resetAllAttributed];
    [self setNeedsDisplay];
}

- (void)setDelegate:(id<TYAttributedLabelDelegate>)delegate
{
    if (delegate == _delegate)  return;
    _delegate = delegate;
    
    _delegateFlags.textStorageClickedAtPoint = [delegate respondsToSelector:@selector(attributedLabel:textStorageClicked:atPoint:)];
    _delegateFlags.textStorageLongPressedOnStateAtPoint = [delegate respondsToSelector:@selector(attributedLabel:textStorageLongPressed:onState:atPoint:)];
}

#pragma mark - add textStorage
- (void)addTextStorage:(id<TYTextStorageProtocol>)textStorage
{
    [_textContainer addTextStorage:textStorage];
}

- (void)addTextStorageArray:(NSArray *)textStorageArray
{
    if (textStorageArray) {
        [_textContainer addTextStorageArray:textStorageArray];
        [self setNeedsDisplay];
    }
}

- (void)resetAllAttributed
{
    _runRectDictionary = nil;
    _linkRectDictionary = nil;
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self removeSingleTapGesture];
}

#pragma mark reset framesetter
- (void)resetFramesetter
{
    [_textContainer resetFrameRef];
    [self setNeedsDisplay];
}

#pragma mark - drawRect
- (void)drawRect:(CGRect)rect {
    
    if (_textContainer == nil ||  _textContainer.attString == nil) {
        return;
    }

    //	跟很多底层 API 一样，Core Text 使用 Y翻转坐标系统，而且内容的呈现也是上下翻转的，所以需要通过转换内容将其翻转
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    CGContextTranslateCTM(context, 0, self.bounds.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);

    [_textContainer createTextContainerWithTextWidth:CGRectGetWidth(self.frame)];
    
    if (_highlightedLinkBackgroundColor && _linkRectDictionary.count > 0) {
        [self drawSelectionAreaFrame:_textContainer.frameRef InRange:_clickLinkRange bgColor:_highlightedLinkBackgroundColor];
    }
    
    // CTFrameDraw 将 frame 描述到设备上下文
    [self drawText:_textContainer.attString frame:_textContainer.frameRef rect:rect context:context];
    
    // 画其他元素
    [self drawTextStorageWithFrame:_textContainer.frameRef context:context];
}

// this code quote TTTAttributedLabel
- (void)drawText: (NSAttributedString *)attributedString
            frame:(CTFrameRef)frame
            rect: (CGRect)rect
         context: (CGContextRef)context
{
    if (_textContainer.numberOfLines > 0)
    {
        CFArrayRef lines = CTFrameGetLines(frame);
        NSInteger numberOfLines = MIN(_textContainer.numberOfLines, CFArrayGetCount(lines));
        
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
    
    NSInteger numberOfLines = _textContainer.numberOfLines > 0 ? MIN(_textContainer.numberOfLines, CFArrayGetCount(lines)) : CFArrayGetCount(lines);
    
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
                } else if (_delegateFlags.textStorageLongPressedOnStateAtPoint && [textStorage conformsToProtocol:@protocol(TYLinkStorageProtocol)]) {
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
    }else {
        _linkRectDictionary = nil;
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
                [weakSelf.delegate attributedLabel:weakSelf textStorageLongPressed:obj onState:sender.state atPoint:point];
                *stop = YES;
            }
        }
    }];
}

#pragma mark - touches action

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (_linkRectDictionary) {
        UITouch *touch = [touches anyObject];
        CGPoint point = [touch locationInView:self];
        
        // CoreText context coordinates are the opposite to UIKit so we flip the bounds
        CGAffineTransform transform =  CGAffineTransformScale(CGAffineTransformMakeTranslation(0, self.bounds.size.height), 1.f, -1.f);
        
        __typeof (self) __weak weakSelf = self;
        [_linkRectDictionary enumerateKeysAndObjectsUsingBlock:^(NSValue *keyRectValue, id<TYLinkStorageProtocol> obj, BOOL *stop) {
            CGRect imgRect = [keyRectValue CGRectValue];
            CGRect rect = CGRectApplyAffineTransform(imgRect, transform);
            
            // point 是否在rect里
            if(CGRectContainsPoint(rect, point)){
                NSRange curClickLinkRange = obj.realRange;
            [weakSelf setHighlightLinkWithSaveLinkColor:(obj.textColor ? obj.textColor:weakSelf.textContainer.linkColor) linkRange:curClickLinkRange];
                return ;
            }
        }];
    }

    [super touchesBegan:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
    if (!_linkRectDictionary) {
        return;
    }
    
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    
    // CoreText context coordinates are the opposite to UIKit so we flip the bounds
    CGAffineTransform transform =  CGAffineTransformScale(CGAffineTransformMakeTranslation(0, self.bounds.size.height), 1.f, -1.f);
    
    __block BOOL isUnderClickLink = NO;
    __block NSRange curClickLinkRange;
    __block UIColor *saveLinkColor = nil;
    
    __typeof (self) __weak weakSelf = self;
    [_linkRectDictionary enumerateKeysAndObjectsUsingBlock:^(NSValue *keyRectValue, id<TYLinkStorageProtocol> obj, BOOL *stop) {
        CGRect imgRect = [keyRectValue CGRectValue];
        CGRect rect = CGRectApplyAffineTransform(imgRect, transform);
        
        // point 是否在rect里
        if(CGRectContainsPoint(rect, point)){
            curClickLinkRange = obj.realRange;;
            isUnderClickLink = YES;
            saveLinkColor = obj.textColor ? obj.textColor:weakSelf.textContainer.linkColor;
            *stop = YES;
        }
    }];
    
    if (isUnderClickLink) {
        if (!NSEqualRanges(curClickLinkRange, _clickLinkRange)) {
            if (_saveLinkColor) {
                [_textContainer.attString addAttributeTextColor:_saveLinkColor range:_clickLinkRange];
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
    if (_linkRectDictionary && _clickLinkRange.length > 0) {
        [self resetHighLightLink];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    if (_linkRectDictionary && _clickLinkRange.length > 0) {
        [self resetHighLightLink];
    }
}

// 设置高亮链接
- (void)setHighlightLinkWithSaveLinkColor:(UIColor *)saveLinkColor linkRange:(NSRange)linkRange
{
    if (NSMaxRange(linkRange) > _textContainer.attString.length) {
        _clickLinkRange.length = 0;
        return;
    }
    _clickLinkRange = linkRange;
    if (_highlightedLinkColor)
    {
        [_textContainer.attString addAttributeTextColor:_highlightedLinkColor range:_clickLinkRange];
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
            [_textContainer.attString addAttributeTextColor:_saveLinkColor range:_clickLinkRange];
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
- (void)drawSelectionAreaFrame:(CTFrameRef)frameRef InRange:(NSRange)selectRange bgColor:(UIColor *)bgColor{
    
    NSInteger selectionStartPosition = selectRange.location;
    NSInteger selectionEndPosition = NSMaxRange(selectRange);
    
    if (selectionStartPosition < 0 || selectRange.length <= 0 || selectionEndPosition > _textContainer.attString.length) {
        return;
    }
    
    CFArrayRef lines = CTFrameGetLines(frameRef);
    if (!lines) {
        return;
    }
    CFIndex count = CFArrayGetCount(lines);
    // 获得每一行的origin坐标
    CGPoint origins[count];
    CTFrameGetLineOrigins(frameRef, CFRangeMake(0,0), origins);
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
    // 是否需要更新frame
    return [_textContainer getHeightWithFramesetter:nil Width:width];
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
    _textContainer = nil;
}

#pragma mark - getter

- (NSString *)text{
    return _textContainer.text;
}

- (NSAttributedString *)attributedText
{
    return _textContainer.attributedText;
}

- (NSInteger)numberOfLines
{
    return _textContainer.numberOfLines;
}

- (UIColor *)textColor
{
    return _textContainer.textColor;
}

- (UIFont *)font
{
    return _textContainer.font;
}

- (unichar)characterSpacing
{
    return _textContainer.characterSpacing;
}

- (CGFloat)linesSpacing
{
    return _textContainer.linesSpacing;
}

- (CTTextAlignment)textAlignment
{
    return _textContainer.textAlignment;
}

- (UIColor *)linkColor
{
    return _textContainer.linkColor;
}

#pragma mark - setter

- (void)setText:(NSString *)text
{
    [_textContainer setText:text];
    [self resetAllAttributed];
    [self setNeedsDisplay];
}

- (void)setAttributedText:(NSAttributedString *)attributedText
{
    [_textContainer setAttributedText:attributedText];
    [self resetAllAttributed];
    [self setNeedsDisplay];
}

- (void)setNumberOfLines:(NSInteger)numberOfLines
{
    [_textContainer setNumberOfLines:numberOfLines];
}

- (void)setTextColor:(UIColor *)textColor
{
    [_textContainer setTextColor:textColor];
    [self setNeedsDisplay];
}

- (void)setFont:(UIFont *)font
{
    [_textContainer setFont:font];
    [self setNeedsDisplay];
}

- (void)setCharacterSpacing:(unichar)characterSpacing
{
    [_textContainer setCharacterSpacing:characterSpacing];
    [self setNeedsDisplay];
}

- (void)setLinesSpacing:(CGFloat)linesSpacing
{
    [_textContainer setLinesSpacing:linesSpacing];
    [self setNeedsDisplay];
}

- (void)setTextAlignment:(CTTextAlignment)textAlignment
{
    [_textContainer setTextAlignment:textAlignment];
    [self setNeedsDisplay];
}

- (void)setLinkColor:(UIColor *)linkColor
{
    [_textContainer setLinkColor:linkColor];
}

@end

#pragma mark - append attributedString

@implementation TYAttributedLabel (AppendAttributedString)

- (void)appendText:(NSString *)text
{
    [_textContainer appendText:text];
    [self setNeedsDisplay];
}

- (void)appendTextAttributedString:(NSAttributedString *)attributedText
{
    [_textContainer appendTextAttributedString:attributedText];
    [self setNeedsDisplay];
}

- (void)appendTextStorage:(id<TYAppendTextStorageProtocol>)textStorage
{
    if (textStorage) {
        [_textContainer appendTextStorage:textStorage];
        [self setNeedsDisplay];
    }
}

- (void)appendTextStorageArray:(NSArray *)textStorageArray
{
    if (textStorageArray) {
        [_textContainer appendTextStorageArray:textStorageArray];
        [self setNeedsDisplay];
    }
}

@end

@implementation TYAttributedLabel (Link)

#pragma mark - addLink
- (void)addLinkWithLinkData:(id)linkData range:(NSRange)range
{
    [self addLinkWithLinkData:linkData linkColor:nil range:range];
}

- (void)addLinkWithLinkData:(id)linkData linkColor:(UIColor *)linkColor range:(NSRange )range;
{
    [self addLinkWithLinkData:linkData linkColor:linkColor underLineStyle:kCTUnderlineStyleSingle range:range];
}

- (void)addLinkWithLinkData:(id)linkData linkColor:(UIColor *)linkColor underLineStyle:(CTUnderlineStyle)underLineStyle range:(NSRange )range
{
    [_textContainer addLinkWithLinkData:linkData linkColor:linkColor underLineStyle:underLineStyle range:range];
    [self setNeedsDisplay];
}

#pragma mark - appendLink
- (void)appendLinkWithText:(NSString *)linkText linkFont:(UIFont *)linkFont linkData:(id)linkData
{
    [self appendLinkWithText:linkText linkFont:linkFont linkColor:nil linkData:linkData];
}

- (void)appendLinkWithText:(NSString *)linkText linkFont:(UIFont *)linkFont linkColor:(UIColor *)linkColor linkData:(id)linkData
{
    [self appendLinkWithText:linkText linkFont:linkFont linkColor:linkColor underLineStyle:kCTUnderlineStyleSingle linkData:linkData];
}

- (void)appendLinkWithText:(NSString *)linkText linkFont:(UIFont *)linkFont linkColor:(UIColor *)linkColor underLineStyle:(CTUnderlineStyle)underLineStyle linkData:(id)linkData
{
    [_textContainer appendLinkWithText:linkText linkFont:linkFont linkColor:linkColor underLineStyle:underLineStyle linkData:linkData];
    [self setNeedsDisplay];
}

@end

@implementation TYAttributedLabel (UIImage)

#pragma mark addImage

- (void)addImage:(UIImage *)image range:(NSRange)range size:(CGSize)size alignment:(TYDrawAlignment)alignment
{
    [_textContainer addImage:image range:range size:size alignment:alignment];
}

- (void)addImage:(UIImage *)image range:(NSRange)range size:(CGSize)size
{
    [self addImage:image range:range size:size alignment:TYDrawAlignmentTop];
}

- (void)addImage:(UIImage *)image range:(NSRange)range
{
    [self addImage:image range:range size:image.size];
}

- (void)addImageWithName:(NSString *)imageName range:(NSRange)range size:(CGSize)size alignment:(TYDrawAlignment)alignment
{
    [_textContainer addImageWithName:imageName range:range size:size alignment:alignment];
}

- (void)addImageWithName:(NSString *)imageName range:(NSRange)range size:(CGSize)size
{
    [self addImageWithName:imageName range:range size:size alignment:TYDrawAlignmentTop];
}

- (void)addImageWithName:(NSString *)imageName range:(NSRange)range
{
    [self addImageWithName:imageName range:range size:CGSizeMake(self.font.pointSize, self.font.ascender)];
    
}

#pragma mark - appendImage

- (void)appendImage:(UIImage *)image size:(CGSize)size alignment:(TYDrawAlignment)alignment
{
    [_textContainer appendImage:image size:size alignment:alignment];
}

- (void)appendImage:(UIImage *)image size:(CGSize)size
{
    [self appendImage:image size:size alignment:TYDrawAlignmentTop];
}

- (void)appendImage:(UIImage *)image
{
    [self appendImage:image size:image.size];
}

- (void)appendImageWithName:(NSString *)imageName size:(CGSize)size alignment:(TYDrawAlignment)alignment
{
    [_textContainer appendImageWithName:imageName size:size alignment:alignment];
}

- (void)appendImageWithName:(NSString *)imageName size:(CGSize)size
{
    [self appendImageWithName:imageName size:size alignment:TYDrawAlignmentTop];
}

- (void)appendImageWithName:(NSString *)imageName
{
    [self appendImageWithName:imageName size:CGSizeMake(self.font.pointSize, self.font.ascender)];
    
}

@end

@implementation TYAttributedLabel (UIView)

#pragma mark - addView

- (void)addView:(UIView *)view range:(NSRange)range alignment:(TYDrawAlignment)alignment
{
    [_textContainer addView:view range:range alignment:alignment];
}

- (void)addView:(UIView *)view range:(NSRange)range
{
    [self addView:view range:range alignment:TYDrawAlignmentTop];
}

#pragma mark - appendView

- (void)appendView:(UIView *)view alignment:(TYDrawAlignment)alignment
{
    [_textContainer appendView:view alignment:alignment];
}

- (void)appendView:(UIView *)view
{
    [self appendView:view alignment:TYDrawAlignmentTop];
}


@end


