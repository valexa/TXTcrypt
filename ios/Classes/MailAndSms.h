//
//  MailAndSms.h
//  TXTcrypt
//
//  Created by Vlad Alexa on 6/29/10.
//  Copyright 2010 NextDesign. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MessageUI/MessageUI.h>

@protocol MailAndSmsDelegate;

@interface MailAndSms : NSObject <MFMailComposeViewControllerDelegate,MFMessageComposeViewControllerDelegate>{
	id<MailAndSmsDelegate> delegate;
}

@property (nonatomic, assign) id<MailAndSmsDelegate> delegate;

- (id) initWithDelegate:(id<MailAndSmsDelegate>)theDelegate;

- (void)sendMail:(NSString*)body;
- (void)sendSms:(NSString*)body;

@end

@protocol MailAndSmsDelegate<NSObject>

@required
- (void)presentModalViewController:(UIViewController *)modalViewController animated:(BOOL)animated;
- (void)dismissModalViewControllerAnimated:(BOOL)animated;

@end;


