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

@end
