//
//  PKPaymentField.h
//  PKPayment Example
//
//  Created by Alex MacCaw on 1/22/13.
//  Copyright (c) 2013 Stripe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PKCard.h"
#import "PKCardNumber.h"
#import "PKCardExpiry.h"
#import "PKCardCVC.h"
#import "PKAddressZip.h"
#import "PKUSAddressZip.h"
#import "PKTextField.h"

@class PKView;

@protocol PKViewDelegate <NSObject>
@optional
- (void) paymentView:(PKView*)paymentView withCard:(PKCard*)card isValid:(BOOL)valid;
@end

@interface PKView : UIView <UITextFieldDelegate>

- (BOOL)isValid;

@property (nonatomic, readonly) PKCardNumber* cardNumber;
@property (nonatomic, readonly) PKCardExpiry* cardExpiry;
@property (nonatomic, readonly) PKCardCVC* cardCVC;
@property (nonatomic, readonly) PKAddressZip* addressZip;

@property IBOutlet UIView* innerView;
@property IBOutlet UIView* clipView;
@property IBOutlet PKTextField* cardNumberField;
@property IBOutlet PKTextField* cardExpiryField;
@property IBOutlet PKTextField* cardCVCField;
@property IBOutlet PKTextField* addressZipField;
@property IBOutlet UIImageView* placeholderView;
@property IBOutlet UIButton* transitionArea;

@property (weak) id <PKViewDelegate> delegate;
@property (readonly) PKCard* card;
@property (setter = setUSAddress:) BOOL usAddress;

// Make the state management methods public
- (void)stateCardNumber;
- (void)stateMeta;
- (void)stateCardCVC;
- (void)stateZip;

// Add public interface method to programmatically set the card number (useful for Card.io and similar such services)
- (void)setCardNumberToNumber:(NSString *)number;

// Add public interface methods to allow updating the font and text colors
- (void)setDefaultFont:(UIFont *)font textColor:(UIColor *)textColor;
- (void)setDefaultFont:(UIFont *)font textColor:(UIColor *)textColor errorTextColor:(UIColor *)errorTextColor;
- (void)setPlaceholderFont:(UIFont *)font placeholderTextColor:(UIColor *)textColor;

@end
