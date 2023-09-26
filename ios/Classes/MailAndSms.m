//
//  MailAndSms.m
//  TXTcrypt
//
//  Created by Vlad Alexa on 6/29/10.
//  Copyright 2010 NextDesign. All rights reserved.
//

#import "MailAndSms.h"


@implementation MailAndSms

@synthesize delegate;

- (id) initWithDelegate:(id<MailAndSmsDelegate>)theDelegate
{
    self = [super init];    
	if (self) {				
		self.delegate = theDelegate;		
	}
	return self;
}

- (void)dealloc {
    [super dealloc];
}


- (void)sendMail:(NSString*)body{
	Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));	
	if (mailClass != nil){	
		if ([mailClass canSendMail]){			
			MFMailComposeViewController *controller = [[MFMailComposeViewController alloc] init];		
			controller.mailComposeDelegate = self;
			[controller setToRecipients:nil];
			[controller setSubject:@""];
			[controller setMessageBody:body isHTML:NO];	
			if ( (self.delegate != nil) && [self.delegate respondsToSelector:@selector(presentModalViewController:animated:)] ) {					
				[self.delegate presentModalViewController:controller animated:YES];					
			}				
			[controller release];				
		}else {
			NSLog(@"Device can not send mail");			
		}		
	}else {	
		NSLog(@"Using workaround to send mail");		
		NSString *email = [NSString stringWithFormat:@"mailto:?subject=&body=%@",body];
		email = [email stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];		
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:email]];	
	}	
}

- (void)sendSms:(NSString*)body{
	Class smsClass = (NSClassFromString(@"MFMessageComposeViewController"));	
	if (smsClass != nil){	
		if ([smsClass canSendText]){			
			MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];		
			controller.messageComposeDelegate = self;
			[controller setBody:body];	
			if ( (self.delegate != nil) && [self.delegate respondsToSelector:@selector(presentModalViewController:animated:)] ) {					
				[self.delegate presentModalViewController:controller animated:YES];					
			}				
			[controller release];				
		}else {
			NSLog(@"Device can not send sms");			
		}		
	}else {	
		NSLog(@"Using workaround to send sms");		
		NSString *sms = [NSString stringWithFormat:@"sms:?body=%@",body];
		sms = [sms stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];		
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:sms]];	
	}		
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
	switch (result)
	{
		case MessageComposeResultCancelled:
			NSLog(@"Sms result: canceled");
			break;
		case MessageComposeResultSent:
			NSLog(@"Sms result: sent");
			break;
		case MessageComposeResultFailed:
			NSLog(@"Sms result: failed");
			break;
		default:
			NSLog(@"Sms result: not sent");
			break;
	}
	if ( (self.delegate != nil) && [self.delegate respondsToSelector:@selector(dismissModalViewControllerAnimated:)] ) {	
		[self.delegate dismissModalViewControllerAnimated:YES];		
	}
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error 
{	
	switch (result)
	{
		case MFMailComposeResultCancelled:
			NSLog(@"Mail result: canceled");
			break;
		case MFMailComposeResultSaved:
			NSLog(@"Mail result: saved");
			break;
		case MFMailComposeResultSent:
			NSLog(@"Mail result: sent");
			break;
		case MFMailComposeResultFailed:
			NSLog(@"Mail result: failed");
			break;
		default:
			NSLog(@"Mail result: not sent");
			break;
	}
	if ( (self.delegate != nil) && [self.delegate respondsToSelector:@selector(dismissModalViewControllerAnimated:)] ) {	
		[self.delegate dismissModalViewControllerAnimated:YES];		
	}	
}

@end
