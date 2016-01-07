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
@property (nonatomic, assign,readonly) CGFloat     textWidth;

- (void)resetFrameRef;

- (void)resetRectDictionary;

- (BOOL)existRunRectDictionary;
- (BOOL)existLinkRectDictionary;
- (BOOL)existDrawRectDictionary;

- (void)enumerateDrawRectDictionaryUsingBlock:(void (^)(id<TYDrawStorageProtocol> drawStorage, CGRect rect))block;

- (BOOL)enumerateRunRectContainPoint:(CGPoint)point
                          viewHeight:(CGFloat)viewHeight
                        successBlock:(void (^)(id<TYTextStorageProtocol> textStorage))successBlock;

- (BOOL)enumerateLinkRectContainPoint:(CGPoint)point
                           viewHeight:(CGFloat)viewHeight
                         successBlock:(void (^)(id<TYLinkStorageProtocol> linkStorage))successBlock;

@end

@interface TYAttributedLabel ()<UIGestureRecognizerDelegate>
{
    struct {
        unsigned int textStorageClickedAtPoint :1;
        unsigned int textStorageLongPressedOnStateAtPoint :1;
    }_delegateFlags;
    
    NSRange                     _clickLinkRange;     // 点击的link的范围
}

@property (nonatomic, strong) UITapGestureRecognizer  *singleTapGuesture; // 点击手势
@property (nonatomic, strong) UILongPressGestureRecognizer *longPressGuesture;// 长按手势
@property (nonatomic, strong) UIColor *saveLinkColor;
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
    _preferredMaxLayoutWidth = attStringCreater.textWidth;
    [self invalidateIntrinsicContentSize];
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
    [self invalidateIntrinsicContentSize];
}

- (void)addTextStorageArray:(NSArray *)textStorageArray
{
    if (textStorageArray) {
        [_textContainer addTextStorageArray:textStorageArray];
        [self invalidateIntrinsicContentSize];
        [self setNeedsDisplay];
    }
}

- (void)resetAllAttributed
{
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self removeSingleTapGesture];
    [self removeLongPressGesture];
}

#pragma mark reset framesetter
- (void)resetFramesetter
{
    [_textContainer resetRectDictionary];
    [_textContainer resetFrameRef];
    [self setNeedsDisplay];
}

#pragma mark - drawRect
- (void)drawRect:(CGRect)rect {
    
    if (_textContainer == nil ||  _textContainer.attString == nil) {
        return;
    }
    
    [_textContainer createTextContainerWithContentSize:self.bounds.size];
    
    // 文本垂直对齐方式位移
    CGFloat verticalOffset = 0;
    switch (_verticalAlignment) {
        case TYVerticalAlignmentCenter:
            verticalOffset = MAX(0, (CGRectGetHeight(rect) - _textContainer.textHeight)/2);
            break;
        case TYVerticalAlignmentBottom:
            verticalOffset = MAX(0, (CGRectGetHeight(rect) - _textContainer.textHeight));
            break;
        default:
            break;
    }

    //	跟很多底层 API 一样，Core Text 使用 Y翻转坐标系统，而且内容的呈现也是上下翻转的，所以需要通过转换内容将其翻转
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    CGContextTranslateCTM(context, 0, self.bounds.size.height + verticalOffset);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    if (_highlightedLinkBackgroundColor && [_textContainer existLinkRectDictionary]) {
        [self drawSelectionAreaFrame:_textContainer.frameRef InRange:_clickLinkRange bgColor:_highlightedLinkBackgroundColor];
    }
    
    // CTFrameDraw 将 frame 描述到设备上下文
    [self drawText:_textContainer.attString frame:_textContainer.frameRef rect:rect context:context];
    
    // 画其他元素
    [self drawTextStorage];
}

// this code quote M80AttributedLabel
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
        
        BOOL truncateLastLine = (_textContainer.lineBreakMode == kCTLineBreakByTruncatingTail);
        
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

- (void)drawTextStorage
{
    // draw storage
    [_textContainer enumerateDrawRectDictionaryUsingBlock:^(id<TYDrawStorageProtocol> drawStorage, CGRect rect) {
        if ([drawStorage conformsToProtocol:@protocol(TYViewStorageProtocol) ]) {
            [(id<TYViewStorageProtocol>)drawStorage setOwnerView:self];
        }
        rect = UIEdgeInsetsInsetRect(rect,drawStorage.margin);
        [drawStorage drawStorageWithRect:rect];
    }];
    
    if ([_textContainer existRunRectDictionary]) {
        if (_delegateFlags.textStorageClickedAtPoint) {
            [self addSingleTapGesture];
        }else {
            [self removeSingleTapGesture];
        }
        if (_delegateFlags.textStorageLongPressedOnStateAtPoint) {
            [self addLongPressGesture];
        }else {
            [self removeLongPressGesture];
        }
    }else {
        [self removeSingleTapGesture];
        [self removeLongPressGesture];
    }
}

#pragma mark - add Gesture
- (void)addSingleTapGesture
{
    if (_singleTapGuesture == nil) {
        // 单指单击
        _singleTapGuesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
        _singleTapGuesture.delegate = self;
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

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    CGPoint point = [touch locationInView:self];
    
    return [_textContainer enumerateRunRectContainPoint:point viewHeight:CGRectGetHeight(self.frame) successBlock:nil];
}

- (void)singleTap:(UITapGestureRecognizer *)sender
{
    CGPoint point = [sender locationInView:self];
    
    __typeof (self) __weak weakSelf = self;
    [_textContainer enumerateRunRectContainPoint:point viewHeight:CGRectGetHeight(self.frame) successBlock:^(id<TYTextStorageProtocol> textStorage){
        if (_delegateFlags.textStorageClickedAtPoint) {
            [_delegate attributedLabel:weakSelf textStorageClicked:textStorage atPoint:point];
        }
    }];
}

- (void)longPress:(UILongPressGestureRecognizer *)sender
{
    CGPoint point = [sender locationInView:self];
    
    __typeof (self) __weak weakSelf = self;
    [_textContainer enumerateRunRectContainPoint:point viewHeight:CGRectGetHeight(self.frame) successBlock:^(id<TYTextStorageProtocol> textStorage){
        if (_delegateFlags.textStorageLongPressedOnStateAtPoint) {
                [weakSelf.delegate attributedLabel:weakSelf textStorageLongPressed:textStorage onState:sender.state atPoint:point];
        }
    }];
}

#pragma mark - touches action

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    __block BOOL found = NO;
    if ([_textContainer existLinkRectDictionary]) {
        UITouch *touch = [touches anyObject];
        CGPoint point = [touch locationInView:self];
        
        __typeof (self) __weak weakSelf = self;
        [_textContainer enumerateLinkRectContainPoint:point viewHeight:CGRectGetHeight(self.frame) successBlock:^(id<TYLinkStorageProtocol> linkStorage) {
            NSRange curClickLinkRange = linkStorage.realRange;
            [weakSelf setHighlightLinkWithSaveLinkColor:(linkStorage.textColor ? linkStorage.textColor:weakSelf.textContainer.linkColor) linkRange:curClickLinkRange];
            found = YES;
        }];
    }

    if (!found) {
        [super touchesBegan:touches withEvent:event];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
    if (![_textContainer existLinkRectDictionary]) {
        return;
    }
    
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    
    __block BOOL isUnderClickLink = NO;
    __block NSRange curClickLinkRange;
    __block UIColor *saveLinkColor = nil;
    
    __typeof (self) __weak weakSelf = self;
    [_textContainer enumerateLinkRectContainPoint:point viewHeight:CGRectGetHeight(self.frame) successBlock:^(id<TYLinkStorageProtocol> linkStorage) {
        curClickLinkRange = linkStorage.realRange;;
        isUnderClickLink = YES;
        saveLinkColor = linkStorage.textColor ? linkStorage.textColor:weakSelf.textContainer.linkColor;
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
    if ([_textContainer existLinkRectDictionary] && _clickLinkRange.length > 0) {
        [self resetHighLightLink];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    if ([_textContainer existLinkRectDictionary] && _clickLinkRange.length > 0) {
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
    return [_textContainer getHeightWithFramesetter:nil width:width];
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

- (void)setPreferredMaxLayoutWidth:(CGFloat)preferredMaxLayoutWidth
{
    if (_preferredMaxLayoutWidth != preferredMaxLayoutWidth) {
        _preferredMaxLayoutWidth = preferredMaxLayoutWidth;
        [self invalidateIntrinsicContentSize];
    }
}

- (CGSize)intrinsicContentSize
{
    return CGSizeMake(self.preferredMaxLayoutWidth, [self getHeightWithWidth:self.preferredMaxLayoutWidth]);
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

- (CTLineBreakMode)lineBreakMode
{
    return _textContainer.lineBreakMode;
}

- (CTTextAlignment)textAlignment
{
    return _textContainer.textAlignment;
}

- (CGFloat)textHeight{
    return _textContainer.textHeight;
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
    [self invalidateIntrinsicContentSize];
    [self setNeedsDisplay];
}

- (void)setAttributedText:(NSAttributedString *)attributedText
{
    [_textContainer setAttributedText:attributedText];
    [self resetAllAttributed];
    [self invalidateIntrinsicContentSize];
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

- (void)setLineBreakMode:(CTLineBreakMode)lineBreakMode
{
    [_textContainer setLineBreakMode:lineBreakMode];
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
    [self invalidateIntrinsicContentSize];
    [self setNeedsDisplay];
}

- (void)appendTextAttributedString:(NSAttributedString *)attributedText
{
    [_textContainer appendTextAttributedString:attributedText];
    [self invalidateIntrinsicContentSize];
    [self setNeedsDisplay];
}

- (void)appendTextStorage:(id<TYAppendTextStorageProtocol>)textStorage
{
    if (textStorage) {
        [_textContainer appendTextStorage:textStorage];
        [self invalidateIntrinsicContentSize];
        [self setNeedsDisplay];
    }
}

- (void)appendTextStorageArray:(NSArray *)textStorageArray
{
    if (textStorageArray) {
        [_textContainer appendTextStorageArray:textStorageArray];
        [self invalidateIntrinsicContentSize];
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