//
//  TXTcryptViewController.m
//  TXTcrypt
//
//  Created by Vlad Alexa on 4/6/10.
//  Copyright 2010 NextDesign. All rights reserved.
//

#import "TXTcryptViewController.h"


@implementation TXTcryptViewController

@synthesize passView,txtView,txtlbl;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.    
	
	cryptor = [[TXTcryptor alloc] init];
	
	mailAndSms = [[MailAndSms alloc] initWithDelegate:self];	
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pasteboardChangedNotification:) name:UIPasteboardChangedNotification object:[UIPasteboard generalPasteboard]]; 
	
	self.view.backgroundColor = [UIColor whiteColor];
		
	
	txtView = [[UITextView alloc] initWithFrame: CGRectMake(30, 40, 260, 160)];	
	txtView.keyboardAppearance = UIKeyboardAppearanceAlert;
	txtView.autocorrectionType = UITextAutocorrectionTypeNo;	
    txtView.font = [UIFont systemFontOfSize:16];
	txtView.backgroundColor = [UIColor clearColor];
	txtView.textColor = [UIColor darkGrayColor];
	txtView.text = @"enter your text here";	
	txtView.delegate = self;	
    [txtView setEditable:YES];
    [self.view addSubview:txtView];	
    
	
	passView = [[UITextField alloc] initWithFrame:CGRectMake(30, 210, 260, 24)];
	passView.keyboardAppearance = UIKeyboardAppearanceAlert;	
	passView.secureTextEntry = YES;
	passView.textColor = [UIColor darkGrayColor];
	passView.borderStyle = UITextBorderStyleNone;
	passView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.0];
	passView.clearButtonMode = UITextFieldViewModeWhileEditing;
	passView.autocorrectionType = UITextAutocorrectionTypeNo;	
	passView.keyboardType = UIKeyboardTypeASCIICapable;	
	passView.returnKeyType = UIReturnKeyDone;
	passView.delegate = self;
	passView.placeholder = @"enter password for the text here";	
	[self.view addSubview:passView];
	
	//add buttons
	cryptButton = [UIButton buttonWithType:UIButtonTypeSystem];
	[cryptButton setTitle:@"Encrypt" forState:UIControlStateNormal];
	[cryptButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	cryptButton.enabled = NO;		
	[cryptButton addTarget:self action:@selector(cryptButtonPressed) forControlEvents:UIControlEventTouchUpInside];	
	//cryptButton.frame = CGRectMake(45, 320, 100, 39);	
	[self.view addSubview:cryptButton];		
	
	decryptButton = [UIButton buttonWithType:UIButtonTypeSystem];
	[decryptButton setTitle:@"Decrypt" forState:UIControlStateNormal];
	[decryptButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	decryptButton.enabled = NO;		
	[decryptButton addTarget:self action:@selector(decryptButtonPressed) forControlEvents:UIControlEventTouchUpInside];	
	//decryptButton.frame = CGRectMake(180, 320, 100, 39);	
	[self.view addSubview:decryptButton];			
	
	//add txt counter
	txtlbl = [[UILabel alloc] initWithFrame:CGRectMake(170, 24, 96, 16)];
	txtlbl.textColor = [UIColor grayColor];
	txtlbl.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.0];
    txtlbl.font = [UIFont systemFontOfSize:12];	
	[txtlbl setText:@"(0 characters)"]; 
	[txtlbl setTextAlignment:NSTextAlignmentCenter];
	[self.view addSubview:txtlbl];	
	
	//add progress
    progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(30, 234, 260, 10)];	
	progressView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.0];
	//progressView.progressViewStyle =  UIProgressViewStyleBar;
    [self.view addSubview:progressView];	
	
	//add pass counter
	passlbl = [[UILabel alloc] initWithFrame:CGRectMake(240, 250, 50, 16)];
	passlbl.textColor = [UIColor grayColor];
	passlbl.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.0];
	passlbl.font = [UIFont systemFontOfSize:12];	
	[passlbl setText:@"  0 bit"]; 	
	[self.view addSubview:passlbl];
	
	copyButton = [UIButton buttonWithType:UIButtonTypeSystem];
	[copyButton setTitle:@"Copy" forState:UIControlStateNormal & UIControlStateDisabled];

	copyButton.enabled = NO;		
	[copyButton addTarget:self action:@selector(copyButtonPressed) forControlEvents:UIControlEventTouchUpInside];	
	//copyButton.frame = CGRectMake(45, 386, 100, 39);
    copyButton.titleLabel.font = [UIFont boldSystemFontOfSize:16];
	[self.view addSubview:copyButton];		
	
	pasteButton = [UIButton buttonWithType:UIButtonTypeSystem];
	[pasteButton setTitle:@"Paste" forState:UIControlStateNormal & UIControlStateDisabled];

	pasteButton.enabled = NO;		
	[pasteButton addTarget:self action:@selector(pasteButtonPressed) forControlEvents:UIControlEventTouchUpInside];	
	//pasteButton.frame = CGRectMake(180, 386, 100, 39);	
    pasteButton.titleLabel.font = [UIFont boldSystemFontOfSize:16];
	[self.view addSubview:pasteButton];				
	
	//add website button
	UIImage *infoImage = [UIImage imageNamed:@"info.png"];
	infoButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[infoButton setImage:infoImage forState:UIControlStateNormal];
	[infoButton addTarget:self action:@selector(infoButtonPressed) forControlEvents:UIControlEventTouchUpInside];	
	//infoButton.frame = CGRectMake(130, 23, 20, 20);
	infoButton.alpha = 0.4;
	[self.view addSubview:infoButton];
	
	//add sms button	
	UIImage *smsImage = [UIImage imageNamed:@"sms.png"];	
	smsButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[smsButton setImage:smsImage forState:UIControlStateNormal];		
	[smsButton addTarget:self action:@selector(smsButtonPressed) forControlEvents:UIControlEventTouchUpInside];	
	//smsButton.frame = CGRectMake(135, 23, 35, 25);
	smsButton.alpha = 0.7;
	[smsButton setEnabled:NO];	
	[self.view addSubview:smsButton];	

	//add mail button	
	UIImage *mailImage = [UIImage imageNamed:@"mail.png"];	
	mailButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[mailButton setImage:mailImage forState:UIControlStateNormal];		
	[mailButton addTarget:self action:@selector(mailButtonPressed) forControlEvents:UIControlEventTouchUpInside];	
	//mailButton.frame = CGRectMake(165, 23, 35, 25);
	mailButton.alpha = 0.7;
	[mailButton setEnabled:NO];			
	[self.view addSubview:mailButton];	
	
	//hide sms button on ipad unless iOS5+       
    if ([[[UIDevice currentDevice] systemVersion] compare:@"5.0" options:NSNumericSearch] == NSOrderedAscending){
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {           
            [smsButton setHidden:YES];
        }	    
    }        

	defaults = [NSUserDefaults standardUserDefaults];	
	
	//iAd and IAP code for when removedAds is the only purchase 
	if ([defaults boolForKey:@"removedAds"] != YES) {
		//add iad frame	
		adBanner = [[ADBannerView alloc] initWithFrame:CGRectMake(0,-100,320, 50)];				
		adBanner.delegate = self;
		[adBanner setHidden:YES];		
		[self.view addSubview:adBanner];	
		
		//add remove ads button
		adButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[adButton addTarget:self action:@selector(adsButtonPressed) forControlEvents:UIControlEventTouchUpInside];	
		[adButton setImage:[UIImage imageNamed:@"iad_minus.png"] forState:UIControlStateNormal];
		[adButton setHidden:YES];		
		[self.view addSubview:adButton];
		
		//enable purchases
		paymentObserver = [[PaymentObserver alloc] initWithDelegate:self];
        [paymentObserver requestProductData:@"com.vladalexa.TXTcrypt.removeads"];        
		[[SKPaymentQueue defaultQueue] addTransactionObserver:paymentObserver];		
		if ([[defaults objectForKey:@"runCount"] intValue] == 2 && ![defaults boolForKey:@"removedAds"]) {
			//on second run check if not bought allready
			//[[SKPaymentQueue defaultQueue] restoreCompletedTransactions];		
		}	
	}else{		
		//assume the plist was not hacked to add removedAds		
		NSLog(@"removedAds bought, nothing to buy and no ad to display");		
	}
			
}

- (void)pasteboardChangedNotification:(NSNotification*)notification {
	//paste button
	UIPasteboard *gpBoard = [UIPasteboard generalPasteboard];
	if ([gpBoard containsPasteboardTypes:[NSArray arrayWithObject:(NSString *)kUTTypeText]]) {
        [pasteButton setEnabled:YES];
    }else {
        [pasteButton setEnabled:NO];        
    }
}

-(void)viewWillAppear:(BOOL)animated
{
	//paste button
	UIPasteboard *gpBoard = [UIPasteboard generalPasteboard];
	if ([gpBoard containsPasteboardTypes:[NSArray arrayWithObject:(NSString *)kUTTypeText]]) {
        [pasteButton setEnabled:YES];
    }else {
        [pasteButton setEnabled:NO];        
    }
	//sync layout
	[self syncLayout];		
	//put the banner, the minus and table in the right places
	[self resizeBanner];
    [super viewWillAppear:animated];
}

- (void)dealloc {
	[mailAndSms release];
	[paymentObserver release];	
	[adButton release];
	[adBanner release];		
    [super dealloc];
}

- (void)syncLayout{

	float width = self.view.bounds.size.width;
	float height = self.view.bounds.size.height;
    float x = (width-200)/3;
    float y = ((height/3)-15)/3;
	
	txtlbl.frame = CGRectMake(width-121, 25, 96, 16);
	textView.frame = CGRectMake(20, 20, width-40, height/2.5);		
	txtView.frame = CGRectMake(24, 39, width-46, height/2.5-22);	
	passwView.frame = CGRectMake(20, (height/2.5)+26, width-40, 63);	
	passView.frame = CGRectMake(25, (height/2.5)+30, width-50, 24);	
    progressView.frame = CGRectMake(22, (height/2.5)+56, width-44, 10);
	passlbl.frame = CGRectMake(width-65, (height/2.5)+70 , 100, 16);
	infoButton.frame = CGRectMake(width/2-40, 23, 20, 20);
	smsButton.frame = CGRectMake(width/2-10, 23, 20, 20);
	mailButton.frame = CGRectMake(width/2+20, 23, 20, 20);
	
	UIInterfaceOrientation fromInterfaceOrientation = [self interfaceOrientation];
	
    if ( (fromInterfaceOrientation == UIInterfaceOrientationPortrait || fromInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) && INTERFACE_IS_PHONE){
        cryptButton.frame =		CGRectMake(x*1, height-(y*1.3)-110, 100, 39);
        decryptButton.frame =	CGRectMake((x*2)+100, height-(y*1.3)-110, 100, 39);
        copyButton.frame =		CGRectMake(x*1, height-(y*1.2)-50, 100, 39);
        pasteButton.frame =		CGRectMake((x*2)+100, height-(y*1.2)-50, 100, 39);
    }else {
        float spacing = (width-400)/5;
        cryptButton.frame = CGRectMake(spacing*1, (height/2)+67, 100, 39);
        decryptButton.frame = CGRectMake((spacing*2)+100, (height/2)+67, 100, 39);
        copyButton.frame = CGRectMake((spacing*3)+200, (height/2)+67, 100, 39);
        pasteButton.frame = CGRectMake((spacing*4)+300, (height/2)+67, 100, 39);
    }
    
	[self.view setNeedsDisplay];
	
	//NSLog(@"did sync to width %f height %f",width,height);
	
}

-(void)doConfirmation{
	passConfirmation = [[UIAlertView alloc] initWithTitle:@"Confirm your password" message:@"\n\n" delegate:self cancelButtonTitle:NSLocalizedString(@"OK",nil) otherButtonTitles:nil, nil];
	
	UITextField *passField = [[UITextField alloc] initWithFrame:CGRectMake(12,48,260,28)];
	passField.font = [UIFont systemFontOfSize:16];
	passField.borderStyle = UITextBorderStyleRoundedRect;
	passField.delegate = self;
	passField.autocapitalizationType = UITextAutocapitalizationTypeNone;
	passField.autocorrectionType = UITextAutocorrectionTypeNo;
	[passField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];	
	[passField becomeFirstResponder];
	[passConfirmation addSubview:passField];
	
	[passConfirmation show];
	[passField release];
}


// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    //return (interfaceOrientation == UIInterfaceOrientationPortrait);
	return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    //IOS 6+ to override iphone default UIInterfaceOrientationMaskAllButUpsideDown
    return UIInterfaceOrientationMaskAll;
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	//Tell user
	//NSLog(@"Got memory warning.");		
	//UIAlertView *sendAlert = [[UIAlertView alloc] initWithTitle:@"Low Memory" message:@"The system is experiencing memory shortages, you should consider quitting this application to free resources." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil ,nil];                                              				                                             		
	//[sendAlert show];
	//[sendAlert release];	
	
	// Release any cached data, images, etc that aren't in use.
}


- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {	
    if ([theTextField isFirstResponder]) {
        //take focus away from the text field so that the keyboard is dismissed.        
        [theTextField resignFirstResponder];	     
        //password confirmation
        if (theTextField == passView && [defaults boolForKey:@"confirmPass"] == YES && [passView.text length] > 0) {
            [self doConfirmation];
        }        
    }
	
	//not interested in the placeholder text
	if ([txtView.text isEqualToString:@"enter your text here"]){
		return NO;		
	}	
	
    return YES;	
}

-(void)textViewDidChange:(UITextView *)aView {
	
	//toggle decrypt/encrypt
	if ([passView.text length] < 1 || [txtView.text length] < 1){
		[cryptButton setEnabled:NO];
		[decryptButton setEnabled:NO];						
	}else if ([passView.text length] > 0 && [txtView.text length] > 0){		
		[cryptButton setEnabled:YES];
		[decryptButton setEnabled:YES];				
	}
	
	//toggle sms and mail
	if ([txtView.text length] < 1){
		[mailButton setEnabled:NO];	
		[smsButton setEnabled:NO];					
	}else if ([txtView.text length] > 0){		
		[mailButton setEnabled:YES];	
		[smsButton setEnabled:YES];			
	}	 
	
	//toggle copy button
	if ([txtView.text length] > 0){	
		[copyButton setEnabled:YES];
	}else{
		[copyButton setEnabled:NO];		
	}	
	
	//update txtlbl
	[txtlbl setText:[NSString stringWithFormat:@"(%lu characters)",(unsigned long)txtView.text.length]];
	
	[self.view setNeedsDisplay];	
}

- (void)textFieldDidEndEditing:(UITextField *)theTextField{
    if (theTextField != passView) {
        return;
    }
	//limit password to enforce Wassenaar Arrangement compliance	
	if (passView.text.length > 8){	
		passView.text = [passView.text substringWithRange:NSMakeRange(0,8)];	
	}		
	//update pass lenght
	NSInteger len = passView.text.length;
	float pro = len * 0.125;
	[progressView setProgress:pro];			
	NSInteger bit = len * 8;
	[passlbl setText:[NSString stringWithFormat:@"  %li bit",(long)bit]];	
}

- (BOOL)textField:(UITextField *)theTextField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{	
	
	if (theTextField == passView) {

		//toggle decrypt/encrypt
		if (range.location == 0 && [string length] == 0){
			[cryptButton setEnabled:NO];
			[decryptButton setEnabled:NO];			
			[self.view setNeedsDisplay];		
		}else if ([string length] != 0 && [txtView.text length] > 0){			
			[cryptButton setEnabled:YES];
			[decryptButton setEnabled:YES];		
			[self.view setNeedsDisplay];		
		}	
		
		//limit password to enforce Wassenaar Arrangement compliance
		if (range.location > 7){		
			return NO;		
		}	
		
		//update pass lenght
		NSInteger len = theTextField.text.length;
		if ([string length] == 0){
			len = len-1;		
		}else{
			len = len+1;		
		}
		float pro = len * 0.125;
		[progressView setProgress:pro];			
		NSInteger bit = len * 8;
		[passlbl setText:[NSString stringWithFormat:@"  %li bit",(long)bit]];
		
	}
	
	return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)aView {
	//for real there is no plaeholder for textview
	if ([aView.text isEqualToString:@"enter your text here"]){
		aView.text = @"";	
	}	
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    // Dismiss the keyboard when the view outside the text field is touched.
    if ([txtView isFirstResponder]) {
        [txtView resignFirstResponder];	        
    }

	[self textFieldShouldReturn:passView];	
}

#pragma mark actions

- (void)cryptButtonPressed{		
    if (lastCryptTime > 1) {
        UIAlertView *sendAlert = [[UIAlertView alloc] initWithTitle:@"Prepare to wait" message:@"The encrypting proccess will no longer be instant due to the lenght of the text." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil ,nil];                                              				                                             		
        [sendAlert show];
        [sendAlert release];        
    }
	if (lastCryptTime > 0.1){
		[txtlbl setTextColor:[UIColor colorWithRed:0.6 green:0.4 blue:0.4 alpha:1.0]];			
	}else{
		[txtlbl setTextColor:[UIColor grayColor]];					
	}    
    CFTimeInterval startTime = CFAbsoluteTimeGetCurrent();     
	//NSLog([NSString stringWithFormat:@"%@",password]);
	NSString *result = [cryptor encrypt:txtView.text password:passView.text];
	txtView.text = result;	
	[self textViewDidChange:txtView];
	[self.view setNeedsDisplay];
	lastCryptTime = CFAbsoluteTimeGetCurrent()-startTime;
    //NSLog(@"Encrypted %i characters in %f",[txtView.text length],lastCryptTime);      
} 

- (void)decryptButtonPressed{
	if (lastCryptTime > 0.1){
		[txtlbl setTextColor:[UIColor colorWithRed:0.6 green:0.4 blue:0.4 alpha:1.0]];			
	}else{
		[txtlbl setTextColor:[UIColor grayColor]];					
	}    
    CFTimeInterval startTime = CFAbsoluteTimeGetCurrent();     
	//remove newlines
	txtView.text = [txtView.text stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];		
	//NSLog([NSString stringWithFormat:@"%@",result]);
	NSString *result = [cryptor decrypt:txtView.text password:passView.text];
	lastCryptTime = CFAbsoluteTimeGetCurrent()-startTime;    
	if ([result length] > 0) {
		txtView.text = result;
		[self textViewDidChange:txtView];
		[self.view setNeedsDisplay];			
	}else {
		UIAlertView *sendAlert = [[UIAlertView alloc] initWithTitle:@"Decryption with the given password did not yeld any results, make sure you have the right password/text combination." message:result delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil ,nil];
		[sendAlert show];
		[sendAlert release];				
	}
}

- (void)copyButtonPressed{
	UIPasteboard *gpBoard = [UIPasteboard generalPasteboard];	
	[gpBoard setValue:txtView.text forPasteboardType:(NSString *)kUTTypeText];	
	[pasteButton setEnabled:YES];				
}	

- (void)pasteButtonPressed{	
	UIPasteboard *gpBoard = [UIPasteboard generalPasteboard];	
	NSString *result = [gpBoard valueForPasteboardType:(NSString *)kUTTypeText];	
	txtView.text = result;
	[self textViewDidChange:txtView];	
	[self.view setNeedsDisplay];	
}

- (void)infoButtonPressed{  
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://vladalexa.com/apps/iphone/txtcrypt/"]];
} 

- (void)mailButtonPressed{
	[mailAndSms sendMail:txtView.text];
}

- (void)smsButtonPressed{
	[mailAndSms sendSms:txtView.text];
}

#pragma mark PaymentObserverDelegate, UserPromptsDelegate and ADBannerViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{  
	if ([alertView.title isEqualToString:@"Confirm your password"]){
		if (buttonIndex == 0 ) {
			UITextField *passField = [[alertView subviews] lastObject];
			if ([passField.text isEqualToString:passView.text]) {
				//NSLog(@"Password confirmed");
			}else {
				//NSLog(@"Wrong password");	
				passView.text = @"";
				UIAlertView *sendAlert = [[UIAlertView alloc] initWithTitle:@"Confirmation failed" message:@"The passwords were not the same, please try again." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil ,nil];                                              				                                             		
				[sendAlert show];
				[sendAlert release];					
			}
			[passConfirmation release];
		}
	}    
	if ([alertView.title isEqualToString:@"Remove ads"]){
		if (buttonIndex == 1) {
            //restore the payment
            [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];		
		}
		if (buttonIndex == 2) {
            //queue the payment
            if ([SKPaymentQueue canMakePayments]) {
                [adButton setEnabled:NO];
                NSArray *products = paymentObserver.products;
                if ([products count] == 1) {
                    SKPayment *payment = [SKPayment paymentWithProduct:[products objectAtIndex:0]];
                    [[SKPaymentQueue defaultQueue] addPayment:payment];	                    
                }else{
                    NSLog(@"Error getting products : %@",products);
                }
            }else {
                UIAlertView *dataAlert = [[UIAlertView alloc] initWithTitle:@"In App Purchases Not Enabled" message:@"The ability to make purchases is disabled in this device's Settings" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil,nil];                                              
                [dataAlert show];
                [dataAlert release];
            }			
		}		
	}	
}

-(void)adsButtonPressed{		
	UIAlertView *sendAlert = [[UIAlertView alloc] initWithTitle:@"Remove ads" message:@"You can chose to either make or restore a purchase if you previously removed the ads from another device." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Restore",@"Buy", nil];                                              				                                             		
	[sendAlert show];
	[sendAlert release];
} 

- (void) removedAdsPurchased{
	[adBanner removeFromSuperview];
	[adButton removeFromSuperview];
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:1];	
	[self resizeBanner];
	[UIView commitAnimations];	
	[self.view setNeedsDisplay];
}

- (void)bannerViewDidLoadAd:(ADBannerView *)banner{
	if ([adBanner isBannerLoaded]) {
		//only show banner if it has something loaded
		[adBanner setHidden:NO];
		[adButton setHidden:NO];		
		[self resizeBanner];		
	}	
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration{
	//resize base items
	[self syncLayout];		
	//resize banner
	[self resizeBanner];			
}

-(void)resizeBanner{
	float width = self.view.bounds.size.width;
	float height = self.view.bounds.size.height;		
	if ([defaults boolForKey:@"removedAds"] == YES || [adBanner isHidden] == YES || adBanner == nil) {
		//put interface in banner free mode							
	}else {	
		UIInterfaceOrientation orientation = [self interfaceOrientation];	
		if (orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight)	{						
            adBanner.currentContentSizeIdentifier = ADBannerContentSizeIdentifierLandscape;
		}		
		if (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown)	{					
            adBanner.currentContentSizeIdentifier = ADBannerContentSizeIdentifierPortrait;		
		}
		adBanner.frame = CGRectMake(0,height-adBanner.bounds.size.height,width,adBanner.bounds.size.height);		
		adButton.frame = CGRectMake(0, height-22-adBanner.frame.size.height, 24,22);
	}	
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error{
	NSLog(@"didFailToReceiveAdWithError %@",[error localizedDescription]);
}

@end
