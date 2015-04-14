//
//  TYAttributedLabel.m
//  TYAttributedLabelDemo
//
//  Created by tanyang on 15/4/8.
//  Copyright (c) 2015年 tanyang. All rights reserved.
//

#import "TYAttributedLabel.h"
#import "MagnifiterView.h"
#import <CoreText/CoreText.h>

// 文本颜色
#define kTextColor      [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1]

#define RGB(R, G, B)    [UIColor colorWithRed:R/255.0 green:G/255.0 blue:B/255.0 alpha:1.0]

#define ANCHOR_TARGET_TAG 1
#define FONT_HEIGHT  40

typedef enum TYAttributedLabelState : NSInteger {
    TYAttributedLabelStateNormal,       // 普通状态
    TYAttributedLabelStateTouching,     // 正在按下，需要弹出放大镜
    TYAttributedLabelStateSelecting     // 选中了一些文本，需要弹出复制菜单
}TYAttributedLabelState;

@interface TYAttributedLabel ()
{
    CTFramesetterRef            _framesetter;
    CTFrameRef                  _frameRef;
}
@property (nonatomic, strong)   NSMutableAttributedString   *attString;         // 文字属性
@property (nonatomic, strong)   NSMutableArray              *textRunArray;      // run数组
@property (nonatomic,strong)    NSDictionary                *runRectDictionary; // runRect字典
@property (nonatomic, strong)   UITapGestureRecognizer      *singleTap;         //点击手势

@property (nonatomic)           NSInteger                   selectionStartPosition;
@property (nonatomic)           NSInteger                   selectionEndPosition;
@property (nonatomic)           TYAttributedLabelState      state;
@property (strong, nonatomic)   UIImageView                 *leftSelectionAnchor;
@property (strong, nonatomic)   UIImageView                 *rightSelectionAnchor;
@property (strong, nonatomic)   MagnifiterView              *magnifierView;

@end

@implementation TYAttributedLabel

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

- (NSMutableArray *)textRunArray
{
    if (_textRunArray == nil) {
        _textRunArray = [NSMutableArray array];
    }
    return _textRunArray;
}

#pragma mark - 设置属性
- (void)setupProperty
{
    if (self.backgroundColor == nil) {
        self.backgroundColor = [UIColor whiteColor];
    }
    self.userInteractionEnabled = NO;
    _font = [UIFont systemFontOfSize:16];
    _characterSpacing = 1;
    _linesSpacing = 4;
    _textAlignment = kCTLeftTextAlignment;
    _lineBreakMode = kCTLineBreakByCharWrapping;
    _textColor = kTextColor;
    _state = TYAttributedLabelStateNormal;
    _longPressShowMenuEnable = NO;
}

- (void)setLongPressShowMenuEnable:(BOOL)longPressShowMenuEnable
{
    _longPressShowMenuEnable = longPressShowMenuEnable;
    
    if (longPressShowMenuEnable) {
        [self addLongPressGestureRecognizer];
    }
}

- (void)addLongPressGestureRecognizer{
    
}

- (NSString *)text{
    return _attString.string;
}

- (NSAttributedString *)attributedText
{
    return _attString;
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
        [self resetTextRunArray];
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

#pragma mark - add textRun
- (void)addTextRun:(id<TYTextRunProtocol>)textRun
{
    if (textRun ) {
        if ([textRun conformsToProtocol:@protocol(TYDrawRunProtocol)]) {
            [(id<TYDrawRunProtocol>)textRun setTextFontAscent:_font.ascender descent:_font.descender];
        }
        if ([textRun conformsToProtocol:@protocol(TYDrawViewRunProtocol)]){
            [(id<TYDrawViewRunProtocol>)textRun setSuperView:self];
        }

        [self.textRunArray addObject:textRun];
    }
}

- (void)addTextRunArray:(NSArray *)textRunArray
{
    if (textRunArray) {
        for (id textRun in textRunArray) {
            if ([textRun conformsToProtocol:@protocol(TYTextRunProtocol)]) {
                [self addTextRun:textRun];
            }
        }
        [self resetFramesetter];
    }
}

- (void)resetAllAttributed
{
    _runRectDictionary = nil;
    _textRunArray = nil;
    [self removeSingleTapGesture];
    [self setupProperty];
}

- (void)resetTextRunArray
{
    for (id<TYTextRunProtocol>textRun in self.textRunArray) {
        if ([textRun conformsToProtocol:@protocol(TYDrawRunProtocol)]) {
            [(id<TYDrawRunProtocol>)textRun setTextFontAscent:_font.ascender descent:_font.descender];
        }
    }
}

#pragma mark 重置framesetter
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

#pragma mark 更新framesetter，如果需要
- (void)updateFramesetterIfNeeded
{
    // 是否更新了内容
    if (_framesetter == nil) {
        
        // 添加文本run属性
        [self addTextRunsWithAtrributedString:_attString];
        
        _framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)_attString);
        
    }
}

#pragma mark - 创建属性文本字符串
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

#pragma mark -  添加文本run属性
- (void)addTextRunsWithAtrributedString:(NSMutableAttributedString *)attString
{
    if (attString && _textRunArray.count > 0) {
        for (id<TYTextRunProtocol> textRun in _textRunArray) {
            // 验证范围
            if (NSMaxRange([textRun range]) < attString.length) {
                [textRun addTextRunWithAttributedString:attString];
            }
        }
        [_textRunArray removeAllObjects];
    }
}

#pragma mark - 绘画
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
    [self updateFramesetterIfNeeded];
    
    BOOL reDraw = NO;
    if (_frameRef == nil) {
        _frameRef = CTFramesetterCreateFrame(_framesetter, CFRangeMake(0, [_attString length]), path, NULL);
        reDraw = YES;
    }
    
    if (self.state == TYAttributedLabelStateTouching || self.state == TYAttributedLabelStateSelecting) {
        [self drawSelectionArea];
        [self drawAnchors];
    }
    
    CTFrameDraw(_frameRef, context);	// CTFrameDraw 将 frame 描述到设备上下文
    
    // 画其他元素
    [self drawTextRunFrame:_frameRef context:context];

}

#pragma mark - drawTextRun
- (void)drawTextRunFrame:(CTFrameRef)frame context:(CGContextRef)context
{
    // 获取每行
    CFArrayRef lines = CTFrameGetLines(frame);
    CGPoint lineOrigins[CFArrayGetCount(lines)];
    CTFrameGetLineOrigins(frame, CFRangeMake(0, 0), lineOrigins);
    
    NSMutableDictionary *runRectDictionary = [NSMutableDictionary dictionary];
    // 获取每行有多少run
    for (int i = 0; i < CFArrayGetCount(lines); i++) {
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
            id<TYTextRunProtocol> textRun = [attributes objectForKey:kTYTextRunAttributedName];
            //CTRunDelegateRef delegate = (__bridge CTRunDelegateRef)[attributes valueForKey:(id)kCTRunDelegateAttributeName];
            
            if (textRun) {
                CGFloat runWidth  = CTRunGetTypographicBounds(run, CFRangeMake(0,0), &runAscent, &runDescent, NULL);
                
                CGRect runRect = CGRectMake(lineOrigin.x + CTLineGetOffsetForStringIndex(line, CTRunGetStringRange(run).location, NULL), lineOrigin.y - runDescent, runWidth, runAscent + runDescent);
                
                if ([textRun conformsToProtocol:@protocol(TYDrawRunProtocol)]) {
                    [(id<TYDrawRunProtocol>)textRun drawRunWithRect:runRect];
                }
                
                [runRectDictionary setObject:textRun forKey:[NSValue valueWithCGRect:runRect]];
                
            }

        }
    }
    
    
    if (runRectDictionary.count > 0) {
        // 添加响应点击rect
        [self addRunRectDictionary:[runRectDictionary copy]];
    }
}

// 添加响应点击rect
- (void)addRunRectDictionary:(NSDictionary *)runRectDictionary
{
    if (runRectDictionary.count < _runRectDictionary.count) {
        NSMutableArray *drawRunArray = [[_runRectDictionary allValues]mutableCopy];
        // 剔除已经画出来的
        [drawRunArray removeObjectsInArray:[runRectDictionary allValues]];
        
        // 遍历不会画出来的
        for (id<TYTextRunProtocol>drawRun in drawRunArray) {
            if ([drawRun conformsToProtocol:@protocol(TYDrawRunProtocol)]
                && [drawRun respondsToSelector:@selector(didNotDrawRun)]) {
                [(id<TYDrawRunProtocol>)drawRun didNotDrawRun];
            }
        }
    }
    
    _runRectDictionary = runRectDictionary;
    [self addSingleTapGesture];
}

#pragma mark 添加点击手势
- (void)addSingleTapGesture
{
    if (_singleTap == nil) {
        self.userInteractionEnabled = YES;
        //单指单击
        _singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
        //手指数
        _singleTap.numberOfTouchesRequired = 1;
        //点击次数
        _singleTap.numberOfTapsRequired = 1;
        //增加事件者响应者，
        [self addGestureRecognizer:_singleTap];
    }
}

- (void)removeSingleTapGesture
{
    if (_singleTap) {
        [self removeGestureRecognizer:_singleTap];
        _singleTap = nil;
    }
}

#pragma mark 手指点击事件
- (void)singleTap:(UITapGestureRecognizer *)sender
{
    CGPoint point = [sender locationInView:self];
    if (_state == TYAttributedLabelStateNormal) {
        // CoreText context coordinates are the opposite to UIKit so we flip the bounds
        CGAffineTransform transform =  CGAffineTransformScale(CGAffineTransformMakeTranslation(0, self.bounds.size.height), 1.f, -1.f);
    
        __typeof (self) __weak weakSelf = self;
        // 遍历run位置字典
        [_runRectDictionary enumerateKeysAndObjectsUsingBlock:^(NSValue *keyRectValue, id<TYTextRunProtocol> obj, BOOL *stop) {
        
            CGRect imgRect = [keyRectValue CGRectValue];
            CGRect rect = CGRectApplyAffineTransform(imgRect, transform);
        
            // point 是否在rect里
            if(CGRectContainsPoint(rect, point)){
                NSLog(@"点击了 run ");
                // 调用代理
                if ([_delegate respondsToSelector:@selector(attributedLabel:textRunClicked:)]) {
                    [_delegate attributedLabel:weakSelf textRunClicked:obj];
                    *stop = YES;
                }
            }
        }];
    }else {
        self.state = TYAttributedLabelStateNormal;
    }
}

#pragma mark - 获得label最合适的高度 (请在设置text 字体和大小 行距等等 后在调用)
- (int)getHeightWithWidth:(CGFloat)width
{
    if (_attString == nil) {
        return 0;
    }
    
    // 是否需要更新frame
    [self updateFramesetterIfNeeded];
    
    // 获得建议的size
    CGSize suggestedSize = CTFramesetterSuggestFrameSizeWithConstraints(_framesetter, CFRangeMake(0, 0), NULL, CGSizeMake(width,MAXFLOAT), NULL);
    
    return ceilf(suggestedSize.height)+1;
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

#pragma mark 调用这个获得合适的Frame
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

- (void)drawSelectionArea
{
    
}

- (void)drawAnchors
{
    
}

@end

#pragma mark - append text textRun

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

- (void)appendTextRun:(id<TYAppendTextRunProtocol>)textRun
{
    if (textRun) {
        if ([textRun conformsToProtocol:@protocol(TYDrawRunProtocol)]) {
            [(id<TYDrawRunProtocol>)textRun setTextFontAscent:_font.ascender descent:_font.descender];
        }
        if ([textRun conformsToProtocol:@protocol(TYDrawViewRunProtocol)]){
            [(id<TYDrawViewRunProtocol>)textRun setSuperView:self];
        }
        
        [self appendTextAttributedString:[textRun appendTextRunAttributedString]];
    }
}

@end

#pragma mark - 长按出现菜单选择

@implementation TYAttributedLabel (LongPressShowMenu)


- (void)addLongPressGestureRecognizer{
    UIGestureRecognizer *longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                                             action:@selector(userLongPressedGuestureDetected:)];
    [self addGestureRecognizer:longPressRecognizer];
    
    UIGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(userPanGuestureDetected:)];
    [self addGestureRecognizer:panRecognizer];
    self.userInteractionEnabled = YES;
    
}

- (void)setupAnchors {
    if (_selectionStartPosition < 0 && _selectionEndPosition < 0) {
        return;
    }
    _leftSelectionAnchor = [self createSelectionAnchorWithTop:YES];
    _rightSelectionAnchor = [self createSelectionAnchorWithTop:NO];
    [self addSubview:_leftSelectionAnchor];
    [self addSubview:_rightSelectionAnchor];
}

- (MagnifiterView *)magnifierView {
    if (_magnifierView == nil) {
        _magnifierView = [[MagnifiterView alloc] init];
        _magnifierView.viewToMagnify = self;
        [self addSubview:_magnifierView];
    }
    return _magnifierView;
}

- (UIImage *)cursorWithFontHeight:(CGFloat)height isTop:(BOOL)top {
    // 22
    CGRect rect = CGRectMake(0, 0, 22, height * 2);
    UIColor *color = RGB(28, 107, 222);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    // draw point
    if (top) {
        CGContextAddEllipseInRect(context, CGRectMake(0, 0, 22, 22));
    } else {
        CGContextAddEllipseInRect(context, CGRectMake(0, height * 2 - 22, 22, 22));
    }
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillPath(context);
    // draw line
    [color set];
    CGContextSetLineWidth(context, 4);
    CGContextMoveToPoint(context, 11, 22);
    CGContextAddLineToPoint(context, 11, height * 2 - 22);
    CGContextStrokePath(context);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (UIImageView *)createSelectionAnchorWithTop:(BOOL)isTop {
    UIImage *image = [self cursorWithFontHeight:FONT_HEIGHT isTop:isTop];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.frame = CGRectMake(0, 0, 11, FONT_HEIGHT);
    return imageView;
}

- (void)removeSelectionAnchor {
    if (_leftSelectionAnchor) {
        [_leftSelectionAnchor removeFromSuperview];
        _leftSelectionAnchor = nil;
    }
    if (_rightSelectionAnchor) {
        [_rightSelectionAnchor removeFromSuperview];
        _rightSelectionAnchor = nil;
    }
}

- (void)removeMaginfierView {
    if (_magnifierView) {
        [_magnifierView removeFromSuperview];
        _magnifierView = nil;
    }
}

- (void)setState:(TYAttributedLabelState)state {
    if (_state == state) {
        return;
    }
    _state = state;
    if (_state == TYAttributedLabelStateNormal) {
        _selectionStartPosition = -1;
        _selectionEndPosition = -1;
        [self removeSelectionAnchor];
        [self removeMaginfierView];
        [self hideMenuController];
    } else if (_state == TYAttributedLabelStateTouching) {
        if (_leftSelectionAnchor == nil && _rightSelectionAnchor == nil) {
            [self setupAnchors];
        }
    } else if (_state == TYAttributedLabelStateSelecting) {
        if (_leftSelectionAnchor == nil && _rightSelectionAnchor == nil) {
            [self setupAnchors];
        }
        if (_leftSelectionAnchor.tag != ANCHOR_TARGET_TAG && _rightSelectionAnchor.tag != ANCHOR_TARGET_TAG) {
            [self removeMaginfierView];
            [self hideMenuController];
        }
    }
    [self setNeedsDisplay];
}

- (CFIndex)touchContentOffsetInView:(UIView *)view atPoint:(CGPoint)point{
    //CTFrameRef textFrame = data.ctFrame;
    CFArrayRef lines = CTFrameGetLines(_frameRef);
    if (!lines) {
        return -1;
    }
    CFIndex count = CFArrayGetCount(lines);
    
    // 获得每一行的origin坐标
    CGPoint origins[count];
    CTFrameGetLineOrigins(_frameRef, CFRangeMake(0,0), origins);
    
    // 翻转坐标系
    CGAffineTransform transform =  CGAffineTransformMakeTranslation(0, view.bounds.size.height);
    transform = CGAffineTransformScale(transform, 1.f, -1.f);
    
    CFIndex idx = -1;
    for (int i = 0; i < count; i++) {
        CGPoint linePoint = origins[i];
        CTLineRef line = CFArrayGetValueAtIndex(lines, i);
        // 获得每一行的CGRect信息
        CGRect flippedRect = [self getLineBounds:line point:linePoint];
        CGRect rect = CGRectApplyAffineTransform(flippedRect, transform);
        
        if (CGRectContainsPoint(rect, point)) {
            // 将点击的坐标转换成相对于当前行的坐标
            CGPoint relativePoint = CGPointMake(point.x-CGRectGetMinX(rect),
                                                point.y-CGRectGetMinY(rect));
            // 获得当前点击坐标对应的字符串偏移
            idx = CTLineGetStringIndexForPosition(line, relativePoint);
        }
    }
    return idx;
}

- (CGRect)getLineBounds:(CTLineRef)line point:(CGPoint)point {
    CGFloat ascent = 0.0f;
    CGFloat descent = 0.0f;
    CGFloat leading = 0.0f;
    CGFloat width = (CGFloat)CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
    CGFloat height = ascent + descent;
    return CGRectMake(point.x, point.y - descent, width, height);
}

- (void)showMenuController {
    if ([self becomeFirstResponder]) {
        CGRect selectionRect = [self rectForMenuController];
        // 翻转坐标系
        CGAffineTransform transform =  CGAffineTransformMakeTranslation(0, self.bounds.size.height);
        transform = CGAffineTransformScale(transform, 1.f, -1.f);
        selectionRect = CGRectApplyAffineTransform(selectionRect, transform);
        
        UIMenuController *theMenu = [UIMenuController sharedMenuController];
        [theMenu setTargetRect:selectionRect inView:self];
        [theMenu setMenuVisible:YES animated:YES];
    }
}

- (void)hideMenuController {
    if ([self resignFirstResponder]) {
        UIMenuController *theMenu = [UIMenuController sharedMenuController];
        [theMenu setMenuVisible:NO animated:YES];
    }
}

- (void)userLongPressedGuestureDetected:(UILongPressGestureRecognizer *)recognizer {
    CGPoint point = [recognizer locationInView:self];
    //debugMethod();
    //NSLog(@"state = %d", recognizer.state);
    //NSLog(@"point = %@", NSStringFromCGPoint(point));
    if (recognizer.state == UIGestureRecognizerStateBegan ||
        recognizer.state == UIGestureRecognizerStateChanged) {
        CFIndex index = [self touchContentOffsetInView:self atPoint:point];
        if (index != -1 && index < _attString.length) {
            _selectionStartPosition = index;
            _selectionEndPosition = index + 2;
        }
        self.magnifierView.touchPoint = point;
        self.state = TYAttributedLabelStateTouching;
    } else {
        if (_selectionStartPosition >= 0 && _selectionEndPosition <= _attString.length) {
            self.state = TYAttributedLabelStateSelecting;
            [self showMenuController];
        } else {
            self.state = TYAttributedLabelStateNormal;
        }
    }
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    if (action == @selector(copy:) || action == @selector(selectAll:)) {
        return YES;
    }
    return NO;
}

- (void)copy:(id)sender
{
    if (_selectionStartPosition > -1 && _selectionEndPosition > -1) {
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        NSString *selectText = [self.text substringWithRange:NSMakeRange(_selectionStartPosition, _selectionEndPosition - _selectionStartPosition)];
        NSLog(@"%@",selectText);
        [pasteboard setString:selectText];
    }
    self.state = TYAttributedLabelStateNormal;
}

- (void)selectAll:(id)sender
{
    _selectionStartPosition = 0;
    _selectionEndPosition = self.text.length-1;
    
    [self setNeedsDisplay];
    [self showMenuController];
}

- (void)userPanGuestureDetected:(UIGestureRecognizer *)recognizer {
    if (self.state == TYAttributedLabelStateNormal) {
        return;
    }
    CGPoint point = [recognizer locationInView:self];
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        if (_leftSelectionAnchor && CGRectContainsPoint(CGRectInset(_leftSelectionAnchor.frame, -28, -10), point)) {
            //NSLog(@"try to move left anchor");
            _leftSelectionAnchor.tag = ANCHOR_TARGET_TAG;
            [self hideMenuController];
        } else if (_rightSelectionAnchor && CGRectContainsPoint(CGRectInset(_rightSelectionAnchor.frame, -28, -10), point)) {
            //NSLog(@"try to move right anchor");
            _rightSelectionAnchor.tag = ANCHOR_TARGET_TAG;
            [self hideMenuController];
        }
        [self setNeedsDisplay];
    } else if (recognizer.state == UIGestureRecognizerStateChanged) {
        CFIndex index = [self touchContentOffsetInView:self atPoint:point];
        if (index == -1 || ( _selectionEndPosition != _selectionStartPosition && (index == _selectionEndPosition || index == _selectionStartPosition))) {
            return;
        }
        if (_leftSelectionAnchor.tag == ANCHOR_TARGET_TAG && index < _selectionEndPosition) {
            //NSLog(@"change start position to %ld", index);
            _selectionStartPosition = index;
            self.magnifierView.touchPoint = point;
            [self hideMenuController];
        } else if (_rightSelectionAnchor.tag == ANCHOR_TARGET_TAG && index > _selectionStartPosition) {
            //NSLog(@"change end position to %ld", index);
            _selectionEndPosition = index;
            self.magnifierView.touchPoint = point;
            [self hideMenuController];
        }
        [self setNeedsDisplay];
    } else if (recognizer.state == UIGestureRecognizerStateEnded ||
               recognizer.state == UIGestureRecognizerStateCancelled) {
        //NSLog(@"end move");
        _leftSelectionAnchor.tag = 0;
        _rightSelectionAnchor.tag = 0;
        [self removeMaginfierView];
        [self showMenuController];
        [self setNeedsDisplay];
    }
}

- (void)drawAnchors {
    if (_selectionStartPosition < 0 || _selectionEndPosition > _attString.length) {
        return;
    }
    
    CFArrayRef lines = CTFrameGetLines(_frameRef);
    if (!lines) {
        return;
    }
    
    // 翻转坐标系
    CGAffineTransform transform =  CGAffineTransformMakeTranslation(0, self.bounds.size.height);
    transform = CGAffineTransformScale(transform, 1.f, -1.f);
    
    CFIndex count = CFArrayGetCount(lines);
    // 获得每一行的origin坐标
    CGPoint origins[count];
    CTFrameGetLineOrigins(_frameRef, CFRangeMake(0,0), origins);
    for (int i = 0; i < count; i++) {
        CGPoint linePoint = origins[i];
        CTLineRef line = CFArrayGetValueAtIndex(lines, i);
        CFRange range = CTLineGetStringRange(line);
        
        if ([self isPosition:_selectionStartPosition inRange:range]) {
            CGFloat ascent, descent, leading, offset;
            offset = CTLineGetOffsetForStringIndex(line, _selectionStartPosition, NULL);
            CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
            CGPoint origin = CGPointMake(linePoint.x + offset - 5, linePoint.y + ascent + 11);
            origin = CGPointApplyAffineTransform(origin, transform);
            _leftSelectionAnchor.frame = CGRectMake(origin.x, origin.y, CGRectGetWidth(_leftSelectionAnchor.frame), CGRectGetHeight(_leftSelectionAnchor.frame));
        }
        if ([self isPosition:_selectionEndPosition inRange:range]) {
            CGFloat ascent, descent, leading, offset;
            offset = CTLineGetOffsetForStringIndex(line, _selectionEndPosition, NULL);
            CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
            CGPoint origin = CGPointMake(linePoint.x + offset - 5, linePoint.y - descent+28);
            origin = CGPointApplyAffineTransform(origin, transform);
            _rightSelectionAnchor.frame = CGRectMake(origin.x, origin.y, CGRectGetWidth(_rightSelectionAnchor.frame), CGRectGetHeight(_rightSelectionAnchor.frame));
            break;
        }
    }
}

- (void)drawSelectionArea {
    if (_selectionStartPosition < 0 || _selectionEndPosition > _attString.length) {
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
        if ([self isPosition:_selectionStartPosition inRange:range] && [self isPosition:_selectionEndPosition inRange:range]) {
            CGFloat ascent, descent, leading, offset, offset2;
            offset = CTLineGetOffsetForStringIndex(line, _selectionStartPosition, NULL);
            offset2 = CTLineGetOffsetForStringIndex(line, _selectionEndPosition, NULL);
            CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
            CGRect lineRect = CGRectMake(linePoint.x + offset, linePoint.y - descent, offset2 - offset, ascent + descent);
            [self fillSelectionAreaInRect:lineRect];
            break;
        }
        
        // 2. start和end不在一个line
        // 2.1 如果start在line中，则填充Start后面部分区域
        if ([self isPosition:_selectionStartPosition inRange:range]) {
            CGFloat ascent, descent, leading, width, offset;
            offset = CTLineGetOffsetForStringIndex(line, _selectionStartPosition, NULL);
            width = CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
            CGRect lineRect = CGRectMake(linePoint.x + offset, linePoint.y - descent, width - offset, ascent + descent);
            [self fillSelectionAreaInRect:lineRect];
        } // 2.2 如果 start在line前，end在line后，则填充整个区域
        else if (_selectionStartPosition < range.location && _selectionEndPosition >= range.location + range.length) {
            CGFloat ascent, descent, leading, width;
            width = CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
            CGRect lineRect = CGRectMake(linePoint.x, linePoint.y - descent, width, ascent + descent);
            [self fillSelectionAreaInRect:lineRect];
        } // 2.3 如果start在line前，end在line中，则填充end前面的区域,break
        else if (_selectionStartPosition < range.location && [self isPosition:_selectionEndPosition inRange:range]) {
            CGFloat ascent, descent, leading, width, offset;
            offset = CTLineGetOffsetForStringIndex(line, _selectionEndPosition, NULL);
            width = CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
            CGRect lineRect = CGRectMake(linePoint.x, linePoint.y - descent, offset, ascent + descent);
            [self fillSelectionAreaInRect:lineRect];
        }
    }
}

- (CGRect)rectForMenuController {
    if (_selectionStartPosition < 0 || _selectionEndPosition > _attString.length) {
        return CGRectZero;
    }
    
    CFArrayRef lines = CTFrameGetLines(_frameRef);
    if (!lines) {
        return CGRectZero;
    }
    CFIndex count = CFArrayGetCount(lines);
    // 获得每一行的origin坐标
    CGPoint origins[count];
    CTFrameGetLineOrigins(_frameRef, CFRangeMake(0,0), origins);
    
    CGRect resultRect = CGRectZero;
    for (int i = 0; i < count; i++) {
        CGPoint linePoint = origins[i];
        CTLineRef line = CFArrayGetValueAtIndex(lines, i);
        CFRange range = CTLineGetStringRange(line);
        // 1. start和end在一个line,则直接弄完break
        if ([self isPosition:_selectionStartPosition inRange:range] && [self isPosition:_selectionEndPosition inRange:range]) {
            CGFloat ascent, descent, leading, offset, offset2;
            offset = CTLineGetOffsetForStringIndex(line, _selectionStartPosition, NULL);
            offset2 = CTLineGetOffsetForStringIndex(line, _selectionEndPosition, NULL);
            CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
            CGRect lineRect = CGRectMake(linePoint.x + offset, linePoint.y - descent, offset2 - offset, ascent + descent);
            resultRect = lineRect;
            break;
        }
    }
    if (!CGRectIsEmpty(resultRect)) {
        return resultRect;
    }
    
    // 2. start和end不在一个line
    for (int i = 0; i < count; i++) {
        CGPoint linePoint = origins[i];
        CTLineRef line = CFArrayGetValueAtIndex(lines, i);
        CFRange range = CTLineGetStringRange(line);
        // 如果start在line中，则记录当前为起始行
        if ([self isPosition:_selectionStartPosition inRange:range]) {
            CGFloat ascent, descent, leading, width, offset;
            offset = CTLineGetOffsetForStringIndex(line, _selectionStartPosition, NULL);
            width = CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
            CGRect lineRect = CGRectMake(linePoint.x + offset, linePoint.y - descent, width - offset, ascent + descent);
            resultRect = lineRect;
        }
    }
    return resultRect;
}

- (BOOL)isPosition:(NSInteger)position inRange:(CFRange)range {
    if (position >= range.location && position < range.location + range.length) {
        return YES;
    } else {
        return NO;
    }
}

- (void)fillSelectionAreaInRect:(CGRect)rect {
    UIColor *bgColor = RGB(204, 221, 236);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, bgColor.CGColor);
    CGContextFillRect(context, rect);
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}


@end
