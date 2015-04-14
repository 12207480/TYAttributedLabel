//
//  MagnifiterView.m
//  CoreTextDemo
//
//  Created by tangqiao on 5/8/14.
//  Copyright (c) 2014 TangQiao. All rights reserved.
//

#import "MagnifiterView.h"

@implementation MagnifiterView

- (id)initWithFrame:(CGRect)frame {
	if (self = [super initWithFrame:CGRectMake(0, 0, 80, 80)]) {
		// make the circle-shape outline with a nice border.
		self.layer.borderColor = [[UIColor lightGrayColor] CGColor];
		self.layer.borderWidth = 1;
		self.layer.cornerRadius = 40;
		self.layer.masksToBounds = YES;
	}
	return self;
}

- (void)setTouchPoint:(CGPoint)touchPoint {
    _touchPoint = touchPoint;
    // update the position of the magnifier (to just above what's being magnified)
    self.center = CGPointMake(touchPoint.x, touchPoint.y - 70);
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
	// here we're just doing some transforms on the view we're magnifying,
	// and rendering that view directly into this view,
	// rather than the previous method of copying an image.
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextTranslateCTM(context, CGRectGetWidth(self.frame) * 0.5, CGRectGetHeight(self.frame) * 0.5);
	CGContextScaleCTM(context, 1.5, 1.5);
	CGContextTranslateCTM(context, -1 * (_touchPoint.x), -1 * (_touchPoint.y));
	[self.viewToMagnify.layer renderInContext:context];
}

@end
