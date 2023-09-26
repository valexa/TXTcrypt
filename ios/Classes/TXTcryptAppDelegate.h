//
//  TXTcryptAppDelegate.h
//  TXTcrypt
//
//  Created by Vlad Alexa on 6/7/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TXTcryptViewController.h"
#import "UserPrompts.h"

@interface TXTcryptAppDelegate : NSObject <UIApplicationDelegate> {
	
	UIWindow *window;
	TXTcryptViewController *controller;
	NSUserDefaults *defaults;
    UserPrompts *promts;
	
}

@end

