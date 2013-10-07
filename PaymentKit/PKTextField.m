//
//  PKTextField.m
//  PaymentKit Example
//
//  Created by Chris Hollindale on 10/6/13.
//  Copyright (c) 2013 Stripe. All rights reserved.
//

#import "PKTextField.h"

@implementation PKTextField

- (void)drawPlaceholderInRect:(CGRect)rect
{
    [self.placeholderColor setFill];
    [[self placeholder] drawInRect:rect withFont:self.placeholderFont];
}

// Override hitTest so that we have a larger area to tap on, but don't interfere with Apple's standard overlay stuff - call super first

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *hitView = [super hitTest:point withEvent:event];
    if (hitView) {
        return hitView;
    } else {
        int errorMargin = 8;
        CGRect largerFrame = CGRectMake(0 - errorMargin, 0 - errorMargin, self.frame.size.width + 2*errorMargin, self.frame.size.height + 2*errorMargin);
        return (CGRectContainsPoint(largerFrame, point) == 1) ? self : nil;
    }
}

@end
