//
//  PKPaymentField.m
//  PKPayment Example
//
//  Created by Alex MacCaw on 1/22/13.
//  Copyright (c) 2013 Stripe. All rights reserved.
//

#define RGB(r,g,b) [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:1.0f]
#define DarkGreyColor RGB(77,77,77)
#define RedColor RGB(253,0,17)
#define DefaultBoldFont [UIFont boldSystemFontOfSize:16]

#define kPKViewPlaceholderViewAnimationDuration 0.25

#import <QuartzCore/QuartzCore.h>
#import "PKView.h"

@interface PKView () {
@private
    BOOL isInitialState;
    BOOL isValidState;
    BOOL isUSAddress;
}

- (void)setup;
- (void)setupPlaceholderView;
- (void)setupCardNumberField;
- (void)setupCardExpiryField;
- (void)setupCardCVCField;
- (void)setupZipField;

- (void)setPlaceholderViewImage:(UIImage *)image;
- (void)setPlaceholderToCVC;
- (void)setPlaceholderToCardType;

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)replacementString;
- (BOOL)cardNumberFieldShouldChangeCharactersInRange: (NSRange)range replacementString:(NSString *)replacementString;
- (BOOL)cardExpiryShouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)replacementString;
- (BOOL)cardCVCShouldChangeCharactersInRange: (NSRange)range replacementString:(NSString *)replacementString;
- (BOOL)addressZipShouldChangeCharactersInRange: (NSRange)range replacementString:(NSString *)replacementString;

- (void)checkValid;
- (void)textFieldIsValid:(UITextField *)textField;
- (void)textFieldIsInvalid:(UITextField *)textField withErrors:(BOOL)errors;
@end

@implementation PKView

@synthesize innerView, cardNumberField,
            cardExpiryField, cardCVCField, addressZipField,
            placeholderView, delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setup];
}

- (void)setup
{
    isInitialState = YES;
    isValidState   = NO;
    isUSAddress    = YES;
    
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, 290, 45);
    self.backgroundColor = [UIColor whiteColor];
    self.layer.cornerRadius = 9.0f;
    self.layer.borderWidth = 1.0f;
    self.layer.borderColor = [RGB(171,171,171) CGColor];
    self.layer.shadowColor = [RGB(255,255,255) CGColor];
    self.layer.shadowOffset = CGSizeMake(0, 1.0);
    self.layer.shadowOpacity = 1.0;
    self.layer.shadowRadius = 0.3;
    
    CALayer *innerShadow = [CALayer layer];
    innerShadow.frame = CGRectMake(0, 1, self.frame.size.width, 1);
    innerShadow.backgroundColor = [RGB(230,230,230) CGColor];
    innerShadow.cornerRadius = 9.0f;
    [self.layer addSublayer:innerShadow];
    
    self.innerView = [[UIView alloc] initWithFrame:CGRectMake(48, 13, self.frame.size.width - 48, 20)];
    self.innerView.clipsToBounds = YES;
    
    [self setupPlaceholderView];
    [self setupCardNumberField];
    [self setupCardExpiryField];
    [self setupCardCVCField];
    [self setupZipField];
    
    [self.innerView addSubview:cardNumberField];
    [self addSubview:self.innerView];
    [self addSubview:placeholderView];
    
    [self stateCardNumber];
}


- (void)setupPlaceholderView
{
    placeholderView = [[UIImageView alloc] initWithFrame:CGRectMake(12, 13, 32, 20)];
    placeholderView.backgroundColor = [UIColor whiteColor];
    placeholderView.image = [UIImage imageNamed:@"placeholder"];
    
    CALayer *clip = [CALayer layer];
    clip.frame = CGRectMake(32, 0, 4, 20);
    clip.backgroundColor = [UIColor whiteColor].CGColor;
    [placeholderView.layer addSublayer:clip];
}

- (void)setupCardNumberField
{
    cardNumberField = [[UITextField alloc] initWithFrame:CGRectMake(40-26-10,0,160,20)];
    
    cardNumberField.delegate = self;
    
    cardNumberField.placeholder = @"1234 5678 9012 3456";
    cardNumberField.keyboardType = UIKeyboardTypeNumberPad;
    cardNumberField.textColor = DarkGreyColor;
    cardNumberField.font = DefaultBoldFont;
    
    [cardNumberField.layer setMasksToBounds:YES];
}

- (void)setupCardExpiryField
{
    cardExpiryField = [[UITextField alloc] initWithFrame:CGRectMake(100-26-10,0,60,20)];

    cardExpiryField.delegate = self;
    
    cardExpiryField.placeholder = @"MM/YY";
    cardExpiryField.keyboardType = UIKeyboardTypeNumberPad;
    cardExpiryField.textColor = DarkGreyColor;
    cardExpiryField.font = DefaultBoldFont;
    
    cardExpiryField.layer.opacity = 0;
    
    [cardExpiryField.layer setMasksToBounds:YES];
}

- (void)setupCardCVCField
{
    cardCVCField = [[UITextField alloc] initWithFrame:CGRectMake(129,0,55,20)];
    
    cardCVCField.delegate = self;
    
    cardCVCField.placeholder = @"CVC";
    cardCVCField.keyboardType = UIKeyboardTypeNumberPad;
    cardCVCField.textColor = DarkGreyColor;
    cardCVCField.font = DefaultBoldFont;
    
    cardCVCField.layer.opacity = 0;
    
    [cardCVCField.layer setMasksToBounds:YES];
}

- (void)setupZipField
{
    addressZipField = [[UITextField alloc] initWithFrame:CGRectMake(184,0,50,20)];
    
    addressZipField.delegate = self;
    
    addressZipField.placeholder = @"ZIP";
    addressZipField.keyboardType = UIKeyboardTypeNumberPad;
    addressZipField.textColor = DarkGreyColor;
    addressZipField.font = DefaultBoldFont;
    
    addressZipField.layer.opacity = 0;
    
    [addressZipField.layer setMasksToBounds:YES];
}

- (BOOL)usAddress
{
    return isUSAddress;
}

- (void)setUSAddress:(BOOL)enabled
{
    isUSAddress = enabled;
    
    if (isUSAddress) {
        addressZipField.keyboardType = UIKeyboardTypeNumberPad;
    } else {
        addressZipField.keyboardType = UIKeyboardTypeASCIICapable;
    }
}

// Accessors

- (PKCardNumber*)cardNumber
{
    return [PKCardNumber cardNumberWithString:cardNumberField.text];
}

- (PKCardExpiry*)cardExpiry
{
    return [PKCardExpiry cardExpiryWithString:cardExpiryField.text];
}

- (PKCardCVC*)cardCVC
{
    return [PKCardCVC cardCVCWithString:cardCVCField.text];
}

- (PKAddressZip*)addressZip
{
    if (isUSAddress) {
        return [PKUSAddressZip addressZipWithString:addressZipField.text];
    } else {
        return [PKAddressZip addressZipWithString:addressZipField.text];
    }
}

// State

- (void)stateCardNumber
{
    if (!isInitialState) {
        // Animate left
        isInitialState = YES;
        
        [UIView animateWithDuration:0.400
                              delay:0
                            options:(UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionAllowUserInteraction)
                         animations:^{
                             cardExpiryField.layer.opacity = 0;
                             cardCVCField.layer.opacity = 0;
                             addressZipField.layer.opacity = 0;
                            cardNumberField.frame = CGRectMake(4,
                                                               cardNumberField.frame.origin.y,
                                                               cardNumberField.frame.size.width,
                                                               cardNumberField.frame.size.height);
                         }
                         completion:^(BOOL completed) {
                             [cardExpiryField removeFromSuperview];
                             [cardCVCField removeFromSuperview];
                             [addressZipField removeFromSuperview];
                         }];
    }
    
    [self.cardNumberField becomeFirstResponder];
}

- (void)stateMeta
{
    isInitialState = NO;
    
    CGSize cardNumberSize = [self.cardNumber.formattedString sizeWithFont:DefaultBoldFont];
    CGSize lastGroupSize = [self.cardNumber.lastGroup sizeWithFont:DefaultBoldFont];
    CGFloat frameX = self.cardNumberField.frame.origin.x - (cardNumberSize.width - lastGroupSize.width);
        
    [UIView animateWithDuration:0.400 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        cardExpiryField.layer.opacity = 1;
        cardCVCField.layer.opacity = 1;
        addressZipField.layer.opacity = 1;
        cardNumberField.frame = CGRectMake(frameX,
                                           cardNumberField.frame.origin.y,
                                           cardNumberField.frame.size.width,
                                           cardNumberField.frame.size.height);
    } completion:nil];
    
    [self addSubview:placeholderView];
    [self.innerView addSubview:cardExpiryField];
    [self.innerView addSubview:cardCVCField];
    [self.innerView addSubview:addressZipField];
    [cardExpiryField becomeFirstResponder];
}

- (void)stateCardCVC
{
    [cardCVCField becomeFirstResponder];
}

- (void)stateZip
{
    [addressZipField becomeFirstResponder];
}

- (BOOL)isValid
{    
    return [self.cardNumber isValid] && [self.cardExpiry isValid] &&
           [self.cardCVC isValid] && [self.addressZip isValid];
}

- (PKCard*)card
{
    PKCard* card    = [[PKCard alloc] init];
    card.number     = [self.cardNumber string];
    card.cvc        = [self.cardCVC string];
    card.expMonth   = [self.cardExpiry month];
    card.expYear    = [self.cardExpiry year];
    card.addressZip = [self.addressZip string];
    
    return card;
}

- (void)setPlaceholderViewImage:(UIImage *)image
{
    if(![placeholderView.image isEqual:image]) {
        __block __weak UIView *previousPlaceholderView = placeholderView;
        [UIView animateWithDuration:kPKViewPlaceholderViewAnimationDuration delay:0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^
         {
             placeholderView.layer.opacity = 0.0;
             placeholderView.layer.transform = CATransform3DMakeScale(1.2, 1.2, 1.2);
         } completion:^(BOOL finished) {
             [previousPlaceholderView removeFromSuperview];
         }];
        placeholderView = nil;
        
        [self setupPlaceholderView];
        placeholderView.image = image;
        placeholderView.layer.opacity = 0.0;
        placeholderView.layer.transform = CATransform3DMakeScale(0.8, 0.8, 0.8);
        [self insertSubview:placeholderView belowSubview:previousPlaceholderView];
        [UIView animateWithDuration:kPKViewPlaceholderViewAnimationDuration delay:0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^
         {
             placeholderView.layer.opacity = 1.0;
             placeholderView.layer.transform = CATransform3DIdentity;
         } completion:^(BOOL finished) {}];
    }
}

- (void)setPlaceholderToCVC
{
    PKCardNumber *cardNumber = [PKCardNumber cardNumberWithString:cardNumberField.text];
    PKCardType cardType      = [cardNumber cardType];
    
    if (cardType == PKCardTypeAmex) {
        [self setPlaceholderViewImage:[UIImage imageNamed:@"cvc-amex"]];
    } else {
        [self setPlaceholderViewImage:[UIImage imageNamed:@"cvc"]];
    }
}

- (void)setPlaceholderToCardType
{
    PKCardNumber *cardNumber = [PKCardNumber cardNumberWithString:cardNumberField.text];
    PKCardType cardType      = [cardNumber cardType];
    NSString* cardTypeName   = @"placeholder";
    
    switch (cardType) {
        case PKCardTypeAmex:
            cardTypeName = @"amex";
            break;
        case PKCardTypeDinersClub:
            cardTypeName = @"diners";
            break;
        case PKCardTypeDiscover:
            cardTypeName = @"discover";
            break;
        case PKCardTypeJCB:
            cardTypeName = @"jcb";
            break;
        case PKCardTypeMasterCard:
            cardTypeName = @"mastercard";
            break;
        case PKCardTypeVisa:
            cardTypeName = @"visa";
            break;
        default:
            break;
    }

    [self setPlaceholderViewImage:[UIImage imageNamed:cardTypeName]];
    
}

// Delegates

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if ([textField isEqual:cardCVCField]) {
        [self setPlaceholderToCVC];
    } else {
        [self setPlaceholderToCardType];
    }
    
    if ([textField isEqual:cardNumberField] && !isInitialState) {
        [self stateCardNumber];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)replacementString
{
    if ([textField isEqual:cardNumberField]) {
        return [self cardNumberFieldShouldChangeCharactersInRange:range replacementString:replacementString];
    }
    
    if ([textField isEqual:cardExpiryField]) {
        return [self cardExpiryShouldChangeCharactersInRange:range replacementString:replacementString];
    }
    
    if ([textField isEqual:cardCVCField]) {
        return [self cardCVCShouldChangeCharactersInRange:range replacementString:replacementString];
    }
    
    if ([textField isEqual:addressZipField]) {
        return [self addressZipShouldChangeCharactersInRange:range replacementString:replacementString];
    }
    
    return YES;
}

- (BOOL)cardNumberFieldShouldChangeCharactersInRange: (NSRange)range replacementString:(NSString *)replacementString
{
    NSString *resultString = [cardNumberField.text stringByReplacingCharactersInRange:range withString:replacementString];
    PKCardNumber *cardNumber = [PKCardNumber cardNumberWithString:resultString];
    
    if ( ![cardNumber isPartiallyValid] )
        return NO;
    
    if (replacementString.length > 0) {
        cardNumberField.text = [cardNumber formattedStringWithTrail];
    } else {
        cardNumberField.text = [cardNumber formattedString];
    }
    
    [self setPlaceholderToCardType];
    
    if ([cardNumber isValid]) {
        [self textFieldIsValid:cardNumberField];
        [self stateMeta];
        
    } else if ([cardNumber isValidLength] && ![cardNumber isValidLuhn]) {
        [self textFieldIsInvalid:cardNumberField withErrors:YES];
        
    } else if (![cardNumber isValidLength]) {
        [self textFieldIsInvalid:cardNumberField withErrors:NO];
    }
    
    return NO;
}

- (BOOL)cardExpiryShouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)replacementString
{
    NSString *resultString = [cardExpiryField.text stringByReplacingCharactersInRange:range withString:replacementString];
    PKCardExpiry *cardExpiry = [PKCardExpiry cardExpiryWithString:resultString];
    
    if (![cardExpiry isPartiallyValid]) return NO;
    
    // Only support shorthand year
    if ([cardExpiry formattedString].length > 5) return NO;
    
    if (replacementString.length > 0) {
        cardExpiryField.text = [cardExpiry formattedStringWithTrail];
    } else {
        cardExpiryField.text = [cardExpiry formattedString];
    }
    
    if ([cardExpiry isValid]) {
        [self textFieldIsValid:cardExpiryField];
        [self stateCardCVC];
        
    } else if ([cardExpiry isValidLength] && ![cardExpiry isValidDate]) {
        [self textFieldIsInvalid:cardExpiryField withErrors:YES];
    } else if (![cardExpiry isValidLength]) {
        [self textFieldIsInvalid:cardExpiryField withErrors:NO];
    }
    
    return NO;
}

- (BOOL)cardCVCShouldChangeCharactersInRange: (NSRange)range replacementString:(NSString *)replacementString
{
    NSString *resultString = [cardCVCField.text stringByReplacingCharactersInRange:range withString:replacementString];
    PKCardCVC *cardCVC = [PKCardCVC cardCVCWithString:resultString];
    PKCardType cardType = [[PKCardNumber cardNumberWithString:cardNumberField.text] cardType];
    
    // Restrict length
    if ( ![cardCVC isPartiallyValidWithType:cardType] ) return NO;
    
    // Strip non-digits
    cardCVCField.text = [cardCVC string];
    
    if ([cardCVC isValidWithType:cardType]) {
        [self textFieldIsValid:cardCVCField];
        [self stateZip];
    } else {
        [self textFieldIsInvalid:cardCVCField withErrors:NO];
    }
    
    return NO;
}

- (BOOL)addressZipShouldChangeCharactersInRange: (NSRange)range replacementString:(NSString *)replacementString
{
    NSString *resultString = [addressZipField.text stringByReplacingCharactersInRange:range withString:replacementString];
    PKAddressZip *addressZip;
    
    if (isUSAddress) {
        addressZip = [PKUSAddressZip addressZipWithString:resultString];
    } else {
        addressZip = [PKAddressZip addressZipWithString:resultString];
    }

    // Restrict length
    if ( ![addressZip isPartiallyValid] ) return NO;
    
    addressZipField.text = [addressZip string];
    
    if ([addressZip isValid]) {
        [self textFieldIsValid:addressZipField];
    } else {
        [self textFieldIsInvalid:addressZipField withErrors:NO];
    }
    
    return NO;
}

// Validations

- (void)checkValid
{
    if ([self isValid] && !isValidState) {
        isValidState = YES;

        if ([self.delegate respondsToSelector:@selector(paymentView:withCard:isValid:)]) {
            [self.delegate paymentView:self withCard:self.card isValid:YES];
        }
        
    } else if (![self isValid] && isValidState) {
        isValidState = NO;
        
        if ([self.delegate respondsToSelector:@selector(paymentView:withCard:isValid:)]) {
            [self.delegate paymentView:self withCard:self.card isValid:NO];
        }
    }
}

- (void)textFieldIsValid:(UITextField *)textField {
    textField.textColor = DarkGreyColor;
    [self checkValid];
}

- (void)textFieldIsInvalid:(UITextField *)textField withErrors:(BOOL)errors {
    if (errors) {
        textField.textColor = RedColor;
    } else {
        textField.textColor = DarkGreyColor;        
    }

    [self checkValid];
}

// Custom methods

- (void)setCardNumberToNumber:(NSString *)cardNumber
{
    PKCardNumber *cardNumber = [PKCardNumber cardNumberWithString:cardNumber];
    
    // Don't allow anything that's too long
    if ( ![cardNumber isPartiallyValid] )
        return;
    
    cardNumberField.text = [cardNumber formattedString];
    
    [self setPlaceholderToCardType];
    
    if ([cardNumber isValid]) {
        [self textFieldIsValid:cardNumberField];
        [self stateMeta];
        
    } else if ([cardNumber isValidLength] && ![cardNumber isValidLuhn]) {
        [self textFieldIsInvalid:cardNumberField withErrors:YES];
        
    } else if (![cardNumber isValidLength]) {
        [self textFieldIsInvalid:cardNumberField withErrors:NO];
    }
}

@end