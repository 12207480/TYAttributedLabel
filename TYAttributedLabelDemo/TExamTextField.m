//
//  TExamTextField.m
//  TYAttributedLabelDemo
//
//  Created by tanyang on 15/10/10.
//  Copyright © 2015年 tanyang. All rights reserved.
//

#import "TExamTextField.h"

@interface TExamTextField ()
@property (nonatomic, weak) UIImageView *rightImageView; // 对错
@end

#define kRightImageViewWidth 15
#define kRightImageViewHeight 18

@implementation TExamTextField

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        [self addRightImageView];
    }
    return self;
}

- (void)addRightImageView
{
    UIImageView *rightImageView = [[UIImageView alloc]initWithFrame:CGRectMake(CGRectGetWidth(self.frame) - kRightImageViewWidth, CGRectGetHeight(self.frame) - kRightImageViewHeight, kRightImageViewWidth, kRightImageViewHeight)];
    rightImageView.contentMode = UIViewContentModeBottom;
    [self addSubview:rightImageView];
    _rightImageView = rightImageView;
}

- (void)setExamState:(TExamTextFieldState)examState
{
    _examState = examState;
    
    switch (examState) {
        case TExamTextFieldStateNormal:
            self.userInteractionEnabled = YES;
            _rightImageView.image = nil;
            break;
        case TExamTextFieldStateCorrect:
            self.userInteractionEnabled = NO;
            _rightImageView.image = [UIImage imageNamed:@"icon_zt_dui"];
            break;
        case TExamTextFieldStateError:
            self.userInteractionEnabled = NO;
            _rightImageView.image = [UIImage imageNamed:@"icon_zt_cuo"];
            break;
            
        default:
            break;
    }
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    //[super drawRect:rect];
    // Drawing code
    CGContextRef context = UIGraphicsGetCurrentContext();
    //画一条底部线
    CGContextSetRGBStrokeColor(context, 207.0/255, 207.0/255, 207.0/255, 1);//线条颜色
    CGContextMoveToPoint(context, 0, rect.size.height);
    CGContextAddLineToPoint(context, rect.size.width,rect.size.height);
    CGContextStrokePath(context);
}


@end
