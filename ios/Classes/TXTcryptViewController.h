//
//  TXTcryptViewController.h
//  TXTcrypt
//
//  Created by Vlad Alexa on 4/6/10.
//  Copyright 2010 NextDesign. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <iAd/iAd.h>

#import "TXTcryptor.h"
#import "UserPrompts.h"
#import "PaymentObserver.h"
#import "MailAndSms.h"

@interface TXTcryptViewController : UIViewController <UITextFieldDelegate,UITextViewDelegate,UserPromptsDelegate,PaymentObserverDelegate,MailAndSmsDelegate,ADBannerViewDelegate> {

	NSUserDefaults *defaults;	
	MailAndSms *mailAndSms;
	TXTcryptor *cryptor;
	UIView *textView;
	UITextView  *txtView;	
	UILabel *txtlbl;	
	UIView *passwView;
	UITextField *passView;
	UILabel *passlbl;
	UIProgressView *progressView;
	UIButton *cryptButton;
	UIButton *decryptButton;	
	UIButton *copyButton;
	UIButton *pasteButton;
	UIButton *infoButton;
	UIButton *mailButton;
	UIButton *smsButton;	
	UIButton *tweetButton;	    
	
	PaymentObserver *paymentObserver;	
	ADBannerView *adBanner;	
	UIButton *adButton;	
	UIAlertView *passConfirmation;

    CFAbsoluteTime lastCryptTime;
}

@property (nonatomic, retain) UILabel *txtlbl;
@property (nonatomic, retain) UITextField *passView;
@property (nonatomic, retain) UITextView  *txtView;

- (void)syncLayout;
- (void)copyButtonPressed;
- (void)pasteButtonPressed;
- (void)cryptButtonPressed;
- (void)decryptButtonPressed;
- (void)infoButtonPressed;

- (void)mailButtonPressed;
- (void)smsButtonPressed;

-(void) resizeBanner;
- (void) adsButtonPressed;
- (void) removedAdsPurchased;

@end
